# EDC Testing Examples

This document provides curl commands for testing the complete EDC flow.

## Environment Setup

```bash
# Provider endpoints
export PROVIDER_API="http://localhost:11000/api/management"
export PROVIDER_KEY="SomeOtherApiKey"

# Consumer endpoints
export CONSUMER_API="http://localhost:22000/api/management"
export CONSUMER_KEY="SomeOtherApiKey"
```

---

## 1. Create Asset (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/assets" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "Asset",
    "@id": "test-asset-001",
    "properties": {
      "name": "Test Weather API",
      "description": "Weather data from open-meteo",
      "contenttype": "application/json",
      "version": "1.0"
    },
    "dataAddress": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true",
      "method": "GET"
    }
  }'
```

---

## 2. List Assets (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/assets/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "QuerySpec",
    "limit": 50
  }' | jq
```

---

## 3. Create Access Policy (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/policydefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "PolicyDefinitionDto",
    "@id": "access-policy-unrestricted",
    "policy": {
      "@type": "Policy",
      "odrl:permission": [{
        "odrl:action": "USE"
      }]
    }
  }'
```

---

## 4. Create Contract Policy (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/policydefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "PolicyDefinitionDto",
    "@id": "contract-policy-unrestricted",
    "policy": {
      "@type": "Policy",
      "odrl:permission": [{
        "odrl:action": "USE"
      }]
    }
  }'
```

---

## 5. List Policies (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/policydefinitions/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "QuerySpec",
    "limit": 50
  }' | jq
```

---

## 6. Create Contract Definition (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/contractdefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "ContractDefinition",
    "@id": "contract-def-001",
    "accessPolicyId": "access-policy-unrestricted",
    "contractPolicyId": "contract-policy-unrestricted",
    "assetsSelector": [{
      "@type": "Criterion",
      "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
      "operator": "=",
      "operandRight": "test-asset-001"
    }]
  }'
```

---

## 7. List Contract Definitions (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/contractdefinitions/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "QuerySpec",
    "limit": 50
  }' | jq
```

---

## 8. Request Catalog (Consumer)

```bash
curl -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "counterPartyId": "provider",
    "protocol": "dataspace-protocol-http",
    "querySpec": {
      "limit": 50
    }
  }' | jq '.'
```

**IMPORTANT**: Save the `@id` from `"odrl:hasPolicy"` - you'll need it for negotiation!

```bash
# Extract offer ID
export OFFER_ID=$(curl -s -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "counterPartyId": "provider",
    "protocol": "dataspace-protocol-http"
  }' | jq -r '."dcat:dataset"[0]."odrl:hasPolicy"."@id"')

echo "Offer ID: $OFFER_ID"
```

---

## 9. Negotiate Contract (Consumer)

```bash
curl -X POST "$CONSUMER_API/v3/contractnegotiations" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@type": "Offer",
      "@id": "'"$OFFER_ID"'",
      "assigner": "provider",
      "target": "test-asset-001"
    }
  }' | jq '.'
```

**Save the negotiation `@id`!**

```bash
# Save negotiation ID
export NEGOTIATION_ID="<paste-negotiation-id-here>"
```

---

## 10. Check Negotiation Status (Consumer)

```bash
curl -X GET "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" \
  -H "X-Api-Key: $CONSUMER_KEY" | jq '.'
```

**Wait for status to be `FINALIZED`**

Check every few seconds:

```bash
watch -n 2 "curl -s -H 'X-Api-Key: $CONSUMER_KEY' \
  $CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID | jq '.state'"
```

**Save the `contractAgreementId`:**

```bash
export AGREEMENT_ID=$(curl -s -H "X-Api-Key: $CONSUMER_KEY" \
  "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" | \
  jq -r '.contractAgreementId')

