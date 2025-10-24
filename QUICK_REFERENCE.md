# EDC Quick Reference Card

A one-page reference for the most common operations.

## 🚀 Quick Start

```bash
# 1. Start demo
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d

# 2. Verify it's running
curl http://localhost:11000/api/check/health

# 3. Open UIs
# Provider: http://localhost:11000
# Consumer: http://localhost:22000
```

## 🔑 Credentials

```bash
Management API Key: SomeOtherApiKey
Provider Participant ID: provider
Consumer Participant ID: consumer
```

## 📡 Essential API Endpoints

### Provider

```
UI:              http://localhost:11000
Management API:  http://localhost:11000/api/management
DSP Endpoint:    http://provider/api/v1/dsp
Health:          http://localhost:11000/api/check/health
```

### Consumer

```
UI:              http://localhost:22000
Management API:  http://localhost:22000/api/management
DSP Endpoint:    http://consumer/api/v1/dsp
Health:          http://localhost:22000/api/check/health
```

## 🔧 Environment Variables

```bash
export PROVIDER_API="http://localhost:11000/api/management"
export PROVIDER_KEY="SomeOtherApiKey"
export CONSUMER_API="http://localhost:22000/api/management"
export CONSUMER_KEY="SomeOtherApiKey"
```

## 📋 The 7-Step Flow

```
1. CREATE ASSET       (Provider)  → Data to share
2. CREATE POLICIES    (Provider)  → Access rules
3. PUBLISH OFFER      (Provider)  → Combine asset + policies
4. BROWSE CATALOG     (Consumer)  → Discover offers
5. NEGOTIATE CONTRACT (Consumer)  → Agree on terms
6. TRANSFER DATA      (Consumer)  → Move/access data
7. USE DATA           (Consumer)  → Consume data
```

## 🎯 Most Used Commands

### Create Asset

```bash
curl -X POST "$PROVIDER_API/v3/assets" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "Asset",
    "@id": "my-asset",
    "properties": {"name": "My Asset"},
    "dataAddress": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "https://api.example.com/data",
      "method": "GET"
    }
  }'
```

### Create Policy (Unrestricted)

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
    "@id": "unrestricted",
    "policy": {
      "odrl:permission": [{"odrl:action": "USE"}]
    }
  }'
```

### Create Contract Definition

```bash
curl -X POST "$PROVIDER_API/v3/contractdefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "ContractDefinition",
    "@id": "my-offer",
    "accessPolicyId": "unrestricted",
    "contractPolicyId": "unrestricted",
    "assetsSelector": [{
      "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
      "operator": "=",
      "operandRight": "my-asset"
    }]
  }'
```

### Request Catalog

```bash
curl -X POST "$CONSUMER_API/v3/catalog/request" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "CatalogRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "counterPartyId": "provider",
    "protocol": "dataspace-protocol-http"
  }'
```

### Negotiate Contract

```bash
# Get OFFER_ID from catalog response first!
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
      "@id": "OFFER_ID_HERE",
      "assigner": "provider",
      "target": "my-asset"
    }
  }'
```

### Check Negotiation Status

```bash
curl "$CONSUMER_API/v3/contractnegotiations/NEGOTIATION_ID" \
  -H "X-Api-Key: $CONSUMER_KEY"
```

### Initiate Transfer

```bash
# Get AGREEMENT_ID from negotiation response
curl -X POST "$CONSUMER_API/v3/transferprocesses" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"},
    "@type": "TransferRequest",
    "contractId": "AGREEMENT_ID_HERE",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "dataDestination": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "https://webhook.site/YOUR-ID"
    },
    "transferType": "HttpData-PUSH"
  }'
```

## 📊 Listing Resources

```bash
# List all assets
curl -X POST "$PROVIDER_API/v3/assets/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"@context":{"edc":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}'

# List all policies
curl -X POST "$PROVIDER_API/v3/policydefinitions/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"@context":{"edc":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}'

# List all contract definitions
curl -X POST "$PROVIDER_API/v3/contractdefinitions/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"@context":{"edc":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}'

# List all transfers
curl -X POST "$CONSUMER_API/v3/transferprocesses/request" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"@context":{"edc":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}'
```

## 🗑️ Deleting Resources

```bash
# Delete asset
curl -X DELETE "$PROVIDER_API/v3/assets/ASSET_ID" \
  -H "X-Api-Key: $PROVIDER_KEY"

# Delete policy
curl -X DELETE "$PROVIDER_API/v3/policydefinitions/POLICY_ID" \
  -H "X-Api-Key: $PROVIDER_KEY"

# Delete contract definition
curl -X DELETE "$PROVIDER_API/v3/contractdefinitions/CONTRACT_DEF_ID" \
  -H "X-Api-Key: $PROVIDER_KEY"
```

## 🐳 Docker Commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Clean everything (including volumes)
docker compose down -v

# Restart a service
docker compose restart provider-connector

# View service status
docker compose ps
```

## 🔍 Debugging

```bash
# Check connector health
curl http://localhost:11000/api/check/health

# View provider logs
docker compose logs -f provider-connector

# View consumer logs
docker compose logs -f consumer-connector

# Access database
docker compose exec provider-connector-db psql -U db-user -d db-name

# Query tables in database
SELECT * FROM edc_asset;
SELECT * FROM edc_contract_agreement;
SELECT * FROM edc_transfer_process;
```

## ⚡ Quick Test Data

### Test Asset (Public Weather API)

```json
{
  "@id": "weather-api",
  "properties": { "name": "Weather Data" },
  "dataAddress": {
    "type": "HttpData",
    "baseUrl": "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true",
    "method": "GET"
  }
}
```

### Test Sink (Webhook.site)

1. Go to https://webhook.site/
2. Copy your unique URL
3. Use as data sink in transfer request

## 📝 State Transitions

### Negotiation

```
REQUESTING → REQUESTED → AGREED → FINALIZED ✅
```

### Transfer

```
STARTED → REQUESTED → IN_PROGRESS → COMPLETED ✅
```

## 🎯 Common HTTP Status Codes

```
200 OK         - Request successful
201 Created    - Resource created
204 No Content - Deletion successful
400 Bad Request - Invalid input
401 Unauthorized - Wrong/missing API key
404 Not Found  - Resource doesn't exist
409 Conflict   - Resource already exists
500 Server Error - Internal error
```

## 💡 Tips & Tricks

1. **Use jq for JSON**

   ```bash
   curl ... | jq '.'
   ```

2. **Watch for status changes**

   ```bash
   watch -n 2 'curl -s -H "X-Api-Key: $KEY" $URL | jq .state'
   ```

3. **Extract specific fields**

   ```bash
   curl ... | jq -r '.["@id"]'
   ```

4. **Save response to variable**

   ```bash
   OFFER_ID=$(curl ... | jq -r '."dcat:dataset"[0]."odrl:hasPolicy"."@id"')
   ```

5. **Test with fake data first**
   - Use webhook.site for data sinks
   - Use public APIs for data sources
   - Test policies with unrestricted first

## 🔗 Useful Links

- Provider UI: http://localhost:11000
- Consumer UI: http://localhost:22000
- Webhook Site: https://webhook.site/
- API Docs: `/docs/api/eclipse-edc-management-api.yaml`
- Chat App Example: `/examples/chat-app/`

## 🆘 Quick Help

```bash
# Interactive menu
./quick-start.sh

# Full guide
cat LOCAL_SETUP_GUIDE.md

# API examples
cat API_TESTING_GUIDE.md

# Flow diagrams
cat FLOW_DIAGRAMS.md

# Stop everything
docker compose down -v
```

---

**Print this page for quick reference! 📄**
