# 🎨 EDC Frontend UI Testing Guide

## Complete Provider & Consumer Testing via Web Interface

This guide focuses exclusively on testing EDC data exchange flows using the **Web UI** (frontend). No API knowledge required!

---

## 🎯 Overview

The sovity EDC-CE provides a full-featured **Next.js web interface** that allows you to:

- ✅ Create and manage data assets
- ✅ Define access and contract policies
- ✅ Publish data offers to the dataspace
- ✅ Browse catalogs from other connectors
- ✅ Negotiate and manage contracts
- ✅ Initiate and monitor data transfers
- ✅ View dashboards and analytics

**No coding required** - everything can be done through the browser!

---

## ✅ Prerequisites Checklist

Before you begin, ensure you have:

### **System Requirements:**

- ✅ **Docker Desktop 20.10+** (Mac/Windows) or **Docker Engine** (Linux)
- ✅ **8 GB RAM minimum** (16 GB recommended for smooth operation)
- ✅ **10 GB free disk space** (for Docker images and containers)
- ✅ **Internet connection** (for pulling Docker images)

### **Network Requirements:**

- ✅ **Ports 11000, 22000 must be available** (not used by other services)
- ✅ **Firewall allows Docker networking**

### **Browser Requirements:**

- ✅ **Modern browser**: Chrome 90+, Firefox 88+, Safari 14+, or Edge 90+
- ✅ **JavaScript enabled**
- ✅ **Cookies enabled**

### **Optional but Helpful:**

- ⭕ **Webhook.site account** (free - for testing HTTP Push transfers)
- ⭕ **Postman or curl** (for testing EDR tokens manually)
- ⭕ **Text editor** (for viewing JSON responses)

### **Quick Verification:**

Run these commands to verify your system is ready:

```bash
# 1. Check Docker is installed and running
docker --version
# Expected: Docker version 20.10.0 or higher

docker compose version
# Expected: Docker Compose version v2.0.0 or higher

# 2. Verify ports are available (should return nothing if free)
lsof -i :11000
lsof -i :22000

# 3. Check available disk space
df -h | grep -E 'Filesystem|/$'
# Should show at least 10GB free
```

**✅ If all checks pass, you're ready to proceed!**

**❌ If any check fails:**

- Docker not installed? → Visit https://docs.docker.com/get-docker/
- Ports in use? → Stop the service using that port or use different ports
- Not enough disk space? → Free up space or use external drive

---

## 🚀 Quick Setup

### 1. Start the Local Demo

```bash
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d
```

### 2. Wait for Services to Start

Wait 60 seconds for all services to initialize.

### 3. Access the UIs

Open two browser tabs:

- **Provider Connector**: http://localhost:11000
- **Consumer Connector**: http://localhost:22000

---

## 🏢 Two Perspectives: Provider & Consumer

In a dataspace, there are **two roles**:

### 📤 **Provider** (Data Source)

- **Who**: Organization sharing data
- **UI**: http://localhost:11000
- **Responsibilities**:
  - Create data assets
  - Define policies (who can access, under what conditions)
  - Publish data offers
  - Monitor incoming requests
  - Approve/deny access

### 📥 **Consumer** (Data Requestor)

- **Who**: Organization requesting data
- **UI**: http://localhost:22000
- **Responsibilities**:
  - Browse available data offers
  - Negotiate contracts
  - Initiate data transfers
  - Monitor transfer status
  - Consume received data

---

## � First Time Opening the UI

If this is your first time using an EDC connector interface, here's what to expect:

### **When you open http://localhost:11000 (Provider), you'll see:**

**🎨 Layout:**

