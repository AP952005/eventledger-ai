"""
PayGo — Transaction Normalization & Analytics Service
Transforms raw AA-format transactions into internal schema,
computes spending summaries, detects recurring transactions.
"""
import uuid
from datetime import datetime, timedelta
from collections import defaultdict

from services.categorization_service import categorize


# ── In-memory storage ──
_financial_accounts: dict[str, dict] = {}  # account_id -> account
_transactions: list[dict] = []            # normalized transactions
_user_accounts: dict[str, list[str]] = defaultdict(list)  # user_id -> [account_id]


def store_account(user_id: str, account: dict) -> dict:
    """Store a linked financial account."""
    internal_id = str(uuid.uuid4())
    stored = {
        "id": internal_id,
        "user_id": user_id,
        "fip_id": account["fip_id"],
        "account_type": account["account_type"],
        "masked_account_number": account["masked_account_number"],
        "bank_name": account["bank_name"],
        "balance": account.get("balance", 0.0),
        "holder_name": account.get("holder_name", "Abishek"),
        "linked_at": datetime.now().isoformat(),
        "last_synced": datetime.now().isoformat(),
        "status": "ACTIVE",
        "aa_account_id": account.get("account_id", ""),
    }
    _financial_accounts[internal_id] = stored
    _user_accounts[user_id].append(internal_id)
    return stored


def get_user_accounts(user_id: str) -> list[dict]:
    """Get all linked accounts for a user."""
    return [
        _financial_accounts[aid]
        for aid in _user_accounts.get(user_id, [])
        if aid in _financial_accounts and _financial_accounts[aid]["status"] == "ACTIVE"
    ]


def unlink_account(account_id: str) -> bool:
    """Mark an account as unlinked."""
    if account_id in _financial_accounts:
        _financial_accounts[account_id]["status"] = "UNLINKED"
        return True
    return False


def normalize_and_store(raw_transactions: list[dict], account_id: str) -> int:
    """
    Normalize raw AA-format transactions into internal schema and store.
    Returns count of transactions stored.
    """
    count = 0
    existing_txn_ids = {t["transaction_id"] for t in _transactions if t["account_id"] == account_id}

    for raw in raw_transactions:
        txn_id = raw["transaction_id"]
        if txn_id in existing_txn_ids:
            continue  # skip duplicates

        normalized = {
            "id": str(uuid.uuid4()),
            "account_id": account_id,
            "transaction_id": txn_id,
            "date": raw["date"],
            "amount": float(raw["amount"]),
            "type": raw["type"],  # DEBIT | CREDIT
            "description": raw["description"],
            "merchant": raw.get("merchant", "Unknown"),
            "category": categorize(raw["description"], raw.get("category_hint")),
            "is_recurring": raw.get("is_recurring", False),
            "created_at": datetime.now().isoformat(),
        }
        _transactions.append(normalized)
        count += 1

    return count


def get_transactions(
    user_id: str,
    account_id: str | None = None,
    category: str | None = None,
    from_date: str | None = None,
    to_date: str | None = None,
    txn_type: str | None = None,
) -> list[dict]:
    """Get filtered transactions for a user."""
    user_account_ids = set(_user_accounts.get(user_id, []))
    if account_id:
        user_account_ids = {account_id} & user_account_ids

    results = [t for t in _transactions if t["account_id"] in user_account_ids]

    if category:
        results = [t for t in results if t["category"] == category]

    if txn_type:
        results = [t for t in results if t["type"] == txn_type]

    if from_date:
        results = [t for t in results if t["date"] >= from_date]

    if to_date:
        results = [t for t in results if t["date"] <= to_date]

    # Sort by date descending
    results.sort(key=lambda t: t["date"], reverse=True)
    return results


