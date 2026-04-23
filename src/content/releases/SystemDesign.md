---
title: "System Design 1.2: Data Tunnel Architecture"
date: "2026-04-16"
publisher: "Haoqi Sheng"
summary: "We have finalized the DSD-S1 technical architecture, focusing on a high-throughput 'Data Tunnel' with asynchronous buffering for raw IMU data acquisition."
---

# System Design 1.2

**Project Team:** Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, Silva André

## Revision History

| Date | Description |
| :--- | :--- |
| April 9 | Refined against SRS; integrated use cases and initial IF1 contract (1.0) |
| April 12 | Integrated functional mapping, data flow steps, and specific technology selections (1.1) |
| April 16 | **Architecture Simplified:** Shifted focus to a "Data Tunnel" model for raw byte stream acquisition and persistent storage, removing real-time parsing logic (1.2) |


## 1. Introduction

This document describes the system architecture for the wireless joint motion capture system. Based on recent project scope adjustments, the current primary objective is to establish a high-efficiency **"Data Tunnel"**.

In this phase, the system will **not** perform real-time semantic parsing of the sensor bits. Instead, it acts as a universal data acquisition platform responsible for:

- Establishing a stable Bluetooth connection to the IMU sensor
- Receiving the raw byte stream transparently
- Writing it directly to persistent storage for future offline analysis

This document is intended to be read alongside the SRS, which defines use cases and the IF1 Interface Contract as the Sprint 1 deliverable.

---

## 2. Functional Architecture

The system is simplified into three core modules reflecting the **Connect–Acquire–Store** objective.

### 2.1 Sensor Layer (Acquisition)

- **Responsibility:** Generate raw motion data via IMU sensors.
- **Interaction:** Broadcasts availability via Bluetooth and waits for the host to establish the data tunnel.
- **Hardware:** 6 IMU sensors.

### 2.2 Data Relay Layer (Intermediate / IF1)

- **Responsibility:** Manage the BLE connection lifecycle (scan, connect, disconnect, auto-reconnect); act as a transparent proxy receiving the pure byte stream; implement an in-memory queue/buffer to prevent packet loss caused by downstream disk I/O latency.
- **IF1 Interface Contract:** Defined purely as a **Streaming Interface**. The system is agnostic to specific bit meanings within the packets; it only guarantees the sequential integrity and lossless transfer of the received bytes.

### 2.3 Storage Layer (Back-end)

- **Responsibility:** Stream received bytes asynchronously into local files or a database; record session metadata (start timestamp, duration, sensor MAC address) for each recording session.

---

## 3. Core Data Flow

The end-to-end data pipeline operates strictly sequentially:

```
 ┌──────────────┐   BLE (raw bytes)   ┌──────────────────┐   async flush   ┌─────────────┐
 │  S1  Sensor  │ ──────────────────► │  Data Relay      │ ──────────────► │  Storage    │
 │  (ESP32/IMU) │                     │  (Memory Buffer) │                 │  (.bin / DB)│
 └──────────────┘                     └──────────────────┘                 └──────┬──────┘
       ▲                                                                          │
       │  BLE scan & connect                                                      │ 
  ┌────┴─────────┐                                                         ┌──────▼──────┐
  │  Host App    │                                                         │     S2      │
  │  (M1 / User) │                                                         │  Data Acq.  │
  └──────────────┘                                                         └─────────────┘
```

1. **Link Establishment:** The host program handshakes with the sensor via BLE.
2. **Streaming:** The sensor continuously pushes pure raw bytes over the wireless connection.
3. **Buffering & Relay:** The host receives the byte stream and immediately pushes it into a memory buffer.
4. **Disk I/O:** An asynchronous background task flushes the buffer to the storage device, ensuring the acquisition thread is never blocked.

---

## 4. Technical Route Selection

| Concern | Selection | Rationale |
| :------ | :-------- | :-------- |
| Hardware | IMU         | Integrated BLE; available with China-based team members |
| Communication | BLE — Serial Pass-through (UART) mode | Low overhead; suitable for continuous byte-stream |
| Host Application | Python (`bleak` + `asyncio`) or Node.js | Strong async/non-blocking event loops for concurrent BLE and I/O |
| Storage Format | Raw binary `.bin` or high-throughput time-series DB | Maximum write speed; no encoding overhead |

---

## 5. Non-Functional Requirements

- **High Throughput Reliability:** The intermediate buffer must be adequately sized to handle 50 Hz+ sampling without overflowing during temporary disk write delays.
- **Concurrency:** The Bluetooth receiving thread and the File I/O writing thread must be strictly decoupled to maintain real-time acquisition performance.
- **Resilience:** The host application must gracefully handle unexpected Bluetooth disconnections, securely closing the current file before attempting to reconnect.
