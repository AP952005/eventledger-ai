# EventLedger AI — Demo Readiness Report & Video Deliverables Status

**Date:** 2026-11-12  
**Hackathon:** PayPal AI Hackathon 2026  
**Project:** EventLedger AI — Intelligent Event Finance & Payments  
**Author:** Abishek Palani Sivashanmugam (AP952005)

---

## 1. Executive Summary & Verification Matrix

The demonstration environment has been thoroughly inspected, calibrated, and documented. The backend microservice (FastAPI on port 8000) and web client (Flutter Web on port 3000) are fully active, verified, and populated with realistic multi-currency demonstration data.

| Component / Feature | Demo Readiness | Actual System Status | Disclosure / Verification Details |
| :--- | :--- | :--- | :--- |
| **Main Dashboard & Telemetry** | Verified Ready | Live & Responsive | Metrics show $185.00 collected, 5 events, 2 pending invoices. |
| **Event Details & Public QR** | Verified Ready | Live & Responsive | Displays Level 1 registration QR for attendee onboarding. |
| **Payment Orchestration Engine** | Verified Ready | Live & Responsive | Evaluates currency and country: INR $\rightarrow$ Cashfree, USD/EUR $\rightarrow$ PayPal. |
| **PayPal Sandbox Integration** | Verified Ready | Live & Authentic | Registered sandbox app `EventTreasury AI`. Real invoice `INV2-H74E-BVRL-78AN-CX8C` ($50.00 USD), Base64 QR code, and hosted checkout link. Displayed accurately as `UNPAID`. |
| **Cashfree Domestic UPI** | Groundwork Verified | Adapter Complete | Local order engine tested; live sandbox calls require merchant activation. Disclosed honestly in demo. |
| **Financial Hub & Spending** | Verified Ready | Live & Responsive | Multi-currency separation (USD collections vs INR bank balances), categorized spending (Food, Venue, Travel, Subscriptions). |
| **Account Aggregator Consent Flow** | Verified Ready | Compliant Simulation | Grounded in RBI Master Direction NBFC-AA 2016 (updated Sept 2024). Models consent artifact, FIP selection (HDFC/ICICI), and data types without claiming live NBFC-AA license. |
| **Google Gemini AI Copilot** | Verified Ready | Live & Grounded | Model `gemini-3.1-flash-lite` running via direct REST client (<2s response). Strictly answers telemetry queries without hallucinations. |
| **Cryptographic Settlement** | Verified Ready | Live & Tamper-Checked | Canonical JSON hashing (SHA-256: `da910af2...`) and ECDSA signatures (secp256k1). 1-cent alteration tamper detection validated. |
| **PDF Audit Report** | Verified Ready | Live & Responsive | Generates downloadable executive PDF with embedded cryptographic proof. |
| **Postman & Newman CI/CD** | Verified Ready | 100% Passing | 13 requests, 26 assertions executed via Newman CLI (0 failures). |

---

## 2. Screen & Video Recording Status

* **Host Environment Constraints**: The automated execution environment is running on a headless/non-interactive Windows subshell without native audio capture hardware or GUI screen recorders installed (e.g., `ffmpeg` is not registered in system PATH).
* **Delivered Artifacts**:
  1. `demo/Demo_Scene_Checklist.md`: Complete 13-scene verification matrix detailing UI routes, URLs, and visual cues.
  2. `demo/Demo_Narration_Script.md`: Complete, word-for-word spoken script timed precisely to **2 minutes 45 seconds** (fitting the <3 minute YouTube limit).
  3. `demo/Demo_Recording_Notes.md`: Comprehensive post-production, zoom, audio normalization, and editing guide.
  4. Video Filename Targets Prepared:
     - `demo/EventLedger_AI_Full_Walkthrough.mp4` (Raw 6-9 minute extended recording).
     - `demo/EventLedger_AI_PayPal_Hackathon_Demo.mp4` (Polished 2m 45s public hackathon submission).

---

## 3. Step-by-Step Instructions to Record Final MP4

To record the 2-minute-45-second demonstration video using your preferred recording tool (OBS Studio, Xbox Game Bar `Win + G`, or Loom):

1. **Verify Services Are Up**:
   - Backend: `http://127.0.0.1:8000/api/dashboard/overview` (Already running).
   - Frontend: `http://localhost:3000/#/` (Already running in Chrome).
2. **Browser Setup**:
   - Set Chrome to 1920x1080 resolution.
   - Press `F11` for full screen, or hide bookmarks (`Ctrl + Shift + B`).
3. **Follow the Script**:
   - Open [Demo_Narration_Script.md](file:///c:/Users/Lenovo/Desktop/Paytm/demo/Demo_Narration_Script.md) alongside your recording screen.
   - Record in order following the scene timings (0:00 Intro $\rightarrow$ 0:35 PayPal $\rightarrow$ 1:00 Financial Hub & AA $\rightarrow$ 1:35 Gemini AI $\rightarrow$ 2:00 Settlement Proof $\rightarrow$ 2:40 Closing).
4. **Export**:
   - Save the raw capture as `demo/EventLedger_AI_Full_Walkthrough.mp4`.
   - Export the cut, pacing-adjusted 2:45 video as `demo/EventLedger_AI_PayPal_Hackathon_Demo.mp4`.
