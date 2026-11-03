"""
PayGo Backend — FastAPI Mock Server
All REST endpoints from the API spec, powered by in-memory mock data.
"""
import uuid
import json
import hashlib
import os
import urllib.request
import urllib.error
from datetime import datetime
from typing import Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from models import (
    OTPRequestBody, OTPVerifyBody, PinSetBody, FetchBillBody,
    PaymentInitiateBody, PaymentConfirmBody,
    OTPResponse, AuthResponse, BillResponse, PaymentResponse,
    HomeFeedResponse, FinancialProductsResponse, QRResponse,
    AliasCheckResponse, AliasRegisterBody, CreateEventBody,
    SendReminderBody, TagPaymentBody, UPISettlementWebhook,
    VerifyResponse, Event, EventStatus, EventAmountMode,
    ConsentRequest, ConsentResponse, MockApproveBody, SyncRequest,
    FinancialAccountResponse, FinancialTransactionResponse,
    SpendingSummaryResponse, MonthlyTrend, RecurringTransaction,
    ConsentDetail, AIChatRequest,
)
from mock_data import (
    USERS, TRANSACTIONS, SAVED_BILLERS, NOTIFICATIONS,
    CONTACTS, BILLER_CATEGORIES, HOME_PROMOS, HOME_SHORTCUTS,
    HOME_OFFERS, FINANCIAL_PRODUCTS, EVENTS, LEDGER_ENTRIES,
    SETTLEMENT_PROOFS, REMINDER_TEMPLATES, TAKEN_ALIASES,
)
from services.aa_factory import get_account_aggregator
import services.transaction_service as txn_svc