- **Top Navigation Bar**: Shows your connector name and participant ID
- **Left Sidebar**: Main navigation menu (where you'll spend most of your time)
- **Center Area**: Main content area showing dashboard or selected page
- **Bottom Status Bar**: Connection status and system health indicators

**📋 Menu Overview (Provider - localhost:11000):**

| Menu Item            | Icon | What It Does                   | When to Use                                      |
| -------------------- | ---- | ------------------------------ | ------------------------------------------------ |
| **Dashboard**        | 🏠   | Overview and statistics        | First landing page, check system status          |
| **Assets**           | 📦   | Your data offerings            | Create and manage data you want to share         |
| **Policies**         | 📜   | Access rules and constraints   | Define who can access your data and how          |
| **Data Offers**      | 🎯   | Published contract definitions | Combine assets + policies into offers            |
| **Contracts**        | 📋   | Active agreements              | View negotiated contracts with consumers         |
| **Transfer History** | 📊   | Data transfer logs             | Monitor data delivery status                     |
| **Settings**         | ⚙️   | Configuration                  | Advanced settings (usually don't need to change) |

**📋 Menu Overview (Consumer - localhost:22000):**

| Menu Item            | What It Does                                 | When to Use                             |
| -------------------- | -------------------------------------------- | --------------------------------------- |
| **Dashboard**        | Overview and statistics                      | First landing page                      |
| **Catalog Browser**  | Search for data from other connectors        | Find data you want to consume           |
| **Contracts**        | Your agreements (tabs: Consuming, Providing) | View contracts you've negotiated        |
| **Transfer History** | Your data transfers                          | Check transfer status and results       |
| **Assets**           | Your data offerings                          | (Yes, consumers can also be providers!) |

### **💡 First-Time Tips:**

1. **Start with Dashboard** - Get familiar with the layout, no risk of breaking anything
2. **Left-to-Right Flow** - Provider workflow follows the menu order: Assets → Policies → Data Offers
3. **Two Browser Windows** - Keep both provider (11000) and consumer (22000) open side-by-side
4. **Wait for Actions** - After creating/updating, give the UI 1-2 seconds to refresh
5. **Look for Notifications** - Success/error messages appear in the top-right corner
6. **Green = Good** - Status badges in green mean active/successful

### **🎯 What You'll Do:**

**As Provider (localhost:11000):**

1. Create an asset (Part 2)
2. Create a policy (Part 3)
3. Create a contract definition (Part 4)
4. Wait for consumer to discover your offer

**As Consumer (localhost:22000):**

1. Browse the catalog (Part 5)
2. Negotiate a contract (Part 7)
3. Initiate a data transfer (Part 9)
4. Verify data received (Part 10)

**Total Time: ~60 minutes for first time** (subsequent runs: ~15 minutes)

---

## �🎬 Complete Flow: Provider Side

### Part 1: Provider Dashboard

1. Open **Provider UI**: http://localhost:11000
2. You'll see the **Dashboard** with:
   - Connector status
   - Participant ID: `provider`
   - DSP Endpoint
   - Environment info
   - Quick stats (assets, policies, contracts)

![Dashboard](/docs/images/provider-dashboard-1.png)

---

### Part 2: Create Data Asset (Provider)

**Navigation**: Left sidebar → **"Assets"** → Click **"Create Asset"** button

#### Fill in Asset Details:

**Basic Information:**

- **Asset ID**: `weather-api-asset` (must be unique)
- **Asset Name**: `Weather API Data`
- **Description**: `Real-time weather data from Open-Meteo API`
- **Version**: `1.0`
- **Content Type**: `application/json`
- **Language**: `en`
- **Publisher**: `Open-Meteo`
- **License**: `CC-BY-SA-4.0`

**Data Source Configuration:**

- **Offer Type**: Select `Available (with data source)`
- **Data Source Type**: `HTTP Data` (from dropdown)
- **Base URL**: `https://api.open-meteo.com/v1/forecast`
- **Method**: `GET`
- **Query Params** (optional):
  ```
  latitude=52.52
  longitude=13.41
  current_weather=true
  ```

**Private Properties** (optional):

- Add custom metadata that won't be shared in catalog
- Example: `internal-id` = `WX-001`

Click **"Create Asset"** button.

---

#### ✅ **Success Indicators:**

**What Success Looks Like:**

- 🟢 **Green notification** appears in top-right: "Asset created successfully"
- 🟢 **Automatic redirect** to Assets list page
- 🟢 **Your new asset appears** in the table with asset ID `weather-api-asset`
- 🟢 **Status badge shows "Active"** (green badge)
- 🟢 **Asset details are saved** - click on asset to verify all fields

**How to Verify:**

1. Go to **Assets** menu (left sidebar)
2. Look for your asset ID in the list
3. Click on the asset row to view details
4. Verify all fields match what you entered

#### ❌ **Common Issues & Solutions:**

| Problem                                 | Likely Cause          | Solution                                         |
| --------------------------------------- | --------------------- | ------------------------------------------------ |
| ❌ Red error: "Asset ID already exists" | ID is not unique      | Choose a different ID (add -v2, timestamp, etc.) |
| ❌ Red error: "Invalid URL format"      | Base URL is malformed | Ensure URL starts with http:// or https://       |
| ❌ Red error: "Required field missing"  | Mandatory field empty | Check Asset ID and Name are filled               |
| ❌ No redirect after clicking Create    | Browser/network issue | Check browser console (F12), refresh page        |
| ❌ Asset not visible in list            | Page not refreshed    | Manually refresh the Assets page                 |

**Troubleshooting Steps:**

```bash
# Check provider connector is running
docker compose ps | grep provider-connector
# Should show "running (healthy)"

# View provider logs if errors occur
docker compose logs provider-connector --tail=50
```

---

**✅ Result**: Asset created and appears in Assets list!

![Create Asset](/docs/images/provider-asset-create-1.png)

---

### Part 3: Create Access Policy (Provider)

**Navigation**: Left sidebar → **"Policies"** → Click **"Create Policy"** button

#### Option A: Unrestricted Policy (for testing)

- **Policy ID**: `allow-all-policy`
- **Policy Type**: Leave as default (no constraints)
- **Expression**: Don't add any constraints

Click **"Create Policy"**.

#### Option B: Restricted Policy (BPN-based)

- **Policy ID**: `bpn-restricted-policy`
- **Policy Type**: `Business Partner Number`
- **Constraint**:
  - **Left Operand**: `BusinessPartnerNumber`
  - **Operator**: `eq` (equals)
  - **Right Operand**: `BPNL000000000001`

Click **"Create Policy"**.

#### Option C: Time-Limited Policy

- **Policy ID**: `time-limited-policy`
- **Policy Type**: `Temporal`
- **Constraint**:
  - **Left Operand**: `validUntil`
  - **Operator**: `lt` (less than)
  - **Right Operand**: `2025-12-31T23:59:59Z`

Click **"Create Policy"**.

---

#### ✅ **Success Indicators:**

**What Success Looks Like:**

- 🟢 **Green notification**: "Policy created successfully"
- 🟢 **Redirect to Policies list** page
- 🟢 **Your policy appears** with the ID you specified
- 🟢 **Policy type shown** in the list (e.g., "Unrestricted", "BPN", "Temporal")

**How to Verify:**

1. Navigate to **Policies** menu
2. Find your policy ID in the list
3. Click to view details and verify constraints

#### ❌ **Common Issues & Solutions:**

| Problem                            | Likely Cause                | Solution                                                |
| ---------------------------------- | --------------------------- | ------------------------------------------------------- |
| ❌ "Policy ID already exists"      | Duplicate ID                | Use a different, unique policy ID                       |
| ❌ "Invalid constraint expression" | Malformed constraint syntax | Check operator and operand values match expected format |
| ❌ "Invalid date format"           | Wrong temporal format       | Use ISO 8601: `YYYY-MM-DDTHH:MM:SSZ`                    |
| ❌ Policy created but not usable   | Constraint logic error      | Review constraint - e.g., past date in validUntil       |

**💡 Policy Testing Tip:**

- Start with **unrestricted policy** (no constraints) for initial testing
- Add constraints gradually once basic flow works
- BPN constraints require exact match - typos will block access

---

✅ **Result**: Policy created and appears in Policies list!

![Create Policy](/docs/images/provider-policy-create-1.png)

---

### Part 4: Create Contract Definition (Publish Data Offer)

**Navigation**: Left sidebar → **"Data Offers"** → Click **"Create Data Offer"** button

#### Fill in Contract Definition:

**Basic Info:**

- **Data Offer ID**: `weather-data-offer-1` (must be unique)
- **Access Policy**: Select `allow-all-policy` (from dropdown)
- **Contract Policy**: Select `allow-all-policy` (from dropdown)

**Assets Selection:**

- Check the box next to `weather-api-asset` (or your asset)
- You can select multiple assets for one offer

**Policy Difference**:

- **Access Policy**: Controls WHO can SEE the offer in the catalog
- **Contract Policy**: Controls WHEN a contract can be NEGOTIATED

Click **"Create Data Offer"** button.

---

#### ✅ **Success Indicators:**

**What Success Looks Like:**

- 🟢 **Green notification**: "Data offer created successfully"
- 🟢 **Redirect to Data Offers list**
- 🟢 **Your offer appears** with offer ID `weather-data-offer-1`
- 🟢 **Asset count shown** (e.g., "1 asset" or "3 assets")
- 🟢 **Policies listed** in the offer details
- 🟢 **Offer is now discoverable** by consumers in catalog

**How to Verify:**

1. Go to **Data Offers** menu
2. Find your offer in the list
3. Click to view details - should show:
   - Selected assets
   - Access policy
   - Contract policy
   - Publication status

**Test Visibility (Optional):**

- Switch to Consumer UI (localhost:22000)
- Browse catalog with provider's DSP endpoint
- Your offer should appear in results

#### ❌ **Common Issues & Solutions:**

| Problem                             | Likely Cause                  | Solution                                 |
| ----------------------------------- | ----------------------------- | ---------------------------------------- |
| ❌ "Offer ID already exists"        | Duplicate ID                  | Use unique offer ID                      |
| ❌ "Policy not found"               | Selected policy was deleted   | Re-create the policy first               |
| ❌ "No assets selected"             | Forgot to check asset boxes   | Select at least one asset                |
| ❌ Offer created but not in catalog | Access policy too restrictive | Check access policy constraints          |
| ❌ "Invalid policy reference"       | Policy doesn't exist          | Verify policy ID exists in Policies list |

**💡 Contract Definition Tips:**

- **Access Policy = Catalog Visibility**: Restrictive access policy means fewer consumers can see your offer
- **Contract Policy = Negotiation Rules**: Restrictive contract policy means negotiation might fail even if offer is visible
- **For testing**: Use `allow-all-policy` for both to avoid policy-related issues
- **Multiple Assets**: One offer can bundle multiple related assets

---

✅ **Result**: Data offer published to the dataspace!

![Create Data Offer](/docs/images/provider-contractdefinition-dataoffer-create-1.png)

---

## 🛒 Complete Flow: Consumer Side

### Part 5: Browse Catalog (Consumer)

1. Open **Consumer UI**: http://localhost:22000
2. Navigate to **"Catalog Browser"** (left sidebar)

#### Request Catalog from Provider:

- **Counterparty Connector URL**: `http://provider/api/v1/dsp`
- **Participant ID**: `provider`

Click **"Fetch Catalog"** button.

---

#### ✅ **Success Indicators:**

**What Success Looks Like:**

- 🟢 **Catalog fetched successfully** message appears
- 🟢 **Data offer cards displayed** (at least one if provider has published offers)
- 🟢 **Each card shows**:
  - Data Offer ID (e.g., `weather-data-offer-1`)
  - Asset name(s)
  - Publisher information
  - Brief description
- 🟢 **Cards are clickable** - hovering shows interaction

**How to Verify:**

1. You should see at least one offer card (the one we created in Part 4)
2. Card should show "Weather API Data" or your asset name
3. Click on card to view full details

#### ❌ **Common Issues & Solutions:**

| Problem                    | Likely Cause                                       | Solution                                                                       |
| -------------------------- | -------------------------------------------------- | ------------------------------------------------------------------------------ |
| ❌ "No offers found"       | Provider has no offers OR access policy blocks you | Check provider has created offer (Part 4). Check access policy allows consumer |
| ❌ "Connection failed"     | DSP URL wrong or provider down                     | Verify `http://provider/api/v1/dsp` URL. Check: `docker compose ps`            |
| ❌ "Participant not found" | Wrong participant ID                               | Use `provider` (case-sensitive)                                                |
| ❌ Catalog loads but empty | Access policy too restrictive                      | Provider: check access policy constraints                                      |
| ❌ Timeout error           | Provider connector slow/restarting                 | Wait 30 seconds, try again                                                     |

**Troubleshooting Steps:**

```bash
# 1. Verify provider connector is running
docker compose ps provider-connector
# Should show "running (healthy)"

# 2. Check DSP endpoint is accessible from consumer
docker compose exec consumer-connector curl -s http://provider/api/v1/dsp
# Should return JSON (not error)

# 3. View provider logs for incoming requests
docker compose logs provider-connector --tail=30 | grep -i catalog
```

**💡 Catalog Tips:**

- **Empty catalog ≠ Error**: Provider might have offers with restrictive access policies
- **Multiple offers**: If provider has multiple offers, all matching access policy will show
- **Refresh**: Catalog is fetched fresh each time (not cached)

---

#### What You'll See:

- List of data offers that passed the access policy check
- Each card shows:
  - Data Offer ID
  - Asset names included
  - Publisher info
  - Description
  - Policies applied

Click on a **data offer card** to see details.

![Catalog Browser](/docs/images/consumer-catalog-browser-1.png)

---

### 💡 Important: Understanding Docker Network URLs

**For Catalog Browsing:**

- Use Docker internal URLs: `http://provider/api/v1/dsp`
- This works because both connectors are in the same Docker network

**For Data Access (EDR Tokens):**

- EDR returns internal URL: `http://provider/api/public`
- You must use localhost mapping: `http://localhost:11000/api/public`
- This is because your browser/curl runs on the host machine, not in Docker

**Quick Reference:**

- Provider connector UI: `http://localhost:11000`
- Provider DSP endpoint: `http://provider/api/v1/dsp` (for catalog)
- Provider data endpoint: `http://localhost:11000/api/public` (for EDR access)

The UI handles this automatically when using "View EDR" - just remember this when exporting tokens!

---

### Part 6: View Offer Details (Consumer)

On the **Data Offer Detail Page**, you'll see:

**Offer Information:**

- Contract Offer ID
- Provider Participant ID
- Asset details
- Access Policy constraints
- Contract Policy constraints

**Available Actions:**

- **"Negotiate Contract"** button

Click **"Negotiate Contract"** to start negotiation.

---

### Part 7: Contract Negotiation (Consumer)

After clicking "Negotiate Contract":

1. **Negotiation Started**: System sends contract request to provider
2. **Status Updates**: Watch the negotiation status
   - `REQUESTING` → `REQUESTED` → `AGREED` → `FINALIZED`
3. **Auto-Navigation**: Once finalized, you're taken to the **Contracts** page

**⏱️ Wait Time**: Typically 5-10 seconds for negotiation to complete.

---

#### ✅ **Success Indicators:**

**What Success Looks Like:**

- 🟢 **Negotiation initiated** message appears
- 🟢 **Status progresses** through states:
  - `REQUESTING` (0-2 seconds)
  - `REQUESTED` (2-5 seconds)
  - `AGREED` (5-8 seconds)
  - `FINALIZED` (8-10 seconds)
- 🟢 **Automatic redirect** to Contracts page
- 🟢 **New contract appears** in "Consuming Contracts" tab
- 🟢 **"Transfer Data" button** is now available

**How to Verify:**

1. After redirect, check **Contracts** → **Consuming Contracts** tab
2. Your contract should appear with:
   - Contract Agreement ID (long alphanumeric string)
   - Counterparty: `provider`
   - Asset: `weather-api-asset`
   - Status: Active

#### ❌ **Common Issues & Solutions:**

| Problem                             | Likely Cause                              | Solution                                                                   |
| ----------------------------------- | ----------------------------------------- | -------------------------------------------------------------------------- |
| ❌ Stuck in "REQUESTING" >30 sec    | Provider connector down or slow           | Check: `docker compose ps provider-connector`                              |
| ❌ Status: "FAILED" or "TERMINATED" | Contract policy constraints not satisfied | Check provider's contract policy. Your consumer attributes might not match |
| ❌ "Policy violation" error         | BPN mismatch, time constraint, etc.       | Provider: Review policy constraints. Consumer: Check your participant ID   |
| ❌ No redirect after FINALIZED      | UI refresh issue                          | Manually navigate to Contracts page                                        |
| ❌ Contract not visible in list     | Wrong tab selected                        | Check "Consuming Contracts" tab, not "Providing"                           |

**Troubleshooting Steps:**

```bash
# 1. Check provider connector is responsive
docker compose ps | grep provider-connector
# Should show "running (healthy)"

# 2. View provider logs for negotiation activity
docker compose logs provider-connector --tail=50 | grep -i negotiation

# 3. View consumer logs for negotiation errors
docker compose logs consumer-connector --tail=50 | grep -i "negotiation\|contract"

# 4. If stuck, check both connectors' health
curl -s http://localhost:11002/api/check/liveness  # Provider
curl -s http://localhost:22002/api/check/liveness  # Consumer
```

**Policy Constraint Troubleshooting:**

If negotiation fails with policy error:

1. **BPN Policy**: Ensure consumer's participant ID matches provider's allowed BPN list
2. **Temporal Policy**: Check current time is within policy's valid time window
3. **Custom Constraints**: Verify consumer has required attributes

**Recovery Steps:**

1. Go back to Catalog Browser
2. Try negotiating a different offer (with unrestricted policy)
3. Or ask provider to adjust policy constraints

**💡 Negotiation Tips:**

- **Be patient**: First negotiation can take up to 15 seconds
- **One offer, multiple contracts**: You can negotiate the same offer multiple times
- **Failed negotiations auto-cleanup**: No manual deletion needed (24h retention)

---

### Part 8: View Active Contracts (Consumer)

**Navigation**: Left sidebar → **"Contracts"**

#### Tabs Available:

1. **Consuming Contracts**: Contracts where YOU are consuming data
2. **Providing Contracts**: Contracts where YOU are providing data
3. **Active Contracts**: Currently valid contracts
4. **Terminated Contracts**: Expired or canceled contracts

#### Contract Card Shows:

- Contract Agreement ID
- Counterparty
- Asset information
- Signing date
- Policy constraints
- Transfer count
- **"Transfer Data"** button

Click on a contract to see full details.

![Contracts Overview](/docs/images/consumer-contracts-overview-1.png)

---

### Part 9: Initiate Data Transfer (Consumer)

On the **Contract Detail Page**, click **"Transfer Data"** button.

#### Choose Transfer Type:

**Option A: HTTP Push** (Provider sends to you)

- **Transfer Type**: `HTTP Push`
- **Data Sink URL**: Your webhook endpoint
  - Example: `https://webhook.site/unique-id`
  - Or your local endpoint: `http://consumer-backend/data-receiver`
- **Method**: `POST`
- **Content Type**: `application/json`

**Option B: HTTP Pull** (You fetch from provider)

- **Transfer Type**: `HTTP Pull`
- **No sink URL needed**
- You'll receive an **EDR token** to fetch data

Click **"Start Transfer"** button.

---

#### ✅ **Success Indicators:**

**What Success Looks Like:**

- 🟢 **"Transfer initiated" message** appears
- 🟢 **Automatic redirect** to Transfer History page
- 🟢 **New transfer entry** appears at top of list
- 🟢 **Transfer ID generated** (long alphanumeric string)
- 🟢 **Initial state**: `REQUESTING` or `REQUESTED`

**How to Verify:**

1. After clicking "Start Transfer", you should be on Transfer History page
2. Look for most recent transfer entry
3. Note the Transfer Process ID for tracking

#### ❌ **Common Issues & Solutions:**

| Problem                           | Likely Cause                     | Solution                                              |
| --------------------------------- | -------------------------------- | ----------------------------------------------------- |
| ❌ "Invalid sink URL" (HTTP Push) | Malformed webhook URL            | Ensure URL starts with http:// or https://, no spaces |
| ❌ "Contract not found"           | Contract expired/terminated      | Check contract is in Active Contracts tab             |
| ❌ "Transfer failed immediately"  | Provider data source unreachable | Provider: Check asset's data source URL is accessible |
| ❌ No transfer appears in history | UI not refreshed                 | Manually refresh Transfer History page                |
| ❌ "Method not allowed" error     | Wrong HTTP method for Push       | Use POST for most webhooks                            |

**💡 Transfer Type Guide:**

**HTTP Push** - Use when:

- ✅ You have a webhook endpoint ready (webhook.site, your server)
- ✅ You want provider to deliver data to you
- ✅ One-time data push is sufficient
- ❌ Don't use if: Your endpoint isn't publicly accessible

**HTTP Pull** - Use when:

- ✅ You want to fetch data on-demand (multiple times)
- ✅ You don't have a public webhook endpoint
- ✅ You want control over when to fetch
- ❌ Don't use if: Token might expire before you use it

---

### Part 10: Monitor Transfer Status (Consumer)

**Navigation**: Left sidebar → **"Transfer History"**

#### Transfer States:

```
REQUESTING → REQUESTED → STARTED → COMPLETED
```

Or if error:

```
REQUESTING → REQUESTED → STARTED → FAILED
```

#### Transfer Card Shows:

- Transfer Process ID
- State (with color indicator)
- Asset name
- Counterparty
- Transfer type
- Initiated timestamp
- Error details (if failed)

**For HTTP Pull Transfers:**

- Click **"View EDR"** to get the access token
- Use the token to call the provider's data endpoint

**Using the EDR Token:**

The EDR response provides two key pieces:

- **endpoint**: Docker internal URL (e.g., `http://provider/api/public`)
- **authorization**: Bearer token (JWT)

**⚠️ Important: URL Mapping**

The EDR endpoint uses Docker internal hostnames. To access data from your host machine:

| EDR Endpoint (Internal)      | Your Machine (External)             |
| ---------------------------- | ----------------------------------- |
| `http://provider/api/public` | `http://localhost:11000/api/public` |
| `http://consumer/api/public` | `http://localhost:22000/api/public` |

**Example: Fetch Data with curl**

```bash
# Get EDR token from UI (copy from "View EDR" modal)
EDR_TOKEN="eyJraWQ..."

# Access data (replace internal URL with localhost)
curl -X GET "http://localhost:11000/api/public" \
  -H "Authorization: $EDR_TOKEN"
```

---

#### ✅ **Success Indicators:**

**For HTTP Push Transfers:**

- 🟢 **Transfer state**: `REQUESTING` → `REQUESTED` → `STARTED` → `COMPLETED` (5-15 seconds)
- 🟢 **Green "COMPLETED" badge** in Transfer History
- 🟢 **Data appears at your webhook** (check webhook.site page)
- 🟢 **Webhook received POST request** with JSON payload
- 🟢 **Status code: 200 OK** from your webhook

**For HTTP Pull Transfers:**

- 🟢 **Transfer state**: `REQUESTING` → `REQUESTED` → `STARTED` → `COMPLETED` (5-10 seconds)
- 🟢 **"View EDR" button appears** on transfer card
- 🟢 **EDR modal shows**:
  - Endpoint URL
  - Authorization token (JWT)
  - Expiration time
- 🟢 **curl command returns data** (not 401/403 error)
- 🟢 **JSON response received** with actual weather/API data

**How to Verify HTTP Push:**

1. Open your webhook.site page in another tab
2. Refresh the page after transfer shows COMPLETED
3. You should see a new POST request
4. Click on request to view payload - should match provider's data source

**How to Verify HTTP Pull:**

1. Wait for transfer to reach COMPLETED state
2. Click "View EDR" button
3. Copy the authorization token
4. Use curl command (replace localhost:11000 with correct port)
5. Response should be real data (not error message)

#### ❌ **Common Issues & Solutions:**

| Problem                           | Likely Cause                        | Solution                                                                |
| --------------------------------- | ----------------------------------- | ----------------------------------------------------------------------- |
| ❌ Stuck in "STARTED" >30 sec     | Provider data source unreachable    | Provider: Check asset's Base URL is accessible from Docker network      |
| ❌ State: "FAILED"                | Provider data fetch error           | Check provider logs: `docker compose logs provider-connector --tail=50` |
| ❌ Webhook receives 404           | Provider's data source returned 404 | Provider: Verify Base URL and query params are correct                  |
| ❌ EDR token gives 401 error      | Token expired or invalid            | Initiate new transfer to get fresh token                                |
| ❌ EDR curl returns Docker error  | Used internal URL from host         | Replace `http://provider/...` with `http://localhost:11000/...`         |
| ❌ Transfer completes but no data | Webhook URL was wrong               | Check webhook URL is correct and accessible                             |
| ❌ "Connection refused" (Push)    | Webhook endpoint down               | Ensure your webhook/server is running and publicly accessible           |

**Troubleshooting Steps:**

```bash
# For HTTP Push failures - check provider can reach the webhook
docker compose exec provider-connector curl -X POST https://webhook.site/your-id \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
# Should return 200 OK

# For HTTP Pull - verify EDR endpoint is accessible
curl -X GET "http://localhost:11000/api/public" \
  -H "Authorization: Bearer YOUR_EDR_TOKEN"
# Should return data (not 401/404)

# Check transfer process details in logs
docker compose logs consumer-connector --tail=100 | grep -i "transfer\|COMPLETED\|FAILED"

# Check provider's data plane logs
docker compose logs provider-connector --tail=50 | grep -i "data plane\|transfer"
```

**💡 Transfer Monitoring Tips:**

- **Refresh frequently**: Transfer History doesn't auto-update - click refresh button
- **State progression timing**:
  - REQUESTING → REQUESTED: 1-2 seconds
  - REQUESTED → STARTED: 2-5 seconds
  - STARTED → COMPLETED: 3-10 seconds (depends on data size)
- **COMPLETED ≠ Data received**: For Push, also check your webhook
- **EDR tokens expire**: Typically 30-60 minutes - use them promptly
- **Multiple EDRs allowed**: Initiate multiple Pull transfers for the same contract

---

✅ **Result**: You'll receive the actual data from the provider's data source!

---

## 🎯 Complete Testing Scenarios

### Scenario 1: Simple Data Sharing (Push)

**Provider Steps:**

1. ✅ Create asset with HTTP data source
2. ✅ Create unrestricted policy
3. ✅ Publish data offer

**Consumer Steps:**

1. ✅ Browse catalog
2. ✅ Negotiate contract
3. ✅ Initiate HTTP Push transfer to webhook
4. ✅ Verify data received at webhook

**Expected Result**: Data from provider's source URL delivered to consumer's webhook.

---

### Scenario 2: API Access (Pull with EDR)

**Provider Steps:**

1. ✅ Create asset pointing to REST API
2. ✅ Create time-limited policy
3. ✅ Publish data offer

**Consumer Steps:**

1. ✅ Browse catalog
2. ✅ Negotiate contract
3. ✅ Initiate HTTP Pull transfer
4. ✅ Get EDR token from Transfer History
5. ✅ Call API with EDR token multiple times

**Expected Result**: Consumer can access provider's API for limited time using EDR.

---

### Scenario 3: Restricted Access (BPN Policy)

**Provider Steps:**

1. ✅ Create asset
2. ✅ Create BPN-restricted policy (specific partner only)
3. ✅ Publish data offer

**Consumer Steps:**

1. ✅ Browse catalog
   - ❌ Offer NOT visible if BPN doesn't match
   - ✅ Offer visible if BPN matches
2. ✅ Negotiate contract (only if visible)
3. ✅ Transfer data

**Expected Result**: Only authorized partners see and access the data.

---

### Scenario 4: Multiple Assets in One Offer

**Provider Steps:**

1. ✅ Create 3 different assets (e.g., temperature, humidity, pressure)
2. ✅ Create policy
3. ✅ Publish ONE data offer with ALL 3 assets selected

**Consumer Steps:**

1. ✅ Browse catalog - see one offer containing 3 assets
2. ✅ Negotiate contract (one contract covers all)
3. ✅ Initiate separate transfers for each asset

**Expected Result**: Single contract grants access to multiple datasets.

---

### Scenario 5: Contract Termination

**Provider Steps:**

1. ✅ Navigate to **"Contracts"** → **"Providing Contracts"**
2. ✅ Find active contract with consumer
3. ✅ Click **"Terminate Contract"** button
4. ✅ Provide termination reason

**Consumer Steps:**

1. ✅ Check **"Contracts"** → **"Terminated"** tab
2. ✅ See terminated contract with reason
3. ❌ Cannot initiate new transfers on terminated contract

**Expected Result**: Contract terminated, no further transfers allowed.

---

## 🔍 UI Features Explained

### Dashboard

**Provider Dashboard Shows:**

- Total assets created
- Active data offers
- Active providing contracts
- Recent transfer requests
- Connector health
- Environment info

**Consumer Dashboard Shows:**

- Catalog queries made
- Active consuming contracts
- Recent transfers initiated
- Connector health
- Environment info

---

### Assets Page

**View Modes:**

- **List View**: Table with all assets
- **Card View**: Visual cards with preview

**Filters:**

- Search by asset ID or name
- Filter by content type
- Sort by creation date

**Actions Per Asset:**

- 👁️ View details
- ✏️ Edit asset
- 🗑️ Delete asset (only if not used in offers)

---

### Policies Page

**Policy Types Available:**

- Unrestricted (allow all)
- Business Partner Number (BPN)
- Temporal (time-based)
- Custom expressions (JSON-LD)

**Policy Builder:**

- Visual editor for constraints
- AND/OR operators
- Left operand, operator, right operand
- Validation on save

---

### Data Offers Page

**Offer Status:**

- 🟢 Active: Published and available
- 🔴 Inactive: Not visible in catalog

**Bulk Actions:**

- Select multiple offers
- Deactivate/activate
- Delete unused offers

---

### Catalog Browser Page

**Search Features:**

- Recent queries saved
- Bookmark favorite providers
- Filter results by asset type
- Full-text search in descriptions

**Provider Discovery:**

- Manual endpoint entry
- Saved providers list
- Auto-discovery (if enabled)

---

### Contracts Page

**Tabs:**

- **Consuming**: You're the consumer
- **Providing**: You're the provider
- **Active**: Currently valid
- **Terminated**: Ended contracts

**Contract Actions:**

- 📊 View details
- 📤 Initiate transfer (consumer side)
- 🛑 Terminate contract (provider side)
- 📋 Export contract data

---

### Transfer History Page

**Real-time Updates:**

- Auto-refresh every 10 seconds
- WebSocket notifications (if enabled)

**Transfer Details:**

- Full timeline view
- Error messages with details
- Retry options for failed transfers
- EDR token viewer (Pull transfers)

**Filters:**

- By state (completed, failed, etc.)
- By date range
- By counterparty
- By asset

---

## 🎨 UI Customization

### Branding (Provider Settings)

Navigate to **Settings** → **Branding**:

- **Organization Name**
- **Logo URL**
- **Primary Color**
- **Contact Email**
- **Privacy Policy URL**
- **Terms of Service URL**

These appear in:

- Dashboard header
- Catalog entries shown to consumers
- Data offer cards

---

### Connector Configuration (Admin)

Navigate to **Settings** → **Configuration**:

- **Participant ID**: Your unique ID in dataspace
- **DSP Endpoint**: Your connector's DSP URL
- **Management API Endpoint**
- **Catalog Endpoint**
- **Default Policy Template**
- **Notification Settings**

---

## 🐛 Troubleshooting: UI Edition

### Problem: Can't See Provider's Offers in Catalog

**Checklist:**

1. ✅ Correct DSP endpoint format: `http://provider/api/v1/dsp`
2. ✅ Correct participant ID: `provider`
3. ✅ Provider has published data offers
4. ✅ Access policy allows you to see offers
5. ✅ Both connectors are running

**Fix:**

```bash
# Check provider logs
docker compose logs provider-connector | grep -i error

# Verify provider has data offers
# Open provider UI → Data Offers → Should see offers
```

---

### Problem: Contract Negotiation Stuck

**Symptoms:**

- Status stuck at `REQUESTING` or `REQUESTED`
- Never reaches `AGREED` or `FINALIZED`

**Possible Causes:**

1. ❌ Contract policy constraints not met
2. ❌ Provider connector down/unreachable
3. ❌ Network issue between connectors

**Fix:**

- Check contract policy constraints match your credentials
- Verify provider connector is running
- Check provider logs for rejection reasons
- Try negotiating a different offer

---

### Problem: Transfer Fails Immediately

**Symptoms:**

- Transfer goes `REQUESTED` → `FAILED`
- Error message in transfer details

**Common Issues:**

**For HTTP Push:**

- ❌ Data sink URL unreachable
- ❌ Data sink doesn't accept POST
- ❌ Provider's data source returns error

**For HTTP Pull:**

- ❌ Asset data source unreachable
- ❌ Asset data source requires auth

**Fix:**

- Verify URLs are accessible
- Test data source manually with curl
- Check provider and consumer logs
- Try with known working endpoints (like webhook.site)

---

### Problem: EDR Token Not Working

**Symptoms:**

- Have EDR token from HTTP Pull transfer
- Get 401/403 when calling provider endpoint

**Checklist:**

1. ✅ Using correct endpoint from EDR response
2. ✅ Including token in `Authorization` header
3. ✅ Token not expired
4. ✅ Transfer in `STARTED` or `COMPLETED` state

**Fix:**

```bash
# Correct format
curl -X GET "https://provider/endpoint" \
  -H "Authorization: Bearer YOUR_EDR_TOKEN"

# Check transfer is still active
# UI: Transfer History → Find transfer → Check state
```

---

### Problem: UI Shows Empty Dashboards

**Symptoms:**

- Dashboard shows zeros for all metrics
- No assets/policies/offers appear

**Causes:**

- ❌ Database connection issue
- ❌ Management API not responding
- ❌ Browser cache issue

**Fix:**

1. Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
2. Clear browser cache
3. Check connector logs
4. Restart connector
5. Check database is running

---

## 📱 Mobile/Tablet Support

The sovity EDC UI is **responsive** and works on:

- ✅ Desktop browsers (Chrome, Firefox, Safari, Edge)
- ✅ Tablet devices (iPad, Android tablets)
- ⚠️ Mobile phones (limited - some features better on larger screens)

**Recommended**: Use desktop or tablet for best experience.

---

## 🎓 Learning Exercise: Complete Walkthrough

### Exercise 1: Basic Data Exchange (30 mins)

**Goal**: Complete provider → consumer data transfer using only the UI

**Steps:**

1. Start both connectors
2. Provider: Create weather API asset
3. Provider: Create unrestricted policy
4. Provider: Publish data offer
5. Consumer: Browse catalog and find offer
6. Consumer: Negotiate contract
7. Consumer: Initiate HTTP Pull transfer
8. Consumer: Use EDR token to fetch data

**Success Criteria:**

- ✅ Transfer shows `COMPLETED`
- ✅ Data successfully retrieved with EDR token

---

### Exercise 2: Policy Testing (20 mins)

**Goal**: Test different policy constraints

**Steps:**

1. Provider: Create asset
2. Provider: Create BPN-restricted policy (with wrong BPN)
3. Provider: Publish offer
4. Consumer: Try to browse catalog
   - **Expected**: Offer NOT visible
5. Provider: Edit policy to allow consumer's BPN
6. Provider: Update data offer
7. Consumer: Browse catalog again
   - **Expected**: Offer NOW visible
8. Consumer: Complete negotiation and transfer

**Success Criteria:**

- ✅ Understanding of access vs contract policies
- ✅ Successfully tested policy restrictions

---

### Exercise 3: Contract Management (15 mins)

**Goal**: Understand contract lifecycle

**Steps:**

1. Complete Exercise 1 to have an active contract
2. Consumer: View contract details
3. Consumer: Initiate 2-3 transfers on same contract
4. Provider: View providing contracts
5. Provider: Terminate the contract
6. Consumer: Try to initiate another transfer
   - **Expected**: Error or disabled button
7. Consumer: View terminated contracts

**Success Criteria:**

- ✅ Multiple transfers on one contract
- ✅ Successfully terminated contract
- ✅ Understood contract reusability

---

## 🔗 Related Documentation

For deeper understanding:

- **Frontend Walkthrough**: `/docs/Frontend/walkthrough-guide.md`
- **Provider Guide**: `/docs/Frontend/Providing/`
- **Consumer Guide**: `/docs/Frontend/Consuming/`
- **API Alternative**: `/API_TESTING_GUIDE.md`
- **Flow Diagrams**: `/FLOW_DIAGRAMS.md`

---

## 💡 Pro Tips

### Tip 1: Use Two Browser Windows Side-by-Side

Open provider UI in one window, consumer UI in another. This helps visualize the two-party interaction.

### Tip 2: Use Browser Dev Tools

- **Network Tab**: See API calls made by UI
- **Console Tab**: Check for JavaScript errors
- **Application Tab**: View stored tokens/state

### Tip 3: Bookmark Test URLs

Save your frequently used endpoints:

- Provider UI
- Consumer UI
- Test webhook URL
- Sample data sources

### Tip 4: Use Real APIs for Testing

Instead of mock data, use real public APIs:

- Weather: `https://api.open-meteo.com`
- JSON Placeholder: `https://jsonplaceholder.typicode.com`
- Cat Facts: `https://catfact.ninja/fact`
- Dog API: `https://dog.ceo/api/breeds/image/random`

### Tip 5: Export/Import Configuration

Some UIs allow exporting policies and assets as JSON - use this to:

- Backup configurations
- Share with team
- Quick setup on new connectors

---

## 🎯 Next Steps

Once comfortable with the UI:

1. **Try the Chat App Example**

   ```bash
   cd examples/chat-app/source-final
   ./start.sh
   ```

   Full working application using EDC!

2. **Explore Advanced UI Features**

   - Vault secrets integration
   - Business partner groups
   - Custom data source types

3. **Learn the Management API**

   - Read `/API_TESTING_GUIDE.md`
   - Automate what you did in UI
   - Build your own applications

4. **Deploy to Production**
   - Read `/docs/deployment-guide/`
   - Configure real IAM (DAPS/DID)
   - Set up monitoring

---

**Happy Testing! 🚀**

Questions? Check the [sovity EDC-CE Discussions](https://github.com/sovity/edc-ce/discussions)
