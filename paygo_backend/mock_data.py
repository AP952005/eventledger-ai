"""
PayGo Backend — In-Memory Mock Data
Seed data for development and testing.
"""
from datetime import datetime, timedelta
from models import (
    User, BankAccount, Transaction, SavedBiller, Notification, Contact,
    TransactionDirection, TransactionCategory, TransactionStatus, NotificationType,
    BillerCategory, Event, LedgerEntry, SettlementProofModel, ReminderTemplateModel,
    EventAmountMode, EventStatus
)

# ──────────────────────────────────────────────
# Users
# ──────────────────────────────────────────────

USERS = [
    User(
        id="u-001",
        name="Abishek",
        phone="9363684402",
        upi_id="9363684402@ptyes",
        is_verified=True,
        avatar_url="https://i.pravatar.cc/150?u=u-001",
        linked_banks=[
            BankAccount(id="b-001", bank_name="State Bank of India", account_last4="4521", is_primary=True),
            BankAccount(id="b-002", bank_name="HDFC Bank", account_last4="8832", is_primary=False),
        ],
        postpaid_limit=60000.0,
        wallet_balance=2450.75,
        event_vpa="abishek2026@paygo",
        event_alias="abishek2026",
    ),
    User(
        id="u-002",
        name="Priya Sharma",
        phone="+919123456789",
        upi_id="priya.s@paygo",
        is_verified=True,
        avatar_url=None,
        linked_banks=[
            BankAccount(id="b-003", bank_name="ICICI Bank", account_last4="1190", is_primary=True),
        ],
        wallet_balance=8320.00,
    ),
    User(
        id="u-003",
        name="Rahul Gupta",
        phone="+919988776655",
        upi_id="rahul.g@paygo",
        is_verified=False,
        avatar_url=None,
        linked_banks=[
            BankAccount(id="b-004", bank_name="Axis Bank", account_last4="6643", is_primary=True),
        ],
        wallet_balance=540.50,
    ),
]

# ──────────────────────────────────────────────
# Transactions
# ──────────────────────────────────────────────

_now = datetime.utcnow()

