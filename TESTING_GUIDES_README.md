# 🎓 Local Testing & Learning Resources

This directory contains comprehensive guides for setting up and testing sovity EDC-CE locally.

> **💡 NEW TO EDC?** Start with the **FRONTEND_TESTING_GUIDE.md** - no coding required!

---

## 📚 Available Guides

### 1. **FRONTEND_TESTING_GUIDE.md** - UI-Based Testing (⭐ START HERE!)

**The easiest way to learn EDC - using the Web UI only!**

- 🎨 Complete provider & consumer workflows via browser
- 🖱️ No coding or API knowledge required
- 🏢 Clear separation of Provider vs Consumer perspectives
- 📊 Dashboard, catalog browser, and transfer monitoring
- 🎯 3 hands-on exercises with success criteria
- 🐛 UI-specific troubleshooting guide

**👉 Perfect for beginners and business users!**

### 2. **LOCAL_SETUP_GUIDE.md** - Complete Setup Guide

**Comprehensive guide covering both UI and API!**

- Prerequisites and installation
- Step-by-step setup instructions
- UI walkthrough for complete flow
- Management API testing examples
- Troubleshooting tips
- Advanced scenarios

**👉 For users who want both UI and API!**

### 3. **quick-start.sh** - Interactive Setup Script

**Automate your setup with one command!**

```bash
# Interactive menu
./quick-start.sh

# Or use direct commands
./quick-start.sh start        # Full start with checks
./quick-start.sh sample       # Create sample data
./quick-start.sh logs         # View logs
./quick-start.sh stop         # Stop services
```

Features:

- ✅ Prerequisites checking
- 🚀 One-command startup
- 📊 Health checks
- 🔧 Sample data creation
- 📝 Log viewing
- 🧹 Cleanup utilities

### 4. **API_TESTING_GUIDE.md** - curl Command Reference

**Complete API testing examples!**

- Every API endpoint documented
- Copy-paste ready curl commands
- Environment variable setup
- Complete end-to-end script
- Extraction and chaining examples

**Perfect for automation and scripting!**

### 5. **FLOW_DIAGRAMS.md** - Visual Workflow Guide

**Understand the flow visually!**

- ASCII art diagrams
- State transition diagrams
- Decision trees
- Timeline views
- Architecture overview
- Policy evaluation flows

**Great for presentations and documentation!**

### 6. **QUICK_REFERENCE.md** - One-Page Cheat Sheet

**Keep this open while working!**

- Essential commands
- Common endpoints
- Quick snippets
- Status codes
- Docker commands
- Debugging tips

**Print this for your desk! 🖨️**

---

## 🚀 Getting Started (Choose Your Style)

### 🎨 Option A: UI-Only (Easiest - No Coding!)

**Perfect for: Business users, beginners, first-time EDC users**

```bash
# 1. Start services
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d

# 2. Wait 60 seconds, then open TWO browser tabs:
# Provider UI: http://localhost:11000
# Consumer UI: http://localhost:22000

# 3. Follow FRONTEND_TESTING_GUIDE.md step-by-step
```

**What you'll learn:**

- ✅ Provider perspective: Create assets, policies, publish offers
- ✅ Consumer perspective: Browse catalog, negotiate, transfer data
- ✅ Complete data exchange using only the web interface

---

### 🔧 Option B: Interactive Script (Automated)

**What you'll learn:**

- ✅ Provider perspective: Create assets, policies, publish offers
- ✅ Consumer perspective: Browse catalog, negotiate, transfer data
- ✅ Complete data exchange using only the web interface

---

### 🔧 Option B: Interactive Script (Automated)

**Perfect for: Quick setup, repeated testing, automation**

```bash
# 1. Run the script
./quick-start.sh

# 2. Select option 1 (Start Demo)
# 3. Select option 3 (Create Sample Asset)
# 4. Open the UIs and explore!
```

**What you'll learn:**

- ✅ Automated environment setup
- ✅ Sample data creation
- ✅ Log monitoring and debugging

---

### 💻 Option C: API-First (For Developers)

### 💻 Option C: API-First (For Developers)

**Perfect for: Backend developers, automation, CI/CD integration**

