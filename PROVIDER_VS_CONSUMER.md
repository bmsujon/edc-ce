# 🎭 Provider vs Consumer: Complete Comparison

## Side-by-Side View of Both Roles

This guide shows **exactly what each party does** in a data exchange, helping you understand both perspectives.

---

## 🏢 Role Definitions

| Aspect             | 📤 Provider            | 📥 Consumer             |
| ------------------ | ---------------------- | ----------------------- |
| **Identity**       | Data owner/source      | Data requestor          |
| **Local URL**      | http://localhost:11000 | http://localhost:22000  |
| **Participant ID** | `provider`             | `consumer`              |
| **Primary Goal**   | Share data securely    | Access needed data      |
| **Business Value** | Monetize/share data    | Gain insights from data |

---

## 🎬 Complete Flow: Both Perspectives

### Phase 1: Setup & Configuration

<table>
<tr>
<th>📤 Provider Side</th>
<th>📥 Consumer Side</th>
</tr>
<tr>
<td>

**Step 1: Create Data Asset**

_UI: Assets → Create Asset_

```
Asset ID: weather-data
Data Source:
  Type: HTTP Data
  URL: https://api.open-meteo.com/v1/forecast
  Method: GET
```

**What it means:** "I have weather data to share"

</td>
<td>

**Step 1: Prepare Data Sink**

_Optional: Set up webhook or endpoint_

```
Data Sink Options:
  - Public webhook (webhook.site)
  - Your API endpoint
  - Or use HTTP Pull (no sink needed)
```

**What it means:** "I'm ready to receive data"

</td>
</tr>
<tr>
<td>

**Step 2: Create Policies**

_UI: Policies → Create Policy_

```
Access Policy: allow-all-policy
  (who can SEE the offer)

Contract Policy: allow-all-policy
  (who can NEGOTIATE)
```

**What it means:** "Anyone can see and use this data"

</td>
<td>

**Step 2: Identify Providers**

_Research dataspaces_

```
Find Provider:
  - Search dataspace directory
  - Get DSP endpoint
  - Note Participant ID
```

**What it means:** "Where can I find relevant data?"

</td>
</tr>
<tr>
<td>

**Step 3: Publish Data Offer**

_UI: Data Offers → Create_

```
Data Offer ID: weather-offer
Access Policy: allow-all-policy
Contract Policy: allow-all-policy
Assets: [weather-data]
```

**What it means:** "My data is now available in the dataspace"

</td>
<td>

**Step 3: Ready to Browse**

_UI: Catalog Browser_

```
Status: Ready
Next: Query provider catalogs
```

**What it means:** "I'm ready to discover data offers"

</td>
</tr>
</table>

---

### Phase 2: Discovery & Evaluation

<table>
<tr>
<th>📤 Provider Side</th>
<th>📥 Consumer Side</th>
</tr>
<tr>
<td>

**Provider Waits**

_Monitoring dashboard_

```
Status:
  ✅ Data offer published
  ⏳ Waiting for catalog queries
  📊 Monitoring access
```

**Provider sees:**

- Data offer is active
- Asset is linked
- Policies are enforced

</td>
<td>

**Consumer Discovers**

_UI: Catalog Browser → Fetch Catalog_

```
Provider DSP:
  http://provider/api/v1/dsp
Participant ID: provider

[Fetch Catalog]
```

**Consumer sees:**

- List of available offers
- Asset descriptions
- Policy constraints
- Provider information

</td>
</tr>
<tr>
<td>

**Provider Logs Show**

```
INFO: Catalog request from 'consumer'
INFO: Evaluating access policy...
INFO: Access granted - returning 1 offer
```

**Policy evaluation happens here**

</td>
<td>

**Consumer Reviews Offer**

_Click on data offer card_

```
Offer Details:
  - Asset: weather-data
  - Description: Real-time weather
  - Access Policy: Unrestricted
  - Contract Policy: Unrestricted

[Negotiate Contract]
```

**Consumer evaluates:**

- Is this the right data?
- Can I meet policy terms?
- What are the costs/constraints?

</td>
</tr>
</table>

---

### Phase 3: Contract Negotiation

<table>
<tr>
<th>📤 Provider Side</th>
<th>📥 Consumer Side</th>
</tr>
<tr>
<td>

**Provider Receives Request**

_Automatic processing_

```
1. Contract request arrives
2. Validate consumer credentials
3. Check contract policy constraints
4. Make decision: AGREE or REJECT
```

**Provider logs:**

```
INFO: Contract negotiation from 'consumer'
INFO: Offer ID: weather-offer
INFO: Evaluating contract policy...
INFO: Policy satisfied ✅
INFO: Contract AGREED
```

</td>
<td>

**Consumer Initiates**

_UI: Offer details → Negotiate Contract_

