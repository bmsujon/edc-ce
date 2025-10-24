# EDC Data Exchange Flow - Visual Guide

This document provides a visual representation of the complete EDC data exchange workflow.

## Overview: The Complete Journey

```
┌─────────────┐                                  ┌─────────────┐
│   Provider  │                                  │  Consumer   │
│  Connector  │                                  │  Connector  │
└──────┬──────┘                                  └──────┬──────┘
       │                                                │
       │                                                │
```

---

## Phase 1: Setup & Publishing (Provider Side)

```
Provider Actions:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. CREATE ASSET                                                │
│     ┌──────────────────────────────────┐                       │
│     │ Asset ID: my-api                 │                       │
│     │ Name: Weather Data API           │                       │
│     │ Data Source: HTTP endpoint       │                       │
│     │ URL: https://api.example.com     │                       │
│     └──────────────────────────────────┘                       │
│                    │                                            │
│                    ↓                                            │
│  2. CREATE POLICIES                                             │
│     ┌──────────────────────────────────┐                       │
│     │ Access Policy (Who can see?)     │                       │
│     │ - Unrestricted / BPN-based       │                       │
│     └──────────────────────────────────┘                       │
│     ┌──────────────────────────────────┐                       │
│     │ Contract Policy (Who can use?)   │                       │
│     │ - Unrestricted / Time-limited    │                       │
│     └──────────────────────────────────┘                       │
│                    │                                            │
│                    ↓                                            │
│  3. CREATE CONTRACT DEFINITION (Data Offer)                    │
│     ┌──────────────────────────────────┐                       │
│     │ Links: Asset + Policies          │                       │
│     │ Creates: Data Offer              │                       │
│     │ Result: Visible in Catalog       │                       │
│     └──────────────────────────────────┘                       │
│                                                                 │
│  ✅ DATA OFFER NOW PUBLISHED                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 2: Discovery (Consumer Side)

```
Consumer Actions:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  4. REQUEST CATALOG                                             │
│     ┌──────────────────────────────────┐                       │
│     │ Query: Provider endpoint         │                       │
│     │ With: Provider participant ID    │                       │
│     └──────────────────────────────────┘                       │
│                    │                                            │
│                    ↓                                            │
│            [DSP Protocol]                                       │
│                    │                                            │
│                    ↓                                            │
│     Provider checks Access Policy                              │
│                    │                                            │
│                    ↓                                            │
│     ┌──────────────────────────────────┐                       │
│     │ Catalog Response                 │                       │
│     │ - Data Offer Details             │                       │
│     │ - Offer ID (for negotiation)     │                       │
│     │ - Asset metadata                 │                       │
│     │ - Policies                       │                       │
│     └──────────────────────────────────┘                       │
│                                                                 │
│  ✅ CONSUMER CAN SEE AVAILABLE OFFERS                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 3: Contract Negotiation

```
Negotiation Flow:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  5. INITIATE CONTRACT NEGOTIATION                               │
│                                                                 │
│     Consumer                         Provider                  │
│        │                                │                       │
│        │  ContractRequest               │                       │
│        │  (with Offer ID)               │                       │
│        ├───────────────────────────────>│                       │
│        │                                │                       │
│        │         State: REQUESTING      │                       │
│        │                                │                       │
│        │                                ├─ Check Contract      │
│        │                                │  Policy               │
│        │                                │  (BPN, constraints)   │
│        │                                │                       │
│        │         State: REQUESTED       │                       │
│        │                                │                       │
│        │<───────────────────────────────┤                       │
│        │  Agreement Offer               │                       │
│        │                                │                       │
│        ├─ Verify terms                  │                       │
│        │                                │                       │
│        │  Agreement Accepted            │                       │
│        ├───────────────────────────────>│                       │
│        │                                │                       │
│        │         State: AGREED          │                       │
│        │                                │                       │
│        │<───────────────────────────────┤                       │
│        │  Confirmation                  │                       │
│        │                                │                       │
│        │      State: FINALIZED          │                       │
│        │   Contract Agreement Created   │                       │
│        │   (Agreement ID generated)     │                       │
│        │                                │                       │
│                                                                 │
│  ✅ CONTRACT AGREEMENT ESTABLISHED                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Timeline: Usually completes in 1-3 seconds
```