echo "Agreement ID: $AGREEMENT_ID"
```

---

## 11. Initiate Transfer - HTTP Push (Consumer)

### Option A: To Webhook.site

First, get a unique webhook URL from https://webhook.site/

```bash
export WEBHOOK_URL="https://webhook.site/<your-unique-id>"

curl -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "dataDestination": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "'"$WEBHOOK_URL"'",
      "method": "POST"
    },
    "transferType": "HttpData-PUSH"
  }' | jq '.'
```

### Option B: To Local Server

```bash
# Start a simple local server to receive data
python3 -c "
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        print('\\n=== Received Data ===')
        print(body.decode('utf-8'))
        print('====================\\n')
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')

print('Starting server on http://localhost:8888')
HTTPServer(('0.0.0.0', 8888), Handler).serve_forever()
" &

# Use localhost as data sink
curl -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "dataDestination": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "http://host.docker.internal:8888",
      "method": "POST"
    },
    "transferType": "HttpData-PUSH"
  }' | jq '.'
```

**Save the transfer process `@id`:**

```bash
export TRANSFER_ID="<paste-transfer-id-here>"
```

---

## 12. Monitor Transfer Status (Consumer)

```bash
curl -X GET "$CONSUMER_API/v3/transferprocesses/$TRANSFER_ID" \
  -H "X-Api-Key: $CONSUMER_KEY" | jq '.'
```

Watch it progress:

```bash
watch -n 2 "curl -s -H 'X-Api-Key: $CONSUMER_KEY' \
  $CONSUMER_API/v3/transferprocesses/$TRANSFER_ID | jq '.state'"
```

States: `STARTED` → `REQUESTED` → `IN_PROGRESS` → `COMPLETED`

---

## 13. List All Transfers (Consumer)

```bash
curl -X POST "$CONSUMER_API/v3/transferprocesses/request" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "QuerySpec",
    "limit": 50
  }' | jq '.'
```

---

## 14. Request EDR (HTTP Pull) (Consumer)

For pull-based data access:

```bash
curl -X POST "$CONSUMER_API/v2/edrs" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@type": "Offer",
      "@id": "'"$OFFER_ID"'",
      "assigner": "provider",
      "target": "test-asset-001"
    }
  }' | jq '.'
```

**Save the EDR ID:**

```bash
export EDR_ID="<paste-edr-id-here>"
```

---

## 15. Retrieve EDR Details (Consumer)

```bash
curl -X GET "$CONSUMER_API/v2/edrs/$EDR_ID" \
  -H "X-Api-Key: $CONSUMER_KEY" | jq '.'
```

Extract endpoint and token:

```bash
# Get endpoint
export EDR_ENDPOINT=$(curl -s -H "X-Api-Key: $CONSUMER_KEY" \
  "$CONSUMER_API/v2/edrs/$EDR_ID" | jq -r '.endpoint')

# Get authorization token
export EDR_TOKEN=$(curl -s -H "X-Api-Key: $CONSUMER_KEY" \
  "$CONSUMER_API/v2/edrs/$EDR_ID" | jq -r '.authCode')

echo "Endpoint: $EDR_ENDPOINT"
echo "Token: $EDR_TOKEN"
```

---

## 16. Fetch Data using EDR (Consumer)

```bash
curl -X GET "$EDR_ENDPOINT" \
  -H "Authorization: $EDR_TOKEN" | jq '.'
```

---

## 17. Terminate Contract (Consumer or Provider)

```bash
curl -X POST "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID/terminate" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "TerminateNegotiation",
    "reason": "Testing contract termination"
  }'
```

---

## 18. Health Checks

```bash
# Provider health
curl http://localhost:11000/api/check/health | jq '.'

# Consumer health
curl http://localhost:22000/api/check/health | jq '.'

# Provider liveness
curl http://localhost:11000/api/check/liveness

# Provider readiness
curl http://localhost:11000/api/check/readiness

# Provider startup
curl http://localhost:11000/api/check/startup
```

---

## Complete End-to-End Script

```bash
#!/bin/bash