```bash
# 1. Start services
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d

# 2. Set environment variables
export PROVIDER_API="http://localhost:11000/api/management"
export PROVIDER_KEY="SomeOtherApiKey"
export CONSUMER_API="http://localhost:22000/api/management"
export CONSUMER_KEY="SomeOtherApiKey"

# 3. Follow API examples in API_TESTING_GUIDE.md
```

**What you'll learn:**

- ✅ Management API endpoints and JSON payloads
- ✅ Contract negotiation state machine
- ✅ EDR token handling and data access
- ✅ Scripting and automation patterns

---

## 🏢 Understanding Provider vs Consumer Roles

Every EDC dataspace interaction involves **two parties**:

### 📤 Provider (Data Source Owner)

**Participant ID**: `provider`  
**UI**: http://localhost:11000  
**API**: http://localhost:11000/api/management

**Responsibilities:**

- 🏗️ Create data assets (what data to share)
- 🔐 Define policies (who can access, under what conditions)
- 📢 Publish data offers (make available in dataspace)
- ✅ Approve/monitor access requests
- 📊 Track outgoing data transfers

**UI Journey:**

1. Dashboard → Assets → Create Asset
2. Dashboard → Policies → Create Policy
3. Dashboard → Data Offers → Publish Offer
4. Dashboard → Contracts (Providing) → Monitor usage

---

### 📥 Consumer (Data Requestor)

**Participant ID**: `consumer`  
**UI**: http://localhost:22000  
**API**: http://localhost:22000/api/management

**Responsibilities:**

- 🔍 Browse catalog from providers
- 📋 Find relevant data offers
- 🤝 Negotiate contracts
- 📥 Initiate data transfers
- 💾 Consume received data

**UI Journey:**

1. Dashboard → Catalog Browser → Fetch Catalog
2. Select Offer → Negotiate Contract
3. Dashboard → Contracts (Consuming) → View Agreements
4. Contract Details → Initiate Transfer
5. Dashboard → Transfer History → Monitor Status

---

**💡 Key Insight**: In your local setup, you can play BOTH roles by using two browser windows!

**💡 Key Insight**: In your local setup, you can play BOTH roles by using two browser windows!

---

## 📖 Learning Paths

### 🎨 Path 1: Complete Beginner (UI-First)

**Goal: Understand EDC concepts through hands-on UI experience**

1. Read `FRONTEND_TESTING_GUIDE.md` - Overview & Concepts
2. Run `./quick-start.sh` → Option 1 (Start)
3. Open **Provider UI**: http://localhost:11000
4. Open **Consumer UI**: http://localhost:22000 (different browser window)
5. Follow **Provider Steps** in FRONTEND_TESTING_GUIDE.md (Parts 1-4)
6. Follow **Consumer Steps** in FRONTEND_TESTING_GUIDE.md (Parts 5-10)
7. Complete Exercise 1 in FRONTEND_TESTING_GUIDE.md
8. Review `FLOW_DIAGRAMS.md` to visualize what you did

**Estimated time: 45-60 minutes**

**Success Criteria:**

- ✅ Created asset as provider
- ✅ Published data offer
- ✅ Browsed catalog as consumer
- ✅ Negotiated and completed contract
- ✅ Transferred data successfully

---

### 💻 Path 2: Developer Integration (API-First)

**Goal: Integrate EDC into your applications via Management API**

### 💻 Path 2: Developer Integration (API-First)

**Goal: Integrate EDC into your applications via Management API**

1. Start services: `./quick-start.sh start`
2. Read `API_TESTING_GUIDE.md` - Introduction & Setup
3. Test **Provider API** calls (sections 1-4)
   - Create asset via API
   - Create policy via API
   - Publish contract definition
4. Test **Consumer API** calls (sections 5-8)
   - Request catalog
   - Negotiate contract
   - Initiate transfer
   - Monitor status
5. Run the complete E2E script (section 18)
6. Review `QUICK_REFERENCE.md` for daily use

**Estimated time: 1-2 hours**

**Success Criteria:**

