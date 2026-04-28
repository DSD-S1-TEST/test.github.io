---
title: "Software Requirements Specification version 0.2"
date: "2026-04-18"
publisher: "Admin"
summary: "An updated Software Requirements Specification detailing the Data Tunnel architecture, IF1 streaming contract, and resilient IMU data acquisition."
---

# Software Requirements Specification

**Project:** Limb Motion Recognition and Assistant System
**Programme:** Distributed Software Development 2025–2026
**Partners:** UTAD (Portugal) and Jilin University (China)
**Date:** April 18, 2026
**Authors:** Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, Silva André

---

## 1. Executive Summary

### 1.1 The Vision
Physical rehabilitation often suffers from a lack of objective, measurable data when patients practice at home. The **Intelligent Limb Motion Rehabilitation Platform** bridges this gap by merging IoT (Internet of Things) with Cloud AI. By outfitting patients with wearable Inertial Measurement Units (IMUs), the system continuously monitors joint angles, evaluates them against clinical baselines using artificial intelligence, and corrects postures in real-time. 

### 1.2 Core Objectives
- **Empower Patients:** Provide a foolproof, guided exercise experience at home with instant posture feedback.
- **Enable Clinicians:** Deliver rich, quantitative data regarding patient compliance and recovery progress.

---

## 2. Platform Topology and Ownership

The system operates across three distinct operational frontiers, collaboratively built by six specialized teams:

### 2.1 The Edge (Sensor Integration)
- **S1 (Hardware & Firmware):** The physical IMU arrays that sit on the patient's body. Responsible for battery management, raw vector capture, and BLE (Bluetooth Low Energy) broadcasting.
- **S2 (Acquisition Pipeline):** The bridge software. It ingests the raw BLE stream, handles initial buffering, and securely tunnels this data up to the cloud without dropping packets.

### 2.2 The Cloud (Brain & Storage)
- **V1 (AI Inference Engine):** The analytical core. It consumes raw motion arrays, filters out noise, predicts current joint angles, and flags deviations against a prescribed exercise baseline.
- **V2 (Central API Gateway):** The nervous system. It orchestrates user identities, permanently archives session graphs, and coordinates responses back to the user interfaces.

### 2.3 The Presentation (User Interfaces)
- **M1 (Patient App):** A high-reactivity mobile app offering live exercise guides and immediate corrective alerts.
- **M2 (Clinical Dashboard):** A comprehensive web portal for doctors to review historical recovery trajectories and assign customized rehabilitation plans.

---

## 3. Key User Journeys

Instead of atomic use cases, the system's value is best understood through its two primary workflows:

### 3.1 The Patient's Journey (Execution & Correction)
1. **Setup & Calibration:** The patient opens the M1 app and pairs their IMU bands (S1/S2). The system requires a quick 3-second calibration to establish spatial orientation.
2. **Active Routine:** As the patient moves, data flows continuously (up to 50Hz) to the V1 AI engine.
3. **Live Feedback Loop:** Within half a second (<500ms), the system responds. If the patient overextends a joint, the M1 app immediately flashes a warning and pauses the session, ensuring unsafe exercises are stopped instantly.
4. **Offline Resilience:** If the Wi-Fi drops, the S2 pipeline automatically caches data locally. The patient finishes their session uninterrupted, and data seamlessly syncs when connectivity returns.

### 3.2 The Clinician's Journey (Analysis & Prescription)
1. **Macro Overview:** A doctor logs into the M2 web portal to view a dashboard grouping all their patients by risk or compliance levels.
2. **Micro Analysis:** The doctor selects a specific patient to visualize a 3D playback of their recent session, observing exactly where their range of motion falls short.
3. **Dynamic Prescription:** Based on the data, the doctor alters the expected target angles and assigns a newly adjusted weekly plan via the V2 system, which instantly pushes to the patient's M1 app.

---

## 4. Contractual Boundaries (Interfaces)

To prevent integration chaos among the six teams, two strict technological borders are enforced:

- **The Upstream Contract (IF1):** Between the Edge (S2) and Cloud AI (V1). This is a purely transactional, high-velocity stream. It guarantees data ordering and assigns session unique identifiers, ensuring the AI receives a continuous, unbroken telemetry flow.
- **The Downstream Contract (IF2):** Between the Cloud API (V2) and Clients (M1/M2). Built on RESTful principles and WebSockets, this interface governs secure authentication (JWT), historical data retrieval, and real-time bidirectional alerts.

---

## 5. Vital Technical Specifications

To be deemed clinically viable, the platform must satisfy these uncompromising constraints:

