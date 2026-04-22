---
title: "Finalization of System Architecture and Protocols"
date: "2026-04-16"
author: "Haoqi Sheng"
summary: "We have completed the System Design 1.1 document, establishing the core data flow and IF1 communication interfaces for our project."
---

# System Design 1.1

**This document is currently under review by all teams.**

**Project Team:** Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, Silva André

Revision History:

| Date | Description |
| :--- | :--- |
| April 9 | Initial document structure drafted (0.1) with system decomposition  |
| April 12 | Content expanded based on core project requirements (0.2)  |
| April 15 | Refined against SRS; integrated use cases, IF1 contract, and actor flows (1.0)  |
| April 16 | Integrated functional mapping, data flow steps, and specific technology selections (1.1)  |

## Introduction

This document describes the system design for a wireless joint motion capture system developed as part of an international collaborative course project. The system focuses on wireless sensor implementation, communication protocol design, and reliable transmission of motion data.

The document reflects the consensus of teams on the modular division, and defines how modules communicate with each other, providing a crucial basis of module design for developers and testers across teams. It is intended to be read alongside the Software Requirements Specification (SRS), which defines use cases and the IF1 Interface Contract as the Sprint 1 deliverable.

The specifications in each section under the *New in version x.y* is added since this version. Lines starting with *Changed in version x.y* state how the specifications above this line changed in this version.

## Functional requirement clustering

A module takes charge respectively of a cluster of requirements.

A **component diagram** shows here the clusters.

![]()

The system is decomposed into three primary layers: a **Front-end** layer handling user interaction (registration, login, sensor control, and data visualization) via IMU and mobile devices; an **Intermediate** layer managing the wireless communication protocol, session management, and request routing; and a **Back-end** layer responsible for user account management, data processing, joint angle calibration, and motion data storage. Sensor firmware runs on microcontrollers at the hardware layer and feeds data upward through the communication stack.

The use cases defined in the SRS map to these layers as follows:

| Use Case | Primary Layer(s) |
| -------- | ---------------- |
| 1.1 User Register | Front-end, Back-end |
| 1.2 User Login | Front-end, Back-end |
| 1.3 Connect Sensor | Front-end, Intermediate |
| 1.4 Calibrate Joint Angle | Back-end, Hardware |
| 1.5 Transmit Motion Data | Intermediate, Back-end |

### Front-end

*Version 1.1*

The front-end interacts with human users via IMU devices and mobile devices. It is responsible for user account flows, sensor connection controls, real-time joint motion visualization, and surfacing system status.

#### Functional requirement list

The requirements answered by this component:
- Present registration and login forms; collect and validate user credentials (UC 1.1, 1.2)
- Display connection controls to power on sensors and initiate the wireless handshake (UC 1.3)
- Show connection status ("Connected" / error message) (UC 1.3)
- Display real-time motion capture data streamed from the intermediate layer (UC 1.5)
- Notify users of transmission errors, packet loss, or sensor disconnection (UC 1.5)

### Intermediate (Communication Protocol & IF1 Contract)

*Version 1.1*

The web server acts as an intermediate to receive requests, enforce the wireless communication protocol, and route data. It is the primary owner of the **IF1 Interface Contract** (Sprint 1 deliverable).

#### Functional requirement list

- Receive and forward user account requests to the back-end (UC 1.1, 1.2)
- Detect sensor broadcast signals and initiate the wireless handshake (UC 1.3)
- Confirm data packet format and sampling rate with the sensor (UC 1.3)
- Receive data packets from sensor firmware and route them without loss or corruption (UC 1.5)

#### IF1 Interface Contract — Communication Protocol Design

**Data Packet Format**

Each packet transmitted from the sensor shall contain:

| Field | Description |
| ----- | ----------- |
| Header | Packet start identifier |
| Device ID | Unique identifier of the sensor node |
| Timestamp | Capture time in milliseconds since session start |
| Sequence Number | Monotonically increasing counter for loss detection |
| Joint Angle Payload | Calibrated angle values (one per tracked joint) |
| Checksum / CRC | Error-detection field covering the full packet |

**Sampling Rate**
The default target rate is 50Hz, configurable per session within hardware limits. A higher rate improves accuracy, while a lower rate saves bandwidth and power.

**Error Handling Mechanisms**

| Fault Condition | System Response |
| --------------- | --------------- |
| Packet loss (gap in sequence) | Log loss event; request retransmission |
| Corrupted packet (CRC mismatch)| Discard packet; log error; request retransmission |
| Sensor signal lost | Auto-reconnect attempt; notify front-end after timeout |
| Reconnection failure | Display error message to user; end session gracefully |

### Back-end

*Version 1.1*

The back-end is responsible for user account management, receiving/decoding motion data, performing joint angle calibration, and persisting results.

#### Functional requirement list
- Validate uniqueness of new user accounts and enforce password format regulations (UC 1.1)
- Authenticate returning users against stored credentials (UC 1.2)
- Perform joint angle calibration algorithms on raw IMU sensor data (UC 1.4)
- Store processed motion data for session replay and analysis (UC 1.5)

#### Hardware Integration Note
Since physical sensors are currently only available in China, hardware-related tasks — including sensor firmware implementation, hardware drivers, and microcontroller integration — are primarily handled by China-based team members (Programmers CN).

## Data Flow Architecture

*New in version 1.1*

The overarching end-to-end data flow operates sequentially as follows:
1. **Acquisition:** Sensor collects raw motion data.
2. **Encoding:** Sensor firmware encodes data into the IF1 defined packet structure.
3. **Transmission:** Data is transmitted via the selected wireless protocol.
4. **Validation:** Server (Intermediate layer) receives and validates the packet (CRC, Sequence check).
5. **Processing & Storage:** Back-end parses data, calibrates angles, and stores the results in the database.
6. **Delivery:** Front-end retrieves data via API.
7. **Visualization:** Real-time motion is rendered to the user interface.

## Non-functional requirement response

*Version 1.0*

- **Reliability**: Protocol must handle packet loss gracefully through CRC checking and retransmission.
- **Latency**: End-to-end latency (sensor capture to display) should target <100ms for real-time visualization.
- **Scalability**: Architecture should support multiple simultaneous IMU sensor nodes.
- **Security**: User account credentials must be transmitted securely (HTTPS); password formatting enforced.
- **Cross-cultural collaboration**: Documentation must be accessible across time zones (China and Portugal).

## Technical route selection

*Version 1.1*

The following technical choices have been identified:
- **Microcontroller platform**: ESP32 (or similar) supporting IMU sensor interfacing and wireless transmission.
- **Wireless protocol**: Bluetooth Low Energy (BLE) for low power, or Wi-Fi (UDP/TCP) for high throughput. Final selection codified in IF1.
- **Sensor firmware**: C/C++ for hardware interaction, calibration, and serialization.
- **Back-end services**: Python (FastAPI) or Node.js. Database utilizing PostgreSQL or a Time-series DB for motion tracking.
- **Front-end platform**: Web-based UI built with React or Vue.

## Future Improvements

*New in version 1.1*

- Add motion prediction algorithms for latency compensation.
- Integrate 3D skeletal visualization on the front-end dashboard.
- Optimize deep sleep cycles for power consumption on physical sensors.
