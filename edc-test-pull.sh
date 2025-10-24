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