### 5.1 Performance & Throughput
- **Real-Time Responsiveness:** The total time from a patient extending their arm to the AI returning a correction must remain under **500 milliseconds**. Faster internal processing (V1 under 100ms) guarantees this buffer.
- **Concurrency:** The cloud endpoints (V2) must absorb load from at least 100 simultaneous active sessions without severe throttling.

### 5.2 Fault Tolerance
- **Zero Drop Policy:** Network turbulence is inevitable. The edge systems must buffer arrays locally to guarantee that 100% of recorded data eventually reaches the secure V2 vault.
- **Hardware Limitations:** Since sensors run on batteries capped at ~8 hours, the onboarding and connection flow must be aggressively efficient to conserve energy.

### 5.3 Privacy & Security
- **Medical Grade Compliance:** As the data pertains to physical health, the entire pipeline must operate under GDPR guidelines. 
- **Encryption:** Payload in transit is secured via TLS, and rest-state authorizations utilize industry-standard Argon2/bcrypt hashing.

---

## 6. System Data Flow Architecture

To ensure real-time responsiveness and data integrity, the telemetry follows a strict pipeline:

1. **Ingestion (The Physical Layer - S1 to S2):** 
   Raw IMU sensor arrays generate motion vectors (accelerometer, gyroscope, magnetometer). This stream of raw binary data is transmitted over Bluetooth Low Energy (BLE) to the S2 data acquisition proxy. 
2. **Tunneling & Buffering (The Edge Layer - S2 to V1):** 
   S2 acts as a highly resilient buffer. It converts and groups the raw vectors into structured JSON payloads, injecting them with precise timestamps and unique Session IDs. S2 then pushes this data across the IF1 interface to the V1 AI engine. If network availability drops, S2 queues this payload in local storage.
3. **AI Inference & Evaluation (The Analytics Layer - V1):** 
   Upon receiving the IF1 payload, V1 parses the sequential arrays through its core motion-recognition model to determine the patient's exact joint angles in 3D space. These calculated angles are immediately matched against the patient's personalized clinical baseline.
4. **Distribution & Persistence (The Gateway Layer - V1 to V2 to M1/M2):** 
   V1 outputs an analytical conclusion (e.g., "Left elbow overextended by 15 degrees, confidence 94%") and passes it to V2. V2 immediately forks the process: it commits the event to the persistent database, and simultaneously fires an asynchronous WebSocket interrupt via IF2 to the M1 app, triggering a UI visual alert and haptic feedback.

---

## 7. Explicit Functional Requirements (FRs)

While the User Journeys describe *how* platform features are experienced, the system explicitly guarantees the following functional capabilities to map development objectives:

### 7.1 Identity and Access Management
- **FR-IAM-01:** The platform shall support secure, role-based onboarding, authentication, and login routing for three distinct user types: Patients, Doctors, and Administrators.
- **FR-IAM-02:** All endpoints requesting or modifying patient health data must be authenticated via timed JSON Web Tokens (JWTs).

### 7.2 Sensor & Hardware Lifecycle
- **FR-SENS-01:** The patient application shall automatically discover, identify, and pair authorized S1 IMU hardware via Bluetooth.
- **FR-SENS-02:** Prior to recording an active rehabilitative session, the system must enforce and successfully complete a spatial calibration routine (e.g., holding a rigid posture for 3 seconds).

### 7.3 Data Pipeline & AI Processing
- **FR-PIPE-01:** The S2 node shall sustain continuous ingestion of high-frequency sensor payloads (up to 50Hz) without blocking the primary application UI thread.
- **FR-AI-01:** V1 shall decode incoming data frames, execute inference operations, and generate reliable angle deviation metrics.
- **FR-AI-02:** V1 must rigorously emit structured telemetry outcomes back to the system, explicitly declaring processing successes, partial failures, or low-confidence inference flags.

### 7.4 Live Alerting & Offline Resilience
- **FR-ALRT-01:** The system shall instantly calculate and dispatch a "Dangerous Posture" interrupt whenever the measured angle violates predefined clinical safety thresholds.
- **FR-OFF-01:** The localized environment (M1/S2) shall seamlessly activate local buffering mechanisms when upstream (Cloud) connectivity degrades, silently queuing session data and dynamically resuming sync once reconnected.

### 7.5 Clinical Operations (Doctor Dashboard)
- **FR-CLIN-01:** The M2 web dashboard shall query historical session records from V2 and visualize longitudinal patient compliance, rendering intuitive statistical charts for accuracy and motion quality.
- **FR-CLIN-02:** Medical professionals shall be able to digitally prescribe, modify, and assign detailed exercise schemas (including target joint angles and rep counts). These updates must be pushed automatically to the respective patient's M1 client.
