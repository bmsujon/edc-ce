# 🎉 Complete EDC API Testing - Quick Start

## What You Get

✅ **Full E2E Workflows**: Both HTTP Pull and HTTP Push data transfers  
✅ **Working Scripts**: Run complete tests with one command  
✅ **Comprehensive Guide**: Step-by-step instructions with examples  
✅ **Real Data**: Tested with live weather API  
✅ **Production Ready**: JSON-LD format validated and working

---

## 🚀 Quick Start (Choose One)

### Option 1: Run Automated Test (Fastest)

**HTTP Pull** (Consumer fetches data):

```bash
./edc-test-pull.sh
```

**HTTP Push** (Provider pushes data):

```bash
./edc-test-push.sh
```

**Time**: ~10 seconds per test

### Option 2: Follow Step-by-Step Guide

```bash
# Read the complete guide
open EDC_API_WORKFLOW_COMPLETE.md
```

**Time**: 30-45 minutes (includes learning)

---

## 📚 Documentation Files

| File                           | Purpose                            | When to Use          |
| ------------------------------ | ---------------------------------- | -------------------- |
| `EDC_API_WORKFLOW_COMPLETE.md` | Complete guide with both workflows | Learning, reference  |
| `edc-test-pull.sh`             | Automated HTTP Pull test           | Quick validation     |
| `edc-test-push.sh`             | Automated HTTP Push test           | Quick validation     |
| `SESSION_SUMMARY_20251024.md`  | Today's achievements summary       | Review what was done |
| `START_HERE.md`                | Entry point for all testing        | First time users     |

---

## 🎯 What These Scripts Do

### edc-test-pull.sh

1. ✅ Request catalog from provider
2. ✅ Extract offer ID for weather asset
3. ✅ Negotiate contract with JSON-LD
4. ✅ Wait for FINALIZED state
5. ✅ Initiate HTTP Pull transfer
6. ✅ Retrieve EDR token
7. ✅ Fetch actual weather data

**Output**: Real-time weather JSON

### edc-test-push.sh

1. ✅ Create webhook.site endpoint
2. ✅ Request catalog from provider
3. ✅ Negotiate contract
4. ✅ Initiate HTTP Push transfer to webhook
5. ✅ Verify data received at webhook

**Output**: Webhook URL with pushed data

---

## ✨ Key Features

### 1. Both Transfer Types Supported

- **HTTP Pull**: Consumer-controlled, on-demand access
- **HTTP Push**: Provider-initiated, event-driven delivery

### 2. Correct JSON-LD Format

All scripts use the correct format discovered through testing:

```json
"odrl:assigner": {"@id": "provider"},
"odrl:target": {"@id": "weather-api-asset"}
```

### 3. Complete Error Handling

Scripts check each step and fail fast with clear messages.

### 4. Real Data Transfer

Not just mocks - actual weather data from Open-Meteo API through EDC dataspace.

---

## 🔍 Prerequisites

### Docker Services Running

```bash
cd docs/deployment-guide/goals/local-demo-ce
docker compose ps
```

All 8 services should be "Up".

### jq Installed

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

---

## 📖 Detailed Workflows

### HTTP Pull Workflow

```
Consumer                Provider
   |                       |
   |--1. Catalog Request-->|
   |<--2. Offers List------|
   |                       |
   |--3. Contract Neg.---->|
   |<--4. Agreement--------|
   |                       |
   |--5. Transfer Init.--->|
   |<--6. EDR Token--------|
   |                       |
   |--7. Fetch Data------->|
   |<--8. Data Payload-----|
```

**Steps**: 8  
**Time**: ~5 seconds  
**Control**: Consumer

### HTTP Push Workflow

```
Consumer                Provider
   |                       |
   |--1. Catalog Request-->|
   |<--2. Offers List------|
   |                       |
   |--3. Contract Neg.---->|
   |<--4. Agreement--------|
   |                       |
   |--5. Transfer Init.--->|
   |   (with webhook URL)  |
   |                       |
   |<------6. Data Push----|
```

**Steps**: 6  
**Time**: ~5 seconds  
**Control**: Provider

---

## 🎓 Learning Path

1. **Start Here**: Run `edc-test-pull.sh` to see it work
2. **Understand**: Read `EDC_API_WORKFLOW_COMPLETE.md`
3. **Experiment**: Modify scripts to test different scenarios
4. **Integrate**: Build your own client using the patterns

---

## 🔧 Customization

### Test Different Assets

Edit scripts to change asset ID:

```bash
# Find this line in edc-test-pull.sh
OFFER_ID=$(jq -r '.dcat:dataset[] | select(."edc:id" == "weather-api-asset") | ."@id"' /tmp/catalog.json)

# Change to your asset
OFFER_ID=$(jq -r '.dcat:dataset[] | select(."edc:id" == "YOUR-ASSET-ID") | ."@id"' /tmp/catalog.json)
```