```
[Negotiate Contract]

Status updates:
  REQUESTING... ⏳
  REQUESTED... ⏳
  AGREED... ✅
  FINALIZED... ✅
```

**Consumer waits:**

- Typically 5-10 seconds
- Provider validates policies
- Contract is signed by both

</td>
</tr>
<tr>
<td>

**Provider's Contract View**

_UI: Contracts → Providing_

```
New contract appears:
  Counterparty: consumer
  Asset: weather-data
  Status: Active
  Signed: 2024-10-24 10:30 UTC
```

**Provider can:**

- Monitor usage
- See transfer count
- Terminate if needed

</td>
<td>

**Consumer's Contract View**

_UI: Contracts → Consuming_

```
New contract appears:
  Counterparty: provider
  Asset: weather-data
  Status: Active
  Signed: 2024-10-24 10:30 UTC

[Transfer Data]
```

**Consumer can:**

- Initiate transfers
- Multiple transfers allowed
- Reuse same contract

</td>
</tr>
</table>

---

### Phase 4: Data Transfer

<table>
<tr>
<th>📤 Provider Side (HTTP Push)</th>
<th>📥 Consumer Side (HTTP Push)</th>
</tr>
<tr>
<td>

**Provider Receives Transfer Request**

_Automatic processing_

```
1. Transfer request arrives
2. Validate contract is active
3. Fetch data from source
4. POST to consumer's sink URL
```

**Provider logs:**

```
INFO: Transfer request from 'consumer'
INFO: Contract valid ✅
INFO: Fetching from:
      https://api.open-meteo.com/...
INFO: Posting to consumer sink:
      https://consumer-webhook.com/data
INFO: Transfer COMPLETED ✅
```

</td>
<td>

**Consumer Initiates Transfer**

_UI: Contract → Transfer Data_

```
Transfer Type: HTTP Push
Data Sink URL:
  https://webhook.site/abc123
Method: POST

[Start Transfer]
```

**Consumer monitors:**

```
Transfer Status:
  REQUESTING... ⏳
  REQUESTED... ⏳
  STARTED... ⏳
  COMPLETED... ✅
```

**Consumer receives data at webhook**

</td>
</tr>
</table>

<table>
<tr>
<th>📤 Provider Side (HTTP Pull)</th>
<th>📥 Consumer Side (HTTP Pull)</th>
</tr>
<tr>
<td>

**Provider Sets Up Data Plane**

_Automatic_

```
1. Transfer request arrives
2. Validate contract
3. Generate EDR token
4. Prepare data endpoint
5. Return token to consumer
```

**Provider logs:**

```
INFO: Transfer request (Pull) from 'consumer'
INFO: Contract valid ✅
INFO: EDR token generated
INFO: Endpoint:
      http://provider/api/public/...
INFO: Token valid for: 1 hour
INFO: Transfer STARTED ✅
```

**Data stays with provider** until consumer fetches it

</td>
<td>

**Consumer Gets EDR Token**

_UI: Contract → Transfer Data_

```
Transfer Type: HTTP Pull

[Start Transfer]

Transfer Status: STARTED ✅

[View EDR]
```

**EDR Token Response:**

```json
{
  "endpoint": "http://provider/api/public/data",
  "authorization": "Bearer eyJ...",
  "expiresAt": "2024-10-24T11:30:00Z"
}
```

**Consumer uses token:**

```bash
curl "http://provider/api/public/data" \
  -H "Authorization: Bearer eyJ..."
```

**Consumer can call multiple times** until token expires

</td>
</tr>
</table>

---

## 🎯 Key Differences Summary

| Aspect              | Provider                         | Consumer                                |
| ------------------- | -------------------------------- | --------------------------------------- |
| **Initiative**      | Passive (waits for requests)     | Active (browses, requests)              |
| **Data Flow**       | Outbound (provides data)         | Inbound (receives data)                 |
| **Policy Role**     | Defines and enforces policies    | Must satisfy policy constraints         |
| **Typical UI Flow** | Asset → Policy → Offer → Monitor | Browse → Negotiate → Transfer → Consume |
| **Control**         | Controls who accesses            | Controls what to access                 |
| **Responsibility**  | Data quality & availability      | Proper data usage                       |

---

## 🔄 Interaction Patterns

### Pattern 1: Push Transfer

```
Provider: "I'll send you the data"
Consumer: "Here's where to send it" (webhook URL)

Flow:
  Consumer → Transfer Request → Provider
  Provider → Fetch from source
  Provider → POST to consumer sink → Consumer receives
```

**Use when:** Consumer has public endpoint, one-time data delivery

---

### Pattern 2: Pull Transfer (with EDR)

