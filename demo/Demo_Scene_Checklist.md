# EventLedger AI — Demo Scene Checklist & Verification Matrix

This checklist specifies the exact UI screen, backend trigger, and visual checks for each scene in both the **Full Walkthrough** and the **Final Hackathon Cut (2m 45s)**.

| Scene # | Scene Title | UI Screen / Route | Target URL / Action | Verified Feature / Telemetry Check |
| :--- | :--- | :--- | :--- | :--- |
| **01** | Introduction & Product Value | Header Branding / Splash | `http://localhost:3000/#/` | Displays "EventLedger AI — Intelligent Event Finance & Payments". States problem: financial data blindspot across accounts. |
| **02** | Main Dashboard & Analytics | Home Dashboard | `http://localhost:3000/#/` | Verified metrics ($185.00 collected across 5 events), active events table, recent activity audit feed. |
| **03** | Event Creation & Registration | Event Details & Attendees | `http://localhost:3000/#/events/evt-paypal-001` | Displays Global AI & Fintech Summit 2026 ($45.00 ticket fee). Shows Level 1 Public Registration QR code. |
| **04** | Payment Orchestration Engine | Payment Routing & Order Modal | `POST /api/payments/eligibility` | Evaluates payer country and currency: INR $\rightarrow$ Cashfree UPI; USD/EUR $\rightarrow$ PayPal Invoicing v2. |
| **05** | PayPal Developer Sandbox (Invoicing v2) | Hosted Checkout & Invoice QR | `http://localhost:3000/#/checkout` | Demonstrates real PayPal Sandbox Invoicing (`INV2-H74E-BVRL-78AN-CX8C`). Shows Level 2 700-byte Base64 QR code and hosted URL. Status clearly shown as `UNPAID` (real sandbox state). |
| **06** | Cashfree UPI Integration | Domestic UPI Checkout | `http://localhost:3000/#/checkout` | Demonstrates domestic UPI Intent/QR architecture, noting activation prerequisite for live processing. |
| **07** | Financial Hub & Cashflow Analytics | Financial Hub Screen | `http://localhost:3000/#/financial-hub` | Core differentiator: Displays net worth, liquid balances, categorized burn (Food, Venue, Travel, Utilities), and runway. |
| **08** | Consent-Driven Account Aggregator Flow | AA Consent Portal | `http://localhost:3000/#/financial-hub/consent` | Grounded in RBI AA Framework (Directions updated Sept 2024). FIP selection (HDFC, ICICI, Axis), purpose definition, and consent execution. |
| **09** | Google Gemini AI Copilot | Floating AI Copilot Widget | Floating modal on all screens | Natural language Q&A grounded in live telemetry. Questions: "Summarize financial position", "What are our pending invoices?". Direct, non-hallucinated answers. |
| **10** | Cryptographic Settlement & Tamper Proof | Audit Verification Portal | `http://localhost:3000/#/events/evt-paypal-003` | Silicon Valley Founders Pitch Night (CLOSED). Shows canonical SHA-256 digest (`da910af2...`) and secp256k1 signature. Shows tamper detection alert on 1-cent alteration. |
| **11** | PDF Audit Report Generation | Executive PDF Exporter | `http://localhost:3000/#/events/evt-paypal-001/pdf` | Client-side compilation of verified attendees, payment gateway references, and cryptographic signature into a downloadable PDF. |
| **12** | Architecture, Postman & Newman Suite | Technical Summary / Terminal | Postman Collection / Newman CLI | 13 automated requests across 5 suites, 26 assertions passing at 100%. Python unit tests 16/16. |
| **13** | Closing & Hackathon Summary | Main Title Card | `http://localhost:3000/#/` | Final summary: "EventLedger AI — Intelligent Event Finance & Payments". |

---

## Pre-Recording Sanity Checks
- [x] Backend running on port 8000 (`uvicorn main:app`).
- [x] Flutter Web running on port 3000 (`flutter run -d chrome --web-port 3000`).
- [x] PayPal Sandbox credentials verified (`EventTreasury AI` REST application).
- [x] Gemini API key configured with responsive `< 2s` latency.
- [x] Seed data initialized with distinct currencies and realistic ledger entries.
- [x] Browser resolution set to 1920x1080 with clean window profile.

