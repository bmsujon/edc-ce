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
