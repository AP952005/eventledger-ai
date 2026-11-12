"""
EventTreasury AI — Mock & Seed Data Store
Seeds multi-tenant events, participants, and PayPal sandbox references.
All monetary values use Decimal for precise fintech arithmetic.
"""
from decimal import Decimal
from datetime import datetime, timezone, timedelta
from models import (
    Event, Participant, LedgerEntry, SettlementProofModel, AuditLog,
    EventStatus, RegistrationStatus, InvoiceStatus, PaymentStatus, ProcessedWebhookEvent
)

_now = datetime.now(timezone.utc)

# Seed Events
EVENTS: list[Event] = [
    Event(
        id="evt-paypal-001",
        organizer_id="org-001",
        title="Global AI & Fintech Summit 2026",
        description="The premier gathering of fintech engineers, AI innovators, and product leaders exploring agentic banking and PayPal integrations.",
        category="Conference",
        currency="USD",
        amount=Decimal("45.00"),
        target_amount=Decimal("4500.00"),
        expected_participants=100,
        max_participants=150,
        expiry_at=(_now + timedelta(days=14)).isoformat(),
        status=EventStatus.ACTIVE,
        created_at=(_now - timedelta(days=3)).isoformat(),
        terms_and_conditions="Admittance strictly with verified PayPal registration QR badge.",
        refund_policy="Full refund available up to 48 hours prior to summit keynote.",
        paypal_merchant_id="sandbox-merchant-01"
    ),
    Event(
        id="evt-paypal-003",
        organizer_id="org-001",
        title="Silicon Valley Founders Pitch Night",
        description="Closed-door startup showcase with leading fintech angels and seed funds.",
        category="Networking",
        currency="USD",
        amount=Decimal("100.00"),
        target_amount=Decimal("5000.00"),
        expected_participants=50,
        max_participants=50,
        expiry_at=(_now - timedelta(days=2)).isoformat(),
        status=EventStatus.CLOSED,
        created_at=(_now - timedelta(days=25)).isoformat(),
        closed_at=(_now - timedelta(days=2)).isoformat(),
        terms_and_conditions="Confidential investor event under standard NVCA mutual NDA.",
        refund_policy="No refunds upon badge issuance.",
        paypal_merchant_id="sandbox-merchant-01"
    ),
]

# Seed Participants (with 3 distinct entity states: registration, invoice, payment)
PARTICIPANTS: list[Participant] = [
    Participant(
        id="part-001",
        event_id="evt-paypal-001",
        organizer_id="org-001",
        name="Elena Rostova",
        email="elena.rostova@techcorp.io",
        phone="+14155552671",
        registration_id="REG-2026-001",
        registered_at=(_now - timedelta(days=2)).isoformat(),
        registration_status=RegistrationStatus.CONFIRMED,
        invoice_status=InvoiceStatus.PAID,
        payment_status=PaymentStatus.CAPTURED,
        status="PAID",
        amount=Decimal("45.00"),
        currency="USD",
        paypal_invoice_id="INV2-TEST-ELENA01",
        paypal_payment_url="https://www.sandbox.paypal.com/invoice/p/#INV2-TEST-ELENA01",
        paid_at=(_now - timedelta(days=2, hours=1)).isoformat(),
        transaction_reference="PAYID-ELENA-99128",
    ),
    Participant(
        id="part-002",
        event_id="evt-paypal-001",
        organizer_id="org-001",
        name="Marcus Vance",
        email="marcus.vance@vancecap.com",
        phone="+14155558912",
        registration_id="REG-2026-002",
        registered_at=(_now - timedelta(days=1)).isoformat(),
        registration_status=RegistrationStatus.PENDING,
        invoice_status=InvoiceStatus.SENT,
        payment_status=PaymentStatus.UNPAID,
        status="AWAITING_PAYMENT",
        amount=Decimal("45.00"),
        currency="USD",
        paypal_invoice_id="INV2-TEST-MARCUS02",
        paypal_payment_url="https://www.sandbox.paypal.com/invoice/p/#INV2-TEST-MARCUS02",
    ),
    Participant(
        id="part-003",
        event_id="evt-paypal-001",
        organizer_id="org-001",
        name="Sophia Lin",
        email="sophia.lin@ai-ventures.com",
        phone="+14155559811",
        registration_id="REG-2026-003",
        registered_at=(_now - timedelta(hours=18)).isoformat(),
        registration_status=RegistrationStatus.CONFIRMED,
        invoice_status=InvoiceStatus.PAID,
        payment_status=PaymentStatus.CAPTURED,
        status="PAID",
        amount=Decimal("45.00"),
        currency="USD",
        paypal_invoice_id="INV2-TEST-SOPHIA03",
        paypal_payment_url="https://www.sandbox.paypal.com/invoice/p/#INV2-TEST-SOPHIA03",
        paid_at=(_now - timedelta(hours=16)).isoformat(),
        transaction_reference="PAYID-SOPHIA-44012",
    ),
    Participant(
        id="part-004",
        event_id="evt-paypal-002",
        organizer_id="org-001",
        name="David Kim",
        email="david.kim@coderz.dev",
        phone="+14155554312",
        registration_id="REG-2026-004",
        registered_at=(_now - timedelta(days=3)).isoformat(),
        registration_status=RegistrationStatus.CONFIRMED,
        invoice_status=InvoiceStatus.PAID,
        payment_status=PaymentStatus.CAPTURED,
        status="PAID",
        amount=Decimal("15.00"),
        currency="USD",
        paypal_invoice_id="INV2-TEST-DAVID04",
        paypal_payment_url="https://www.sandbox.paypal.com/invoice/p/#INV2-TEST-DAVID04",
        paid_at=(_now - timedelta(days=3)).isoformat(),
        transaction_reference="PAYID-DAVID-33120",
    ),
    Participant(
        id="part-005",
        event_id="evt-paypal-002",
        organizer_id="org-001",
        name="Aisha Morales",
        email="aisha.m@stanford.edu",
        phone="+14155557761",
        registration_id="REG-2026-005",
        registered_at=(_now - timedelta(days=1)).isoformat(),
        registration_status=RegistrationStatus.PENDING,
        invoice_status=InvoiceStatus.SENT,
        payment_status=PaymentStatus.UNPAID,
        status="AWAITING_PAYMENT",
        amount=Decimal("15.00"),
        currency="USD",
        paypal_invoice_id="INV2-TEST-AISHA05",
        paypal_payment_url="https://www.sandbox.paypal.com/invoice/p/#INV2-TEST-AISHA05",
    ),
]