TRANSACTIONS = [
    Transaction(
        id="txn-001", from_user_id="u-001", to_user_id="u-002",
        amount=7000.0, direction=TransactionDirection.SENT,
        category=TransactionCategory.P2P, status=TransactionStatus.SUCCESS,
        note="Rent share", timestamp=_now - timedelta(hours=2),
    ),
    Transaction(
        id="txn-002", from_user_id="u-002", to_user_id="u-001",
        amount=1500.0, direction=TransactionDirection.RECEIVED,
        category=TransactionCategory.P2P, status=TransactionStatus.SUCCESS,
        note="Dinner split", timestamp=_now - timedelta(hours=5),
    ),
    Transaction(
        id="txn-003", from_user_id="u-001", to_user_id=None,
        merchant_or_biller_id="biller-jio", amount=299.0,
        direction=TransactionDirection.SENT,
        category=TransactionCategory.RECHARGE, status=TransactionStatus.SUCCESS,
        note="Jio Recharge", timestamp=_now - timedelta(days=1),
    ),
    Transaction(
        id="txn-004", from_user_id="u-001", to_user_id=None,
        merchant_or_biller_id="biller-electricity", amount=2350.0,
        direction=TransactionDirection.SENT,
        category=TransactionCategory.BILL, status=TransactionStatus.SUCCESS,
        note="Electricity Bill - Sep", timestamp=_now - timedelta(days=2),
    ),
    Transaction(
        id="txn-005", from_user_id="u-003", to_user_id="u-001",
        amount=500.0, direction=TransactionDirection.RECEIVED,
        category=TransactionCategory.P2P, status=TransactionStatus.SUCCESS,
        note="Tea money", timestamp=_now - timedelta(days=2),
    ),
    Transaction(
        id="txn-006", from_user_id="u-001", to_user_id="u-003",
        amount=12000.0, direction=TransactionDirection.SENT,
        category=TransactionCategory.P2P, status=TransactionStatus.SUCCESS,
        note="Freelance payment", timestamp=_now - timedelta(days=3),
    ),
    Transaction(
        id="txn-007", from_user_id="u-001", to_user_id=None,
        merchant_or_biller_id="biller-dth", amount=450.0,
        direction=TransactionDirection.SENT,
        category=TransactionCategory.RECHARGE, status=TransactionStatus.FAILED,
        note="DTH Recharge", timestamp=_now - timedelta(days=3),
    ),
    Transaction(
        id="txn-008", from_user_id="u-001", to_user_id=None,
        merchant_or_biller_id="merchant-amazon", amount=3499.0,
        direction=TransactionDirection.SENT,
        category=TransactionCategory.SHOPPING, status=TransactionStatus.SUCCESS,
        note="Amazon Purchase", timestamp=_now - timedelta(days=4),
    ),
    Transaction(
        id="txn-009", from_user_id="u-001", to_user_id=None,
        merchant_or_biller_id="invest-gold", amount=1000.0,
        direction=TransactionDirection.SENT,
        category=TransactionCategory.INVESTMENT, status=TransactionStatus.SUCCESS,
        note="Gold Investment", timestamp=_now - timedelta(days=5),
    ),
    Transaction(
        id="txn-010", from_user_id="u-002", to_user_id="u-001",
        amount=2500.0, direction=TransactionDirection.RECEIVED,
        category=TransactionCategory.P2P, status=TransactionStatus.PENDING,
        note="Birthday gift", timestamp=_now - timedelta(hours=1),
    ),
    Transaction(
        id="txn-011", from_user_id="u-001", to_user_id=None,
        merchant_or_biller_id="biller-gas", amount=850.0,
        direction=TransactionDirection.SENT,
        category=TransactionCategory.BILL, status=TransactionStatus.SUCCESS,
        note="Piped Gas Bill", timestamp=_now - timedelta(days=6),
    ),
    Transaction(
        id="txn-012", from_user_id="u-001", to_user_id="u-002",
        amount=350.0, direction=TransactionDirection.SENT,
        category=TransactionCategory.P2P, status=TransactionStatus.SUCCESS,
        note="Coffee ☕", timestamp=_now - timedelta(days=7),
    ),
]

# ──────────────────────────────────────────────
# Saved Billers
# ──────────────────────────────────────────────

SAVED_BILLERS = [
    SavedBiller(
        id="sb-001", user_id="u-001", category="mobile",
        provider_name="Jio", identifier="9876543210",
        added_on=_now - timedelta(days=90), autopay_enabled=True,
    ),
    SavedBiller(
        id="sb-002", user_id="u-001", category="electricity",
        provider_name="Tata Power", identifier="TP-44210098",
        added_on=_now - timedelta(days=60), autopay_enabled=False,
    ),
    SavedBiller(
        id="sb-003", user_id="u-001", category="dth",
        provider_name="Tata Play", identifier="DTH-88321",
        added_on=_now - timedelta(days=45), autopay_enabled=True,
    ),
    SavedBiller(
        id="sb-004", user_id="u-001", category="gas",
        provider_name="Mahanagar Gas", identifier="MGL-55102",
        added_on=_now - timedelta(days=30), autopay_enabled=False,
    ),
    SavedBiller(
        id="sb-005", user_id="u-001", category="credit_card",
        provider_name="HDFC Bank", identifier="XXXX-8832",
        added_on=_now - timedelta(days=20), autopay_enabled=False,
    ),
]

# ──────────────────────────────────────────────
# Notifications
# ──────────────────────────────────────────────

