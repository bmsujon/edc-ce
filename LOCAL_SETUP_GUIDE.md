# sovity EDC-CE: Complete Local Setup & Testing Guide

This guide will walk you through setting up the sovity EDC-CE locally and testing the complete data exchange flow including asset creation, policy definition, contract negotiation, and data transfer.

## 🎯 What You'll Learn

By the end of this guide, you'll understand:

- How to run two EDC connectors locally
- How to create and publish data assets
- How to define and apply policies
- How to negotiate contracts between connectors
- How to transfer data between parties
- How to use both the UI and Management API

---

## 📋 Prerequisites

### Required Software

- **Docker** (with Docker Compose)
- **Docker Hub login** to `ghcr.io`
- **curl** or **Postman** (for API testing)
- _Optional but recommended:_ **jq** (for JSON formatting)

### Login to GitHub Container Registry

```bash
docker login ghcr.io
# Username: your-github-username
# Password: your-github-personal-access-token (with packages:read scope)
```

---

## 🚀 Quick Start: Two-Connector Demo

### Step 1: Navigate to the Demo Directory

```bash
cd docs/deployment-guide/goals/local-demo-ce
```

### Step 2: Start the Services

```bash
docker compose up
```

This command will:

- Pull the sovity EDC-CE images (v16.1.0)
- Start two PostgreSQL databases
- Launch two EDC connectors (Provider & Consumer)
- Launch two web UIs
- Configure Caddy as reverse proxy

### Step 3: Verify Everything is Running

Wait 30-60 seconds for all services to start, then check:

```bash
# Check running containers
docker compose ps

# Check logs
docker compose logs -f provider-connector
docker compose logs -f consumer-connector
```

---

## 🌐 Access Points

### Provider Connector (Participant ID: `provider`)

| Service            | URL                                   | Credentials                      |
| ------------------ | ------------------------------------- | -------------------------------- |
| **Web UI**         | http://localhost:11000                | N/A                              |
| **Management API** | http://localhost:11000/api/management | API Key: `SomeOtherApiKey`       |
| **DSP Endpoint**   | http://provider/api/v1/dsp            | (Internal - Docker network)      |
| **Database**       | localhost:5432 (mapped internally)    | user: `db-user`, pass: `db-pass` |

### Consumer Connector (Participant ID: `consumer`)

| Service            | URL                                   | Credentials                      |
| ------------------ | ------------------------------------- | -------------------------------- |
| **Web UI**         | http://localhost:22000                | N/A                              |
| **Management API** | http://localhost:22000/api/management | API Key: `SomeOtherApiKey`       |
| **DSP Endpoint**   | http://consumer/api/v1/dsp            | (Internal - Docker network)      |
| **Database**       | localhost:5432 (mapped internally)    | user: `db-user`, pass: `db-pass` |

---

## 📚 Complete Flow Testing Guide

### Part 1: Provider Creates an Asset (via UI)

#### Step 1: Open Provider UI

Navigate to: http://localhost:11000

You'll see the **Dashboard** with connector details:

- Participant ID: `provider`
- Connector Endpoint: `http://provider/api/v1/dsp`

#### Step 2: Create an Asset

1. Click **"Assets"** in the left navigation
2. Click **"Create Asset"** button
3. Fill in the form:

**General Information:**

```
Asset ID: my-test-asset
Asset Title: Weather Data API
Asset Description: Real-time weather data from public API
Version: 1.0
Content Type: application/json
Language: en
Publisher: Weather Inc.
```

**Data Offer Type:**

- Select: **"Available (with data source)"**

**Data Source Configuration:**

```
Data Source Type: HttpData
Method: GET
Base URL: https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true
```

4. Click **"Create Asset"**

#### Step 3: Verify Asset Creation

- You should see your asset in the Assets list
- Note the Asset ID: `my-test-asset`

---

### Part 2: Provider Creates Policies (via UI)

#### Step 1: Create Access Policy

This policy controls who can **see** the data offer in the catalog.

1. Click **"Policies"** in the left navigation
2. Click **"Create Policy"** button
3. Fill in:

```
Policy ID: unrestricted-access-policy
Policy Type: Access Policy
```

