"""
EventLedger AI — Pydantic Domain Models
Supports Multi-Provider Payments (PayPal Invoicing v2 + Cashfree Sandbox),
Participant Lifecycle, Gemini AI operations, and cryptographic settlement proofs.
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
from decimal import Decimal


class EventStatus(str, Enum):
    DRAFT = "DRAFT"
    ACTIVE = "ACTIVE"
    SCHEDULED = "SCHEDULED"
    CAPACITY_REACHED = "CAPACITY_REACHED"
    EXPIRED = "EXPIRED"
    CLOSED = "CLOSED"
    CANCELLED = "CANCELLED"


# Distinct Registration, Invoice and Payment Lifecycle States
class RegistrationStatus(str, Enum):
    PENDING = "PENDING"
    CONFIRMED = "CONFIRMED"
    EXPIRED = "EXPIRED"
    CANCELLED = "CANCELLED"


class InvoiceStatus(str, Enum):
    DRAFT = "DRAFT"
    SENT = "SENT"
    PAID = "PAID"
    PARTIALLY_PAID = "PARTIALLY_PAID"
    CANCELLED = "CANCELLED"
    REFUNDED = "REFUNDED"
    FAILED = "FAILED"
    EXPIRED = "EXPIRED"


class PaymentStatus(str, Enum):
    UNPAID = "UNPAID"
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    AUTHORIZED = "AUTHORIZED"
    CAPTURED = "CAPTURED"
    SUCCESS = "SUCCESS"
    REFUNDED = "REFUNDED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
    EXPIRED = "EXPIRED"


class PaymentProvider(str, Enum):
    PAYPAL = "PAYPAL"
    CASHFREE = "CASHFREE"


ParticipantStatus = RegistrationStatus


# ──────────────────────────────────────────────
# Common Provider-Independent Payment Entities
# ──────────────────────────────────────────────

class MerchantAccount(BaseModel):
    id: str
    organizer_id: str = "org-001"
    provider: PaymentProvider
    account_identifier: str
    is_active: bool = True
    supported_currencies: List[str] = ["USD", "INR"]


class PaymentOrder(BaseModel):
    id: str  # ord-<uuid>
    event_id: str
    participant_id: str
    organizer_id: str = "org-001"
    amount: Decimal = Decimal("0.00")
    currency: str = "USD"
    status: PaymentStatus = PaymentStatus.PENDING
    provider: Optional[PaymentProvider] = None
    created_at: str
    expires_at: Optional[str] = None
    paid_at: Optional[str] = None


class PaymentAttempt(BaseModel):
    id: str  # att-<uuid>
    order_id: str
    event_id: str
    participant_id: str
    provider: PaymentProvider
    amount: Decimal = Decimal("0.00")
    currency: str = "USD"
    status: PaymentStatus = PaymentStatus.PENDING
    created_at: str
    
    # Provider references
    provider_order_id: Optional[str] = None      # Cashfree cf_order_id or PayPal invoice_id
    provider_session_id: Optional[str] = None    # Cashfree payment_session_id
    provider_payment_url: Optional[str] = None   # Hosted payment link
    provider_qr_data: Optional[str] = None       # Base64 image (PayPal) or UPI Intent / QR payload (Cashfree)
    error_message: Optional[str] = None


class PaymentTransaction(BaseModel):
    id: str  # txn-<uuid>
    order_id: str
    attempt_id: str
    event_id: str
    participant_id: str
    provider: PaymentProvider
    provider_transaction_id: str
    amount: Decimal = Decimal("0.00")
    currency: str = "USD"
    status: PaymentStatus = PaymentStatus.SUCCESS
    created_at: str
    payment_method: Optional[str] = None  # e.g., "UPI", "PAYPAL_BALANCE", "CREDIT_CARD"


class PaymentRefund(BaseModel):
    id: str  # ref-<uuid>
    order_id: str
    transaction_id: str
    provider: PaymentProvider
    amount: Decimal = Decimal("0.00")
    currency: str = "USD"
    reason: str
    status: str = "PROCESSED"
    created_at: str
    provider_refund_id: Optional[str] = None


# ──────────────────────────────────────────────
# Core Event & Participant Models
# ──────────────────────────────────────────────

class Event(BaseModel):
    id: str
    organizer_id: str = "org-001"
    title: str
    description: str = ""
    category: str = "General"
    currency: str = "USD"
    amount: Decimal = Decimal("0.00")  # Decimal-safe monetary amount
    target_amount: Decimal = Decimal("0.00")
    expected_participants: int = 50
    max_participants: Optional[int] = None
    expiry_at: str  # ISO timestamp
    status: EventStatus = EventStatus.ACTIVE
    created_at: str
    closed_at: Optional[str] = None
    terms_and_conditions: Optional[str] = None
    refund_policy: Optional[str] = None
    paypal_merchant_id: Optional[str] = "sandbox-merchant-01"
    cashfree_app_id: Optional[str] = "sandbox-cashfree-01"


class Participant(BaseModel):
    id: str
    event_id: str
    organizer_id: str = "org-001"
    name: str
    email: str
    phone: Optional[str] = None
    registration_id: str
    registered_at: str
    
    # 3 Distinct Entity Statuses
    registration_status: RegistrationStatus = RegistrationStatus.PENDING
    invoice_status: InvoiceStatus = InvoiceStatus.DRAFT
    payment_status: PaymentStatus = PaymentStatus.UNPAID
    
    # Backward compatibility status accessor
    status: str = "AWAITING_PAYMENT"

    amount: Decimal = Decimal("0.00")
    currency: str = "USD"
    payment_provider: Optional[PaymentProvider] = None
    payment_order_id: Optional[str] = None
    
    # PayPal specific fields
    paypal_invoice_id: Optional[str] = None
    paypal_payment_url: Optional[str] = None
    paypal_qr_base64: Optional[str] = None
    
    # Cashfree specific fields
    cashfree_order_id: Optional[str] = None
    cashfree_payment_session_id: Optional[str] = None
    cashfree_upi_link: Optional[str] = None
    cashfree_qr_data: Optional[str] = None

    paid_at: Optional[str] = None
    transaction_reference: Optional[str] = None
    refunded_at: Optional[str] = None
    refund_reference: Optional[str] = None


class LedgerEntry(BaseModel):
    id: str
    event_id: str
    organizer_id: str = "org-001"
    participant_id: Optional[str] = None
    participant_name: Optional[str] = None
    payer_identifier: str  # email or reference
    amount: Decimal = Decimal("0.00")
    currency: str = "USD"
    provider: PaymentProvider = PaymentProvider.PAYPAL
    order_id: Optional[str] = None
    txn_ref: str
    status: str = "PAID"
    matched_at: str
    tagged_by: Optional[str] = None
    tagged_at: Optional[str] = None


class SettlementProofModel(BaseModel):
    event_id: str
    canonical_snapshot_hash: str  # SHA-256
    signature: str               # ECDSA signature hex
    key_id: str
    signed_at: str
    canonical_snapshot: Optional[str] = None


class ProcessedWebhookEvent(BaseModel):
    webhook_id: str
    event_id: str
    event_type: str
    provider: PaymentProvider = PaymentProvider.PAYPAL
    resource_id: str
    processed_at: str
    status: str


class AuditLog(BaseModel):
    id: str
    actor: str
    action: str
    event_id: Optional[str] = None
    participant_id: Optional[str] = None
    invoice_id: Optional[str] = None
    order_id: Optional[str] = None
    provider: Optional[str] = None
    status: str
    timestamp: str
    details: Optional[Dict[str, Any]] = None


# ── Request / Response Bodies ──

class CreateEventRequest(BaseModel):
    title: str
    description: Optional[str] = ""
    category: Optional[str] = "Conference"
    amount: Decimal = Decimal("0.00")
    target_amount: Optional[Decimal] = None
    expected_participants: Optional[int] = 50
    max_participants: Optional[int] = None
    currency: Optional[str] = "USD"
    expiry_days: Optional[int] = 14
    terms_and_conditions: Optional[str] = None
    refund_policy: Optional[str] = None


class RegisterParticipantRequest(BaseModel):
    name: str
    email: str
    phone: Optional[str] = None


class PaymentEligibilityRequest(BaseModel):
    currency: str
    amount: Decimal
    payer_country: Optional[str] = "IN"  # e.g., "IN", "US", "GB"


class PaymentEligibilityResponse(BaseModel):
    eligible_providers: List[Dict[str, Any]]
    recommended_provider: str
    reason: str


class CreatePaymentOrderRequest(BaseModel):
    participant_id: str
    preferred_provider: Optional[str] = None
    payer_country: Optional[str] = "IN"


class AIPromptRequest(BaseModel):
    prompt: str
    event_id: Optional[str] = None


class AIApproveActionRequest(BaseModel):
    action_type: str  # "PUBLISH_EVENT", "DISPATCH_REMINDERS", "ISSUE_REFUND"
    payload: Dict[str, Any]
    approved: bool = False


class SendReminderRequest(BaseModel):
    participant_ids: List[str]
    custom_message: Optional[str] = None
    tone: Optional[str] = "friendly"


class RefundRequest(BaseModel):
    reason: Optional[str] = "Participant requested refund"
