"""
PayGo — Account Aggregator Factory
Dependency injection wiring. This is the ONLY file that imports MockAA.
"""
from services.aa_gateway import AccountAggregator
from services.mock_aa import MockAA

# Singleton instance for the app lifecycle
_instance: AccountAggregator | None = None


def get_account_aggregator() -> AccountAggregator:
    """
    Returns the active AccountAggregator implementation.
    Currently: MockAA (offline development).
    Future: swap to SandboxAA or ProductionAA here without touching call sites.
    """
    global _instance
    if _instance is None:
        _instance = MockAA()
    return _instance
