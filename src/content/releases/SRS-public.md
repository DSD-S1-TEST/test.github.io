---
title: "Software Requirements Specification"
date: "2026-04-18"
publisher: "Admin"
summary: "A comprehensive Software Requirements Specification detailing the Data Tunnel architecture, IF1 streaming contract, and resilient IMU data acquisition for Sprint 1."
---

# Software Requirements Specification (SRS)

**Project:** Limb Motion Recognition and Assistant System (DSD 2025–2026)
**Sub-System / Team:** Team S1 & S2 (Sensor & Data Acquisition Pipeline)
**Date:** April 18, 2026
**Authors:** Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, Silva André

---

## 1. Introduction

### 1.1 Purpose
This document defines the comprehensive software and system requirements for the Sensor Layer (S1) and the Data Acquisition Pipeline (S2) within the Limb Motion Recognition and Assistant System. It harmonizes the project's global cross-team requirements with our group's specific technological trajectory, which focuses on establishing a highly reliable, high-throughput asynchronous "Data Tunnel" for raw IMU sensor data.

### 1.2 Background
The overarching project is a distributed rehabilitation platform co-developed by UTAD (Portugal) and Jilin University (China). While the global architecture incorporates AI-based motion recognition and clinical web dashboards, Team S1/S2 is exclusively responsible for the critical hardware-software bridge: capturing motion data from wearable IMU sensors and guaranteeing its secure, lossless transmission to the server layer.

### 1.3 Scope & Constraint Statement
In accordance with System Design 1.2, the current phase imposes a strict constraint on the S2 layer: **The system shall not perform real-time semantic parsing of sensor byte payloads.** Instead, S1/S2 shall operate purely as a "Connect-Acquire-Store" universal data platform. Its primary mandate is to ensure the lossless, sequential transmission of raw byte streams for downstream offline analysis.

---

## 2. Global System Architecture Integration

The overarching system operates across three distinct tiers:
1. **Monitor Layer (M1/M2):** The patient-facing mobile application and the medical professional clinical web dashboard.
2. **Server Layer (V1/V2):** The AI inference engine and the Gateway/Storage API.
3. **Sensor Layer (S1/S2 - Our Domain):** 
   * **S1 (IMU Hardware):** Wearable sensor arrays, embedded firmware, and wireless transmission via Bluetooth Low Energy (BLE).
   * **S2 (Data Acquisition Pipeline):** The intermediary software proxy that arbitrates the BLE connection lifecycle, implements traffic buffering, and acts as the authoritative owner of the IF1 interface contract.

---

## 3. Core Architectural Requirements (S1/S2 Specifics)

To fulfill S1/S2's specific technical responsibilities (the Data Tunnel Architecture), the following core architectural requirements must be implemented:

### 3.1 High-Throughput "Data Tunnel" Protocol
The S2 system acts as a transparent payload proxy, demanding an asynchronous, non-blocking sequence:
* **Acquisition:** IMU hardware (ESP32) shall stream pure raw bytes continuously over BLE via Serial Pass-through (UART) mode.
* **Buffering (Critical Path):** The system must natively implement an intermediate in-memory queue. This buffer physically isolates the BLE ingestion layer from the disk writing layer, preventing transmission packet loss caused by underlying disk I/O latency.
* **Persistent Storage:** The system shall asynchronously flush the byte stream to local non-volatile storage, persisting data in raw binary (`.bin`) format or a high-throughput time-series database optimized for byte arrays.

### 3.2 Thread Decoupling & Concurrency
* The BLE receiver thread (e.g., an event loop via Python's `bleak`) and the File I/O writer thread (e.g., via `asyncio` or Node.js equivalent) must be strictly decoupled. The data acquisition stream shall never be blocked or throttled by concurrent storage operations.

### 3.3 Connection Resilience & State Lifecycle
* S2 must govern the complete BLE connection lifecycle autonomously. This includes scanning, authenticating, detecting unexpected disconnects, ensuring safe closure of the active binary file, and seamlessly re-engaging auto-reconnect protocols without destabilizing the main thread.

---

## 4. Functional Requirements (FR)

### 4.1 System & Sensor Connection Lifecycle
* **FR-S01 (Sensor Broadcast):** The S1 hardware shall broadcast its availability and device signature via BLE immediately upon boot.
* **FR-S02 (Connection Handshake):** The S2 system shall scan, uniquely identify, and execute a cryptographic/connection handshake with the S1 sensor.
* **FR-S03 (Resilient Reconnection):** Should an unexpected disconnection occur, the system shall safely terminate the active data file to prevent corruption and automatically initiate a secure reconnection loop.

### 4.2 Raw Data Acquisition & Buffering
* **FR-S04 (Raw Byte Streaming):** The S2 system shall ingest a continuous, unparsed raw byte stream from the S1 hardware. No semantic interpretation of the payload shall occur at this layer.
* **FR-S05 (Asynchronous Ingestion):** Received byte streams must be immediately pushed into the decoupled memory buffer upon arrival.
* **FR-S06 (Asynchronous I/O Flush):** A segregated background task shall continuously sequentially flush the buffer contents to disk.

### 4.3 Session & Storage Management
* **FR-S07 (Session Metadata Generation):** The system shall generate and write descriptive metadata for each recording session (e.g., Start Timestamp, End Timestamp, Duration, Sensor MAC Address).
* **FR-S08 (Binary Persistence):** Data outputs shall be written exclusively in `.bin` formats to maximize raw I/O throughput.

*(Note: Global use cases, such as UC-01 User Registration and UC-02 User Login, are governed by the Gateway layer and are processed by S2 exclusively as external session triggers).*

---

## 5. IF1 Interface Contract (Sprint 1 Deliverable)

For Sprint 1, the **IF1 Contract** (Sensor-to-Server) is designated entirely as a **Streaming Interface**. S2 guarantees the following to upstream consumers (V1/V2):
* **Byte Sequencing:** Absolute sequential integrity of the ingested byte stream.
* **Payload Agnosticism:** Complete independence from packet bit meanings. Headers, footers, and checksums are recorded "as-is" for V1/V2 parsing.
* **Capacity Guarantee:** Zero-overflow assurance at maximum anticipated hardware sampling rates (e.g., capable of sustaining 50Hz+ continuous streams without backpressure).

---

## 6. Non-Functional Requirements (NFR)

### 6.1 Performance & Throughput
* **NFR-01 (Throughput Capacity):** The intermediate memory buffer shall be architected to sustain at least 50Hz+ continuous multi-sensor input during maximum expected disk I/O blockage limits.
* **NFR-02 (Data Integrity):** The architecture shall guarantee zero data loss occurring within the host system from the point of BLE adapter reception to the final disk write completion.

### 6.2 Technology & Infrastructure Context
* **NFR-03 (Hardware Platform):** The target IMU capture hardware shall center on the ESP32 microcontroller ecosystem.
* **NFR-04 (Host Environment):** The host capture application shall utilize event-driven languages explicitly engineered for non-blocking asynchronous IO (e.g., Python utilizing `bleak` and `asyncio`, or Node.js).

### 6.3 Maintainability & Scalability
* **NFR-05 (Documentation Standards):** All pipeline code, especially concurrency handling and buffer management, shall feature stringent inline documentation. This ensures seamless integration when semantic processing requirements are reintroduced in future sprints.
