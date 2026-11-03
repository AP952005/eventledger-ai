"""
PayGo — Account Aggregator Gateway Interface
Abstract base class defining the contract for AA providers.
All backend code depends on this interface — never on a concrete implementation.
"""
from abc import ABC, abstractmethod
from typing import Literal

ConsentStatus = Literal["PENDING", "APPROVED", "REJECTED", "EXPIRED", "REVOKED"]


class AccountAggregator(ABC):
    """
    Abstract Account Aggregator interface.
    Implement this for each AA provider (MockAA, SandboxAA, ProductionAA).
    """

    @abstractmethod
    async def create_consent(
        self, user_id: str, purpose: str, from_date: str, to_date: str, frequency: str
    ) -> dict:
        """
        Create a data-access consent request.
        Returns { consent_id, redirect_url, status }
        """

    @abstractmethod
    async def get_consent_status(self, consent_id: str) -> ConsentStatus:
        """Get current consent status."""

    @abstractmethod
    async def approve_consent(self, consent_id: str, bank_name: str) -> dict:
        """Mock-only: simulate bank approval. Returns { status }."""

    @abstractmethod
    async def reject_consent(self, consent_id: str) -> dict:
        """Mock-only: simulate bank rejection. Returns { status }."""

    @abstractmethod
    async def revoke_consent(self, consent_id: str) -> dict:
        """Revoke an active consent. Returns { status }."""

    @abstractmethod
    async def fetch_accounts(self, consent_id: str) -> list[dict]:
        """
        Fetch linked accounts after consent is approved.
        Returns [{ fip_id, account_type, masked_account_number, bank_name, balance, holder_name }]
        """

    @abstractmethod
    async def fetch_transactions(
        self, consent_id: str, account_id: str, from_date: str, to_date: str
    ) -> list[dict]:
        """
        Fetch raw provider-format transaction records.
        Returns [{ transaction_id, date, amount, type, description, merchant, category_hint }]
        """

    @abstractmethod
    async def get_consent_details(self, consent_id: str) -> dict:
        """
        Get full consent artifact details.
        Returns { consent_id, user_id, purpose, from_date, to_date, frequency, status, created_at, data_types }
        """
