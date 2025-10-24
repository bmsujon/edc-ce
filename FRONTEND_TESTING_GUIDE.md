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

## 🎬 Complete Flow: Provider Side

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

✅ **Result**: Asset created and appears in Assets list!

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