### Use Different Webhooks

For HTTP Push, you can use your own webhook:

```bash
# Instead of webhook.site
WEBHOOK_URL="https://your-endpoint.com/webhook"
```

### Add Logging

Uncomment debug lines or add your own:

```bash
echo "DEBUG: Negotiation response:" | tee -a edc-test.log
curl ... | tee -a edc-test.log
```

---

## 🐛 Troubleshooting

### Script Fails at Catalog Request

**Check**: Docker services running

```bash
docker compose ps
```

**Check**: Provider reachable

```bash
curl http://localhost:11000/api/v1/dsp
```

### JSON-LD Validation Errors

**Problem**: "odrl:assigner/@id cannot be null"

**Solution**: Already fixed in scripts. If you see this, ensure you're using the object format:

```json
"odrl:assigner": {"@id": "provider"}
```

### No Data at Webhook

**Check**: Transfer state

```bash
curl -X GET "http://localhost:22000/api/management/v3/transferprocesses/$TRANSFER_ID" \
  -H "X-Api-Key: SomeOtherApiKey" | jq .
```

**Wait**: Provider may take a few seconds to push data.

---

## 📊 Expected Results

### Successful HTTP Pull Output

```
=== EDC HTTP Pull Complete Test ===
1. Requesting catalog...
✓ Offer ID: d2VhdGhlci1vZmZlci1hcGktdGVzdA==:...
2. Initiating contract negotiation...
✓ Negotiation ID: 019a14dc-8bd1-7321-b96a-1b9847e30bd2
3. Waiting for negotiation to finalize...
✓ Agreement ID: 019a14dc-9418-77fe-bf15-6cb705789790
4. Initiating HTTP Pull transfer...
✓ Transfer ID: 019a14dd-8471-707f-b658-0f563bcb2046
5. Retrieving EDR...
✓ EDR Token received
6. Fetching weather data...
{
  "latitude": 52.52,
  "longitude": 13.419998,
  "current_weather": {
    "temperature": 11.2,
    "windspeed": 15.1,
    "weathercode": 3
  }
}

=== Test Complete! ===
```

### Successful HTTP Push Output

```
=== EDC HTTP Push Complete Test ===
0. Creating webhook endpoint...
✓ Webhook URL: https://webhook.site/4c625d12-2a20-47e5-a1a0-864c7d1eef10
  Visit in browser to see data arrive!
1. Requesting catalog...
✓ Offer ID: d2VhdGhlci1vZmZlci1hcGktdGVzdA==:...
2. Initiating contract negotiation...
✓ Negotiation ID: 019a14e5-6ac4-7bf8-a416-f2095be9aec4
3. Waiting for negotiation to finalize...
✓ Agreement ID: 019a14e5-704a-72a1-ba04-dbb1241e1b9e
4. Initiating HTTP Push transfer...
✓ Transfer ID: 019a14e6-422c-7c7a-a39d-12a74acb97fc
5. Waiting for data to be pushed...
6. Checking webhook for received data...
{
  "latitude": 52.52,
  "longitude": 13.419998,
  "current_weather": {
    "temperature": 11.2,
    "windspeed": 15.1,
    "weathercode": 3
  }
}

=== Test Complete! ===
View all requests at: https://webhook.site/4c625d12-2a20-47e5-a1a0-864c7d1eef10
```

---

## 🌟 What Makes This Special

1. **Battle-Tested**: Debugged through real JSON-LD format issues
2. **Complete**: Covers both major transfer patterns
3. **Automated**: One command to test everything
4. **Educational**: Scripts are readable and well-commented
5. **Real Data**: Uses actual Open-Meteo weather API

---

## 🤝 Contributing

Found an issue? Have an improvement?

1. Test your changes with both scripts
2. Update documentation if needed
3. Ensure JSON-LD format remains valid
4. Share your improvements!

---

## 📞 Support

**Documentation**: Read `EDC_API_WORKFLOW_COMPLETE.md` first  
**Quick Reference**: See `QUICK_REFERENCE.md` for API endpoints  
**Troubleshooting**: Check troubleshooting section in workflow guide  
**Session Notes**: Review `SESSION_SUMMARY_20251024.md` for context

---

## 🎉 Success Criteria

You'll know it's working when:

- ✅ Scripts complete without errors
- ✅ You see JSON weather data in output
- ✅ HTTP Push data appears at webhook.site
- ✅ All negotiation states reach FINALIZED
- ✅ EDR tokens are retrieved successfully

---

**Happy Testing!** 🚀

For the complete story of how these scripts were created and debugged, see `SESSION_SUMMARY_20251024.md`.