NOTIFICATIONS = [
    Notification(
        id="n-001", type=NotificationType.TXN,
        title="Payment Successful",
        body="₹7,000 sent to Priya Sharma",
        read=False, created_at=_now - timedelta(hours=2),
    ),
    Notification(
        id="n-002", type=NotificationType.OFFER,
        title="🎉 Flat ₹30 Cashback!",
        body="Recharge your DTH and get flat ₹30 cashback. Offer valid till tonight!",
        read=False, created_at=_now - timedelta(hours=4),
    ),
    Notification(
        id="n-003", type=NotificationType.TXN,
        title="Money Received",
        body="₹1,500 received from Priya Sharma",
        read=True, created_at=_now - timedelta(hours=5),
    ),
    Notification(
        id="n-004", type=NotificationType.SYSTEM,
        title="Security Alert",
        body="Activate Security Shield to protect your account from fraud.",
        read=False, created_at=_now - timedelta(hours=8),
    ),
    Notification(
        id="n-005", type=NotificationType.OFFER,
        title="Gold Price Drop 📉",
        body="Gold prices are at a 30-day low. Great time to invest!",
        read=True, created_at=_now - timedelta(days=1),
    ),
    Notification(
        id="n-006", type=NotificationType.TXN,
        title="Recharge Successful",
        body="₹299 Jio recharge done for 9876543210",
        read=True, created_at=_now - timedelta(days=1),
    ),
    Notification(
        id="n-007", type=NotificationType.OFFER,
        title="Refer & Win ₹60",
        body="You're just 1 referral away from assured ₹60 cashback!",
        read=False, created_at=_now - timedelta(days=2),
    ),
    Notification(
        id="n-008", type=NotificationType.SYSTEM,
        title="KYC Reminder",
        body="Complete your KYC to enjoy uninterrupted services.",
        read=True, created_at=_now - timedelta(days=3),
    ),
]

# ──────────────────────────────────────────────
# Contacts
# ──────────────────────────────────────────────

CONTACTS = [
    Contact(id="u-002", name="Priya Sharma", phone="+919123456789", upi_id="priya.s@paygo"),
    Contact(id="u-003", name="Rahul Gupta", phone="+919988776655", upi_id="rahul.g@paygo"),
    Contact(id="c-004", name="Ananya Desai", phone="+919871234567", upi_id="ananya.d@paygo"),
    Contact(id="c-005", name="Vikram Singh", phone="+919856781234", upi_id="vikram.s@paygo"),
    Contact(id="c-006", name="Meera Patel", phone="+919845671230", upi_id="meera.p@paygo"),
    Contact(id="c-007", name="Karan Malhotra", phone="+919834567891", upi_id="karan.m@paygo"),
    Contact(id="c-008", name="Sneha Reddy", phone="+919823456780", upi_id="sneha.r@paygo"),
    Contact(id="c-009", name="Dev Joshi", phone="+919812345670", upi_id="dev.j@paygo"),
    Contact(id="c-010", name="Nisha Verma", phone="+919801234560", upi_id="nisha.v@paygo"),
    Contact(id="c-011", name="Amit Kumar", phone="+919790123450", upi_id="amit.k@paygo"),
]

# ──────────────────────────────────────────────
# Biller Categories
# ──────────────────────────────────────────────

BILLER_CATEGORIES = [
    BillerCategory(key="mobile", label="Mobile Recharge", icon="phone_android", badge=None),
    BillerCategory(key="credit_card", label="Credit Card Bill", icon="credit_card", badge=None),
    BillerCategory(key="loan", label="Pay Loan EMI", icon="account_balance", badge=None),
    BillerCategory(key="fastag", label="FASTag Recharge", icon="directions_car", badge="No Fee"),
    BillerCategory(key="electricity", label="Electricity Bill", icon="bolt", badge="Flat ₹30"),
    BillerCategory(key="water", label="Water Bill", icon="water_drop", badge=None),
    BillerCategory(key="gas", label="Piped Gas Bill", icon="local_fire_department", badge=None),
    BillerCategory(key="lpg", label="Book LPG Cylinder", icon="propane_tank", badge=None),
    BillerCategory(key="dth", label="DTH Recharge", icon="satellite_alt", badge="Flat ₹15"),
    BillerCategory(key="cable", label="Cable TV", icon="tv", badge=None),
    BillerCategory(key="wifi", label="Wifi / Landline", icon="wifi", badge=None),
    BillerCategory(key="postpaid", label="Mobile Postpaid", icon="phone_iphone", badge=None),
]

# ──────────────────────────────────────────────
# Home Feed Data
# ──────────────────────────────────────────────

