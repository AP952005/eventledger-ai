# EventLedger AI — Demo Recording & Post-Production Notes

## Recording Environment Guidelines
* **Target Aspect Ratio & Resolution**: 16:9 widescreen at 1920x1080 (Full HD).
* **Browser**: Google Chrome at 100% zoom level, bookmarks bar hidden (`Ctrl+Shift+B`), full screen (`F11`).
* **Active URLs**:
  * Frontend: `http://localhost:3000/`
  * Backend API Docs (if showing Swagger): `http://127.0.0.1:8000/docs`
  * Newman CLI Terminal: Running from `c:\Users\Lenovo\Desktop\Paytm`
* **Audio Setup**: Dedicated cardioid microphone, clean room acoustics, no clipping, sample rate 48kHz, voice normalized to -14 LUFS.

---

## Screen-by-Screen Visual Cues & Actions

### Scene 1: Home Dashboard & Intro (0:00 - 0:15)
- Open Chrome at `http://localhost:3000/`.
- Ensure metrics display: `$185.00 Collected`, `5 Events`, `2 Pending Invoices`.
- Mouse movement: Hover gently over the top left app title **EventLedger AI**, then pan down across the summary cards.

### Scene 2: Event Details & Dual-Level QR (0:15 - 0:35)
- Click on **Global AI & Fintech Summit 2026** in the event table.
- Scroll down to participant list (Elena Rostova, Sophia Lin - Paid; Marcus Vance - Pending).
- Click **View Public Registration QR**. Modal pops up showing Level 1 Registration QR. Close modal.

### Scene 3: Payment Orchestration & PayPal Sandbox (0:35 - 1:00)
- Navigate to the Payment Checkout demonstration screen or simulate Marcus Vance's checkout.
- Show the routing decision badge: `International Payer (USD) -> Routed to PayPal Invoicing API v2`.
- Show the invoice details:
  * Invoice ID: `INV2-H74E-BVRL-78AN-CX8C`
  * Gateway: PayPal Sandbox REST API v2
  * Status Badge: `UNPAID (Sandbox Awaiting Buyer)`
  * PayPal Invoice QR: Base64 QR rendered crisply.
  * Hosted Link: Click or hover over `https://www.sandbox.paypal.com/invoice/p/...`.

### Scene 4: Financial Hub & RBI Account Aggregator Consent (1:00 - 1:35)
- Click **Financial Hub** in the drawer navigation (`#/financial-hub`).
- Point out the Net Worth summary: Consolidated INR bank balances and separated USD event collections.
- Highlight the **Category Spending Chart**: Food & Beverage, Venue Logistics, Travel, Subscriptions.
- Click **+ Link Bank Account** (`#/financial-hub/consent`).
- Highlight the RBI Account Aggregator compliance notice:
  * Master Direction NBFC-AA 2016 (updated Sept 2024).
  * 4 Entities: User, FIP (HDFC/ICICI), AA (Regulated intermediary), FIU (EventLedger AI).
  * Clear disclaimer that AA is for data sharing, not payment execution.
- Select **HDFC Bank**, choose **All Accounts**, review date range, and click **Grant Consent (Simulated)**.
- Observe success confirmation and updated bank ledger.

### Scene 5: Google Gemini AI Copilot (1:35 - 2:00)
- Click the floating blue **AI Copilot** button at the bottom right.
- In the input field, submit:
  `Summarize our financial position and pending invoices.`
- Observe response generated in ~1.5s:
  * Verified collections: $185.00 USD.
  * 2 pending invoices: Marcus Vance ($45.00) and Aisha Morales ($15.00).
- Highlight the concise, grounded nature of the response (zero hallucinations, zero boilerplate).

### Scene 6: Cryptographic Settlement Proof & Tamper Check (2:00 - 2:25)
- Navigate to **Silicon Valley Founders Pitch Night** (`#/events/evt-paypal-003`).
- Note event status: `CLOSED & SETTLED`.
- Scroll to **Cryptographic Audit Proof**:
  * Show Canonical Snapshot JSON.
  * Show SHA-256 Digest: `da910af22097782169543e49e7943c224eb29b3c9597ea9457223b9d6bc44498`.
  * Show ECDSA Digital Signature (secp256k1).
  * Click **Verify Audit Integrity** $\rightarrow$ Green badge: `Signature & Hash Valid`.
  * If demonstrating tamper test: mention that altering Elena Rostova's amount to $45.01 immediately turns the badge red (`HASH MISMATCH - TAMPER DETECTED`).

### Scene 7: PDF Report & Engineering Architecture (2:25 - 2:40)
- On the event detail screen, click **Export Audit PDF**.
- Show the formatted PDF document containing header, attendee table, PayPal transaction references, and embedded cryptographic hash.
- Switch briefly to terminal or slide showing Newman test results:
  * `13 requests, 26 assertions, 0 failures (100% pass)`.
  * PayPal & Gemini REST microservices.

### Scene 8: Closing (2:40 - 2:50)
- Switch back to clean Home Dashboard at `http://localhost:3000/`.
- Conclude with project identity: **EventLedger AI — Intelligent Event Finance & Payments**.

---

## Technical Fallbacks & Disclosures
1. **Cashfree Sandbox**: Disclosed as groundwork/adapter-complete, noting merchant activation requirement for live orders.
2. **Account Aggregator**: Disclosed as a compliant simulation modeling RBI AA framework without requiring live NBFC-AA production licenses.
3. **PayPal Invoice**: Displayed accurately as `UNPAID` in Sandbox, proving authentic API interaction rather than falsified completed receipts.

