---
title: "v1.0.0: The Async BLE Concurrency Engine (Windows version)"
date: "2026-04-28"
publisher: "Haoqi Sheng"
summary: "An initial production release detailing the asynchronous BLE tunnel architecture, the dual-protocol decoding engine, and fault-tolerant multi-sensor data acquisition."
latest: true
---

# Release Notes — v1.0.0
## Overview

`dsd_s1_ble_tunnel` is the initial production release of the **IF-S1-S2 provider** for the DSD-S1 project. It establishes the full communication pipeline between up to six WitMotion BLE inertial measurement units and the S2 data layer, delivering timestamped, normalised `SensorSample` objects through a pair of polling methods — `s1.sensor.read()` and `s1.sensor.status()` — as defined in sections 2.1.3 and 2.1.4 of the interface specification.

---

## Technical Architecture

### Concurrent Worker Model (`asyncio` + `Bleak`)

Each configured sensor is assigned a dedicated `SensorWorker` instance that owns its entire BLE lifecycle: scanning, connecting, subscribing to GATT notifications, detecting disconnections, and reconnecting automatically after a configurable delay (`reconnect_delay_sec`, default 2 s). All workers run as independent `asyncio` tasks under a single event loop managed by `S1SensorService`, so no single sensor's latency or fault can block the others.

```
S1SensorService
 ├── asyncio.create_task → SensorWorker[sensor-1]
 ├── asyncio.create_task → SensorWorker[sensor-2]
 │       ...
 └── asyncio.create_task → SensorWorker[sensor-6]
```

BLE callbacks (`on_notify`, `on_disconnect`) are bridged back to the event loop via `loop.call_soon_threadsafe`, keeping Bleak's internal thread safely decoupled from application state.

The `_guard_worker` coroutine in `S1SensorService` wraps every worker: unhandled exceptions are logged and the worker is restarted, ensuring a single hardware error never takes down the service.

### Dual-Protocol Incremental Decoding Engine (`WitMotionParser`)

`WitMotionParser` is a stateful, streaming decoder that supports two wire formats simultaneously with a single `feed()` call:

| Protocol | Identifier | Packet length | Description |
|---|---|---|---|
| BLE IMU packet | `0x55 0x61` | 20 bytes | All-in-one: acc + gyro + angle in one notification |
| Legacy serial frames | `0x55 0x51–0x53` | 11 bytes each | Three separate frames assembled into one sample |

The parser maintains a rolling receive buffer (`_rx`, max 4 096 bytes) and processes it in a loop: it searches for the `0x55` start byte, classifies the frame type from the following byte, validates the checksum for serial frames, decodes the payload, and advances the buffer pointer. Bytes that cannot be attributed to a valid frame are counted as corruption and skipped, allowing the next valid header to be decoded without loss.

---

## Key Data Structures

### `SensorSample` and `ThreadSafeSampleBuffer`

`SensorSample` is a fully immutable, slot-allocated dataclass carrying one complete IMU reading per the IF-S1-S2 spec. Samples are queued in a `ThreadSafeSampleBuffer` — a thin, lock-protected `deque` — so that BLE callback threads can push data concurrently while the S2 layer polls via `read()` without data races.

```python
@dataclass(slots=True, frozen=True)
class SensorSample:
    """IF-S1-S2 payload item defined by section 2.1.3 of the interface spec."""

    timestamp: int
    deviceId: str
    deviceName: str
    accX: float
    accY: float
    accZ: float
    gyroX: float
    gyroY: float
    gyroZ: float
    roll: float
    pitch: float
    yaw: float


class ThreadSafeSampleBuffer:
    """Drainable thread-safe queue used by IF-S1-S2 read()."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._items: deque[SensorSample] = deque()

    def push(self, sample: SensorSample) -> None:
        with self._lock:
            self._items.append(sample)

    def drain(self) -> list[SensorSample]:
        with self._lock:
            drained = list(self._items)
            self._items.clear()
            return drained
```

`drain()` is atomic: a single lock acquisition snapshots and clears the queue, so no sample can be returned twice and no sample produced during the drain is lost.

### Error Priority Table

When multiple sensors report different error conditions simultaneously, `S1SensorService.status()` surfaces the single most actionable error to S2 using a priority map. Disconnection always takes precedence over a transient timeout, which in turn outranks a data-corruption notice:

```python
ERROR_PRIORITY = {
    "sensor_disconnected": 0,   # highest priority — immediate action required
    "timeout":             1,   # sensor connected but silent
    "data_corruption":     2,   # bad bytes received; self-healing in progress
}
```