HOME_PROMOS = [
    {"title": "Pay Bill, Get Gold", "subtitle": "Pay any bill above ₹500 and get free digital gold", "cta": "Pay Now", "color": "#FFB800"},
    {"title": "Send ₹10 → Get ₹30 Cashback", "subtitle": "Send money to any new contact", "cta": None, "color": "#0077B6"},
    {"title": "Win Scratch Cards!", "subtitle": "Every UPI payment wins you a scratch card", "cta": "Know More", "color": "#00C853"},
]

HOME_SHORTCUTS = [
    {"icon": "qr_code_scanner", "label": "Scan & Pay"},
    {"icon": "contacts", "label": "To Contact"},
    {"icon": "account_balance", "label": "To Bank"},
    {"icon": "history", "label": "History"},
]

HOME_OFFERS = [
    {"title": "15% off on Flights", "category": "travel"},
    {"title": "40% off on Hotels", "category": "travel"},
    {"title": "₹51/day SIP", "category": "investment"},
    {"title": "Free Credit Score Check", "category": "financial"},
]

# ──────────────────────────────────────────────
# Financial Products
# ──────────────────────────────────────────────

FINANCIAL_PRODUCTS = {
    "loans": [
        {"key": "postpaid", "label": "PayGo Postpaid", "icon": "credit_score"},
        {"key": "personal_loan", "label": "Get Loan", "icon": "currency_rupee"},
        {"key": "mf_loan", "label": "Loan on Mutual Fund", "icon": "trending_up"},
        {"key": "gold_loan", "label": "Gold Loan", "icon": "workspace_premium"},
    ],
    "insurance": [
        {"key": "bike", "label": "Bike Insurance", "icon": "two_wheeler"},
        {"key": "car", "label": "Car Insurance", "icon": "directions_car"},
        {"key": "health", "label": "Health Insurance", "icon": "health_and_safety"},
        {"key": "premium", "label": "Insurance Premium", "icon": "verified_user"},
    ],
    "investments": [
        {"key": "mf", "label": "Mutual Fund", "icon": "show_chart"},
        {"key": "stocks", "label": "Stocks", "icon": "candlestick_chart"},
        {"key": "etf", "label": "ETFs", "icon": "auto_graph"},
        {"key": "mtf", "label": "MTF @ 7.99%", "icon": "trending_up"},
    ],
    "cards": [
        {"key": "get_cc", "label": "Get Credit Card", "icon": "add_card"},
        {"key": "pay_cc", "label": "Pay Credit Card Bill", "icon": "payment"},
        {"key": "rupay", "label": "Link RuPay to UPI", "icon": "link"},
    ],
}

# ──────────────────────────────────────────────
# Event Collect — Seed Data
# ──────────────────────────────────────────────

_now = datetime.utcnow()

EVENTS: list[Event] = [
    Event(
        id="evt-001",
        organizer_id="u-001",
        title="CS Dept Farewell 2026",
        amount_mode=EventAmountMode.FIXED,
        amount=500.0,
        target_amount=10000.0,
        same_amount_from_everyone=True,
        expiry_at=(_now + timedelta(days=14)).isoformat(),
        status=EventStatus.ACTIVE,
        settlement_vpa="arjun2026@paygo",
        settlement_name="Arjun Mehta",
        settlement_account_id="b-001",
        created_at=(_now - timedelta(days=3)).isoformat(),
    ),
    Event(
        id="evt-002",
        organizer_id="u-001",
        title="Goa Trip Fund",
        amount_mode=EventAmountMode.SUGGESTED,
        amount=2000.0,
        target_amount=16000.0,
        same_amount_from_everyone=False,
        expiry_at=(_now - timedelta(days=1)).isoformat(),
        status=EventStatus.CLOSED,
        settlement_vpa="arjun2026@paygo",
        settlement_name="Arjun Mehta",
        settlement_account_id="b-001",
        created_at=(_now - timedelta(days=30)).isoformat(),
        closed_at=(_now - timedelta(days=1)).isoformat(),
    ),
]

