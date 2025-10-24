# Complete EDC Data Exchange Workflow via API

**Author**: AI Assistant with User  
**Date**: October 24, 2025  
**EDC Version**: sovity EDC-CE v16.1.0 (Eclipse EDC 0.11.1.3)  
**Status**: ✅ Tested and Working

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Setup Environment](#setup-environment)
4. [Workflow 1: HTTP Pull (Consumer Fetches Data)](#workflow-1-http-pull-consumer-fetches-data)
5. [Workflow 2: HTTP Push (Provider Pushes Data)](#workflow-2-http-push-provider-pushes-data)
6. [Key Learnings](#key-learnings)
7. [Troubleshooting](#troubleshooting)
8. [Reference](#reference)

---

## Overview

This guide documents **two complete data exchange workflows** using the Eclipse EDC Management API v3:

1. **HTTP Pull**: Consumer negotiates contract and fetches data using an EDR token
2. **HTTP Push**: Consumer negotiates contract and provider pushes data to a webhook

Both workflows demonstrate the full EDC dataspace protocol flow:

- Asset discovery via catalog
- Contract negotiation using JSON-LD
- Data transfer initiation
- Actual data retrieval

---

## Prerequisites

### Local Demo Running

```bash
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d

# Verify all containers are running
docker compose ps
```

### Environment Variables

```bash
# Provider Management API
export PROVIDER_API="http://localhost:11000/api/management"

# Consumer Management API
export CONSUMER_API="http://localhost:22000/api/management"

# API Key (same for both in demo)
export API_KEY="SomeOtherApiKey"
```

### Test Asset on Provider

Ensure the `weather-api-asset` exists:

```bash
curl -X GET "$PROVIDER_API/v3/assets/weather-api-asset" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq .
```

Expected: Asset pointing to `https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true`

---

## Setup Environment

### Step 1: Verify Provider Assets

```bash
# List all assets on provider
curl -X POST "$PROVIDER_API/v3/assets/request" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "QuerySpec",
    "limit": 50
  }' | jq .
```

### Step 2: Verify Contract Definitions

```bash
# Check that weather-offer-api-test exists
curl -X GET "$PROVIDER_API/v3/contractdefinitions/weather-offer-api-test" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq .
```

---

## Workflow 1: HTTP Pull (Consumer Fetches Data)

### Step 1: Request Catalog (Consumer)

**Purpose**: Discover available offers from the provider

```bash
curl -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "counterPartyId": "provider"
  }' | jq . > /tmp/catalog.json
```

**Extract Offer ID**:

```bash
OFFER_ID=$(cat /tmp/catalog.json | jq -r '.dcat:dataset[] | select(."edc:id" == "weather-api-asset") | ."@id"')
echo "Offer ID: $OFFER_ID"
```

Expected format: `d2VhdGhlci1vZmZlci1hcGktdGVzdA==:d2VhdGhlci1hcGktYXNzZXQ=:MDE5YTE0ZDUtNDNhOS03NTM2LWJjZDMtMmE0ZmJjMTJjMjkz`

### Step 2: Initiate Contract Negotiation (Consumer)

**Purpose**: Negotiate contract with provider for the asset

**⚠️ Critical JSON-LD Format**:

- `assigner` and `target` MUST be objects with `@id` property
- Use `odrl:` namespace prefix for ODRL terms
- `@type` must be `odrl:Offer`

```bash
curl -X POST "$CONSUMER_API/v3/contractnegotiations" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@context": "http://www.w3.org/ns/odrl.jsonld",
      "@type": "odrl:Offer",
      "@id": "'"$OFFER_ID"'",
      "odrl:permission": {
        "odrl:action": {
          "@id": "USE"
        }
      },
      "odrl:prohibition": [],
      "odrl:obligation": [],
      "odrl:assigner": {
        "@id": "provider"
      },
      "odrl:target": {
        "@id": "weather-api-asset"
      }
    }
  }' | jq -r '."@id"' > /tmp/negotiation_id.txt

NEGOTIATION_ID=$(cat /tmp/negotiation_id.txt)
echo "Negotiation ID: $NEGOTIATION_ID"
```

### Step 3: Check Negotiation State (Consumer)

**Purpose**: Wait for negotiation to reach FINALIZED state

```bash
curl -X GET "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq .

# Extract agreement ID
AGREEMENT_ID=$(curl -s -X GET "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq -r '.contractAgreementId')

echo "Agreement ID: $AGREEMENT_ID"
```

Expected states: `REQUESTING` → `REQUESTED` → `AGREED` → `FINALIZED`

### Step 4: Initiate HTTP Pull Transfer (Consumer)

**Purpose**: Start data transfer and get EDR token

```bash
curl -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "transferType": "HttpData-PULL",
    "dataDestination": {
      "type": "HttpData"
    }
  }' | jq -r '."@id"' > /tmp/transfer_id.txt

TRANSFER_ID=$(cat /tmp/transfer_id.txt)
echo "Transfer ID: $TRANSFER_ID"
```

### Step 5: Retrieve EDR (Endpoint Data Reference) (Consumer)

**Purpose**: Get the endpoint URL and authorization token to access data

```bash
# Wait for transfer to start (usually instant)
sleep 2

curl -X GET "$CONSUMER_API/v3/edrs/$TRANSFER_ID/dataaddress" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq . > /tmp/edr.json

# Extract endpoint and token
ENDPOINT=$(cat /tmp/edr.json | jq -r '.endpoint')
AUTH_TOKEN=$(cat /tmp/edr.json | jq -r '.authorization')

echo "Endpoint: $ENDPOINT"
echo "Auth Token (first 50 chars): ${AUTH_TOKEN:0:50}..."
```

### Step 6: Fetch Data Using EDR (Consumer)

**Purpose**: Retrieve the actual data from provider's data plane

```bash
# Note: Provider endpoint is internal Docker name, use localhost mapping
curl -X GET "http://localhost:11000/api/public" \
  -H "Authorization: $AUTH_TOKEN" | jq .
```

**Expected Output**:

```json
{
  "latitude": 52.52,
  "longitude": 13.419998,
  "current_weather": {
    "time": "2025-10-24T06:15",
    "temperature": 11.2,
    "windspeed": 15.1,
    "winddirection": 230,
    "is_day": 1,
    "weathercode": 3
  }
}
```

### ✅ HTTP Pull Complete!

You have successfully:

1. Discovered the asset via catalog
2. Negotiated a contract
3. Initiated a transfer
4. Retrieved an EDR token
5. Fetched the actual data

---

## Workflow 2: HTTP Push (Provider Pushes Data)

### Step 1-3: Same as HTTP Pull

Follow Steps 1-3 from HTTP Pull workflow to:

1. Request catalog
2. Initiate contract negotiation
3. Wait for FINALIZED state and get agreement ID

### Step 4: Create Webhook Endpoint

**Purpose**: Create a webhook to receive pushed data

```bash
# Create webhook.site endpoint
WEBHOOK_ID=$(curl -s -X POST https://webhook.site/token -H "Content-Type: application/json" | jq -r '.uuid')
echo "Webhook URL: https://webhook.site/$WEBHOOK_ID"

# You can visit this URL in browser to see incoming requests
```

### Step 5: Initiate HTTP Push Transfer (Consumer)

**Purpose**: Request provider to push data to your webhook

```bash
curl -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "transferType": "HttpData-PUSH",
    "dataDestination": {
      "type": "HttpData",
      "baseUrl": "https://webhook.site/'"$WEBHOOK_ID"'"
    }
  }' | jq .
```

### Step 6: Verify Data Received at Webhook

**Purpose**: Check that provider successfully pushed data

**Option A: Via Browser**

1. Open `https://webhook.site/$WEBHOOK_ID` in your browser
2. You should see POST requests with weather data

**Option B: Via API**

```bash
# Wait a few seconds for data to arrive
sleep 5

# Fetch latest request
curl -s "https://webhook.site/token/$WEBHOOK_ID/requests?sorting=newest" | \
  jq -r '.data[0].content' | jq .
```

**Expected Output**:

```json
{
  "latitude": 52.52,
  "longitude": 13.419998,
  "current_weather": {
    "time": "2025-10-24T06:15",
    "temperature": 11.2,
    "windspeed": 15.1,
    "winddirection": 230,
    "is_day": 1,
    "weathercode": 3
  }
}
```

### ✅ HTTP Push Complete!

You have successfully:

1. Discovered the asset via catalog
2. Negotiated a contract
3. Provided a webhook destination
4. Received data pushed by the provider

---

## Key Learnings

### 1. JSON-LD Format is Strict

The Management API v3 requires precise JSON-LD formatting:

**❌ WRONG** - Simple strings:

```json
"policy": {
  "@type": "odrl:Offer",
  "assigner": "provider",
  "target": "weather-api-asset"
}
```

**✅ CORRECT** - Objects with @id:

```json
"policy": {
  "@type": "odrl:Offer",
  "odrl:assigner": {
    "@id": "provider"
  },
  "odrl:target": {
    "@id": "weather-api-asset"
  }
}
```

### 2. Namespace Prefixes Matter

- Use `odrl:` prefix for ODRL vocabulary terms
- Use `edc:` prefix for EDC-specific terms
- Declare namespaces in `@context`

### 3. EDR Endpoint Mapping

The EDR returns Docker internal hostnames. Map them to localhost:

| EDR Endpoint                 | Localhost Equivalent                |
| ---------------------------- | ----------------------------------- |
| `http://provider/api/public` | `http://localhost:11000/api/public` |
| `http://consumer/api/public` | `http://localhost:22000/api/public` |

### 4. Transfer Types Comparison

| Feature          | HTTP Pull             | HTTP Push             |
| ---------------- | --------------------- | --------------------- |
| **Data Flow**    | Consumer fetches      | Provider pushes       |
| **EDR Required** | Yes                   | No                    |
| **Destination**  | Consumer's choice     | Must provide webhook  |
| **Use Case**     | On-demand data access | Event-driven delivery |
| **Complexity**   | More steps            | Simpler for consumer  |

### 5. Contract Negotiation States

Normal flow: `REQUESTING` → `REQUESTED` → `AGREED` → `FINALIZED`

In local demo with unrestricted policy: Often instant (FINALIZED immediately)

### 6. API Version Differences

This guide uses **Management API v3**:

- Endpoints: `/v3/assets`, `/v3/contractnegotiations`, etc.
- JSON-LD required
- More verbose but standards-compliant

For simpler format, use sovity's **Wrapper API**:

- Endpoints: `/wrapper/ui/pages/*`
- Plain JSON (no JSON-LD)
- Designed for UI consumption

---

## Troubleshooting

### Issue: "odrl:assigner/@id cannot be null or blank"

**Cause**: Using simple string instead of object with @id

**Solution**: Change from:

```json
"odrl:assigner": "provider"
```

To:

```json
"odrl:assigner": {"@id": "provider"}
```

### Issue: "@type was expected to be odrl:Offer but it was edc:Offer"

**Cause**: Missing or incorrect namespace prefix

**Solution**: Use exact string `"odrl:Offer"` with namespace declared:

```json
{
  "@context": {
    "odrl": "http://www.w3.org/ns/odrl/2/"
  },
  "policy": {
    "@type": "odrl:Offer"
  }
}
```

### Issue: "Could not resolve host: provider"

**Cause**: Trying to access Docker internal hostname from host machine

**Solution**: Use localhost mapping:

- Provider: `localhost:11000` instead of `provider`
- Consumer: `localhost:22000` instead of `consumer`

### Issue: "Contract negotiation stuck in REQUESTING"

**Cause**: Policy mismatch or connector communication issue

**Solution**:

1. Check provider logs: `docker logs local-demo-ce-provider-connector-1`
2. Verify policy definition exists on provider
3. Ensure DSP endpoint is reachable: `curl http://localhost:11000/api/v1/dsp`

### Issue: "No EDR available for transfer"

**Cause**: Transfer not yet started or using PUSH instead of PULL

**Solution**:

1. Check transfer state: GET `/v3/transferprocesses/{id}`
2. Wait for state to be `STARTED`
3. EDR only available for PULL transfers

### Issue: HTTP Push not delivering data

**Cause**: Webhook URL not accessible from provider

**Solution**:

1. Use public webhook (e.g., webhook.site)
2. Ensure URL is HTTPS
3. Check provider logs for connection errors

---

## Reference

### Complete E2E Script (HTTP Pull)

Save this as `edc-test-pull.sh`:

```bash
#!/bin/bash
set -e

# Configuration
export PROVIDER_API="http://localhost:11000/api/management"
export CONSUMER_API="http://localhost:22000/api/management"
export API_KEY="SomeOtherApiKey"

echo "=== EDC HTTP Pull Complete Test ==="

# Step 1: Request Catalog
echo "1. Requesting catalog..."
curl -s -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"@vocab": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "counterPartyId": "provider"
  }' > /tmp/catalog.json

OFFER_ID=$(jq -r '.dcat:dataset[] | select(."edc:id" == "weather-api-asset") | ."@id"' /tmp/catalog.json)
echo "✓ Offer ID: $OFFER_ID"

# Step 2: Initiate Contract Negotiation
echo "2. Initiating contract negotiation..."
NEGOTIATION_ID=$(curl -s -X POST "$CONSUMER_API/v3/contractnegotiations" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@context": "http://www.w3.org/ns/odrl.jsonld",
      "@type": "odrl:Offer",
      "@id": "'"$OFFER_ID"'",
      "odrl:permission": {"odrl:action": {"@id": "USE"}},
      "odrl:prohibition": [],
      "odrl:obligation": [],
      "odrl:assigner": {"@id": "provider"},
      "odrl:target": {"@id": "weather-api-asset"}
    }
  }' | jq -r '."@id"')

echo "✓ Negotiation ID: $NEGOTIATION_ID"

# Step 3: Wait for Negotiation
echo "3. Waiting for negotiation to finalize..."
sleep 2
AGREEMENT_ID=$(curl -s -X GET "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq -r '.contractAgreementId')

echo "✓ Agreement ID: $AGREEMENT_ID"

# Step 4: Initiate Transfer
echo "4. Initiating HTTP Pull transfer..."
TRANSFER_ID=$(curl -s -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "transferType": "HttpData-PULL",
    "dataDestination": {"type": "HttpData"}
  }' | jq -r '."@id"')

echo "✓ Transfer ID: $TRANSFER_ID"

# Step 5: Get EDR
echo "5. Retrieving EDR..."
sleep 2
AUTH_TOKEN=$(curl -s -X GET "$CONSUMER_API/v3/edrs/$TRANSFER_ID/dataaddress" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq -r '.authorization')

echo "✓ EDR Token received"

# Step 6: Fetch Data
echo "6. Fetching weather data..."
curl -s -X GET "http://localhost:11000/api/public" \
  -H "Authorization: $AUTH_TOKEN" | jq .

echo ""
echo "=== Test Complete! ==="
```

Make executable and run:

```bash
chmod +x edc-test-pull.sh
./edc-test-pull.sh
```

### Complete E2E Script (HTTP Push)

Save this as `edc-test-push.sh`:

```bash
#!/bin/bash
set -e

# Configuration
export PROVIDER_API="http://localhost:11000/api/management"
export CONSUMER_API="http://localhost:22000/api/management"
export API_KEY="SomeOtherApiKey"

echo "=== EDC HTTP Push Complete Test ==="

# Step 0: Create Webhook
echo "0. Creating webhook endpoint..."
WEBHOOK_ID=$(curl -s -X POST https://webhook.site/token -H "Content-Type: application/json" | jq -r '.uuid')
WEBHOOK_URL="https://webhook.site/$WEBHOOK_ID"
echo "✓ Webhook URL: $WEBHOOK_URL"
echo "  Visit in browser to see data arrive!"

# Step 1: Request Catalog
echo "1. Requesting catalog..."
curl -s -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"@vocab": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "counterPartyId": "provider"
  }' > /tmp/catalog.json

OFFER_ID=$(jq -r '.dcat:dataset[] | select(."edc:id" == "weather-api-asset") | ."@id"' /tmp/catalog.json)
echo "✓ Offer ID: $OFFER_ID"

# Step 2: Initiate Contract Negotiation
echo "2. Initiating contract negotiation..."
NEGOTIATION_ID=$(curl -s -X POST "$CONSUMER_API/v3/contractnegotiations" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@context": "http://www.w3.org/ns/odrl.jsonld",
      "@type": "odrl:Offer",
      "@id": "'"$OFFER_ID"'",
      "odrl:permission": {"odrl:action": {"@id": "USE"}},
      "odrl:prohibition": [],
      "odrl:obligation": [],
      "odrl:assigner": {"@id": "provider"},
      "odrl:target": {"@id": "weather-api-asset"}
    }
  }' | jq -r '."@id"')

echo "✓ Negotiation ID: $NEGOTIATION_ID"

# Step 3: Wait for Negotiation
echo "3. Waiting for negotiation to finalize..."
sleep 2
AGREEMENT_ID=$(curl -s -X GET "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq -r '.contractAgreementId')

echo "✓ Agreement ID: $AGREEMENT_ID"

# Step 4: Initiate PUSH Transfer
echo "4. Initiating HTTP Push transfer..."
TRANSFER_ID=$(curl -s -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "transferType": "HttpData-PUSH",
    "dataDestination": {
      "type": "HttpData",
      "baseUrl": "'"$WEBHOOK_URL"'"
    }
  }' | jq -r '."@id"')

echo "✓ Transfer ID: $TRANSFER_ID"

# Step 5: Wait and Check Webhook
echo "5. Waiting for data to be pushed..."
sleep 5

echo "6. Checking webhook for received data..."
curl -s "https://webhook.site/token/$WEBHOOK_ID/requests?sorting=newest" | \
  jq -r '.data[0].content' | jq .

echo ""
echo "=== Test Complete! ==="
echo "View all requests at: $WEBHOOK_URL"
```

Make executable and run:

```bash
chmod +x edc-test-push.sh
./edc-test-push.sh
```

### API Endpoints Quick Reference

| Purpose                     | Method | Endpoint                                   |
| --------------------------- | ------ | ------------------------------------------ |
| List Assets                 | POST   | `/v3/assets/request`                       |
| Get Asset                   | GET    | `/v3/assets/{id}`                          |
| Request Catalog             | POST   | `/v3/catalog/request`                      |
| Create Contract Negotiation | POST   | `/v3/contractnegotiations`                 |
| Get Negotiation State       | GET    | `/v3/contractnegotiations/{id}`            |
| Create Transfer             | POST   | `/v3/transferprocesses`                    |
| Get Transfer State          | GET    | `/v3/transferprocesses/{id}`               |
| Get EDR Data Address        | GET    | `/v3/edrs/{transferProcessId}/dataaddress` |

### JSON-LD Context Blocks

**Standard Context**:

```json
{
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

**ODRL Policy Context**:

```json
{
  "@context": "http://www.w3.org/ns/odrl.jsonld",
  "@type": "odrl:Offer"
}
```

---

## Summary

This guide demonstrated both **HTTP Pull** and **HTTP Push** data transfer workflows using the Eclipse EDC Management API v3. Key takeaways:

1. **JSON-LD formatting is critical** - Use objects with `@id` for assigner/target
2. **HTTP Pull gives consumer control** - Fetch data on-demand with EDR token
3. **HTTP Push is event-driven** - Provider delivers data to consumer's webhook
4. **Contract negotiation is instant** with unrestricted policies in local demo
5. **Both workflows successfully transferred real weather data** ✅

Next steps:

- Try with restricted policies (connector identity, usage constraints)
- Test with different asset types (files, databases, APIs)
- Implement error handling and retry logic
- Explore callback addresses for async notifications

---

**End of Guide**