- ✅ Successful API calls with curl
- ✅ Understanding JSON-LD payloads
- ✅ Complete E2E script runs without errors
- ✅ Can extract and chain API responses

---

### 🚀 Path 3: Advanced Testing (Both UI + API)

### 🚀 Path 3: Advanced Testing (Both UI + API)

**Goal: Test complex scenarios and edge cases**

1. Complete Path 1 or Path 2 first
2. Read `LOCAL_SETUP_GUIDE.md` - Advanced Testing section
3. Test different transfer types:
   - HTTP Push to webhook
   - HTTP Pull with EDR tokens
4. Test policy constraints:
   - BPN restrictions
   - Time-based policies
   - Custom constraint expressions
5. Test contract management:
   - Multiple transfers on one contract
   - Contract termination
6. Mix UI and API approaches for flexibility
7. Explore Chat App example (`examples/chat-app/`)

**Estimated time: 2-3 hours**

**Success Criteria:**

- ✅ Tested multiple transfer patterns
- ✅ Created custom policies with constraints
- ✅ Managed contract lifecycle
- ✅ Comfortable switching between UI and API
- ✅ Ran working Chat App example

---

## 🎯 What Can You Test?

### ✅ Basic Operations

- [x] Create assets with HTTP data sources
- [x] Define access and contract policies
- [x] Publish data offers (contract definitions)
- [x] Browse catalogs from other connectors
- [x] Negotiate contracts
- [x] Transfer data (HTTP Push)
- [x] Monitor transfer status

### ✅ Advanced Features

- [x] HTTP Pull with EDR tokens
- [x] Policy constraints (BPN, time-based, etc.)
- [x] Contract termination
- [x] Multiple assets in one offer
- [x] Business partner groups (Catena-X)
- [x] Secrets management
- [x] Custom data sources/sinks

### ✅ Developer Skills

- [x] Management API usage
- [x] JSON-LD understanding
- [x] DSP protocol basics
- [x] Docker orchestration
- [x] Database inspection
- [x] Log analysis
- [x] Health monitoring

---

## 🔧 Common Scenarios

### Scenario 1: Share a REST API

```
Provider:
1. Create asset with HttpData data source
2. Create unrestricted policies
3. Publish contract definition

Consumer:
1. Browse catalog
2. Negotiate contract
3. Initiate HTTP Pull transfer
4. Get EDR token
5. Call API with token
```

### Scenario 2: Batch Data Transfer

```
Provider:
1. Create asset pointing to data endpoint
2. Create access policy (maybe BPN-restricted)
3. Publish offer

Consumer:
1. Browse catalog
2. Negotiate contract
3. Initiate HTTP Push to webhook
4. Monitor transfer
5. Receive data at webhook
```

### Scenario 3: Real-time Data Access

```
Provider:
1. Create asset with live data endpoint
2. Create time-limited contract policy
3. Publish offer

Consumer:
1. Find offer in catalog
2. Negotiate contract
3. Get EDR token
4. Poll data endpoint multiple times
5. Refresh EDR when needed
```

---

## 🐛 Troubleshooting Quick Guide

### Problem: Services won't start

```bash
# Check Docker is running
docker info

# Check ports aren't in use
lsof -i :11000
lsof -i :22000

# View startup logs
docker compose logs provider-connector
```

### Problem: Catalog is empty

```bash
# Check contract definition exists
curl -X POST "$PROVIDER_API/v3/contractdefinitions/request" \
  -H "X-Api-Key: $PROVIDER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"@context":{"edc":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}'

# Check you're using correct participant ID
# Must be: http://provider/api/v1/dsp?participantId=provider
```

### Problem: Negotiation fails

```bash
# Check provider logs
docker compose logs provider-connector | grep -i error

# Verify offer ID is correct
# It should match the policy @id from catalog response

# Check contract policy constraints are met
```

### Problem: Transfer fails

```bash
# Verify data source is accessible
curl https://your-data-source-url

# Check data sink is reachable
curl -X POST https://your-webhook-url -d "test"

# View transfer process details
curl "$CONSUMER_API/v3/transferprocesses/$TRANSFER_ID" \
  -H "X-Api-Key: $CONSUMER_KEY" | jq '.errorDetail'
```

