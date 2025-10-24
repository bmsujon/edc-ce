# 🎯 EDC Testing: Start Here!

## Choose Your Learning Style

### 🎨 **Option 1: UI-First (Recommended for Beginners)** ⭐

**Best for:** Business users, product managers, first-time EDC users

**Why this approach:**

- ✅ No coding required
- ✅ Visual interface - easier to understand
- ✅ Immediate feedback
- ✅ Great for demos and presentations

**Start with:** `FRONTEND_TESTING_GUIDE.md`

**What you'll do:**

1. Open Provider UI in your browser
2. Create data assets by filling forms
3. Publish data offers with clicks
4. Switch to Consumer UI
5. Browse catalog visually
6. Negotiate contracts
7. Transfer data with buttons

**Time:** 30-45 minutes

---

### 💻 **Option 2: API-First (For Developers)**

**Best for:** Backend developers, DevOps engineers, automation engineers

**Why this approach:**

- ✅ Learn the API for integration
- ✅ Automate workflows
- ✅ Scriptable and repeatable
- ✅ Perfect for CI/CD

**Start with:** `EDC_API_WORKFLOW_COMPLETE.md` ⭐ **NEW!**

**What you'll do:**

1. Use curl commands for full E2E workflow
2. Test both HTTP Pull and HTTP Push transfers
3. Learn JSON-LD format requirements
4. Run automated test scripts
5. Build production-ready integrations

**Bonus:** Ready-to-run scripts: `edc-test-pull.sh` and `edc-test-push.sh`

**Alternative:** `API_TESTING_GUIDE.md` (older, reference-style guide)

**Time:** 1-2 hours

---

### 🚀 **Option 3: Hybrid (Both UI + API)**

**Best for:** Full-stack developers, technical architects, advanced users

**Why this approach:**

- ✅ Complete understanding
- ✅ Flexibility in implementation
- ✅ Debug with both tools
- ✅ Production-ready knowledge

**Start with:** `LOCAL_SETUP_GUIDE.md`

**What you'll do:**

1. Test workflows in UI first
2. Replicate same flows with API
3. Use UI for monitoring
4. Use API for automation
5. Mix approaches as needed

**Time:** 2-3 hours

---

## 🏢 Understanding the Two Roles

Every EDC data exchange involves **two parties**:

### 📤 Provider (Data Owner)

- **URL:** http://localhost:11000
- **Role:** Shares data
- **Actions:**
  - Creates assets
  - Defines policies
  - Publishes offers
  - Monitors access

### 📥 Consumer (Data Requestor)

- **URL:** http://localhost:22000
- **Role:** Requests data
- **Actions:**
  - Browses catalogs
  - Negotiates contracts
  - Initiates transfers
  - Consumes data

**💡 Pro Tip:** Open both URLs in different browser windows to see both perspectives simultaneously!

---

## ⚡ Quick Start (Under 5 Minutes)

### Step 1: Start Services

```bash
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d
```

### Step 2: Wait (Important!)

Wait **60 seconds** for all services to initialize.

### Step 3: Open UIs

Open two browser tabs:

- Provider: http://localhost:11000
- Consumer: http://localhost:22000

### Step 4: Follow a Guide

Pick one guide based on your preference above and follow it!

---

## 📚 All Available Guides

| Guide                         | Focus           | Audience           | Time    | Difficulty  |
| ----------------------------- | --------------- | ------------------ | ------- | ----------- |
| **FRONTEND_TESTING_GUIDE.md** | UI-only testing | Beginners          | 45 min  | ⭐ Easy     |
| **API_TESTING_GUIDE.md**      | curl & API      | Developers         | 1-2 hrs | ⭐⭐ Medium |
| **LOCAL_SETUP_GUIDE.md**      | Both UI + API   | Everyone           | 2-3 hrs | ⭐⭐ Medium |
| **FLOW_DIAGRAMS.md**          | Visual diagrams | Visual learners    | 15 min  | ⭐ Easy     |
| **QUICK_REFERENCE.md**        | Cheat sheet     | Quick lookup       | 5 min   | ⭐ Easy     |
| **quick-start.sh**            | Automation      | Command-line users | 10 min  | ⭐⭐ Medium |

---

## 🎯 Learning Objectives

By the end of any guide, you will:

✅ **Understand** the EDC architecture and dataspace concepts  
✅ **Create** data assets with real data sources  
✅ **Define** access and contract policies  
✅ **Publish** data offers to the dataspace  
✅ **Browse** catalogs from other connectors  
✅ **Negotiate** contracts between parties  
✅ **Transfer** data using HTTP Push or Pull  
✅ **Monitor** transfer status and handle errors