# Setup
export PROVIDER_API="http://localhost:11000/api/management"
export PROVIDER_KEY="SomeOtherApiKey"
export CONSUMER_API="http://localhost:22000/api/management"
export CONSUMER_KEY="SomeOtherApiKey"

echo "1. Creating asset..."
curl -s -X POST "$PROVIDER_API/v3/assets" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "Asset",
    "@id": "e2e-test-asset",
    "properties": {"name": "E2E Test Asset"},
    "dataAddress": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true",
      "method": "GET"
    }
  }' | jq -r '.["@id"]'

echo "2. Creating policies..."
curl -s -X POST "$PROVIDER_API/v3/policydefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/", "odrl": "http://www.w3.org/ns/odrl/2/"},
    "@type": "PolicyDefinitionDto",
    "@id": "e2e-policy",
    "policy": {"@type": "Policy", "odrl:permission": [{"odrl:action": "USE"}]}
  }' > /dev/null

echo "3. Creating contract definition..."
curl -s -X POST "$PROVIDER_API/v3/contractdefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "ContractDefinition",
    "@id": "e2e-contract-def",
    "accessPolicyId": "e2e-policy",
    "contractPolicyId": "e2e-policy",
    "assetsSelector": [{
      "@type": "Criterion",
      "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
      "operator": "=",
      "operandRight": "e2e-test-asset"
    }]
  }' > /dev/null

echo "4. Requesting catalog..."
OFFER_ID=$(curl -s -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "counterPartyId": "provider",
    "protocol": "dataspace-protocol-http"
  }' | jq -r '."dcat:dataset"[0]."odrl:hasPolicy"."@id"')

echo "Offer ID: $OFFER_ID"

echo "5. Negotiating contract..."
NEGOTIATION_ID=$(curl -s -X POST "$CONSUMER_API/v3/contractnegotiations" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/", "odrl": "http://www.w3.org/ns/odrl/2/"},
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@type": "Offer",
      "@id": "'"$OFFER_ID"'",
      "assigner": "provider",
      "target": "e2e-test-asset"
    }
  }' | jq -r '.["@id"]')

echo "Negotiation ID: $NEGOTIATION_ID"

echo "6. Waiting for contract finalization..."
sleep 5

AGREEMENT_ID=$(curl -s -H "X-Api-Key: $CONSUMER_KEY" \
  "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" | \
  jq -r '.contractAgreementId')

echo "Agreement ID: $AGREEMENT_ID"

echo "7. Initiating transfer..."
TRANSFER_ID=$(curl -s -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "TransferRequest",
    "contractId": "'"$AGREEMENT_ID"'",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "dataDestination": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "https://webhook.site/unique-id",
      "method": "POST"
    },
    "transferType": "HttpData-PUSH"
  }' | jq -r '.["@id"]')

echo "Transfer ID: $TRANSFER_ID"

echo "8. Checking transfer status..."
sleep 3
curl -s -H "X-Api-Key: $CONSUMER_KEY" \
  "$CONSUMER_API/v3/transferprocesses/$TRANSFER_ID" | jq '.state'

echo "✅ End-to-end test complete!"
```

---

## Troubleshooting Commands

```bash
# List all assets
curl -s -X POST "$PROVIDER_API/v3/assets/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"@context":{"edc":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}' | jq '.'

# Delete asset
curl -X DELETE "$PROVIDER_API/v3/assets/test-asset-001" \
  -H "X-Api-Key: $PROVIDER_KEY"

# Delete policy
curl -X DELETE "$PROVIDER_API/v3/policydefinitions/access-policy-unrestricted" \
  -H "X-Api-Key: $PROVIDER_KEY"

# Delete contract definition
curl -X DELETE "$PROVIDER_API/v3/contractdefinitions/contract-def-001" \
  -H "X-Api-Key: $PROVIDER_KEY"
```

---

Save these commands to a file and use them for testing!