---

## Phase 4: Data Transfer (HTTP Push)

```
Transfer Flow - HTTP PUSH:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  6. INITIATE TRANSFER (HTTP Push)                               │
│                                                                 │
│     Consumer                Provider              Data Source   │
│        │                       │                      │         │
│        │  TransferRequest      │                      │         │
│        │  + Data Sink URL      │                      │         │
│        ├──────────────────────>│                      │         │
│        │                       │                      │         │
│        │  State: STARTED       │                      │         │
│        │                       │                      │         │
│        │                       ├─ Validate Contract   │         │
│        │                       │  Re-check Policy     │         │
│        │                       │                      │         │
│        │  State: REQUESTED     │                      │         │
│        │                       │                      │         │
│        │                       │  Fetch Data          │         │
│        │                       ├─────────────────────>│         │
│        │                       │                      │         │
│        │  State: IN_PROGRESS   │<─────────────────────┤         │
│        │                       │   Data Retrieved     │         │
│        │                       │                      │         │
│        │                       │                                │
│        │                       ├─ Transform if needed           │
│        │                       │                                │
│        │<──────────────────────┤                                │
│        │   Push Data to Sink   │                                │
│        │                       │                                │
│    [Data Sink]                 │                                │
│     Receives                   │                                │
│     the data                   │                                │
│        │                       │                                │
│        │  ACK                  │                                │
│        ├──────────────────────>│                                │
│        │                       │                                │
│        │  State: COMPLETED     │                                │
│        │                       │                                │
│                                                                 │
│  ✅ DATA SUCCESSFULLY TRANSFERRED                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 4b: Data Transfer (HTTP Pull with EDR)

```
Transfer Flow - HTTP PULL (EDR):
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  6. REQUEST EDR                                                 │
│                                                                 │
│     Consumer                Provider                            │
│        │                       │                                │
│        │  EDR Request          │                                │
│        │  (Contract-based)     │                                │
│        ├──────────────────────>│                                │
│        │                       │                                │
│        │                       ├─ Create EDR Token              │
│        │                       │  - Endpoint URL                │
│        │                       │  - Authorization Token         │
│        │                       │  - Expiry Time                 │
│        │                       │                                │
│        │<──────────────────────┤                                │
│        │   EDR Response        │                                │
│        │   {                   │                                │
│        │     endpoint: "url"   │                                │
│        │     authCode: "token" │                                │
│        │     expiresAt: "..."  │                                │
│        │   }                   │                                │
│        │                       │                                │
│        ├─ Store EDR            │                                │
│        │                       │                                │
│  7. USE EDR TO FETCH DATA                                       │
│        │                       │                                │
│        │  GET {endpoint}       │                                │
│        │  Authorization: token │                                │
│        ├──────────────────────>│                                │
│        │                       │                                │
│        │                       ├─ Validate Token                │
│        │                       ├─ Check Expiry                  │
│        │                       ├─ Fetch Data                    │
│        │                       │                                │
│        │<──────────────────────┤                                │
│        │   Data Response       │                                │
│        │                       │                                │
│    [Process Data]              │                                │
│        │                       │                                │
│        │  (Can request again   │                                │
│        │   with same EDR)      │                                │
│        │                       │                                │
│                                                                 │
│  ✅ DATA PULLED ON-DEMAND                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Benefits:
- Consumer controls when to fetch
- No data sink needed
- Can fetch multiple times
- Real-time / on-demand access
```

---

## State Transitions

### Contract Negotiation States

```
REQUESTING → REQUESTED → AGREED → FINALIZED
     ↓           ↓         ↓         ↓
     ↓           ↓         ↓      ✅ SUCCESS
     ↓           ↓         ↓
     ↓           ↓       TERMINATING → TERMINATED
     ↓           ↓                        ↓
     ↓         DECLINING → DECLINED    ❌ ENDED
     ↓                        ↓
   ERROR ──────────────────────────→ ❌ FAILED
```

### Transfer Process States

```
STARTED → REQUESTED → IN_PROGRESS → COMPLETED ✅
   ↓         ↓            ↓
   ↓         ↓       SUSPENDING → SUSPENDED
   ↓         ↓            ↓
   ↓      TERMINATING  TERMINATING
   ↓         ↓            ↓
   ↓      TERMINATED  TERMINATED ❌
   ↓
