---
title: "System Design 1.1"
date: "2026-04-16"
author: "Haoqi Sheng"
summary: "Technical architecture and communication protocols for the DSD-S1 wireless joint motion capture system."
---

# System Design 1.2

**Status:** Under review by all teams.

**Project Team:** Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, Silva André

## Revision History

| Date | Description |
| :--- | :--- |
| April 15 | Refined against SRS; integrated use cases and initial IF1 contract (1.0) |
| April 16 | Integrated functional mapping, data flow steps, and specific technology selections (1.1) |
| April 22 | **Architecture Simplified:** Shifted focus to a "Data Tunnel" model for raw byte stream acquisition and persistent storage, removing real-time parsing logic (1.2) |

## 1. Introduction

This document describes the system architecture for the DSD-S1 wireless joint motion capture system. Based on recent project scope adjustments, the current primary objective is to establish a high-efficiency "Data Tunnel." 

In this phase, the system will not perform real-time semantic parsing of the sensor bits. Instead, it acts as a universal data acquisition platform responsible for establishing a stable Bluetooth connection, receiving the raw byte stream from the sensors, and writing it directly to persistent storage for future offline analysis.

## 2. Functional Architecture

To achieve the "Connect-Acquire-Store" objective, the system is simplified into three core modules:

### 2.1 Sensor Layer (Acquisition)
* **Responsibility:** Generate raw motion data via IMU sensors.
* **Interaction:** Broadcasts availability via Bluetooth and waits for the host to establish the data tunnel.

### 2.2 Data Relay Layer (Intermediate / IF1)
* **Responsibility:** * Manage the Bluetooth Low Energy (BLE) connection lifecycle (scan, connect, disconnect, auto-reconnect).
  * Act as a transparent proxy, receiving the pure byte stream.
  * **Traffic Buffering:** Implement an in-memory queue/buffer to prevent Bluetooth packet loss caused by downstream disk I/O latency.
* **IF1 Interface Contract:** In this version, IF1 is defined purely as a **Streaming Interface**. The system is agnostic to the specific bit meanings (e.g., headers, payload structures) within the packets; it only guarantees the sequential integrity and lossless transfer of the bytes received.

### 2.3 Storage Layer (Back-end)
* **Responsibility:**
  * **Persistent Storage:** Stream the received bytes asynchronously into local files or a database.
  * **Session Management:** Record metadata for each recording session (e.g., start timestamp, duration, sensor MAC address).

## 3. Core Data Flow

The end-to-end data pipeline operates strictly sequentially:
1. **Link Establishment:** The host program handshakes with the sensor via BLE.
2. **Streaming:** The sensor continuously pushes pure raw bytes over the wireless connection.
3. **Buffering & Relay:** The host program receives the byte stream and immediately pushes it into a memory buffer.
4. **Disk I/O:** An asynchronous background task flushes the buffer to the storage device, ensuring the data acquisition thread is never blocked.

## 4. Technical Route Selection

* **Hardware:** ESP32 microcontrollers with integrated IMU sensors.
* **Communication:** Bluetooth Low Energy (BLE) operating in Serial Pass-through (UART) mode.
* **Host Application:** Python (utilizing asynchronous libraries like `bleak` for BLE and `asyncio` for I/O) or Node.js. Both are chosen for their strong asynchronous non-blocking event loops.
* **Storage Format:** Raw binary files (`.bin`) for maximum write speed, or a high-throughput time-series database optimized for byte arrays.

## 5. Non-Functional Requirements

* **High Throughput Reliability:** The intermediate buffer must be adequately sized to handle the maximum expected data rate (e.g., 50Hz+ sampling) without overflowing during temporary disk write delays.
* **Concurrency:** The Bluetooth receiving thread and the File I/O writing thread must be strictly decoupled to maintain real-time acquisition performance.
* **Resilience:** The host application must gracefully handle unexpected Bluetooth disconnections, securely closing the current file before attempting to reconnect.
