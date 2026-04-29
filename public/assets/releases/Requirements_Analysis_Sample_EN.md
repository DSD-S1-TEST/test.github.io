# Requirements Analysis —— [Project Name]

---

## Part 1 Introduction

### 1. Revision History:

| Date | Author | Description |
| ---- | ------ | ----------- |
| Apr 5 | Xiaoquan Xu | Add use cases |

### 2. Scope

### 3. Glossary (Optional)

| Term | Definition | Abbreviation/Alias | Remarks |
| :--- | :--- | :--- | :--- |
| Term 1 | Precise business definition | Abbreviation | Remarks or reference |

### 4. References (Optional)

| No. | Document Name | Source/Author | Description |
| :--- | :--- | :--- | :--- |
| 1 | Document name | Source | Description |

---

## Part 2 External Use Cases (M1, M2 only)

### 1. Actor Table

| Actor | Description |
| :--- | :--- |
| Actor 1 | Role and responsibility brief |

### 2. Use Case Table

| Use Case ID | Use Case Name | Primary Actor | Brief Description |
| :--- | :--- | :--- | :--- |
| UC-M1-01 | Use case name | Actor | One-sentence description |

### 3. Detailed Use Cases

#### UC-M1-01+Use Case Name

| Element | Description |
| :--- | :--- |
| **Reference** | Use case ID (UC-M1-01) |
| **Actors** | Actor |
| **Goal** | Business goal the use case aims to achieve |
| **Summary** | Brief narrative of the use case |
| **Trigger** | Event that triggers the use case |
| **Precondition** | Conditions that must be true before execution |
| **Postconditions** | System state after successful execution |

**Basic Flow**

| Step | Actor Action | System Response |
| :--- | :--- | :--- |
| 1 | User action | |
| 2 | | System behavior |
| 3 | User action | |

**Alternative Flow** (Optional)

| Occurrence Step | Condition | System Response |
| :--- | :--- | :--- |
| 2 | Exception | Handling method |
| 3 | Exception | Handling method |

---

## Part 3 Internal Use Cases

### 1. Actor Table

*Select and supplement from the following candidate pool: Doctor, Patient, System Administrator, S1, S2, V1, V2, M1, M2.*

| Actor | Description |
| :--- | :--- |
| S1 | Internal module/subsystem responsibility |
| S2 | Internal module/subsystem responsibility |
| V1 | Internal module/subsystem responsibility |
| V2 | Internal module/subsystem responsibility |
| M1 | Application core, coordinates modules |
| M2 | Another application core |
| Patient | External business participant, triggers via UI |
| Doctor | External business participant |
| System Administrator | Maintains system master data |

### 2. Use Case Table

| Use Case ID | Use Case Name | Primary Actors | Brief Description |
| :--- | :--- | :--- | :--- |
| IUC-M1-01 | Internal use case name | List of internal actors | Internal interaction goal |

### 3. Detailed Use Cases

#### IUC-M1-01+Internal Use Case Name

| Element | Description |
| :--- | :--- |
| **Reference** | Corresponding external use case number or own number, e.g., (UC-M1-01 or IUC-M-01) |
| **Actors** | Participants, including internal modules and external triggers |
| **Goal** | Internal collaboration goal |
| **Summary** | Internal process overview |
| **Trigger** | Trigger source (user action or system event) |
| **Precondition** | Preconditions |
| **Postconditions** | Postconditions |

**Basic Flow**

| Step | Actor A | Actor B | Actor C |
| :--- | :--- | :--- | :--- |
| 1 | Action | | |
| 2 | | Response/Action | |
| 3 | | | Action |
| 4 | Result | | |

**Alternative Flow** (Optional)

| Occurrence Step | Condition | System Response |
| :--- | :--- | :--- |
| 2 | Exception | Handling method |
| 3 | Exception | Handling method |

---

## Part 4 Others (Optional, can be supplemented freely)

### 1. Assumptions and Dependencies

### 2. Non-functional Requirements

### 3. Internal Use Case Diagram

*Please insert the use case diagram as an image*
*E.g., ![](https://XXXXXXXXXXXXXXXX.png)*