---

## 📂 File Structure

```
edc-ce/
├── LOCAL_SETUP_GUIDE.md       ← Complete setup & testing guide
├── quick-start.sh             ← Interactive setup script
├── API_TESTING_GUIDE.md       ← curl command reference
├── FLOW_DIAGRAMS.md           ← Visual workflow diagrams
├── QUICK_REFERENCE.md         ← One-page cheat sheet
└── docs/
    └── deployment-guide/
        └── goals/
            └── local-demo-ce/
                ├── docker-compose.yaml  ← Docker setup
                └── caddyfiles/          ← Reverse proxy config
```

---

## 🎓 Next Steps

Once you're comfortable with local testing:

### 1. Explore the Chat App

```bash
cd examples/chat-app/source-final
./start.sh
```

- Real-world use case example
- Shows HttpData-PULL + EDR pattern
- Notification callbacks
- Full-stack application

### 2. Read the Documentation

- **Backend Docs**: `/docs/Backend/`
  - Management API details
  - Data transfer types
  - Policy examples
- **Frontend Docs**: `/docs/Frontend/`
  - UI walkthrough
  - Feature guides
- **Deployment Docs**: `/docs/deployment-guide/`
  - Production setup
  - Configuration options

### 3. Join the Community

- GitHub Discussions: https://github.com/sovity/edc-ce/discussions
- GitHub Issues: https://github.com/sovity/edc-ce/issues
- Contact: contact@sovity.de

---

## 💡 Pro Tips

### Tip 1: Use aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias edc-start='cd docs/deployment-guide/goals/local-demo-ce && docker compose up -d'
alias edc-stop='cd docs/deployment-guide/goals/local-demo-ce && docker compose down'
alias edc-logs='cd docs/deployment-guide/goals/local-demo-ce && docker compose logs -f'
alias edc-provider='curl -s -H "X-Api-Key: SomeOtherApiKey"'
alias edc-consumer='curl -s -H "X-Api-Key: SomeOtherApiKey"'
```

### Tip 2: Keep a test script

Save your common test commands in a personal script:

```bash
#!/bin/bash
# my-edc-tests.sh

source ./edc-env.sh  # Your env variables

# Test provider API
edc-provider "$PROVIDER_API/v3/assets/request" | jq .

# Test consumer API
edc-consumer "$CONSUMER_API/v3/contracts" | jq .
```

### Tip 3: Use VS Code Tasks

Create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start EDC Demo",
      "type": "shell",
      "command": "./quick-start.sh start"
    },
    {
      "label": "View EDC Logs",
      "type": "shell",
      "command": "./quick-start.sh logs"
    }
  ]
}
```

---

## 📊 Learning Progress Checklist

Track your progress:

### Basics

- [ ] Started two local connectors
- [ ] Accessed both UIs
- [ ] Created an asset via UI
- [ ] Created policies via UI
- [ ] Published a data offer
- [ ] Browsed catalog from consumer
- [ ] Completed a contract negotiation
- [ ] Executed a data transfer

### API Skills

- [ ] Created asset via API
- [ ] Created policies via API
- [ ] Listed resources via API
- [ ] Requested catalog via API
- [ ] Negotiated contract via API
- [ ] Initiated transfer via API
- [ ] Monitored transfer status
- [ ] Retrieved and used an EDR token

### Advanced

- [ ] Created custom policy constraints
- [ ] Tested contract termination
- [ ] Used HTTP Pull with EDR
- [ ] Inspected database directly
- [ ] Analyzed connector logs
- [ ] Tested with real data sources
- [ ] Set up custom data sinks
- [ ] Ran Chat App example

---

## 🤝 Contributing

Found an issue or have a suggestion?

1. Check existing issues: https://github.com/sovity/edc-ce/issues
2. Open a new issue or discussion
3. Follow the contribution guide: `CONTRIBUTING.md`

---

## 📝 License

These guides are part of the sovity EDC-CE project.

See `LICENSE` for details.

---

**Happy Learning! 🚀**

For questions or help:

- GitHub Discussions: https://github.com/sovity/edc-ce/discussions
- Email: contact@sovity.de
