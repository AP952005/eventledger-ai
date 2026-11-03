"""
PayGo — Rule-based Transaction Categorization Service
Keyword matching only — no ML models.
"""

CATEGORY_RULES: dict[str, list[str]] = {
    "FOOD": ["swiggy", "zomato", "dominos", "mcdonald", "restaurant", "starbucks", "food", "cafe", "pizza", "burger"],
    "SHOPPING": ["amazon", "flipkart", "myntra", "meesho", "croma", "reliance digital", "shopping", "mart"],
    "TRANSPORT": ["uber", "ola", "rapido", "metro", "petrol", "irctc", "fuel", "cab", "auto", "railway"],
    "BILLS": ["electricity", "jio", "airtel", "vodafone", "water bill", "gas bill", "broadband", "recharge", "postpaid"],
    "INCOME": ["salary", "credit interest", "refund", "cashback"],
    "RENT": ["rent", "landlord", "house rent", "room rent"],
}


def categorize(description: str, category_hint: str | None = None) -> str:
    """
    Categorize a transaction by description keywords.
    Falls back to category_hint from the AA provider if no keyword matches.
    Returns one of: FOOD, SHOPPING, TRANSPORT, BILLS, INCOME, RENT, OTHER.
    """
    if category_hint and category_hint in (
        "FOOD", "SHOPPING", "TRANSPORT", "BILLS", "INCOME", "RENT", "OTHER"
    ):
        return category_hint

    desc_lower = description.lower()
    for category, keywords in CATEGORY_RULES.items():
        if any(keyword in desc_lower for keyword in keywords):
            return category

    return "OTHER"
