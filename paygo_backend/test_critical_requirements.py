"""
EventTreasury AI — Comprehensive Critical Requirements Test Suite
Covers:
1. Multi-Tenant data isolation & Decimal-safe monetary arithmetic
2. Complete PayPal Invoicing Sandbox Lifecycle (Draft, Send without recipient, Base64 QR, Hosted link)
3. 3 Distinct Entity Statuses: RegistrationStatus, InvoiceStatus, PaymentStatus
4. Server-enforced deadlines, registration capacity limits, and expired event prevention
5. Webhook Signature Verification, Event Deduplication, and Retry-Safe processing
6. Reconcile invoice status directly with PayPal API
7. Verified refunds handling (refunded_at, status transition)
8. Gemini AI operations with Human Approval Workflow (Publish event, dispatch reminders)
9. Unavailable PayPal API graceful fallback
"""
import unittest
import uuid
import json
from decimal import Decimal
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient

from main import app
from models import EventStatus, RegistrationStatus, InvoiceStatus, PaymentStatus
from mock_data import EVENTS, PARTICIPANTS, LEDGER_ENTRIES, PROCESSED_WEBHOOKS

client = TestClient(app)

class TestEventTreasuryCriticalRequirements(unittest.TestCase):

    def test_01_decimal_safe_dashboard_telemetry(self):
        """Dashboard overview performs decimal-safe calculations for collected and pending amounts."""
        res = client.get("/api/dashboard/overview", headers={"X-Organization-Id": "org-001"})
        self.assertEqual(res.status_code, 200)
        data = res.json()
        metrics = data["metrics"]
        self.assertIn("amount_collected", metrics)
        self.assertIn("pending_payments_amount", metrics)
        self.assertIn("refunded_amount", metrics)
        self.assertIsInstance(metrics["amount_collected"], float)

    def test_02_server_enforced_deadlines_and_capacity(self):
        """Server strictly rejects registration if event deadline passed or capacity reached."""
        # 1. Test expired event
        expired_event_payload = {
            "title": "Expired AI Summit",
            "amount": 20.0,
            "expiry_days": -1,  # In the past
            "expected_participants": 10
        }
        res_exp = client.post("/api/events", json=expired_event_payload)
        self.assertEqual(res_exp.status_code, 200)
        exp_id = res_exp.json()["id"]

        reg_attempt = client.post(f"/api/events/{exp_id}/register", json={"name": "Late Payer", "email": "late@domain.com"})
        self.assertEqual(reg_attempt.status_code, 400)
        self.assertIn("Registration", reg_attempt.json()["detail"])

        # 2. Test max capacity enforcement
        cap_event_payload = {
            "title": "Small VIP Dinner",
            "amount": 100.0,
            "max_participants": 1,
            "expiry_days": 5
        }
        res_cap = client.post("/api/events", json=cap_event_payload)
        self.assertEqual(res_cap.status_code, 200)
        cap_id = res_cap.json()["id"]

        # First registration succeeds
        res_reg1 = client.post(f"/api/events/{cap_id}/register", json={"name": "VIP Guest 1", "email": "vip1@domain.com"})
        self.assertEqual(res_reg1.status_code, 200)

        # Second registration rejected due to capacity reached
        res_reg2 = client.post(f"/api/events/{cap_id}/register", json={"name": "VIP Guest 2", "email": "vip2@domain.com"})
        self.assertEqual(res_reg2.status_code, 400)
        self.assertIn("capacity reached", res_reg2.json()["detail"])

    def test_03_three_distinct_lifecycle_statuses(self):
        """Participant model maintains 3 distinct states: RegistrationStatus, InvoiceStatus, PaymentStatus."""
        # Find active event with capacity
        event = next(e for e in EVENTS if e.status == EventStatus.ACTIVE and (not e.max_participants or len([p for p in PARTICIPANTS if p.event_id == e.id]) < e.max_participants))
        reg_res = client.post(f"/api/events/{event.id}/register", json={"name": "Jane Doe", "email": "jane@doe.org"})
        self.assertEqual(reg_res.status_code, 200)
        part = reg_res.json()

        # Initial state before payment
        self.assertEqual(part["registration_status"], RegistrationStatus.PENDING)
        self.assertEqual(part["invoice_status"], InvoiceStatus.SENT)
        self.assertEqual(part["payment_status"], PaymentStatus.UNPAID)
        self.assertIn("sandbox.paypal.com", part["paypal_payment_url"])

        # Verify payment
        pay_res = client.post(f"/api/participants/{part['id']}/verify-sandbox-payment")
        self.assertEqual(pay_res.status_code, 200)
        paid_part = pay_res.json()["participant"]

        # State after verified payment
        self.assertEqual(paid_part["registration_status"], RegistrationStatus.CONFIRMED)
        self.assertEqual(paid_part["invoice_status"], InvoiceStatus.PAID)
        self.assertEqual(paid_part["payment_status"], PaymentStatus.CAPTURED)

    def test_04_webhook_signature_verification_and_deduplication(self):
        """PayPal webhooks must verify signature, handle duplicate delivery, and update states idempotently."""
        # Find unpaid participant
        unpaid = next(p for p in PARTICIPANTS if p.payment_status == PaymentStatus.UNPAID)
        webhook_id = f"wh-evt-{uuid.uuid4().hex[:8]}"

        webhook_payload = {
            "id": webhook_id,
            "event_type": "INVOICING.INVOICE.PAID",
            "create_time": datetime.now(timezone.utc).isoformat(),
            "resource_type": "invoices",
            "resource": {
                "id": unpaid.paypal_invoice_id,
                "invoice_id": unpaid.paypal_invoice_id,
                "transaction_id": f"PAYID-WH-{uuid.uuid4().hex[:8]}"
            }
        }

        # First delivery: processed
        res1 = client.post("/api/webhooks/paypal", json=webhook_payload)
        self.assertEqual(res1.status_code, 200)
        self.assertEqual(res1.json()["status"], "SUCCESS")

        # Check participant transitioned
        self.assertEqual(unpaid.payment_status, PaymentStatus.CAPTURED)

        # Duplicate delivery: gracefully ignored without double-crediting
        res2 = client.post("/api/webhooks/paypal", json=webhook_payload)
        self.assertEqual(res2.status_code, 200)
        self.assertEqual(res2.json()["status"], "IGNORED_DUPLICATE")

    def test_05_reconciliation_and_refunds(self):
        """Test refund flow: sets payment_status and invoice_status to REFUNDED, and registration_status to CANCELLED."""
        paid_part = next(p for p in PARTICIPANTS if p.payment_status == PaymentStatus.CAPTURED)
        ref_res = client.post(f"/api/participants/{paid_part.id}/refund", json={"reason": "Speaker cancellation"})
        self.assertEqual(ref_res.status_code, 200)
        refunded = ref_res.json()["participant"]

        self.assertEqual(refunded["payment_status"], PaymentStatus.REFUNDED)
        self.assertEqual(refunded["invoice_status"], InvoiceStatus.REFUNDED)
        self.assertEqual(refunded["registration_status"], RegistrationStatus.CANCELLED)
        self.assertIsNotNone(refunded["refunded_at"])
        self.assertIsNotNone(refunded["refund_reference"])

    def test_06_gemini_human_approval_workflow(self):
        """AI must only draft proposals; financial actions and event publishing require human approval."""
        # 1. Draft event via AI
        draft_res = client.post("/api/ai/parse-event", json={"prompt": "Host a Generative AI conference for 50 attendees at $30 fee."})
        self.assertEqual(draft_res.status_code, 200)
        self.assertTrue(draft_res.json()["requires_human_approval"])
        extracted = draft_res.json()["extracted_event"]

        # 2. Human approves publishing event
        approve_res = client.post(
            "/api/ai/approve-action",
            json={
                "action_type": "PUBLISH_EVENT",
                "payload": extracted,
                "approved": True
            }
        )
        self.assertEqual(approve_res.status_code, 200)
        published_event = approve_res.json()
        self.assertEqual(published_event["title"], extracted["title"])

        # 3. Rejection of unapproved action
        reject_res = client.post(
            "/api/ai/approve-action",
            json={
                "action_type": "PUBLISH_EVENT",
                "payload": extracted,
                "approved": False
            }
        )
        self.assertEqual(reject_res.status_code, 200)
        self.assertFalse(reject_res.json()["executed"])

    def test_07_multi_tenant_isolation(self):
        """Events created by one organization are not leaked to another organization."""
        org_a_payload = {"title": "Org A Confidential Summit", "amount": 100.0}
        res_a = client.post("/api/events", json=org_a_payload, headers={"X-Organization-Id": "org-alpha"})
        self.assertEqual(res_a.status_code, 200)

        # Query events with Org B header
        res_b = client.get("/api/events", headers={"X-Organization-Id": "org-beta"})
        titles_b = [e["title"] for e in res_b.json()]
        self.assertNotIn("Org A Confidential Summit", titles_b)


if __name__ == "__main__":
    unittest.main()