ERROR ────────────────────────────────────→ ❌ FAILED
```

---

## Decision Tree: Which Transfer Type?

```
┌─────────────────────────────────────────────────────┐
│  Need to transfer data?                             │
└────────────────┬────────────────────────────────────┘
                 │
        ┌────────▼─────────┐
        │  Who initiates?  │
        └────┬──────────┬──┘
             │          │
      ┌──────▼──┐   ┌──▼────────┐
      │Provider │   │ Consumer  │
      └──┬──────┘   └─────┬─────┘
         │                │
    ┌────▼─────┐     ┌────▼─────┐
    │HTTP-PUSH │     │HTTP-PULL │
    │          │     │(with EDR)│
    └────┬─────┘     └────┬─────┘
         │                │
    ┌────▼─────────┐ ┌────▼──────────┐
    │ Use Cases:   │ │ Use Cases:    │
    │ - Batch      │ │ - Real-time   │
    │ - Scheduled  │ │ - On-demand   │
    │ - One-time   │ │ - Multiple    │
    │              │ │   requests    │
    │ Pros:        │ │               │
    │ - Simple     │ │ Pros:         │
    │ - No polling │ │ - Flexible    │
    │              │ │ - Consumer    │
    │ Cons:        │ │   control     │
    │ - Needs sink │ │               │
    │ - Push once  │ │ Cons:         │
    │              │ │ - Token mgmt  │
    │              │ │ - Polling     │
    └──────────────┘ └───────────────┘
```

---

## Policies: Access Control Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    POLICY EVALUATION                        │
└─────────────────────────────────────────────────────────────┘

1. CATALOG REQUEST (Access Policy)
   ┌──────────────────────────┐
   │ Consumer requests catalog│
   └───────────┬──────────────┘
               │
        ┌──────▼───────┐
        │ Evaluate     │
        │Access Policy │
        └──┬────────┬──┘
           │        │
      ┌────▼───┐  ┌▼────────┐
      │ ALLOW  │  │ DENY    │
      └───┬────┘  └─┬───────┘
          │         │
   ┌──────▼─────┐  └─────────> Offer NOT in catalog
   │Show in     │
   │Catalog     │
   └────────────┘


2. CONTRACT NEGOTIATION (Contract Policy)
   ┌──────────────────────────┐
   │Consumer initiates negotia│
   └───────────┬──────────────┘
               │
        ┌──────▼────────┐
        │ Evaluate      │
        │Contract Policy│
        └──┬─────────┬──┘
           │         │
      ┌────▼───┐  ┌─▼─────────┐
      │ ALLOW  │  │ DENY      │
      └───┬────┘  └─┬─────────┘
          │         │
   ┌──────▼─────┐  └────────────> Negotiation FAILS
   │Create      │
   │Agreement   │
   └────────────┘


3. DATA TRANSFER (Re-check Contract Policy)
   ┌──────────────────────────┐
   │Consumer initiates transfer│
   └───────────┬──────────────┘
               │
        ┌──────▼────────┐
        │ Re-evaluate   │
        │Contract Policy│
        └──┬─────────┬──┘
           │         │
      ┌────▼───┐  ┌─▼─────────┐
      │ ALLOW  │  │ DENY      │
      └───┬────┘  └─┬─────────┘
          │         │
   ┌──────▼─────┐  └────────────> Transfer FAILS
   │Execute     │
   │Transfer    │
   └────────────┘
```

---

## Common Constraints in Policies

```
┌─────────────────────────────────────────────────────────────┐
│                  POLICY CONSTRAINTS                         │
└─────────────────────────────────────────────────────────────┘

1. Business Partner Number (BPN)
   ┌──────────────────────────────┐
   │ leftOperand: BPN             │
   │ operator: EQ                 │
   │ rightOperand: BPNL0000001    │
   └──────────────────────────────┘
   Use case: Only allow specific companies


2. Time-based
   ┌──────────────────────────────┐
   │ leftOperand: currentDate     │
   │ operator: LT                 │
   │ rightOperand: 2025-12-31     │
   └──────────────────────────────┘
   Use case: Temporary access


3. Usage Purpose
   ┌──────────────────────────────┐
   │ leftOperand: purpose         │
   │ operator: EQ                 │
   │ rightOperand: "quality-check"│
   └──────────────────────────────┘
   Use case: Limit data usage purpose


4. Region-based
   ┌──────────────────────────────┐
   │ leftOperand: region          │
   │ operator: IN                 │
   │ rightOperand: ["EU", "US"]   │
   └──────────────────────────────┘
   Use case: Geographic restrictions


5. Multiple Constraints (AND)
   ┌──────────────────────────────┐
   │ constraint: [                │
   │   { BPN check },             │
   │   { Time check },            │
   │   { Purpose check }          │
   │ ]                            │
   └──────────────────────────────┘
   Use case: All must be satisfied
```