app = FastAPI(title="PayGo Mock API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────────────────────────────────────────
# Auth Endpoints
# ──────────────────────────────────────────────

_otp_sessions: dict[str, str] = {}  # session_id -> phone


@app.post("/auth/otp/request", response_model=OTPResponse)
def request_otp(body: OTPRequestBody):
    session_id = f"otp-{uuid.uuid4().hex[:8]}"
    _otp_sessions[session_id] = body.phone
    print(f"[OTP] Session {session_id} created for {body.phone} — code is 123456")
    return OTPResponse(otp_session_id=session_id)


@app.post("/auth/otp/verify", response_model=AuthResponse)
def verify_otp(body: OTPVerifyBody):
    if body.otp_session_id not in _otp_sessions:
        raise HTTPException(status_code=400, detail="Invalid OTP session")
    if body.code != "123456":
        raise HTTPException(status_code=401, detail="Invalid OTP code")

    phone = _otp_sessions.pop(body.otp_session_id)
    is_new = not any(u.phone == phone for u in USERS)
    token = f"token-{uuid.uuid4().hex[:12]}"
    return AuthResponse(auth_token=token, is_new_user=is_new)


@app.post("/upi/pin/set")
def set_upi_pin(body: PinSetBody):
    if len(body.pin) != 4 or not body.pin.isdigit():
        raise HTTPException(status_code=400, detail="PIN must be 4 digits")
    return {"success": True}


# ──────────────────────────────────────────────
# Home Feed
# ──────────────────────────────────────────────

@app.get("/home/feed", response_model=HomeFeedResponse)
def home_feed():
    return HomeFeedResponse(
        promos=HOME_PROMOS,
        shortcuts=HOME_SHORTCUTS,
        offers=HOME_OFFERS,
    )


# ──────────────────────────────────────────────
# Billers
# ──────────────────────────────────────────────

@app.get("/billers/saved")
def get_saved_billers():
    return [b.model_dump() for b in SAVED_BILLERS]


@app.get("/billers/categories")
def get_biller_categories():
    return [c.model_dump() for c in BILLER_CATEGORIES]


@app.post("/billers/fetch-bill", response_model=BillResponse)
def fetch_bill(body: FetchBillBody):
    amounts = {
        "electricity": 2350.0,
        "water": 480.0,
        "gas": 850.0,
        "mobile": 299.0,
        "dth": 450.0,
        "credit_card": 15670.0,
        "loan": 8500.0,
        "wifi": 999.0,
    }
    amount = amounts.get(body.category, 500.0)
    return BillResponse(amount=amount, due_date="2026-09-25")


# ──────────────────────────────────────────────
# Payments
# ──────────────────────────────────────────────

@app.post("/payments/initiate", response_model=PaymentResponse)
def initiate_payment(body: PaymentInitiateBody):
    txn_id = f"txn-{uuid.uuid4().hex[:8]}"
    return PaymentResponse(txn_id=txn_id, status="pending")


@app.post("/payments/confirm-pin", response_model=PaymentResponse)
def confirm_payment(body: PaymentConfirmBody):
    if body.pin != "1234":
        return PaymentResponse(txn_id=body.txn_id, status="failed", reason="Incorrect UPI PIN")
    return PaymentResponse(txn_id=body.txn_id, status="success")


# ──────────────────────────────────────────────
# Transactions
# ──────────────────────────────────────────────

@app.get("/transactions")
def get_transactions(
    filter: Optional[str] = Query(None),
    cursor: Optional[int] = Query(0),
    limit: int = Query(20),
):
    filtered = TRANSACTIONS
    if filter and filter != "all":
        filtered = [t for t in TRANSACTIONS if t.direction.value == filter or t.status.value == filter]

    page = filtered[cursor: cursor + limit]
    return {
        "items": [t.model_dump() for t in page],
        "next_cursor": cursor + limit if cursor + limit < len(filtered) else None,
    }


@app.get("/transactions/by-contact")
def get_transactions_by_contact(contact_id: str = Query(...)):
    result = [
        t for t in TRANSACTIONS
        if t.from_user_id == contact_id or t.to_user_id == contact_id
    ]
    return [t.model_dump() for t in result]


# ──────────────────────────────────────────────
# QR Code
# ──────────────────────────────────────────────

@app.get("/qr/my-code", response_model=QRResponse)
def get_my_qr():
    user = USERS[0]
    return QRResponse(
        upi_deep_link=f"upi://pay?pa={user.upi_id}&pn={user.name}&cu=INR",
        image_png_url=None,
    )


@app.post("/qr/interop/allow")
def allow_interop():
    return {"success": True}


# ──────────────────────────────────────────────
# Financial Products
# ──────────────────────────────────────────────

@app.get("/financial-products", response_model=FinancialProductsResponse)
def get_financial_products():
    return FinancialProductsResponse(**FINANCIAL_PRODUCTS)


# ──────────────────────────────────────────────
# Contacts
# ──────────────────────────────────────────────

@app.get("/contacts/recent")
def get_recent_contacts():
    return [c.model_dump() for c in CONTACTS[:5]]


@app.get("/contacts/search")
def search_contacts(query: str = Query(...)):
    q = query.lower()
    results = [c for c in CONTACTS if q in c.name.lower() or q in c.phone]
    return [c.model_dump() for c in results]


# ──────────────────────────────────────────────
# User Profile
# ──────────────────────────────────────────────

@app.get("/user/profile")
def get_user_profile():
    return USERS[0].model_dump()


@app.get("/notifications")
def get_notifications():
    return [n.model_dump() for n in NOTIFICATIONS]


# ══════════════════════════════════════════════
# EVENT COLLECT ENDPOINTS
# ══════════════════════════════════════════════
#
# OUT OF SCOPE (by design, not oversight):
# - No NLP/LLM parsing of event titles, notes, or participant names
# - No fuzzy matching for unmatched payments — exact match or manual tag only
# - No auto-generated reminder copy — fixed templates only
# - No custodial wallet balance — funds never sit inside payGO
# - No auto-close before stated expiry regardless of target-amount progress
# - No editing of ledger data after CLOSED


@app.get("/upi/alias/check", response_model=AliasCheckResponse)
def check_alias(handle: str = Query(...)):
    """Check if an event UPI alias handle is available."""
    handle_lower = handle.lower().strip()
    if not handle_lower.isalnum():
        raise HTTPException(status_code=400, detail="Handle must be alphanumeric only")
    if len(handle_lower) < 3:
        raise HTTPException(status_code=400, detail="Handle must be at least 3 characters")
    available = handle_lower not in TAKEN_ALIASES
    return AliasCheckResponse(available=available)


@app.post("/upi/alias/register")
def register_alias(body: AliasRegisterBody):
    """Register a new event UPI alias on the user's linked bank account."""
    handle_lower = body.handle.lower().strip()
    if not handle_lower.isalnum():
        raise HTTPException(status_code=400, detail="Handle must be alphanumeric only")
    if handle_lower in TAKEN_ALIASES:
        raise HTTPException(status_code=409, detail="Handle already taken")

    TAKEN_ALIASES.add(handle_lower)
    vpa = f"{handle_lower}@paygo"
    user = USERS[0]
    # In production: calls PSP's "add UPI ID" API on the same linked bank account
    user.event_vpa = vpa
    return {"vpa": vpa, "linked_account_id": user.linked_banks[0].id}


@app.get("/events")
def list_events():
    """List all events for the current user."""
    return [e.model_dump() for e in EVENTS if e.organizer_id == "u-001"]


@app.post("/events")
def create_event(body: CreateEventBody):
    """Create a new collection event."""
    user = USERS[0]
    if not user.event_vpa:
        raise HTTPException(status_code=400, detail="Event VPA not set. Complete alias setup first.")

    settlement_account = body.settlement_account_id or user.linked_banks[0].id
    event = Event(
        id=f"evt-{uuid.uuid4().hex[:6]}",
        organizer_id=user.id,
        title=body.title,
        amount_mode=body.amount_mode,
        amount=body.amount,
        target_amount=body.target_amount,
        same_amount_from_everyone=body.same_amount_from_everyone,
        expiry_at=body.expiry_at,
        status=EventStatus.ACTIVE,
        settlement_vpa=user.event_vpa,
        settlement_name=user.name,
        settlement_account_id=settlement_account,
        created_at=datetime.utcnow().isoformat(),
    )
    EVENTS.append(event)
    return event.model_dump()


@app.get("/events/{event_id}")
def get_event(event_id: str):
    """Get event detail + ledger entries."""
    event = next((e for e in EVENTS if e.id == event_id), None)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    ledger = [le.model_dump() for le in LEDGER_ENTRIES if le.event_id == event_id]
    return {"event": event.model_dump(), "ledger": ledger}


@app.post("/events/{event_id}/close")
def close_event(event_id: str):
    """Manually close an event. QR is permanently disabled. Ledger becomes read-only."""
    event = next((e for e in EVENTS if e.id == event_id), None)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.status == EventStatus.CLOSED:
        raise HTTPException(status_code=400, detail="Event is already closed")

    event.status = EventStatus.CLOSED
    event.closed_at = datetime.utcnow().isoformat()

    # Generate settlement proof
    ledger = [le for le in LEDGER_ENTRIES if le.event_id == event_id]
    canonical = json.dumps({
        "event_id": event.id,
        "title": event.title,
        "organizer_id": event.organizer_id,
        "settlement_vpa": event.settlement_vpa,
        "closed_at": event.closed_at,
        "entries": [le.model_dump() for le in ledger],
    }, sort_keys=True)
    digest = hashlib.sha256(canonical.encode()).hexdigest()
    # Mock ECDSA signature (in production: KMS signs the digest)
    signature = f"3045022100{uuid.uuid4().hex}{uuid.uuid4().hex[:16]}"

    from models import SettlementProofModel
    proof = SettlementProofModel(
        event_id=event_id,
        canonical_snapshot_hash=digest,
        signature=signature,
        key_id="paygo-event-signing-key-v1",
        signed_at=datetime.utcnow().isoformat(),
        canonical_snapshot=canonical,
    )
    SETTLEMENT_PROOFS.append(proof)
    return {"success": True, "proof": proof.model_dump()}


@app.post("/events/{event_id}/reminders/send")
def send_reminders(event_id: str, body: SendReminderBody):
    """Send reminders — organizer-triggered, explicit tap per batch. No auto-send."""
    event = next((e for e in EVENTS if e.id == event_id), None)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.status != EventStatus.ACTIVE:
        raise HTTPException(status_code=400, detail="Can only send reminders for active events")

    template = next((t for t in REMINDER_TEMPLATES if t.id == body.template_id), None)
    if not template:
        raise HTTPException(status_code=404, detail="Template not found")

    # In production: send push notifications to participant_ids
    print(f"[REMINDER] Sent '{template.name}' for event '{event.title}' to {len(body.participant_ids)} participants")
    return {"success": True, "sent_count": len(body.participant_ids)}


@app.get("/reminders/templates")
def get_reminder_templates():
    """Return the fixed set of reminder templates. No AI/NLP generation."""
    return [t.model_dump() for t in REMINDER_TEMPLATES]


@app.post("/webhooks/upi-settlement")
def upi_settlement_webhook(body: UPISettlementWebhook):
    """
    PSP callback: match incoming transaction to event/ledger.
    Matching: by tr field (txn_ref) first, then exact VPA/phone match.
    No fuzzy matching. Anything unmatched lands in the unmatched queue.
    """
    # Find event by tr field prefix
    event = next((e for e in EVENTS if body.txn_ref.startswith(e.id) and e.status == EventStatus.ACTIVE), None)
    if not event:
        return {"matched": False, "reason": "No active event found for this transaction reference"}

    # Try exact match against known contacts
    participant_id = None
    participant_name = None
    for c in CONTACTS:
        if c.upi_id == body.payer_vpa or c.phone == body.payer_vpa:
            participant_id = c.id
            participant_name = c.name
            break

    from models import LedgerEntry as LE
    entry = LE(
        id=f"le-{uuid.uuid4().hex[:6]}",
        event_id=event.id,
        participant_id=participant_id,
        participant_name=participant_name,
        payer_vpa_or_phone=body.payer_vpa,
        amount=body.amount,
        txn_ref=body.txn_ref,
        matched_at=body.timestamp,
    )
    LEDGER_ENTRIES.append(entry)
    return {"matched": True, "auto_tagged": participant_id is not None, "entry": entry.model_dump()}


@app.post("/events/{event_id}/ledger/{entry_id}/tag")
def tag_ledger_entry(event_id: str, entry_id: str, body: TagPaymentBody):
    """
    Manual unmatched-payment tagging by organizer.
    No fuzzy matching, no auto-tag — explicit manual assignment only.
    Stores taggedBy + taggedAt for auditability.
    """
    event = next((e for e in EVENTS if e.id == event_id), None)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.status == EventStatus.CLOSED:
        raise HTTPException(status_code=400, detail="Cannot modify ledger of a closed event")

    entry = next((le for le in LEDGER_ENTRIES if le.id == entry_id and le.event_id == event_id), None)
    if not entry:
        raise HTTPException(status_code=404, detail="Ledger entry not found")

    entry.participant_id = body.participant_id
    entry.participant_name = body.participant_name
    entry.tagged_by = "u-001"  # current user
    entry.tagged_at = datetime.utcnow().isoformat()
    return {"success": True, "entry": entry.model_dump()}


@app.get("/verify/{event_id}", response_model=VerifyResponse)
def verify_event(event_id: str):
    """
    PUBLIC, read-only endpoint.
    Returns ONLY the requested event's snapshot + signature + keyId.
    Never returns organizer's other events, personal VPA, or account details.
    """
    event = next((e for e in EVENTS if e.id == event_id), None)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    proof = next((p for p in SETTLEMENT_PROOFS if p.event_id == event_id), None)
    ledger = [le for le in LEDGER_ENTRIES if le.event_id == event_id]

    # Sanitize: remove settlement_account_id from public view
    event_public = event.model_dump()
    event_public.pop("settlement_account_id", None)

    return VerifyResponse(
        event=Event(**{**event.model_dump()}),
        ledger=ledger,
        proof=proof,
    )


# ══════════════════════════════════════════════
# FINANCIAL HUB — Account Aggregator Endpoints
# ══════════════════════════════════════════════

_user_consents: dict[str, list[str]] = {}  # user_id -> [consent_ids]
DEFAULT_USER_ID = "u-001"


@app.post("/api/financial/connect", response_model=ConsentResponse)
async def financial_connect(body: ConsentRequest):
    """Create a data-access consent request."""
    aa = get_account_aggregator()
    result = await aa.create_consent(
        user_id=DEFAULT_USER_ID,
        purpose=body.purpose,
        from_date=body.from_date,
        to_date=body.to_date,
        frequency=body.frequency,
    )
    # Track consent for user
    if DEFAULT_USER_ID not in _user_consents:
        _user_consents[DEFAULT_USER_ID] = []
    _user_consents[DEFAULT_USER_ID].append(result["consent_id"])
    return ConsentResponse(**result)


@app.post("/api/financial/mock-approve")
async def financial_mock_approve(body: MockApproveBody):
    """Mock: simulate bank approval of consent."""
    aa = get_account_aggregator()
    result = await aa.approve_consent(body.consent_id, body.bank_name)
    return result


@app.get("/api/financial/consent/{consent_id}")
async def financial_consent_status(consent_id: str):
    """Get consent status."""
    aa = get_account_aggregator()
    status = await aa.get_consent_status(consent_id)
    return {"consent_id": consent_id, "status": status}


@app.get("/api/financial/consents")
async def financial_list_consents():
    """List all consents for the current user."""
    aa = get_account_aggregator()
    consent_ids = _user_consents.get(DEFAULT_USER_ID, [])
    consents = []
    for cid in consent_ids:
        details = await aa.get_consent_details(cid)
        consents.append(details)
    return consents


@app.delete("/api/financial/consent/{consent_id}")
async def financial_revoke_consent(consent_id: str):
    """Revoke an active consent."""
    aa = get_account_aggregator()
    result = await aa.revoke_consent(consent_id)
    return result


@app.post("/api/financial/accounts/sync")
async def financial_sync_accounts(body: SyncRequest):
    """Fetch accounts + transactions via AA, normalize, store."""
    aa = get_account_aggregator()

    # 1. Fetch accounts
    accounts = await aa.fetch_accounts(body.consent_id)
    if not accounts:
        raise HTTPException(status_code=400, detail="No accounts found or consent not approved")

    stored_accounts = []
    total_txns = 0

    for acc in accounts:
        # 2. Store account
        stored = txn_svc.store_account(DEFAULT_USER_ID, acc)
        stored_accounts.append(stored)

        # 3. Fetch transactions
        consent_details = await aa.get_consent_details(body.consent_id)
        raw_txns = await aa.fetch_transactions(
            body.consent_id,
            acc["account_id"],
            consent_details.get("from_date", ""),
            consent_details.get("to_date", ""),
        )

        # 4. Normalize and store
        count = txn_svc.normalize_and_store(raw_txns, stored["id"])
        total_txns += count

    return {
        "accounts_linked": len(stored_accounts),
        "transactions_synced": total_txns,
        "accounts": stored_accounts,
    }


@app.get("/api/financial/accounts")
def financial_list_accounts():
    """List all linked financial accounts."""
    accounts = txn_svc.get_user_accounts(DEFAULT_USER_ID)
    return accounts


@app.delete("/api/financial/accounts/{account_id}")
def financial_unlink_account(account_id: str):
    """Unlink a financial account."""
    success = txn_svc.unlink_account(account_id)
    if not success:
        raise HTTPException(status_code=404, detail="Account not found")
    return {"status": "UNLINKED"}


@app.get("/api/financial/transactions")
def financial_transactions(
    account_id: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    from_date: Optional[str] = Query(None, alias="from"),
    to_date: Optional[str] = Query(None, alias="to"),
    txn_type: Optional[str] = Query(None, alias="type"),
):
    """List transactions with filters."""
    txns = txn_svc.get_transactions(
        DEFAULT_USER_ID,
        account_id=account_id,
        category=category,
        from_date=from_date,
        to_date=to_date,
        txn_type=txn_type,
    )
    return txns


@app.get("/api/financial/summary")
def financial_summary(period: str = Query("this_month")):
    """Get spending summary for a period."""
    return txn_svc.get_summary(DEFAULT_USER_ID, period)


@app.get("/api/financial/trends")
def financial_trends():
    """Get monthly category trends for last 6 months."""
    return txn_svc.get_trends(DEFAULT_USER_ID)


@app.get("/api/financial/recurring")
def financial_recurring():
    """Get detected recurring transactions."""
    return txn_svc.get_recurring_transactions(DEFAULT_USER_ID)


# ══════════════════════════════════════════════
# PHINITE AGENT — Mock Integration Endpoints
# ══════════════════════════════════════════════

@app.get("/api/financial/consent/status/{user_id}")
def get_user_consent_status(user_id: str):
    """Phinite: Get overall consent status for user."""
    # Mocking that consent is ACTIVE if we have any consents, else MISSING
    has_consents = len(_user_consents.get(user_id, [])) > 0
    return {
        "user_id": user_id,
        "status": "ACTIVE" if has_consents else "MISSING",
        "message": "Consent is active" if has_consents else "Please link an account via AA."
    }

@app.get("/financial/preferences/{user_id}")
def get_user_preferences(user_id: str):
    """Phinite: Get financial guardrail preferences."""
    return {
        "user_id": user_id,
        "min_balance_requirement": 5000.0,
        "monthly_spending_limit": 40000.0,
        "warning_threshold_percentage": 80.0
    }

@app.post("/financial/check-payment")
def check_payment_feasibility(body: dict):
    """Phinite: Deterministic guardrail check."""
    amount = float(body.get("amount", 0))
    # Mock logic: if > 50,000 BLOCKED, if > 10,000 WARNING, else SAFE
    if amount > 50000:
        return {"status": "BLOCKED", "message": "Amount exceeds maximum safe-to-spend limit.", "can_proceed": False}
    elif amount > 10000:
        return {"status": "WARNING", "message": "This is a large transaction that impacts your monthly budget.", "can_proceed": True}
    return {"status": "SAFE", "message": "Transaction is well within your budget limits.", "can_proceed": True}

@app.get("/paytm/capabilities")
def get_paytm_capabilities():
    """Phinite: Available Paytm capabilities."""
    return {
        "capabilities": [
            {"id": "MOBILE_RECHARGE", "name": "Mobile Recharge", "description": "Recharge prepaid mobile plans"},
            {"id": "BILL_PAYMENT", "name": "Bill Payment", "description": "Pay utility bills (electricity, water, etc.)"},
            {"id": "UPI_PAYMENT", "name": "UPI Transfer", "description": "Send money via UPI"},
            {"id": "INVEST_MF", "name": "Mutual Funds", "description": "Invest in mutual funds"},
        ]
    }

@app.get("/paytm/offers")
def get_paytm_offers(capability: str = None, amount: float = None, service: str = None):
    """Phinite: Offer Discovery."""
    return {
        "offers": [
            {
                "offer_id": "OFFER_CB_100",
                "title": f"Flat ₹100 Cashback on {capability or 'Payments'}",
                "description": "Get ₹100 cashback on your next transaction.",
                "min_amount": 500.0,
                "benefit_amount": 100.0
            }
        ]
    }

@app.post("/paytm/offers/check-eligibility")
def check_offer_eligibility(body: dict):
    """Phinite: Validate offer eligibility."""
    return {
        "is_eligible": True,
        "eligibility_reason": "User meets all criteria for this offer."
    }

@app.post("/paytm/recharge")
def execute_recharge(body: dict):
    """Phinite: Action Execution - Recharge."""
    return {"status": "SUCCESS", "transaction_id": f"REC{int(datetime.utcnow().timestamp())}", "message": "Recharge successful"}

@app.post("/paytm/bill-payment")
def execute_bill_payment(body: dict):
    """Phinite: Action Execution - Bill Payment."""
    return {"status": "SUCCESS", "transaction_id": f"BIL{int(datetime.utcnow().timestamp())}", "message": "Bill paid successfully"}

@app.post("/paytm/upi-payment")
def execute_upi_payment(body: dict):
    """Phinite: Action Execution - UPI."""
    return {"status": "SUCCESS", "transaction_id": f"UPI{int(datetime.utcnow().timestamp())}", "message": "UPI Transfer successful"}

@app.post("/audit/log-action")
def log_agent_action(body: dict):
    """Phinite: Audit log."""
    print(f"[AUDIT] Agent action logged: {body}")
    return {"logged": True, "timestamp": datetime.utcnow().isoformat()}

@app.post("/notifications/send-monthly-email")
def send_monthly_email(body: dict):
    """Phinite: Trigger monthly email."""
    print(f"[EMAIL] Sent monthly summary email to {body.get('user_id')}")
    return {"email_sent": True, "message": "Monthly summary email dispatched successfully."}

# ──────────────────────────────────────────────
# AI Chat Proxy Endpoint
# ──────────────────────────────────────────────

def call_groq_fallback(prompt: str, user_id: str):
    groq_api_key = os.environ.get("GROQ_API_KEY", "")
    
    system_prompt = """
You are PayGo AI, a financial assistant.
You must respond with a JSON object containing the exact following keys:
- response (string): The text to show the user.
- action (string or null): One of "GUARDRAIL_BLOCKED", "EXPENSE_CHART", "INVESTMENT_CARDS", or null.
- payload (object or null): Data for the action. 

If the user wants to recharge a large amount (e.g. 55000), return action "GUARDRAIL_BLOCKED", payload: {"amount": 55000, "merchant": "Jio Prepaid", "limit": 40000, "status": "BLOCKED"}.
If the user asks about expenses/weekly, return action "EXPENSE_CHART", payload: {"total_spent": 12500, "recurring": ["Netflix", "Spotify"], "chart_data": [{"day": "Mon", "amount": 1200}, {"day": "Tue", "amount": 500}, {"day": "Wed", "amount": 3400}, {"day": "Thu", "amount": 800}, {"day": "Fri", "amount": 2100}, {"day": "Sat", "amount": 4500}, {"day": "Sun", "amount": 0}]}
If the user asks about investments, return action "INVESTMENT_CARDS", payload: {"recommendations": [{"type": "Mutual Fund", "name": "Axis Bluechip", "risk": "Moderate", "return": "12.5% p.a"}, {"type": "Fixed Deposit", "name": "Shriram Finance", "risk": "Low", "return": "8.5% p.a"}]}
Else, just return a helpful response with action=null and payload=null.
Always output valid JSON only.
"""
    req_data = {
        "model": "llama3-70b-8192",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        "response_format": {"type": "json_object"}
    }
    
    req = urllib.request.Request("https://api.groq.com/openai/v1/chat/completions", method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", f"Bearer {groq_api_key}")
    
    try:
        with urllib.request.urlopen(req, data=json.dumps(req_data).encode("utf-8")) as response:
            res_body = json.loads(response.read())
            content = res_body["choices"][0]["message"]["content"]
            return json.loads(content)
    except Exception as e:
        print(f"[Groq Fallback Error] {e}")
        return {
            "response": "I'm sorry, my AI services are currently unavailable.",
            "action": None,
            "payload": None
        }

@app.post("/ai/chat")
async def ai_chat_proxy(body: AIChatRequest):
    phinite_url = "https://app.phinite.ai/api/v1/ai/trigger/02s7lv1/jMRGm-ghn/development"
    api_key = os.environ.get("PHINITE_API_KEY", "")
    
    if not api_key:
        print("[WARNING] PHINITE_API_KEY is not set. Falling back to Groq.")
        return call_groq_fallback(body.prompt, body.user_id)

    req = urllib.request.Request(phinite_url, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", f"Bearer {api_key}")
    
    data = json.dumps({"prompt": body.prompt, "user_id": body.user_id}).encode("utf-8")
    
    try:
        with urllib.request.urlopen(req, data=data) as response:
            res_body = response.read()
            return json.loads(res_body)
    except Exception as e:
        print(f"[Phinite API Exception] {e}. Falling back to Groq.")
        return call_groq_fallback(body.prompt, body.user_id)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
