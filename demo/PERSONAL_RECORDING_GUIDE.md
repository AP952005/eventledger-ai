# EventLedger AI — Personal Demo Recording Guide & Workflow

This step-by-step recording guide ensures your live demonstration flows smoothly, tells a compelling financial story, and highlights both PayPal payments and Account Aggregator cashflows.

---

## 1. Initial State Summary (Already Set Up in Application)
- **Active Events**: Exactly 2 events pre-seeded:
  1. `Global AI & Fintech Summit 2026` — **ACTIVE** (Ticket: $45.00 USD, Target: $4,500.00).
  2. `Silicon Valley Founders Pitch Night` — **CLOSED** (Settled with SHA-256 and ECDSA cryptographic proof).
- **Recent Activity Feed**: **EMPTY (0 items)** — ready to show live population as you perform actions.
- **Financial Hub**: **EMPTY STATE** ("No bank accounts linked yet") — ready to demonstrate the RBI Account Aggregator consent flow.

---

## 2. Step-by-Step Recording Sequence

### Step 1: Show Clean Starting State
- **URL**: `http://localhost:3000/#/`
- **What to say & show**:
  - Show the clean **Home Dashboard**.
  - Point out that we have **1 ACTIVE event** and **1 CLOSED event**.
  - Show that **Recent Activity** is currently empty because no new live transactions or links have been performed in this session.

---

### Step 2: Create a New Event for a "Trip" Using Gemini AI
- **Action**: Click the **"+ Create Event"** button or navigate to `#/events/create`.
- **In the AI Prompt Field**, type or paste:
  > *"Organize a weekend Goa beach trip for 20 tech friends at 50 USD per person with target 1000 USD"*
- **Click**: **"AI Generate Details"** (or parse button).
- **What happens**:
  - Gemini AI immediately extracts and populates:
    * **Title**: `Goa Tech Friends Retreat 2026`
    * **Category**: `Social & Travel`
    * **Amount**: `50.00 USD`
    * **Target**: `1000.00 USD`
    * **Expected Participants**: `20`
- **Click**: **"Create Event & Initialize Ledger"**.
- **Result**: The new event is created and now appears alongside your other events.

---

### Step 3: Register an Attendee & Show Payment Orchestration (PayPal Sandbox)
- **Action**: Go into your newly created trip or `Global AI & Fintech Summit 2026`.
- **Register Attendee**: Add an attendee (e.g., `Alex Rivera`, `alex.rivera@example.com`).
- **Proceed to Payment Checkout** (`#/checkout`):
  - **Explain**: *"Because Alex is paying in USD internationally, EventLedger's payment orchestration routes them directly to PayPal Invoicing API v2."*
  - **Show**:
    1. The live PayPal Sandbox invoice reference: `INV2-H74E-BVRL-78AN-CX8C`.
    2. The generated PayPal Level 2 Base64 QR code.
    3. The hosted invoice checkout link (`https://www.sandbox.paypal.com/invoice/p/...`).
    4. Note that the invoice is `UNPAID` in Sandbox awaiting buyer execution.

---

### Step 4: Financial Hub — Connect Bank via RBI Account Aggregator
- **Action**: Open the navigation drawer and click **"Financial Hub"** (`#/financial-hub`).
- **Show Initial State**:
  - The screen displays an **Empty State** with a message: *"No financial accounts linked yet. Connect a bank account using our consent-driven Account Aggregator flow."*
- **Connect Bank**:
  - Click **"+ Link Bank Account"** (goes to `#/financial-hub/consent`).
  - Explain: *"An event app only sees ticket collections. To see real cashflow and vendor burn, the organizer connects their bank via the RBI Account Aggregator framework."*
  - Select **HDFC Bank** (or State Bank of India), review the consent parameters (validity, purpose, data types), and click **"Grant Consent"**.
- **Show Populated Financial Hub**:
  - Instantly, the dashboard updates:
    * **Total Net Worth & Liquid Balances**: Now displays real bank balances.
    * **Cash Flow Breakdown**: Monthly Inflow vs Outflow.
    * **Categorized Spending Chart**: Food & Beverage, Venue Logistics, Travel, and Subscriptions.
    * **Transaction History**: Displays recent debits (e.g., venue deposit, caterers) alongside PayPal event inflows.

---

### Step 5: Ask Gemini AI Copilot About Finances & Events
- **Action**: Click the floating blue **PayGo AI Copilot** icon at the bottom right.
- **Ask Query 1**:
  > *"Summarize our financial position and pending event invoices."*
  - Gemini returns a crisp, grounded summary showing verified collections and pending participants.
- **Ask Query 2**:
  > *"Which events do we have active right now?"*
  - Gemini immediately lists your active events including the newly created Goa retreat.

---

### Step 6: Show Cryptographic Settlement & Tamper Proof
- **Action**: Go to **Silicon Valley Founders Pitch Night** (`#/events/evt-paypal-003`).
- **Show Closed Event**:
  - Status is **CLOSED**.
  - Scroll down to the **Cryptographic Settlement** section.
  - Show the **SHA-256 Canonical Snapshot Hash** (`da910af2...`) and **ECDSA Digital Signature**.
  - Click **"Verify Settlement Proof"** $\rightarrow$ shows **VALID (Untampered)**.
  - Explain: *"If anyone alters an attendee ledger by even 1 cent, this cryptographic check fails."*

---

### Step 7: Export Executive PDF Audit Report
- **Action**: Click **"Download Audit PDF"** on the event page.
- **Show**: The generated PDF report with the event ledger, attendee table, PayPal invoice reference, and embedded cryptographic hash.

---

## 3. How to Explain Event Usage vs Cashflow & PayPal (Key Narration Points)

When you record, use this simple 3-part mental model to explain why PayPal and Cashflow exist together:

1. **PayPal = Inflow Rail (Global Event Ticket Sales)**:
   - *"PayPal is our global collection gateway. It generates itemized invoices and QR codes so international attendees can pay in USD or EUR."*
2. **Account Aggregator / Financial Hub = Outflow & Context Rail (Real Vendor Expenses)**:
   - *"Ticket sales are only half the story. When an organizer books a beach villa in Goa, pays caterers, or rents sound equipment, that money leaves their bank account, not the ticketing app. The Financial Hub connects to the organizer's bank to track those real vendor outflows."*
3. **EventLedger AI = The Intelligent Bridge**:
   - *"By bringing PayPal ticket revenue and bank cashflow into one workspace, Gemini AI can tell the organizer: 'You collected $1,000 via PayPal, but your Goa villa deposit is $700—leaving $300 in liquid event margin.' That is true event financial intelligence."*