---

## Complete Journey: Timeline View

```
Time  Provider                    Consumer
════╪═══════════════════════════════════════════════════════════
t=0 │ Create Asset
    │ Create Policies
    │ Publish Data Offer
    │    │
    │    ├─── Data Offer visible in dataspace
    │                              │
t=10│                              └─> Request Catalog
    │                                       │
t=11│                              <────────┘ Catalog Response
    │                                       │
    │                                       ├─> Select Offer
    │                                       │
t=15│                              <────────┘ Initiate Negotiation
    │    │
    │    ├─> Validate Contract Policy
    │    │
t=16│    ├─> Create Agreement
    │    │
    │    ├───────────────────────> Agreement Confirmation
    │                                       │
    │                                       ├─> Store Agreement
    │                                       │
t=20│                              <────────┘ Initiate Transfer
    │    │
    │    ├─> Validate Agreement
    │    │
    │    ├─> Fetch from Data Source
    │    │
    │    ├───────────────────────> Push to Data Sink
    │                                       │
    │                              ┌────────▼────────┐
    │                              │  Data Received  │
    │                              └─────────────────┘
t=25│    │
    │    ├<──────────────────────── Transfer Complete ACK
    │    │
    │    ├─> Mark Transfer COMPLETED
    │
    ✅   DONE
```

---

## Debugging Checklist

```
❌ Catalog Request Returns Empty?
   ├─ Check: Access policy allows consumer
   ├─ Check: Contract definition exists
   ├─ Check: Asset is linked in contract definition
   └─ Check: Participant ID in request URL

❌ Contract Negotiation Fails?
   ├─ Check: Offer ID is correct (from catalog)
   ├─ Check: Contract policy constraints are met
   ├─ Check: Target asset ID matches
   └─ Check: Provider connector logs

❌ Transfer Fails?
   ├─ Check: Contract is FINALIZED
   ├─ Check: Agreement ID is correct
   ├─ Check: Data sink is reachable
   ├─ Check: Data source URL works
   └─ Check: Contract policy still valid

❌ EDR Token Doesn't Work?
   ├─ Check: Token hasn't expired
   ├─ Check: Using correct endpoint URL
   ├─ Check: Authorization header format
   └─ Check: Contract agreement is active
```

---

## Architecture: System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                         EDC Connector                           │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Control Plane│  │  Data Plane  │  │  Database    │         │
│  │              │  │              │  │  (Postgres)  │         │
│  │ - Management │  │ - Transfer   │  │              │         │
│  │   API        │  │   execution  │  │ - Assets     │         │
│  │ - Contract   │  │ - EDR mgmt   │  │ - Policies   │         │
│  │   negotiation│  │ - Data proxy │  │ - Contracts  │         │
│  │ - Policy     │  │              │  │ - Transfers  │         │
│  │   evaluation │  │              │  │              │         │
│  │ - Catalog    │  │              │  │              │         │
│  │              │  │              │  │              │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
│         └────────┬────────┴────────┬────────┘                  │
│                  │                 │                           │
│         ┌────────▼─────────────────▼────────┐                  │
│         │      DSP Protocol Endpoint        │                  │
│         │    (Dataspace Protocol HTTP)      │                  │
│         └────────┬──────────────────────────┘                  │
│                  │                                             │
└──────────────────┼─────────────────────────────────────────────┘
                   │
                   ▼
         ┌─────────────────┐
         │  Other EDC      │
         │  Connectors     │
         └─────────────────┘
```

---

**This visual guide should help you understand the complete data exchange flow! 🎨**
