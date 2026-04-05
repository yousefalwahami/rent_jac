# Rentora (PropOS)

Agentic property management system built with [Jac](https://docs.jaseci.org/) for JacHacks 2026.

SMS comes in → AI triage classifies it → walkers diagnose, assess risk, select vendor → landlord approves → vendor dispatched. All on a live property graph.

## Quick Start

```bash
# 1. Install dependencies
pip install jaclang
uv pip install --python ~/.local/share/uv/tools/jaclang/bin/python twilio

# 2. Set up .env (see Environment Variables below)
cp .env.example .env

# 3. Run
jac start main.jac
```

## Environment Variables

```env
# Twilio
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+1...        # Your Twilio number
TWILIO_TARGET_PHONE_NUMBER=+1... # Your personal phone (for testing + alerts)
OWNER_NAME=Your Name

# AI Inference (by llm() → Groq, free tier)
GROQ_API_KEY=gsk_...

# Persistent Memory (Backboard.io)
BACKBOARD_API_KEY=bk_...
```

## Architecture

### AI Stack

| Layer | Provider | Purpose |
|---|---|---|
| `by llm()` inference | **Groq llama-3.1-8b-instant** via byllm (free) | Triage, diagnosis, vendor selection, risk assessment, SMS drafts |
| Persistent memory | **Backboard.io** via `bb_remember` / `bb_recall` | Cross-session tenant history, vendor track records |
| Graph state | **Jac graph store** (built-in) | Property graph — nodes, edges, walker traversal |

`by llm()` talks to Groq directly (free tier, configured in `jac.toml`). Sign up at console.groq.com to get your free API key.

### Database Layers

```
┌─────────────────────────────────────────────────┐
│  Layer 1: JAC Graph Store (nodes/edges)         │  ← Property graph lives here
│  Default: SQLite (dev) → MongoDB (prod)         │
├─────────────────────────────────────────────────┤
│  Layer 2: store() KV Store                      │  ← SMS logs, walker outputs, events
│  Default: SQLite (dev) → Redis (prod)           │
├─────────────────────────────────────────────────┤
│  Layer 3: Python interop → raw MongoDB/Postgres │  ← Complex queries, full documents
│  (motor, pymongo, asyncpg, etc.)                │
└─────────────────────────────────────────────────┘
```

**For development:** SQLite works out of the box (zero setup).
**For production:** Set `MONGODB_URI` and `REDIS_URL` — Jac handles the switch.

### MongoDB Collections (Production)

```
rentora/
├── users            ← landlord accounts (email, hashed pw, portfolio_id)
├── properties       ← property records (address, units[], owner_id)
├── tenants          ← tenant profiles (name, phone, unit_id, screening_data)
├── leases           ← lease documents (unit_id, tenant_id, rent, start, end, status)
├── tickets          ← maintenance tickets (unit_id, category, status, vendor_id, created, resolved)
├── vendors          ← contractor profiles (name, category, rating, avg_cost, phone, job_history[])
├── sms_messages     ← all inbound/outbound SMS (unit_id, from, body, direction, ts)
├── walker_logs      ← every walker run (walker, unit_id, input, output, duration_ms, ts)
├── payments         ← rent payment records (tenant_id, amount, date, status)
└── notifications    ← approval gates + landlord alerts (type, payload, read, ts)
```

### Quick Decision Guide

| What you're storing | Where | How |
|---|---|---|
| Property graph (units, tenants, leases, vendors) | JAC graph store | Define nodes — auto-persisted to SQLite/MongoDB |
| Inbound SMS messages | MongoDB `sms_messages` | `log_sms()` via Python interop |
| Walker execution logs | MongoDB `walker_logs` | `log_walker_run()` via Python interop |
| Approval gate state | `store()` KV | `store(key="approval:{ticket_id}", value={...})` |
| User accounts (landlords) | JAC auth built-in | `/user/register` + `/user/login` |
| Backboard memory (cross-session history) | Backboard | `bb_remember()` / `bb_recall()` via Python interop |

### Property Graph

```
Root → Property →(HasUnit)→ Unit →(HasLease)→ Lease →(HasTenant)→ Tenant
                 →(Services)→ Vendor
                              Unit →(HasTicket)→ Ticket
```

### AI Pipeline (per SMS)

```
SMS Webhook → Triage Walker → classify_event() [by llm()]
                                    │
                            ┌───────┴───────┐
                            │  MAINTENANCE   │
                            └───────┬───────┘
                                    ▼
                         handle_maintenance walker
                         ├─ diagnose_issue()     [by llm()]
                         ├─ assess_risk()        [by llm()]
                         ├─ select_vendor()      [by llm()]
                         ├─ draft_tenant_reply() [by llm()]
                         ├─ draft_owner_alert()  [by llm()]
                         └─ Create Ticket node
                                    ▼
                         Owner Approval Gate
                                    ▼
                         Vendor Dispatch (SMS)
```

## Project Structure

```
rent_jac/
├── main.jac                          # Entry point — imports all symbols
├── jac.toml                          # Project config + byllm model settings
├── services/
│   ├── graphService.jac              # Hub — re-exports all graph symbols
│   ├── appService.jac                # Twilio SMS, webhook, polling
│   ├── profileService.jac            # User profile management
│   ├── dataService.jac               # Phone matching utilities
│   └── graph/
│       ├── models.jac                # Nodes, edges, enums
│       ├── ai.jac                    # by llm() functions + return types
│       ├── seed.jac                  # Demo property + vendor seed
│       ├── crud.jac                  # Read-only walkers
│       ├── triage.jac                # Triage walker (classification + routing)
│       ├── maintenance.jac           # Maintenance walker (full pipeline)
│       ├── actions.jac               # approve_dispatch, resolve_ticket
│       └── backboard.jac             # Backboard.io memory client
├── index.cl.jac                      # Client app shell + header + sidebar
├── incidents.cl.jac                  # Incidents page (card grid + AI flow detail)
├── dashboard.cl.jac                  # Dashboard
├── sms_inbox.cl.jac                  # SMS inbox
├── settings.cl.jac                   # Settings page
├── login.cl.jac                      # Login/signup
├── shared.cl.jac                     # Shared UI components + helpers
└── .env                              # API keys (not committed)
```

## Testing the Pipeline

1. Register a tenant via the API with your real phone number
2. Send an SMS from that phone to your Twilio number (e.g., "My sink is leaking")
3. Watch the webhook trigger → triage → maintenance → ticket created
4. Check the Incidents page — card shows real AI triage results
5. Click the card → full AI pipeline flow visualization

## Database (Dev)

```bash
sudo apt install sqlitebrowser
sqlitebrowser .jac/data/main.db
```