4. Under **Policy Constraints**, select:

   - **Permission**: Allow
   - **Action**: USE
   - _Leave constraints empty for unrestricted access_

5. Click **"Create Policy"**

#### Step 2: Create Contract Policy

This policy controls who can **negotiate** a contract.

1. Click **"Create Policy"** again
2. Fill in:

```
Policy ID: unrestricted-contract-policy
Policy Type: Contract Policy
```

3. Same configuration as access policy (unrestricted)
4. Click **"Create Policy"**

> **Note**: For production, you'd add constraints like Business Partner Numbers (BPNs), time restrictions, or usage purposes.

---

### Part 3: Provider Publishes Data Offer (via UI)

#### Step 1: Create Contract Definition

1. Click **"Data Offers"** in the left navigation
2. Click **"Create Data Offer"** button
3. Fill in:

```
Data Offer ID: weather-data-offer
Description: Public weather data offering
```

4. **Select Policies:**

   - Access Policy: `unrestricted-access-policy`
   - Contract Policy: `unrestricted-contract-policy`

5. **Select Assets:**

   - Check: `my-test-asset` (Weather Data API)

6. Click **"Create Data Offer"**

#### Step 2: Verify Publication

- Your data offer is now published and visible to other connectors
- The catalog now includes this offer for authorized parties

---

### Part 4: Consumer Browses Catalog (via UI)

#### Step 1: Open Consumer UI

Navigate to: http://localhost:22000

#### Step 2: Access Catalog Browser

1. Click **"Catalog Browser"** in the left navigation
2. In the **"Connector Endpoint"** field, enter:
   ```
   http://provider/api/v1/dsp?participantId=provider
   ```
3. Click **"Fetch Catalog"**

#### Step 3: View Available Offers

- You should see the `weather-data-offer`
- Click on it to view details:
  - Asset: my-test-asset
  - Description
  - Policies
  - Data source information (if available)

---

### Part 5: Consumer Negotiates Contract (via UI)

#### Step 1: Initiate Contract Negotiation

While viewing the data offer details:

1. Click **"Negotiate Contract"** button
2. Confirm the negotiation details
3. Click **"Start Negotiation"**

#### Step 2: Monitor Negotiation Status

1. Click **"Contracts"** in the left navigation
2. Switch to **"Consuming"** tab
3. You should see the negotiation:
   - Status: `FINALIZED` (when successful)
   - Asset ID: `my-test-asset`
   - Provider: `provider`

> **Negotiation Flow**: REQUESTING → REQUESTED → AGREED → FINALIZED

---

### Part 6: Consumer Transfers Data (via UI)

#### Step 1: Initiate Data Transfer

1. In the **Contracts** page, click on your finalized contract
2. Click **"Transfer Data"** button
3. Choose transfer method:

**Option A: HTTP Data Push (to a sink)**

```
Transfer Type: HttpData-Push
Data Sink Type: HttpData
Method: POST
Base URL: https://webhook.site/<your-unique-url>
```

**Option B: HTTP Data Pull (get EDR)**

```
Transfer Type: HttpData-Pull
(No sink needed - you'll receive an EDR token)
```

4. Click **"Start Transfer"**

#### Step 2: Monitor Transfer

1. Click **"Transfer History"** in the left navigation
2. View transfer status:
   - `STARTED` → `REQUESTED` → `IN_PROGRESS` → `COMPLETED`

#### Step 3: View Transfer Results

**For HTTP Push:**

- Check your webhook.site URL to see the received data

**For HTTP Pull:**

1. Go to **"Contracts"** → Your contract → **"EDRs"** tab
2. You'll see an EDR with:
   - Endpoint URL
   - Authorization token
   - Expiry time

---

## 🔧 Testing via Management API

Now let's repeat the flow using the Management API (more developer-friendly for integrations).

### Setup Environment Variables

```bash
# Provider endpoints
export PROVIDER_API="http://localhost:11000/api/management"
export PROVIDER_KEY="SomeOtherApiKey"

# Consumer endpoints
export CONSUMER_API="http://localhost:22000/api/management"
export CONSUMER_KEY="SomeOtherApiKey"
```

