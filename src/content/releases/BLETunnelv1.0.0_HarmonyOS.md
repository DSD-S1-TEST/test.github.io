---
title: "v1.0.0: The Async BLE Concurrency Engine (HarmonyOS version)"
date: "2026-04-29"
publisher: "Mofan Xu"
summary: "A HarmonyOS 4/5 port of the async BLE tunnel, featuring multi-sensor concurrency, dual-protocol decoding, and resilient data acquisition with CSV persistence."
latest: true
---

# Release Notes — v1.0.0 (HarmonyOS)

## Overview

`dsd_s1_ble_tunnel` for HarmonyOS is the initial production release of the **IF-S1-S2 provider** on the HarmonyOS 4/5 application stack. It preserves the full data pipeline between up to six WitMotion BLE IMUs and the S2 data layer, exposing `s1.sensor.read()` and `s1.sensor.status()` semantics through the HarmonyOS BLE API, while continuously persisting data to a public CSV file.

---

## Technical Architecture

### Concurrent Worker Model (HarmonyOS BLE + Timed Loop)

Each configured sensor is managed by a dedicated `SensorWorker`, responsible for scanning, connecting, subscribing to characteristic notifications, detecting disconnections, and reconnecting after a configurable delay (`reconnectDelaySec`, default 2 s). Workers operate independently in the app process, ensuring one sensor’s failure never blocks the others.

```
S1SensorService
 ├── SensorWorker[sensor-1]
 ├── SensorWorker[sensor-2]
 │       ...
 └── SensorWorker[sensor-6]
```

BLE scan and notification callbacks are wired to the state manager via event listeners (`BLEDeviceFound`, `BLECharacteristicChange`), while a timed loop performs timeout checks and status updates.

### Dual-Protocol Incremental Decoding Engine (`WitMotionParser`)

`WitMotionParser` remains a streaming decoder that supports **two wire formats** in a single `feed()` call:

| Protocol | Identifier | Packet length | Description |
|---|---|---|---|
| BLE IMU packet | `0x55 0x61` | 20 bytes | All-in-one: acc + gyro + angle in one notification |
| Legacy serial frames | `0x55 0x51–0x53` | 11 bytes each | Three separate frames assembled into one sample |

A rolling RX buffer (max 4 096 bytes) is scanned for the `0x55` header. Corrupt or unaligned bytes are counted and skipped so that valid frames immediately following noise are still recovered.

---

## Key Data Structures

### `SensorSample` and `ThreadSafeSampleBuffer`

`SensorSample` is an immutable data object carrying one complete IMU reading according to the IF-S1-S2 spec. Samples are pushed into a drainable buffer and emitted to S2 via `read()`, ensuring no duplicates and no lost samples even under concurrent notification bursts.

### Error Priority Table

When multiple sensors report different error states, the service surfaces the most actionable error using a fixed priority map:

```typescript
const ERROR_PRIORITY = {
  sensor_disconnected: 0, // highest priority
  timeout: 1,             // connected but silent
  data_corruption: 2      // malformed bytes; self-healing
};
```

The first error in priority order is reported by `s1.sensor.status()`.

---

## Stability and Fault Tolerance

### Auto-Reconnect

Each worker loops indefinitely. Any BLE error or disconnect triggers a delay (`reconnectDelaySec`) followed by a full rescan and reconnect. This ensures continuous recovery in unstable RF environments.

### No-Data Timeout

A monotonic timestamp is updated on every notification. If the elapsed time exceeds `noDataTimeoutSec` (default 2 s) while connected, the sensor state transitions to `timeout` until new data arrives.

### Data Integrity Guard

Malformed packet bytes are detected and counted as corruption. When corruption is observed, the sensor is flagged `data_corruption` but continues parsing to self-heal as soon as valid frames reappear.

### RX Buffer Overflow Protection

If the RX buffer exceeds 4 096 bytes without yielding a valid frame, the parser trims to the latest possible frame header, preventing memory growth and allowing recovery from prolonged noise.

---

## File Output

All drained samples are appended to a **public CSV file** (default example path shown below). Header management is automatic, and writes append safely in UTF-8.

```
/storage/Users/currentUser/Download/sensor_samples.csv
```

---

## Configuration Reference

| Parameter | Default | Description |
|---|---|---|
| `scanTimeoutSec` | `8.0` | BLE scan timeout per reconnect attempt (seconds) |
| `reconnectDelaySec` | `2.0` | Delay between reconnect attempts (seconds) |
| `noDataTimeoutSec` | `2.0` | Silence threshold before `timeout` is raised (seconds) |

Sensors are defined as `{ deviceAddress, notifyCharUuid }` and may be configured for up to six concurrent devices.

---

## Known Limitations

- BLE IMU packets (`0x55 0x61`) do not include a checksum; validity relies on length and magic bytes only.
- The HarmonyOS BLE stack requires runtime permissions (Bluetooth + Location + Media write).
- Background BLE behavior depends on device power policies and may require whitelisting on certain OEM devices.