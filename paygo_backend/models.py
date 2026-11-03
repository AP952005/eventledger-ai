"""
PayGo Backend — Pydantic Data Models
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum


class TransactionDirection(str, Enum):
    SENT = "sent"
    RECEIVED = "received"


class TransactionCategory(str, Enum):
    P2P = "p2p"
    RECHARGE = "recharge"
    BILL = "bill"
    SHOPPING = "shopping"
    INVESTMENT = "investment"


class TransactionStatus(str, Enum):
    SUCCESS = "success"
    PENDING = "pending"
    FAILED = "failed"


class NotificationType(str, Enum):
    TXN = "txn"
    OFFER = "offer"
    SYSTEM = "system"


class BankAccount(BaseModel):
    id: str
    bank_name: str
    account_last4: str
    is_primary: bool


class User(BaseModel):
    id: str
    name: str
    phone: str
    upi_id: str
    is_verified: bool
    avatar_url: Optional[str] = None
    linked_banks: List[BankAccount] = []
    postpaid_limit: Optional[float] = None
    wallet_balance: float = 0.0
    event_vpa: Optional[str] = None  # Event Collect alias VPA


class Transaction(BaseModel):
    id: str
    from_user_id: str
    to_user_id: Optional[str] = None
    merchant_or_biller_id: Optional[str] = None
    amount: float
    direction: TransactionDirection
    category: TransactionCategory
    status: TransactionStatus
    note: Optional[str] = None
    timestamp: datetime


class SavedBiller(BaseModel):
    id: str
    user_id: str
    category: str
    provider_name: str
    identifier: str
    added_on: datetime
    autopay_enabled: bool


class Notification(BaseModel):
    id: str
    type: NotificationType
    title: str
    body: str
    read: bool
    created_at: datetime


class Contact(BaseModel):
    id: str
    name: str
    phone: str
    upi_id: Optional[str] = None
    avatar_url: Optional[str] = None


# ── Event Collect Models ──
# OUT OF SCOPE (by design, not oversight):
# - No NLP/LLM parsing of event titles, notes, or participant names
# - No fuzzy matching for unmatched payments — exact match or manual tag only
# - No auto-generated reminder copy — fixed templates only
# - No custodial wallet balance — funds never sit inside payGO
# - No auto-close before stated expiry
# - No editing of ledger data after CLOSED


class EventAmountMode(str, Enum):
    FIXED = "FIXED"
    SUGGESTED = "SUGGESTED"
    FLEXIBLE = "FLEXIBLE"


class EventStatus(str, Enum):
    ACTIVE = "ACTIVE"
    EXPIRED = "EXPIRED"
    CLOSED = "CLOSED"


class Event(BaseModel):
    id: str
    organizer_id: str
    title: str
    amount_mode: EventAmountMode
    amount: Optional[float] = None
    target_amount: Optional[float] = None
    same_amount_from_everyone: bool = False
    expiry_at: str  # ISO timestamp
    status: EventStatus = EventStatus.ACTIVE
    settlement_vpa: str
    settlement_name: str
    settlement_account_id: str
    created_at: str
    closed_at: Optional[str] = None


class LedgerEntry(BaseModel):
    id: str
    event_id: str
    participant_id: Optional[str] = None   # null until tagged
    participant_name: Optional[str] = None
    payer_vpa_or_phone: str
    amount: float
    txn_ref: str
    matched_at: str
    tagged_by: Optional[str] = None   # organizerUserId if manually matched
    tagged_at: Optional[str] = None


class SettlementProofModel(BaseModel):
    event_id: str
    canonical_snapshot_hash: str  # SHA-256
    signature: str               # ECDSA signature hex
    key_id: str
    signed_at: str
    canonical_snapshot: Optional[str] = None


class ReminderTemplateModel(BaseModel):
    id: str
    name: str
    body_template: str


# --- Request/Response Models ---

class OTPRequestBody(BaseModel):
    phone: str


class OTPVerifyBody(BaseModel):
    otp_session_id: str
    code: str


class PinSetBody(BaseModel):
    pin: str


class FetchBillBody(BaseModel):
    category: str
    identifier: str


class PaymentInitiateBody(BaseModel):
    payee_upi_id: Optional[str] = None
    biller_id: Optional[str] = None
    amount: float
    category: str
    note: Optional[str] = None


class PaymentConfirmBody(BaseModel):
    txn_id: str
    pin: str


class OTPResponse(BaseModel):
    otp_session_id: str


class AuthResponse(BaseModel):
    auth_token: str
    is_new_user: bool


class BillResponse(BaseModel):
    amount: float
    due_date: str


class PaymentResponse(BaseModel):
    txn_id: str
    status: str
    reason: Optional[str] = None


class BillerCategory(BaseModel):
    key: str
    label: str
    icon: str
    badge: Optional[str] = None


class HomeFeedResponse(BaseModel):
    promos: list
    shortcuts: list
    offers: list


class FinancialProductsResponse(BaseModel):
    loans: list
    insurance: list
    investments: list
    cards: list


class QRResponse(BaseModel):
    upi_deep_link: str
    image_png_url: Optional[str] = None


# ── Event Collect Request/Response Bodies ──

class AliasCheckResponse(BaseModel):
    available: bool


class AliasRegisterBody(BaseModel):
    handle: str


class CreateEventBody(BaseModel):
    title: str
    amount_mode: EventAmountMode
    amount: Optional[float] = None
    target_amount: Optional[float] = None
    same_amount_from_everyone: bool = False
    expiry_at: str
    settlement_account_id: Optional[str] = None


class SendReminderBody(BaseModel):
    template_id: str
    participant_ids: List[str]


class TagPaymentBody(BaseModel):
    participant_id: str
    participant_name: str


class UPISettlementWebhook(BaseModel):
    txn_ref: str
    payer_vpa: str
    amount: float
    timestamp: str


class VerifyResponse(BaseModel):
    event: Optional[Event] = None
    ledger: List[LedgerEntry] = []
    proof: Optional[SettlementProofModel] = None


# ══════════════════════════════════════════════
# FINANCIAL HUB — AA Models
# ══════════════════════════════════════════════

class ConsentRequest(BaseModel):
    purpose: str = "Personal financial management"
    from_date: str
    to_date: str
    frequency: str = "ONE_TIME"  # ONE_TIME | RECURRING


class ConsentResponse(BaseModel):
    consent_id: str
    redirect_url: str
    status: str


class MockApproveBody(BaseModel):
    consent_id: str
    bank_name: str


class SyncRequest(BaseModel):
    consent_id: str


class FinancialAccountResponse(BaseModel):
    id: str
    fip_id: str
    account_type: str
    masked_account_number: str
    bank_name: str
    balance: float
    holder_name: str
    linked_at: str
    last_synced: str
    status: str


class FinancialTransactionResponse(BaseModel):
    id: str
    account_id: str
    transaction_id: str
    date: str
    amount: float
    type: str  # DEBIT | CREDIT
    description: str
    merchant: Optional[str] = None
    category: str
    is_recurring: bool = False


class CategoryBreakdown(BaseModel):
    category: str
    amount: float
    percentage: float


class HighestExpense(BaseModel):
    amount: float
    merchant: str
    date: str


class SpendingSummaryResponse(BaseModel):
    period: str
    income: float
    expenses: float
    savings: float
    savings_rate: float
    top_category: Optional[str] = None
    transaction_count: int
    avg_daily_spend: float
    highest_expense: Optional[HighestExpense] = None
    most_frequent_merchant: Optional[str] = None
    category_breakdown: dict = {}


class MonthlyTrend(BaseModel):
    month: str
    income: float
    expenses: float
    savings: float
    categories: dict = {}


class RecurringTransaction(BaseModel):
    merchant: str
    category: str
    avg_amount: float
    frequency: str
    occurrence_count: int
    last_date: Optional[str] = None
    type: str


class ConsentDetail(BaseModel):
    consent_id: str
    user_id: str = ""
    purpose: str = ""
    from_date: str = ""
    to_date: str = ""
    frequency: str = ""
    status: str = ""
    created_at: str = ""
    data_types: List[str] = []
    bank_name: Optional[str] = None


class AIChatRequest(BaseModel):
    prompt: str
    user_id: Optional[str] = "u-001"
