# EventLedger AI — Master Hackathon Demo Narration Script
**Project:** EventLedger AI — Intelligent Event Finance & Payments  
**Target Duration:** 2 minutes 45 seconds (Public YouTube Video)  
**Presenter Tone:** Authoritative, articulate fintech engineer, clear pacing.

---

### [00:00 – 00:15] Scene 1: Problem & Product Introduction
*Visual: Clean browser window at `http://localhost:3000/#/`. Clean blue/teal EventLedger AI branding.*

**Narration:**
> "Managing event finances is far more complicated than collecting registration fees. Organizers juggle ticketing portals, payment gateways, UPI apps, and personal bank accounts—creating a dangerous financial data blindspot where event ticket revenue and external vendor expenses never talk to each other.
>
> Welcome to **EventLedger AI**: an intelligent event finance platform combining PayPal payments, consent-driven account aggregation, and cryptographically verifiable settlement records into one unified workspace."

---

### [00:15 – 00:35] Scene 2 & 3: Main Dashboard & Event Management
*Visual: Hovering over the Metrics Cards ($185.00 collected across 5 events), clicking into 'Global AI & Fintech Summit 2026'. Showing attendee roster and the Level 1 Registration QR code.*

**Narration:**
> "Here on the Organizer Dashboard, we see our live financial telemetry: verified collections, pending invoices, and active events. 
> 
> When we drill into the 'Global AI & Fintech Summit', we see our registered participants. EventLedger AI provides a dual-level QR architecture: Level 1 is this public registration QR for onboarding attendees, while Level 2 generates personalized, dynamic payment QR codes upon checkout."

---

### [00:35 – 01:00] Scene 4 & 5: Payment Orchestration & PayPal Sandbox
*Visual: Navigating to the Checkout screen. Opening PayPal Invoicing flow. Showing the real PayPal Sandbox Invoice ID `INV2-H74E-BVRL-78AN-CX8C`, the 700-byte Base64 QR code, and the hosted PayPal invoice checkout link.*

**Narration:**
> "Under the hood, our server-side Payment Orchestration engine evaluates payer geography and currency. While domestic Indian payments route to UPI, international attendees paying in US Dollars or Euros are seamlessly routed to PayPal.
> 
> Powered by our registered PayPal Developer Sandbox application—**EventTreasury AI**—the backend invokes the PayPal Invoicing API v2 using OAuth 2.0. Here is an actual sandbox invoice generated live on PayPal's servers, complete with PayPal's official Base64 QR payload and hosted checkout link. We display its current status truthfully as UNPAID until completed by a sandbox buyer."

---

### [01:00 – 01:35] Scene 6, 7 & 8: Financial Hub & RBI Account Aggregator Framework
*Visual: Clicking 'Financial Hub' on the navigation drawer (`/financial-hub`). Showing the Net Worth, Bank Balances, and Category Spending breakdown. Then clicking 'Connect New Bank' (`/financial-hub/consent`). Showing HDFC/ICICI selection, consent artifact details (validity, frequency, data types), and simulated approval.*

**Narration:**
> "Now, here is EventLedger AI's core differentiator: the **Financial Hub**. 
>
> An event app that only tracks its own ticket fees is financially blind. Organizers pay venue deposits, caterers, and travel reimbursements from their bank accounts. 
>
> Grounded in the **Reserve Bank of India's Account Aggregator Master Directions**, EventLedger AI models a consent-driven banking layer. In this simulated AA flow, the organizer acts as the account owner, selecting their Financial Information Provider—such as HDFC or ICICI—and granting explicit, time-bound consent. 
>
> Once linked, the platform categorizes real operational outflows—Venue, Food, Travel, Utilities—and calculates true net worth and liquid runway alongside our PayPal event revenue."

---

### [01:35 – 02:00] Scene 9: Grounded Google Gemini AI Copilot
*Visual: Opening the floating PayGo AI Copilot on the bottom right. Typing: "Summarize our financial position and pending invoices". The Gemini copilot returns a concise, accurate 2-sentence response grounded in live telemetry.*

**Narration:**
> "To make sense of all this data, we integrated **Google Gemini 3.1 Flash-Lite**. 
> 
> Rather than hallucinating or dumping unrelated text, Gemini is strictly grounded in our live application telemetry and multi-currency ledger. When we ask: *'Summarize our financial position and pending invoices'*, Gemini immediately identifies our verified collections across events and lists our exact pending attendees—Marcus Vance and Aisha Morales—with zero fluff."

---

### [02:00 – 02:25] Scene 10: Cryptographic Settlement Verification
*Visual: Navigating to 'Silicon Valley Founders Pitch Night' (status CLOSED). Expanding the Cryptographic Proof panel. Showing Canonical JSON snapshot, SHA-256 digest (`da910af2...`), and ECDSA signature. Clicking 'Verify Signature' $\rightarrow$ Green Valid indicator.*

**Narration:**
> "Financial records must be tamper-proof. When an event concludes, EventLedger AI locks the master ledger and generates an immutable canonical JSON snapshot. 
> 
> The snapshot is hashed using SHA-256 and cryptographically signed using an elliptic-curve digital signature (secp256k1). If an unauthorized actor modifies a single attendee amount by even one cent, the cryptographic verification immediately flags the tampering."

---

### [02:25 – 02:40] Scene 11 & 12: PDF Audit Report & Postman CI/CD
*Visual: Clicking 'Download Audit PDF'. Opening the generated PDF with full event breakdown, QR code, and cryptographic hash. Flashing terminal/Newman report showing 13 requests and 26 assertions passing.*

**Narration:**
> "With one click, organizers can compile this verifiable settlement proof into an executive PDF audit report ready for sponsors, corporate finance, or tax auditors.
>
> Our entire architecture is backed by an automated Postman and Newman CI/CD test suite, with 100% of our API and financial math assertions passing."

---

### [02:40 – 02:50] Scene 13: Closing & Title Card
*Visual: Returning to the Main Home Dashboard. Hovering over the EventLedger AI logo and tagline.*

**Narration:**
> "From collecting global event payments to multi-account financial intelligence, EventLedger AI bridges the gap between event ticketing and real financial operations.
>
> **EventLedger AI — Intelligent Event Finance & Payments.** Thank you."
