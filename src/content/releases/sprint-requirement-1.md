---
title: "Requirement analysis version 0.1"
date: "2026-04-06"
publisher: "Admin"
summary: "We released the first version of our project's requirement analysis."
---
# Requirement analysis completed

## The whole analysis is as follows.

### Software Requirements Specification (Draft)

Revision History:

| Date | Author | Description |
| :--- | :--- | :--- |
| Apr 1 | Zhihang Yu | Draft User Register details |
| Apr 3 | Zhihang Yu, Derui Tang, Haoqi Sheng, Mofan Xu, Silva André | Held group meeting to finalize project roadmap, wireless sensor implementation, and Sprint 1 core deliverables |
| Apr 5 | Derui Tang | Add initial use cases and framework |

#### 0. Background

This document outlines the software requirements for a course project within an international collaborative program. Our team will design and implement a wireless joint motion capture system. The project emphasizes teamwork, cross-cultural collaboration, and practical engineering experience, focusing on:
* Wireless sensor implementation
* Communication protocol design
* Reliable transmission of motion data

This SRS is intended for the project team. It specifically defines the system interfaces and message structure required to complete the IF1 Interface Contract, which is the Sprint 1 deliverable.

#### 1. Use Cases

1.1. Case: User Register
1.2. Case: User Login
1.3. Case: Connect Sensor 
1.4. Case: Calibrate Joint Angle 
1.5. Case: Transmit Motion Data 

#### 2. Key Examples

##### 2.1. User Register

###### 2.1.1. Basic Info

- Reference to Use Case: 1.1
- Version: 1.0
- Created: Apr 1
- Authors: Haoqi Sheng, Mofan Xu
- Source: Server
- Actors: New User
- Goal: To make user register in the system
- Summary: This requirement allows new users to join the system and use the system to upload motion data and predict motion.
- Trigger: When new users want to join the system
- Frequency: Decided by the number of new users
- Precondition: The system permits adding new users
- Postconditions: The interface has verified the two inputs of password are the same and created the account

###### 2.1.2. Basic Flow

| Actor | System |
| ----- | ------ |
| New User registers in system | |
| | Check the user account is unique |
| | Check the password is consistent with the regulation |
| | Create user account and add to the database |
| | Return success information to the Interface |
| Interface shows success information | |

###### 2.1.3. Alternative Flow

| Actor | System |
| ----- | ------ |
| User account has existed | |
| | Return information of user account repetition |
| User password is not consistent with regulation | |
| | Return information of password format error |

##### 2.2. Sensor Connection

###### 2.2.1. Basic Info

- Reference to Use Case: 1.3
- Version: 0.1
- Created: Apr 5
- Authors: Silva André
- Source: Sensor Firmware / System Architecture
- Actors: User, Physical Sensor Hardware
- Goal: Establish a reliable wireless connection between the sensors and the system.
- Summary: Initializes the wireless sensors, establishes the communication protocol, and prepares the system for reliable transmission of motion data.
- Trigger: User powers on the sensors and initiates connection via the software interface.
- Frequency: Once per session.
- Precondition: Hardware drivers and microcontroller integration are complete.
- Postconditions: A stable wireless connection is established, and the system is ready to receive data packets.

###### 2.2.2. Basic Flow

| Actor (Sensor/User) | System |
| ----- | ------ |
| Sensor powers on and broadcasts signal | |
| User initiates connection via Interface | |
| | Detect sensor signal and initiate handshake |
| | Establish wireless communication protocol |
| | Confirm data packet format and sampling rate |
| | Return connection success status |
| Interface shows "Connected" | |

###### 2.2.3. Alternative Flow

| Actor (Sensor/User) | System |
| ----- | ------ |
| Sensor signal is lost or interrupted | |
| | Trigger predefined error handling mechanisms |
| | Attempt to reconnect |
| | Display error message to user if reconnection fails |

#### 3. IF1 Interface Contract (Sprint 1 Deliverable)

As required for Sprint 1, the System Architect must define the system interfaces and message structure. The IF1 Interface Contract must specify the following parameters to ensure the reliable transmission of motion data:

* **Communication Protocol**: Defines how the sensor firmware communicates with the system over the wireless network.
* **Data Packet Format**: Specifies the exact structure of the data packets sent from the sensor (e.g., headers, payload containing joint angles, checksums).
* **Sampling Rate**: Defines the frequency at which motion data is captured and transmitted.
* **Error Handling Mechanisms**: Outlines the system's response to signal loss, corrupted packets, or sensor disconnects.

---