The winning error is selected via:

```python
error = min(errors, key=lambda err: ERROR_PRIORITY.get(err, 99)) if errors else None
```

Unknown error strings fall back to priority 99, ensuring forward compatibility without masking defined errors.

### Raw-to-Physical-Unit Normalisation

Raw 16-bit signed integers from the sensor are scaled to engineering units using the WitMotion hardware ranges. The same scaling is applied consistently in both the BLE single-packet path and the legacy serial-frame path:

```python
# Accelerometer: ±16 g full-scale  →  result in g
accX = values[0] / 32768.0 * 16.0

# Gyroscope: ±2000 °/s full-scale  →  result in °/s
gyroX = values[3] / 32768.0 * 2000.0

# Euler angles: ±180 ° full-scale  →  result in degrees
roll  = values[6] / 32768.0 * 180.0
```

---

## Stability and Fault Tolerance

### Auto-Reconnect

`SensorWorker.run()` loops indefinitely. After any BLE error or unexpected disconnection, the worker waits `reconnect_delay_sec` and retries a full scan-connect-subscribe cycle. `SensorState` transitions are managed with a `threading.Lock` throughout, so status snapshots seen by the S2 layer are always internally consistent.

### No-Data Timeout

A monotonic clock timestamp is updated on every incoming notification. `_check_timeout()` is called every 200 ms; if no packet has arrived for `no_data_timeout_sec` (default 2 s) while the sensor is logically connected, the state transitions to `timeout`. Timeout is cleared automatically by `mark_producing()` as soon as the next valid sample arrives.

### Finiteness Guard

Every decoded `SensorSample` passes through `_sample_is_finite()` before being enqueued. Samples containing `NaN` or `±Inf` — which can arise from divide-by-zero in edge hardware states — are silently dropped and the sensor is flagged with `data_corruption` rather than propagating invalid floating-point values to S2.

```python
@staticmethod
def _sample_is_finite(sample: SensorSample) -> bool:
    return all(
        math.isfinite(v)
        for v in [
            sample.accX, sample.accY, sample.accZ,
            sample.gyroX, sample.gyroY, sample.gyroZ,
            sample.roll, sample.pitch, sample.yaw,
        ]
    )
```

### RX Buffer Overflow Protection

If the internal receive buffer exceeds 4 096 bytes without a parseable frame (e.g. a prolonged stream of malformed data), `_trim_rx_if_needed()` seeks the most recent `0x55` header and retains only the tail of the buffer, preventing unbounded memory growth.

---

## Unit Test Coverage

The accompanying `test_dsd_s1_ble_tunnel.py` provides coverage across both protocol paths and the service layer:

| Test | Description |
|---|---|
| `test_feed_decodes_ble_imu_packet` | Verifies correct normalisation of all 9 fields from a `0x55 0x61` BLE packet |
| `test_feed_decodes_complete_sample` | Verifies assembly of acc + gyro + angle across three legacy serial frames |
| `test_feed_reports_corruption_and_recovers` | Confirms corruption byte count is correct and valid frames following garbage are still decoded |
| `test_read_drains_and_sorts_samples` | Confirms `read()` returns samples sorted by `(timestamp, deviceId)` and clears the buffer |
| `test_status_prioritizes_disconnect_over_other_errors` | Confirms `sensor_disconnected` beats `data_corruption` in multi-sensor error aggregation |
| `test_status_requires_all_sensors_connected_and_producing` | Confirms `connected=False` when any sensor has not yet emitted a valid sample |

---

## Configuration Reference

| Parameter | Default | Description |
|---|---|---|
| `scan_timeout_sec` | `8.0` | BLE scan timeout per reconnect attempt (seconds) |
| `reconnect_delay_sec` | `2.0` | Delay between reconnect attempts (seconds) |
| `no_data_timeout_sec` | `2.0` | Silence threshold before `timeout` is raised (seconds) |

Sensors may be provided via repeated `--sensor <address>,<uuid>` CLI flags or a JSON file (`--sensors-json`). Duplicate entries (matched case-insensitively) are deduplicated automatically.

---

## Known Limitations

- The BLE IMU packet path (`0x55 0x61`) does not include a hardware checksum; structural validity relies on the fixed 20-byte length and magic bytes alone.
- The module targets Python 3.10+ (`slots=True` on dataclasses, `match`-free but uses `from __future__ import annotations`).
- `asyncio.run()` is used in `__main__`; embedding this module inside an existing event loop requires calling `S1SensorService.start()` / `wait_forever()` directly.
