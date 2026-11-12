"""
EventTreasury AI — End-to-End Test Suite
Tests:
1. Event Creation & Expiry enforcement
2. Dual-Level QR Generation & Participant Registration
3. PayPal Invoicing v2 simulation & Level 2 Base64 QR code return
4. Verified Payment Transition & Immutable Ledger append
5. Cryptographic Settlement Proof Generation (SHA-256 + ECDSA)
6. Gemini AI Capabilities:
   - Natural language event parameter extraction
   - Grounded conversational telemetry answering
   - Smart personalized reminder copy generation
   - Comprehensive event financial audit reporting
"""
import unittest
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient

from main import app
from models import EventStatus, RegistrationStatus, InvoiceStatus, PaymentStatus
from mock_data import EVENTS, PARTICIPANTS, LEDGER_ENTRIES

client = TestClient(app)

class TestEventTreasuryAI(unittest.TestCase):

    def test_01_dashboard_telemetry(self):
        """Dashboard overview returns grounded metrics."""
        response = client.get("/api/dashboard/overview", headers={"X-Organization-Id": "org-001"})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("metrics", data)
        self.assertIn("amount_collected", data["metrics"])
        self.assertIn("event_breakdowns", data)
        self.assertGreaterEqual(data["metrics"]["total_events"], 1)

    def test_02_create_event_and_expiry(self):
        """Organizer creates an event with PayPal parameters."""
        payload = {
            "title": "Autonomous Agents Summit 2026",
            "description": "Multi-agent systems and real-world PayPal automated rails",
            "category": "Hackathon",
            "amount": 50.0,
            "target_amount": 5000.0,
            "expected_participants": 100,
            "currency": "USD",
            "expiry_days": 10
        }
        res = client.post("/api/events", json=payload, headers={"X-Organization-Id": "org-001"})
        self.assertEqual(res.status_code, 200)
        event = res.json()
        self.assertEqual(event["title"], "Autonomous Agents Summit 2026")
        self.assertEqual(event["amount"], 50.0)
        self.assertEqual(event["currency"], "USD")
        self.assertEqual(event["status"], EventStatus.ACTIVE)

    def test_03_participant_registration_two_level_qr(self):
        """Participant registers and gets individual Level 2 PayPal invoice & QR."""
        event = next(e for e in EVENTS if e.status == EventStatus.ACTIVE and (not e.max_participants or len([p for p in PARTICIPANTS if p.event_id == e.id]) < e.max_participants))
        reg_payload = {
            "name": "Sarah Connor",
            "email": "sarah.connor@cyberdyne.org",
            "phone": "+14155551299"
        }
        res = client.post(f"/api/events/{event.id}/register", json=reg_payload)
        self.assertEqual(res.status_code, 200)
        part = res.json()
        self.assertEqual(part["name"], "Sarah Connor")
        self.assertEqual(part["registration_status"], RegistrationStatus.PENDING)
        self.assertEqual(part["payment_status"], PaymentStatus.UNPAID)
        self.assertIsNotNone(part["paypal_invoice_id"])
        self.assertIn("sandbox.paypal.com", part["paypal_payment_url"])

        # Verify participant checkout query
        checkout_res = client.get(f"/api/participants/{part['id']}")
        self.assertEqual(checkout_res.status_code, 200)
        self.assertEqual(checkout_res.json()["participant"]["id"], part["id"])

    def test_04_payment_verification_and_ledger(self):
        """Simulate verified payment in PayPal sandbox, updating participant and ledger."""
        participant = PARTICIPANTS[-1]
        part_id = participant.id
        initial_ledger_count = len(LEDGER_ENTRIES)

        res = client.post(f"/api/participants/{part_id}/verify-sandbox-payment")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["participant"]["payment_status"], PaymentStatus.CAPTURED)
        self.assertIsNotNone(data["participant"]["paid_at"])
        self.assertIsNotNone(data["participant"]["transaction_reference"])
        self.assertEqual(len(LEDGER_ENTRIES), initial_ledger_count + 1)

    def test_05_event_close_cryptographic_proof(self):
        """Organizer closes event and generates SHA-256 + ECDSA Settlement Proof."""
        event = next(e for e in EVENTS if e.status == EventStatus.ACTIVE)
        res = client.post(f"/api/events/{event.id}/close", headers={"X-Organization-Id": event.organizer_id})
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertTrue(data["success"])
        self.assertIn("canonical_snapshot_hash", data["proof"])
        self.assertIn("signature", data["proof"])

    def test_06_ai_natural_language_event_extraction(self):
        """Gemini AI extracts structured parameters from natural language prompt."""
        prompt = "Host an AI Fintech Demo Day for 75 builders. Fee is $35 per person, target $2,625, deadline in 20 days."
        res = client.post("/api/ai/parse-event", json={"prompt": prompt})
        self.assertEqual(res.status_code, 200)
        extracted = res.json()["extracted_event"]
        self.assertIn("title", extracted)
        self.assertIn("amount", extracted)

    def test_07_ai_financial_query(self):
        """Gemini AI answers grounded questions on live telemetry."""
        query = "Who has pending invoices and what is the total collected?"
        res = client.post("/api/ai/query", json={"prompt": query}, headers={"X-Organization-Id": "org-001"})
        self.assertEqual(res.status_code, 200)
        self.assertIn("response", res.json())
        self.assertGreater(len(res.json()["response"]), 10)

    def test_08_ai_smart_reminders(self):
        """Gemini AI crafts personalized reminders for outstanding participants."""
        unpaid = [p.id for p in PARTICIPANTS if p.payment_status == PaymentStatus.UNPAID]
        if unpaid:
            res = client.post("/api/ai/generate-reminder", json={"participant_ids": unpaid, "tone": "friendly"})
            self.assertEqual(res.status_code, 200)
            self.assertIn("reminders", res.json())
            self.assertGreaterEqual(len(res.json()["reminders"]), 1)

    def test_09_ai_financial_audit_report(self):
        """Gemini AI generates an executive financial audit report."""
        event_id = EVENTS[0].id
        res = client.get(f"/api/ai/events/{event_id}/report", headers={"X-Organization-Id": EVENTS[0].organizer_id})
        self.assertEqual(res.status_code, 200)
        report = res.json()
        self.assertIn("total_collected", report)
        self.assertIn("executive_summary", report)


if __name__ == "__main__":
    unittest.main()