```
Provider: "Here's a token, come get the data"
Consumer: "Thanks, I'll fetch it when needed"

Flow:
  Consumer → Transfer Request → Provider
  Provider → Generate EDR token → Consumer
  Consumer → GET with token → Provider → Data
  Consumer → GET with token → Provider → Data (can repeat)
```

**Use when:** Consumer needs repeated access, real-time APIs

---

## 🎨 UI Navigation Comparison

### Provider's Main Screens

1. **Dashboard**

   - Overview of shared data
   - Active providing contracts
   - Recent access requests

2. **Assets**

   - Create new assets
   - Manage data sources
   - View asset details

3. **Policies**

   - Define access rules
   - Define contract terms
   - Reusable policy templates

4. **Data Offers**

   - Publish offers
   - Activate/deactivate
   - Link assets and policies

5. **Contracts (Providing tab)**
   - Monitor active contracts
   - See transfer count
   - Terminate if needed

---

### Consumer's Main Screens

1. **Dashboard**

   - Overview of consumed data
   - Active consuming contracts
   - Recent transfers

2. **Catalog Browser**

   - Search for providers
   - Browse available offers
   - View offer details

3. **Contracts (Consuming tab)**

   - View active contracts
   - Initiate transfers
   - Monitor usage

4. **Transfer History**
   - See all transfers
   - Check status
   - View EDR tokens (for Pull)
   - Debug failures

---

## 💼 Real-World Scenarios

### Scenario 1: Public Data Sharing

**Provider:**

- Publishes weather data
- No restrictions (allow-all policy)
- Free access for anyone

**Consumer:**

- Any organization in dataspace
- Browses catalog
- Instant access after negotiation

**Example:** Government open data, public APIs

---

### Scenario 2: Restricted B2B Data

**Provider:**

- Publishes sensitive business data
- BPN-restricted policy
- Only authorized partners

**Consumer:**

- Must have matching BPN
- Can see offer only if policy satisfied
- Contract terms enforced

**Example:** Supply chain data, manufacturing specs

---

### Scenario 3: Paid Data Service

**Provider:**

- Publishes premium dataset
- Time-limited contracts
- Usage tracking enabled

**Consumer:**

- Pays for access (external billing)
- Gets temporary contract
- Limited validity period

**Example:** Market research data, analytics reports

---

## 🐛 Troubleshooting by Role

### Provider Issues

**Problem:** No one can see my data offer

**Checklist:**

- ✅ Data offer is created
- ✅ Data offer is active (not disabled)
- ✅ Asset is linked to offer
- ✅ Access policy allows target consumers
- ✅ Connector is reachable from network

---

**Problem:** Contracts keep getting rejected

**Checklist:**

- ✅ Contract policy is not too restrictive
- ✅ Consumer meets policy constraints
- ✅ No errors in provider logs
- ✅ Data source is accessible

---

### Consumer Issues

**Problem:** Can't find any data offers

**Checklist:**

- ✅ Using correct provider DSP endpoint
- ✅ Using correct participant ID
- ✅ Provider has published offers
- ✅ You meet access policy constraints
- ✅ Provider connector is running

---

**Problem:** Transfer fails immediately

**Checklist:**

- ✅ For Push: Your webhook URL is accessible
- ✅ For Push: Webhook accepts POST
- ✅ For Pull: You're using EDR token correctly
- ✅ Contract is still active
- ✅ Provider's data source is reachable

---

## 📊 Metrics & Monitoring

### Provider Metrics

**What to track:**

- Number of published data offers
- Active providing contracts
- Total transfer count
- Failed transfers (fix data sources)
- Catalog query count
- Most popular offers

**Where to see:**

- Provider Dashboard (UI)
- Database queries
- Provider connector logs

---

### Consumer Metrics

**What to track:**

- Number of active consuming contracts
- Total transfers initiated
- Successful vs failed transfers
- Average negotiation time
- Data volume consumed
- EDR token usage

**Where to see:**

- Consumer Dashboard (UI)
- Transfer History page
- Consumer connector logs

---

## 🎓 Learning Exercise

### Exercise: Role Reversal

1. **Complete a flow as Provider then Consumer**

   - Provider: Create offer
   - Consumer: Consume it

2. **Reverse the roles in your head**

   - What would Consumer need to provide?
   - What would Provider need to access?

3. **Try both roles with real data**
   - Each local connector can be both!
   - Create offers on Consumer connector
   - Browse from Provider connector

**This helps understand both perspectives!**

---

## 🔗 Related Guides

- **UI Testing:** FRONTEND_TESTING_GUIDE.md
- **API Testing:** API_TESTING_GUIDE.md
- **Flow Diagrams:** FLOW_DIAGRAMS.md
- **Quick Start:** START_HERE.md

---

**Now you understand both sides of the EDC data exchange! 🎉**
