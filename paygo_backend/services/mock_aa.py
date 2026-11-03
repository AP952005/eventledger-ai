"""
PayGo — Mock Account Aggregator Implementation
Generates realistic fake data for offline development.
This is the ONLY file that should be imported by aa_factory.py.
"""
import random
import uuid
from datetime import datetime, timedelta
from typing import Optional

from services.aa_gateway import AccountAggregator, ConsentStatus


# ── Mock bank definitions ──
MOCK_BANKS = {
    "APS Bank": {"fip_id": "APSBANK", "balance": 124500.00, "last4": "4402"},
    "State Bank of India": {"fip_id": "SBIN", "balance": 87230.50, "last4": "6721"},
    "HDFC Bank": {"fip_id": "HDFC", "balance": 45600.75, "last4": "3318"},
    "ICICI Bank": {"fip_id": "ICICI", "balance": 33200.00, "last4": "9045"},
    "Axis Bank": {"fip_id": "AXIS", "balance": 28750.25, "last4": "7712"},
    "Kotak Mahindra Bank": {"fip_id": "KOTAK", "balance": 56100.00, "last4": "2209"},
}

MERCHANTS = {
    "FOOD": [
        ("Swiggy", 150, 800), ("Zomato", 120, 650), ("Dominos", 200, 900),
        ("McDonald's", 100, 500), ("Local Restaurant", 80, 400), ("Starbucks", 250, 600),
    ],
    "SHOPPING": [
        ("Amazon", 200, 8000), ("Flipkart", 300, 6000), ("Myntra", 400, 5000),
        ("Meesho", 150, 2000), ("Croma", 1000, 15000), ("Reliance Digital", 500, 10000),
    ],
    "TRANSPORT": [
        ("Uber", 80, 600), ("Ola", 70, 500), ("Rapido", 40, 250),
        ("Metro Recharge", 200, 500), ("Petrol Pump", 500, 3000), ("IRCTC", 300, 2500),
    ],
    "BILLS": [
        ("Electricity Board", 800, 3500), ("Jio Recharge", 199, 999),
        ("Airtel Recharge", 239, 899), ("Water Bill", 200, 600),
        ("Gas Bill", 300, 1200), ("Broadband", 500, 1500),
    ],
    "INCOME": [
        ("Salary - Employer", 50000, 50000),
    ],
    "RENT": [
        ("Landlord Transfer", 12000, 12000),
    ],
    "OTHER": [
        ("ATM Withdrawal", 500, 10000), ("Miscellaneous Transfer", 100, 5000),
        ("Gym Membership", 1500, 3000), ("Netflix", 199, 649),
        ("Spotify", 119, 179), ("YouTube Premium", 129, 189),
    ],
}


class MockAA(AccountAggregator):
    """Mock Account Aggregator — generates realistic fake financial data."""

    def __init__(self):
        self._consents: dict[str, dict] = {}
        self._linked_accounts: dict[str, dict] = {}

    async def create_consent(
        self, user_id: str, purpose: str, from_date: str, to_date: str, frequency: str
    ) -> dict:
        consent_id = f"CONSENT-{uuid.uuid4().hex[:8].upper()}"
        now = datetime.now()
        self._consents[consent_id] = {
            "consent_id": consent_id,
            "user_id": user_id,
            "purpose": purpose,
            "from_date": from_date,
            "to_date": to_date,
            "frequency": frequency,
            "status": "PENDING",
            "created_at": now.isoformat(),
            "data_types": [
                "Account information",
                "Transactions",
                "Transaction dates",
                "Transaction amounts",
            ],
        }
        return {
            "consent_id": consent_id,
            "redirect_url": f"/mock-aa/approve/{consent_id}",
            "status": "PENDING",
        }

    async def get_consent_status(self, consent_id: str) -> ConsentStatus:
        if consent_id not in self._consents:
            return "EXPIRED"
        return self._consents[consent_id]["status"]

    async def approve_consent(self, consent_id: str, bank_name: str) -> dict:
        if consent_id not in self._consents:
            return {"status": "EXPIRED"}
        self._consents[consent_id]["status"] = "APPROVED"
        self._consents[consent_id]["bank_name"] = bank_name
        return {"status": "APPROVED"}

    async def reject_consent(self, consent_id: str) -> dict:
        if consent_id not in self._consents:
            return {"status": "EXPIRED"}
        self._consents[consent_id]["status"] = "REJECTED"
        return {"status": "REJECTED"}

    async def revoke_consent(self, consent_id: str) -> dict:
        if consent_id not in self._consents:
            return {"status": "EXPIRED"}
        self._consents[consent_id]["status"] = "REVOKED"
        return {"status": "REVOKED"}

    async def fetch_accounts(self, consent_id: str) -> list[dict]:
        if consent_id not in self._consents:
            return []
        consent = self._consents[consent_id]
        if consent["status"] != "APPROVED":
            return []

        bank_name = consent.get("bank_name", "APS Bank")
        bank_info = MOCK_BANKS.get(bank_name, MOCK_BANKS["APS Bank"])
        account_id = f"ACC-{bank_info['fip_id']}-{uuid.uuid4().hex[:6].upper()}"

        account = {
            "account_id": account_id,
            "fip_id": bank_info["fip_id"],
            "account_type": "SAVINGS",
            "masked_account_number": f"XXXXXX{bank_info['last4']}",
            "bank_name": bank_name,
            "balance": bank_info["balance"],
            "holder_name": "Abishek",
        }
        self._linked_accounts[account_id] = account
        return [account]

    async def fetch_transactions(
        self, consent_id: str, account_id: str, from_date: str, to_date: str
    ) -> list[dict]:
        if consent_id not in self._consents:
            return []
        if self._consents[consent_id]["status"] != "APPROVED":
            return []

        txns = []
        num_txns = random.randint(50, 100)

        # Generate realistic distribution
        category_weights = {
            "FOOD": 25, "SHOPPING": 15, "TRANSPORT": 15,
            "BILLS": 15, "INCOME": 5, "RENT": 5, "OTHER": 20,
        }
        categories = []
        for cat, weight in category_weights.items():
            categories.extend([cat] * weight)

        for i in range(num_txns):
            cat = random.choice(categories)
            merchants_for_cat = MERCHANTS[cat]
            merchant_name, min_amt, max_amt = random.choice(merchants_for_cat)

            days_ago = random.randint(0, 90)
            txn_date = datetime.now() - timedelta(days=days_ago)

            amount = round(random.uniform(min_amt, max_amt), 2)
            txn_type = "CREDIT" if cat == "INCOME" else "DEBIT"

            # Make some transactions recurring
            is_recurring = cat in ("INCOME", "RENT") or (
                cat == "OTHER" and merchant_name in ("Netflix", "Spotify", "YouTube Premium", "Gym Membership")
            )

            txns.append({
                "transaction_id": f"TXN-{account_id[-6:]}-{i:04d}",
                "date": txn_date.isoformat(),
                "amount": amount,
                "type": txn_type,
                "description": f"UPI-{merchant_name.upper().replace(' ', '')}-{txn_date.strftime('%d%m')}",
                "merchant": merchant_name,
                "category_hint": cat,
                "is_recurring": is_recurring,
            })

        # Sort by date descending
        txns.sort(key=lambda t: t["date"], reverse=True)
        return txns

    async def get_consent_details(self, consent_id: str) -> dict:
        if consent_id not in self._consents:
            return {"consent_id": consent_id, "status": "EXPIRED"}
        return self._consents[consent_id]
