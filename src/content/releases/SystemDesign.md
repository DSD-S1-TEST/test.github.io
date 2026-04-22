---
title: "System Design 1.2: Data Tunnel Architecture"
date: "2026-04-22"
author: "Haoqi Sheng"
summary: "We have finalized the DSD-S1 technical architecture, focusing on a high-throughput 'Data Tunnel' with asynchronous buffering for raw IMU data acquisition."
---

DATE: 2026-04-22 | AUTHOR: Haoqi Sheng

## Architecture Milestone: System Design 1.2 Finalized

Following the completion of the SRS on April 6, our team has progressed from initial frameworking to a finalized "Data Tunnel" architecture. This design prioritizes the sequential integrity of raw sensor data and robust asynchronous storage.

<details>
<summary style="cursor: pointer; color: #00e5ff; font-weight: bold;">[ 点击展开查看详细设计方案 / Read More ]</summary>

<br>

### 1. Document Corrections & Refinements
The following updates were implemented based on the latest review phase to ensure clarity in medical and technical roles:

| LOCATION | BEFORE | AFTER | REASON |
| :--- | :--- | :--- | :--- |
| Right-side actor | Patient | Doctor | The M2 Dashboard serves Medical Professionals; the actor now reflects the actual user. |
| S2 → V1 data flow | Formal data | Format data | More accurately describes the 45-value CSV standard output for AI analysis. |
| V1 → V2 DB | Recognition result | Analysis results + Batch Format data | V1 now produces both real-time insights and batch-processed data for storage. |
| V2 DB ↔ M2 | Patient log | Patient log + Doctor Feedback | Added bidirectional flow to reflect the doctor's active role in treatment adjustments. |
| S2-01 ↔ S2-02 | Single arrow | Two unidirectional arrows | Separated "Simulated raw IMU packet" and "request" for independent traceability. |

### 2. Revised Data Flow Diagram (DFD)
The system is partitioned into the **App (Client)**, **Server (Backend)**, and **Monitoring (Dashboard)** layers.

```mermaid
graph LR
    %% Entities
    Patient[/Patient/]
    Doctor[/Doctor/]

    %% App Subsystem
    subgraph App
        S1((S1 Sensor))
        M1((M1 AppFrontend))
        S2((S2 Data Acq.))
    end

    %% Server Subsystem
    subgraph Server
        V1((V1 AI))
        V2((V2 DB))
    end

    M2((M2 Dashboard))

    %% Data Flows
    Patient -- Body movement --> S1
    Patient -- Connection request --> M1
    M1 -- Connection request --> S1
    M1 -- Start/Close session --> S2
    S1 -- Raw IMU packet --> S2
    S2 -- Format data --> V2
    V2 -- Doctor Feedback --> M1
    V2 -- Patient log --> M2
    M2 -- Doctor Feedback --> V2
    M2 -- Patient log --> Doctor
    Doctor -- Doctor Feedback --> M2
    
    %% AI Processing
    V2 --> V1
    V1 -- Analysis results --> V2
    V1 -- Batch Format data --> V2