---

## 🎬 Complete Data Exchange Flow

Here's what happens in a typical EDC data exchange:

### Phase 1: Provider Setup

1. **Provider** creates a data asset (points to actual data)
2. **Provider** creates policies (who can access, under what terms)
3. **Provider** publishes data offer (makes visible in dataspace)

### Phase 2: Consumer Discovery

4. **Consumer** browses catalog from Provider
5. **Consumer** finds relevant data offer
6. **Consumer** reviews policies and constraints

### Phase 3: Contract Negotiation

7. **Consumer** initiates contract negotiation
8. **Provider** evaluates request against policies
9. **Contract** is agreed and finalized (if policies met)

### Phase 4: Data Transfer

10. **Consumer** initiates data transfer
11. **Provider** prepares data from source
12. **Data** is transferred via HTTP Push or Pull
13. **Consumer** receives/accesses data

**💡 Both UI and API support this complete flow!**

---

## 🐛 Common Questions

### Q: Which guide should I start with?

**A:** If unsure, start with **FRONTEND_TESTING_GUIDE.md** - it's the easiest and requires no coding.

### Q: Can I use both UI and API together?

**A:** Yes! Use UI to understand visually, then use API to automate. Check **LOCAL_SETUP_GUIDE.md** for this approach.

### Q: Do I need to know programming?

**A:** No! The **FRONTEND_TESTING_GUIDE.md** uses only the web interface with clicks and forms.

### Q: I'm a developer - which guide for me?

**A:** Start with **API_TESTING_GUIDE.md** to learn the Management API directly.

### Q: How long to complete everything?

**A:**

- Basic understanding: 30-45 minutes (FRONTEND_TESTING_GUIDE.md)
- API proficiency: 1-2 hours (API_TESTING_GUIDE.md)
- Advanced mastery: 3-4 hours (all guides + chat-app example)

### Q: What if I get stuck?

**A:** Each guide has a detailed troubleshooting section. Also check:

- Docker logs: `docker compose logs -f`
- Provider UI dashboard for errors
- Consumer transfer history for status

---

## 🎓 Recommended Learning Paths

### Path A: Business/Product Role

1. Read this START_HERE.md (you are here!)
2. Follow FRONTEND_TESTING_GUIDE.md completely
3. Review FLOW_DIAGRAMS.md to visualize
4. Done! You understand EDC concepts.

### Path B: Frontend Developer Role

1. Read this START_HERE.md
2. Follow FRONTEND_TESTING_GUIDE.md (learn UI)
3. Inspect browser Network tab (see API calls)
4. Follow API_TESTING_GUIDE.md (learn API)
5. Review LOCAL_SETUP_GUIDE.md (advanced topics)

### Path C: Backend Developer Role

1. Read this START_HERE.md
2. Follow API_TESTING_GUIDE.md (learn API first)
3. Test with Postman/Insomnia
4. Build automation scripts
5. Review FRONTEND_TESTING_GUIDE.md (understand UI)

### Path D: DevOps/Architect Role

1. Read this START_HERE.md
2. Follow LOCAL_SETUP_GUIDE.md (comprehensive)
3. Review docker-compose.yaml in detail
4. Test both UI and API approaches
5. Explore deployment-guide docs
6. Test Chat App example

---

## 🔗 External Resources

- **Official Docs:** Detailed documentation in `/docs/` folder
- **Examples:** Working Chat App in `/examples/chat-app/`
- **GitHub:** https://github.com/sovity/edc-ce
- **Discussions:** https://github.com/sovity/edc-ce/discussions

---

## ✅ Quick Checklist

Before starting, make sure you have:

- [ ] Docker Desktop installed and running
- [ ] 60 seconds of patience (services take time to start)
- [ ] Two browser tabs ready (for Provider and Consumer UIs)
- [ ] Chosen a guide based on your role (see above)
- [ ] Internet connection (to pull Docker images)

---

## 🚀 Ready? Let's Start!

### If you want UI-first:

```bash
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d
# Wait 60 seconds
# Open: http://localhost:11000 and http://localhost:22000
# Follow: FRONTEND_TESTING_GUIDE.md
```

### If you want API-first:

```bash
cd docs/deployment-guide/goals/local-demo-ce
docker compose up -d
# Wait 60 seconds
# Follow: API_TESTING_GUIDE.md
```

### If you want automation:

```bash
./quick-start.sh
# Select option 1, then option 3
# Follow prompts
```

---

**Happy Learning! 🎉**

Need help? Check the troubleshooting sections in each guide or ask in [GitHub Discussions](https://github.com/sovity/edc-ce/discussions).