LEDGER_ENTRIES: list[LedgerEntry] = [
    # ── evt-001: Active event, 3 payments (1 unmatched) ──
    LedgerEntry(
        id="le-001", event_id="evt-001",
        participant_id="u-002", participant_name="Priya Sharma",
        payer_vpa_or_phone="priya.s@paygo", amount=500.0,
        txn_ref="evt-001-txn-a01",
        matched_at=(_now - timedelta(days=2)).isoformat(),
    ),
    LedgerEntry(
        id="le-002", event_id="evt-001",
        participant_id="u-003", participant_name="Rahul Gupta",
        payer_vpa_or_phone="rahul.g@paygo", amount=500.0,
        txn_ref="evt-001-txn-a02",
        matched_at=(_now - timedelta(days=1)).isoformat(),
    ),
    LedgerEntry(
        id="le-003", event_id="evt-001",
        participant_id=None, participant_name=None,  # UNMATCHED — manual tag required
        payer_vpa_or_phone="unknown.person@otherbank", amount=500.0,
        txn_ref="evt-001-txn-a03",
        matched_at=(_now - timedelta(hours=6)).isoformat(),
    ),
    # ── evt-002: Closed event, 3 payments (all matched) ──
    LedgerEntry(
        id="le-004", event_id="evt-002",
        participant_id="u-002", participant_name="Priya Sharma",
        payer_vpa_or_phone="priya.s@paygo", amount=2000.0,
        txn_ref="evt-002-txn-b01",
        matched_at=(_now - timedelta(days=20)).isoformat(),
    ),
    LedgerEntry(
        id="le-005", event_id="evt-002",
        participant_id="u-003", participant_name="Rahul Gupta",
        payer_vpa_or_phone="rahul.g@paygo", amount=2500.0,
        txn_ref="evt-002-txn-b02",
        matched_at=(_now - timedelta(days=15)).isoformat(),
    ),
    LedgerEntry(
        id="le-006", event_id="evt-002",
        participant_id="c-004", participant_name="Ananya Desai",
        payer_vpa_or_phone="ananya.d@paygo", amount=2000.0,
        txn_ref="evt-002-txn-b03",
        matched_at=(_now - timedelta(days=10)).isoformat(),
        tagged_by="u-001", tagged_at=(_now - timedelta(days=10)).isoformat(),
    ),
]

SETTLEMENT_PROOFS: list[SettlementProofModel] = [
    SettlementProofModel(
        event_id="evt-002",
        canonical_snapshot_hash="a3f2b8c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1",
        signature="304502210098b7c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3",
        key_id="paygo-event-signing-key-v1",
        signed_at=(_now - timedelta(days=1)).isoformat(),
        canonical_snapshot='{"event_id":"evt-002","title":"Goa Trip Fund","entries":[...]}',
    ),
]

REMINDER_TEMPLATES: list[ReminderTemplateModel] = [
    ReminderTemplateModel(
        id="tmpl-payment-reminder",
        name="Payment Reminder",
        body_template="Hi {participantName}, this is a reminder to pay {amount} for \"{eventTitle}\". The deadline is {deadline}. Please pay at your earliest convenience.",
    ),
    ReminderTemplateModel(
        id="tmpl-final-reminder",
        name="Final Reminder — Event Closes Soon",
        body_template="Hi {participantName}, \"{eventTitle}\" closes on {deadline}. Your payment of {amount} is still pending. This is the final reminder.",
    ),
    ReminderTemplateModel(
        id="tmpl-gentle-nudge",
        name="Gentle Nudge",
        body_template="Hey {participantName}! Just a quick note — your contribution of {amount} for \"{eventTitle}\" is still pending. Deadline: {deadline}.",
    ),
    ReminderTemplateModel(
        id="tmpl-thank-you",
        name="Thank You (Post-Payment)",
        body_template="Thank you {participantName}! Your payment of {amount} for \"{eventTitle}\" has been received. We appreciate your contribution!",
    ),
]

# Alias registry for availability checking
TAKEN_ALIASES: set[str] = {"abishek2026", "demo", "test", "admin", "paygo"}
