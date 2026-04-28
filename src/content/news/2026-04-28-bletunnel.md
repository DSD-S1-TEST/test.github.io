---
title: "DSD-S1 Now Speaks BLE: Introducing the WitMotion Sensor Tunnel (Windows version)"
date: "2026-04-28"
author: "Haoqi Sheng"
summary: "The v1.0.0 release of dsd_s1_ble_tunnel introduces an asynchronous, self-healing BLE communication layer, connecting up to six WitMotion IMU sensors to the S2 data pipeline without blocking."
latest: true
---

# DSD-S1 Now Speaks BLE: Introducing the WitMotion Sensor Tunnel

We are excited to announce the **v1.0.0 release of `dsd_s1_ble_tunnel`** — the new Bluetooth Low Energy communication layer that connects up to six WitMotion IMU sensors to the DSD-S1 S2 data pipeline. This release marks a significant milestone for the project, delivering a production-ready, self-healing sensor interface that the team has been building toward since the project's inception.

---

## The Problem It Solves

Anyone who has worked with multi-sensor BLE systems knows the challenge: each sensor operates on its own connection lifecycle. Scans time out. Devices drop off and reconnect. Notification callbacks arrive on background threads. Naïvely handling all of this in a single-threaded loop means one slow or misbehaving sensor can stall data collection for every other device on the bus.

`dsd_s1_ble_tunnel` eliminates that bottleneck entirely. Each of the six target sensors gets its own **independent `asyncio` worker task**, powered by the [Bleak](https://github.com/hbldh/bleak) BLE library. Scans, connections, GATT subscriptions, and reconnect cycles all run concurrently within a single event loop — a sensor going silent or disconnecting has zero impact on its neighbours. The S2 layer simply calls `s1.sensor.read()` at its own cadence and always receives a sorted, consistent batch of samples.

---

## Self-Healing in Noisy RF Environments

Real-world BLE deployments are messy. Radio frequency interference, hardware glitches, and protocol edge cases can inject corrupted or partial bytes into the notification stream at any time. A parser that crashes — or worse, silently misaligns its frame boundary — is not acceptable in a safety-oriented motion capture system.

The new `WitMotionParser` was built with this reality in mind. Its core loop is **byte-granular and recovery-first**:

1. It scans the internal receive buffer for the `0x55` frame-start marker.
2. Any bytes that appear *before* a valid header are counted as corruption and discarded immediately — they never stall the parser.
3. For serial frames, a checksum is verified before the payload is accepted. A failed checksum causes the parser to search for the *next* `0x55` within the current frame window rather than blindly advancing by one byte, making recovery faster.
4. Both the modern BLE all-in-one packet format (`0x55 0x61`, 20 bytes) and the legacy three-frame serial protocol (`0x51` / `0x52` / `0x53`, 11 bytes each) are decoded by the same engine — no separate code paths to maintain.

The result: **a stream of corrupted bytes does not stop valid data from flowing through.** The parser reports a non-zero corruption count so the service layer can flag the sensor's health status, but it keeps producing good samples for every valid frame it encounters on either side of the noise. Unit tests confirm this behaviour with explicit corruption-injection scenarios.

---

## Built-In Health Monitoring

The module surfaces a clean `SensorStatus` object (as defined in IF-S1-S2 section 2.1.4) that aggregates the state of all configured sensors into a single answer for S2:

- **`connected: bool`** — `True` only when every sensor is both connected *and* actively producing data. A single silent sensor flips this to `False`.
- **`errorMessage: str | None`** — The highest-priority error across all sensors. Disconnection always wins over a timeout, which wins over a data-corruption notice, so operators always see the most actionable condition first.

Errors self-clear automatically. Once a sensor recovers and produces a valid sample, its `timeout` or `data_corruption` flag is reset without any intervention.

---

## What's Included

- **`dsd_s1_ble_tunnel.py`** — The full IF-S1-S2 provider, ready to drop into your DSD-S1 runtime.
- **`test_dsd_s1_ble_tunnel.py`** — Six unit tests covering both wire protocols, corruption recovery, buffer draining, and multi-sensor status aggregation.
- **CLI entrypoint** — Run the tunnel standalone (`python dsd_s1_ble_tunnel.py --sensor <addr>,<uuid> ...`) for integration testing against physical hardware without requiring the full S2 stack.

---

## Get Started

Full technical details — including architecture diagrams, code snippets, configuration parameters, and the complete test coverage matrix — are available in the **[v1.0.0 Release Notes](https://dsd-s1-test.github.io/DSD-S1.github.io/#/releases)**.

Source code, issue tracking, and contribution guidelines live in the **[DSD-S1 GitHub repository](https://dsd-s1-test.github.io/DSD-S1.github.io/#/news)**.

We encourage all integrators and contributors to pull the latest release, run the test suite, and connect your hardware. If you encounter an edge case or have suggestions for improving the parser's recovery logic, open an issue — this is exactly the kind of feedback that makes the next release stronger.

---

*Built with care by Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, and Silva André.*