---

### API Flow 1: Create Asset (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/assets" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "Asset",
    "@id": "api-asset-1",
    "properties": {
      "name": "API Weather Data",
      "description": "Weather API endpoint",
      "contenttype": "application/json"
    },
    "dataAddress": {
      "@type": "DataAddress",
      "type": "HttpData",
      "baseUrl": "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true",
      "method": "GET"
    }
  }' | jq
```

Expected response: `200 OK` with asset ID

---

### API Flow 2: Create Policies (Provider)

**Create Access Policy:**

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
    "@id": "access-policy-1",
    "policy": {
      "@type": "Policy",
      "odrl:permission": [{
        "odrl:action": "USE",
        "odrl:constraint": []
      }]
    }
  }' | jq
```

**Create Contract Policy:**

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
    "@id": "contract-policy-1",
    "policy": {
      "@type": "Policy",
      "odrl:permission": [{
        "odrl:action": "USE",
        "odrl:constraint": []
      }]
    }
  }' | jq
```

---

### API Flow 3: Create Contract Definition (Provider)

```bash
curl -X POST "$PROVIDER_API/v3/contractdefinitions" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "ContractDefinition",
    "@id": "contract-def-1",
    "accessPolicyId": "access-policy-1",
    "contractPolicyId": "contract-policy-1",
    "assetsSelector": [{
      "@type": "Criterion",
      "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
      "operator": "=",
      "operandRight": "api-asset-1"
    }]
  }' | jq
```

---

### API Flow 4: Request Catalog (Consumer)

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
    "protocol": "dataspace-protocol-http"
  }' | jq
```

Expected response: Catalog containing the offered dataset with policies

**Save the `@id` from the `odrl:hasPolicy` field** - you'll need this for negotiation!

---

### API Flow 5: Negotiate Contract (Consumer)

```bash
# Replace OFFER_ID with the policy @id from the catalog response
export OFFER_ID="<copy-from-catalog-response>"

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
      "target": "api-asset-1"
    }
  }' | jq
```

**Save the negotiation `@id` from the response!**

---

### API Flow 6: Check Negotiation Status (Consumer)

```bash
export NEGOTIATION_ID="<your-negotiation-id>"

curl -X GET "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID" \
  -H "X-Api-Key: $CONSUMER_KEY" | jq
```

Wait until `state` becomes `FINALIZED` and note the `contractAgreementId`.

---

### API Flow 7: Initiate Transfer (Consumer)

```bash
export AGREEMENT_ID="<your-contract-agreement-id>"

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
      "baseUrl": "https://webhook.site/<your-webhook-id>"
    },
    "transferType": "HttpData-PUSH"
  }' | jq
```

---

### API Flow 8: Monitor Transfer (Consumer)

```bash
export TRANSFER_ID="<your-transfer-process-id>"

curl -X GET "$CONSUMER_API/v3/transferprocesses/$TRANSFER_ID" \
  -H "X-Api-Key: $CONSUMER_KEY" | jq
```

Check the `state` field: `STARTED` → `REQUESTED` → `COMPLETED`

---

## 🧪 Advanced Testing Scenarios

### Scenario 1: HTTP Data Pull with EDR

Instead of pushing data, get an EDR token to pull data on-demand:

```bash
curl -X POST "$CONSUMER_API/v2/edrs" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "http://provider/api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
      "@type": "Offer",
      "@id": "'"$OFFER_ID"'",
      "assigner": "provider",
      "target": "api-asset-1"
    }
  }' | jq
```

Then retrieve EDR details and use the endpoint + token to fetch data.

---

### Scenario 2: Testing with Policies (BPN Constraint)

Create a policy that only allows specific Business Partners:

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
    "@id": "restricted-policy",
    "policy": {
      "@type": "Policy",
      "odrl:permission": [{
        "odrl:action": "USE",
        "odrl:constraint": [{
          "odrl:leftOperand": "BusinessPartnerNumber",
          "odrl:operator": "EQ",
          "odrl:rightOperand": "BPNL000000000001"
        }]
      }]
    }
  }' | jq