# Seed Verified Ledger Entries
LEDGER_ENTRIES: list[LedgerEntry] = [
    LedgerEntry(
        id="led-001",
        event_id="evt-paypal-001",
        organizer_id="org-001",
        participant_id="part-001",
        participant_name="Elena Rostova",
        payer_identifier="elena.rostova@techcorp.io",
        amount=Decimal("45.00"),
        currency="USD",
        txn_ref="PAYID-ELENA-99128",
        status="PAID",
        matched_at=(_now - timedelta(days=2, hours=1)).isoformat()
    ),
    LedgerEntry(
        id="led-002",
        event_id="evt-paypal-001",
        organizer_id="org-001",
        participant_id="part-003",
        participant_name="Sophia Lin",
        payer_identifier="sophia.lin@ai-ventures.com",
        amount=Decimal("45.00"),
        currency="USD",
        txn_ref="PAYID-SOPHIA-44012",
        status="PAID",
        matched_at=(_now - timedelta(hours=16)).isoformat()
    ),
    LedgerEntry(
        id="led-003",
        event_id="evt-paypal-002",
        organizer_id="org-001",
        participant_id="part-004",
        participant_name="David Kim",
        payer_identifier="david.kim@coderz.dev",
        amount=Decimal("15.00"),
        currency="USD",
        txn_ref="PAYID-DAVID-33120",
        status="PAID",
        matched_at=(_now - timedelta(days=3)).isoformat()
    ),
]

# Settlement Proofs
SETTLEMENT_PROOFS: list[SettlementProofModel] = [
    SettlementProofModel(
        event_id="evt-paypal-003",
        canonical_snapshot_hash="da910af20e26487d0aa5640955c08915c1cc1f487a170d4d30e4a661b45fdc31",
        signature="3045022100d8b5c911a3d9b4b0e891f7601ad892f3c7e0986791e87900b7a8c3d9876a1c89",
        key_id="eventtreasury-secp256k1-v1",
        signed_at=(_now - timedelta(days=2)).isoformat(),
        canonical_snapshot='{"event_id":"evt-paypal-003","title":"Silicon Valley Founders Pitch Night","total_settled":"5000.00","currency":"USD"}'
    )
]

# Deduplication store for Webhook events
PROCESSED_WEBHOOKS: list[ProcessedWebhookEvent] = []

# Provider-Independent Orders, Attempts, and Transactions Store
PAYMENT_ORDERS: list = []
PAYMENT_ATTEMPTS: list = []
PAYMENT_TRANSACTIONS: list = []
MERCHANT_ACCOUNTS: list = []

# Audit Logs
AUDIT_LOGS: list[AuditLog] = []