def get_summary(user_id: str, period: str = "this_month") -> dict:
    """
    Compute spending summary for a user over a period.
    period: 'this_month', 'last_month', '3_months', '6_months'
    """
    now = datetime.now()
    if period == "last_month":
        start = (now.replace(day=1) - timedelta(days=1)).replace(day=1)
        end = now.replace(day=1) - timedelta(days=1)
    elif period == "3_months":
        start = now - timedelta(days=90)
        end = now
    elif period == "6_months":
        start = now - timedelta(days=180)
        end = now
    else:  # this_month
        start = now.replace(day=1)
        end = now

    start_str = start.isoformat()
    end_str = end.isoformat()

    txns = get_transactions(user_id, from_date=start_str, to_date=end_str)

    income = sum(t["amount"] for t in txns if t["type"] == "CREDIT")
    expenses = sum(t["amount"] for t in txns if t["type"] == "DEBIT")

    # Category breakdown (expenses only)
    by_category: dict[str, float] = defaultdict(float)
    for t in txns:
        if t["type"] == "DEBIT":
            by_category[t["category"]] += t["amount"]

    top_category = max(by_category, key=by_category.get) if by_category else None

    # Budget insights
    debit_txns = [t for t in txns if t["type"] == "DEBIT"]
    days_in_period = max((end - start).days, 1)
    avg_daily_spend = expenses / days_in_period if days_in_period > 0 else 0
    highest_expense = max(debit_txns, key=lambda t: t["amount"]) if debit_txns else None

    # Most frequent merchant
    merchant_counts: dict[str, int] = defaultdict(int)
    for t in debit_txns:
        merchant_counts[t["merchant"]] += 1
    most_frequent_merchant = max(merchant_counts, key=merchant_counts.get) if merchant_counts else None

    savings_rate = ((income - expenses) / income * 100) if income > 0 else 0

    return {
        "period": period,
        "income": round(income, 2),
        "expenses": round(expenses, 2),
        "savings": round(income - expenses, 2),
        "savings_rate": round(savings_rate, 1),
        "top_category": top_category,
        "transaction_count": len(txns),
        "avg_daily_spend": round(avg_daily_spend, 2),
        "highest_expense": {
            "amount": highest_expense["amount"],
            "merchant": highest_expense["merchant"],
            "date": highest_expense["date"],
        } if highest_expense else None,
        "most_frequent_merchant": most_frequent_merchant,
        "category_breakdown": dict(by_category),
    }


def get_trends(user_id: str) -> list[dict]:
    """Get monthly category trends for the last 6 months."""
    now = datetime.now()
    monthly_data = []

    for months_ago in range(5, -1, -1):
        month_start = (now - timedelta(days=months_ago * 30)).replace(day=1)
        if months_ago == 0:
            month_end = now
        else:
            month_end = (month_start + timedelta(days=32)).replace(day=1) - timedelta(days=1)

        txns = get_transactions(
            user_id,
            from_date=month_start.isoformat(),
            to_date=month_end.isoformat(),
        )

        income = sum(t["amount"] for t in txns if t["type"] == "CREDIT")
        expenses = sum(t["amount"] for t in txns if t["type"] == "DEBIT")

        by_category: dict[str, float] = defaultdict(float)
        for t in txns:
            if t["type"] == "DEBIT":
                by_category[t["category"]] += t["amount"]

        monthly_data.append({
            "month": month_start.strftime("%b %Y"),
            "income": round(income, 2),
            "expenses": round(expenses, 2),
            "savings": round(income - expenses, 2),
            "categories": dict(by_category),
        })

    return monthly_data


def get_recurring_transactions(user_id: str) -> list[dict]:
    """Detect recurring transactions (rule-based: same merchant + is_recurring flag)."""
    txns = get_transactions(user_id)
    recurring = [t for t in txns if t.get("is_recurring", False)]

    # Group by merchant
    by_merchant: dict[str, list[dict]] = defaultdict(list)
    for t in recurring:
        by_merchant[t["merchant"]].append(t)

    results = []
    for merchant, merchant_txns in by_merchant.items():
        amounts = [t["amount"] for t in merchant_txns]
        avg_amount = sum(amounts) / len(amounts)
        dates = sorted([t["date"] for t in merchant_txns])
        last_date = dates[-1] if dates else None

        results.append({
            "merchant": merchant,
            "category": merchant_txns[0]["category"],
            "avg_amount": round(avg_amount, 2),
            "frequency": "Monthly",
            "occurrence_count": len(merchant_txns),
            "last_date": last_date,
            "type": merchant_txns[0]["type"],
        })

    results.sort(key=lambda r: r["avg_amount"], reverse=True)
    return results