```

---

### Scenario 3: Contract Termination

Terminate an active contract:

```bash
curl -X POST "$CONSUMER_API/v3/contractnegotiations/$NEGOTIATION_ID/terminate" \
  -H "X-Api-Key: $CONSUMER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "@context": {
      "edc": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "TerminateNegotiation",
    "reason": "Data no longer needed"
  }' | jq
```

---

## 📊 Monitoring & Debugging

### View Connector Logs

```bash
# Provider logs
docker compose logs -f provider-connector

# Consumer logs
docker compose logs -f consumer-connector

# All logs
docker compose logs -f
```

### Check Database State

```bash
# Access provider database
docker compose exec provider-connector-db psql -U db-user -d db-name

# List tables
\dt

# Query assets
SELECT * FROM edc_asset;

# Query contract agreements
SELECT * FROM edc_contract_agreement;

# Query transfer processes
SELECT * FROM edc_transfer_process;

# Exit
\q
```

### Health Check Endpoint

```bash
# Check provider health
curl http://localhost:11000/api/check/health

# Check consumer health
curl http://localhost:22000/api/check/health
```

---

## 🎓 Next Steps: Chat App Tutorial

For a complete real-world example, try the Chat App:

```bash
cd ../../examples/chat-app/source-final
./start.sh
```

Then open:

- Provider Chat App: http://localhost:13000
- Consumer Chat App: http://localhost:23000

This demonstrates:

- Auto-setup of EDC resources
- HttpData-PULL with EDR tokens
- Notification callbacks
- Real-time messaging between connectors

---

## 🧹 Cleanup

### Stop Services

```bash
docker compose down
```

### Remove Volumes (clears database)

```bash
docker compose down -v
```

### Full Cleanup

```bash
docker compose down -v --rmi all
```

---

## 🔍 Troubleshooting

### Issue: "Cannot connect to connector"

- Check if all services are running: `docker compose ps`
- Check logs for errors: `docker compose logs`
- Verify database health: Should show `healthy` status

### Issue: "Catalog request returns empty"

- Ensure you're using the correct participant ID in the URL
- Check that the contract definition is properly created
- Verify access policy allows the consumer

### Issue: "Contract negotiation fails"

- Check that contract policy constraints are met
- Verify the offer ID is correct (from catalog response)
- Check provider logs for detailed error messages

### Issue: "Transfer fails"

- Verify the data sink is reachable
- Check if the data source URL is accessible
- Ensure contract agreement is FINALIZED before transfer

---

## 📚 Additional Resources

- **API Documentation**: `/docs/api/eclipse-edc-management-api.yaml`
- **Postman Collection**: `/docs/api/postman_collection.json`
- **Frontend Walkthrough**: `/docs/Frontend/walkthrough-guide.md`
- **Deployment Guide**: `/docs/deployment-guide/README.md`
- **FAQ**: `/docs/faq.md`

---

## 💡 Key Concepts Summary

| Concept                  | Description                                                          |
| ------------------------ | -------------------------------------------------------------------- |
| **Asset**                | The data resource you want to share                                  |
| **Policy**               | Rules controlling access (access policy) and usage (contract policy) |
| **Contract Definition**  | Combines assets + policies = Data Offer                              |
| **Catalog**              | Browsable list of data offers from a provider                        |
| **Contract Negotiation** | Agreement process between consumer and provider                      |
| **Contract Agreement**   | Finalized contract allowing data transfer                            |
| **EDR**                  | Endpoint Data Reference - token for pull-based data access           |
| **Transfer Process**     | Actual data movement between systems                                 |

---

## 🎯 Success Checklist

- [ ] Two connectors running and accessible via UI
- [ ] Created an asset on the provider side
- [ ] Created access and contract policies
- [ ] Published a contract definition (data offer)
- [ ] Browsed catalog from consumer side
- [ ] Successfully negotiated a contract
- [ ] Completed a data transfer (push or pull)
- [ ] Retrieved and used an EDR token (pull scenario)
- [ ] Tested via both UI and Management API
- [ ] Reviewed logs and database state

---

**Happy Data Sharing! 🚀**

For questions or issues, check the [GitHub Discussions](https://github.com/sovity/edc-ce/discussions) or open an issue.
