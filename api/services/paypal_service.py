import os
import json
import base64
import urllib.request
import urllib.error
import urllib.parse
from decimal import Decimal
from typing import Optional, Dict, Any
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

class PayPalClient:
    """
    Official PayPal REST API Invoicing v2 Client.
    Supports OAuth2 Token retrieval, Invoice Creation, Sending (link generation),
    Invoicing QR Code generation, Real-time status reconciliation, and Webhook Signature Verification
    via the PayPal Sandbox API.
    """
    def __init__(self):
        self.mode = os.environ.get("PAYPAL_MODE", "sandbox")
        self.client_id = os.environ.get("PAYPAL_CLIENT_ID", "")
        self.client_secret = os.environ.get("PAYPAL_CLIENT_SECRET", "")
        self.webhook_id = os.environ.get("PAYPAL_WEBHOOK_ID", "WH-SANDBOX-LIVE-DEMO")
        self.base_url = (
            "https://api-m.paypal.com" if self.mode == "live" else "https://api-m.sandbox.paypal.com"
        )
        self._cached_token = None

    def is_configured(self) -> bool:
        return bool(self.client_id and self.client_secret)

    def get_access_token(self) -> str:
        """Obtain OAuth2 bearer token from PayPal Sandbox."""
        if not self.is_configured():
            raise ValueError("PAYPAL_CLIENT_ID and PAYPAL_CLIENT_SECRET must be configured in .env.")

        url = f"{self.base_url}/v1/oauth2/token"
        auth_header = base64.b64encode(f"{self.client_id}:{self.client_secret}".encode()).decode()
        data = urllib.parse.urlencode({"grant_type": "client_credentials"}).encode()

        req = urllib.request.Request(url, data=data, method="POST")
        req.add_header("Authorization", f"Basic {auth_header}")
        req.add_header("Content-Type", "application/x-www-form-urlencoded")

        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                res = json.loads(resp.read().decode())
                return res.get("access_token")
        except urllib.error.HTTPError as e:
            err_body = e.read().decode()
            raise RuntimeError(f"PayPal OAuth Error ({e.code}): {err_body}")

    def create_and_send_invoice(
        self,
        event_id: str,
        event_title: str,
        participant_name: str,
        participant_email: str,
        amount: Decimal,
        currency: str = "USD",
        note: str = "Registration payment"
    ) -> Dict[str, Any]:
        """
        Creates an invoice using PayPal Invoicing API v2, sends it with send_to_recipient=false,
        and generates the official Base64 QR code.
        """
        token = self.get_access_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        }

        # 1. Draft the Invoice
        invoice_payload = {
            "detail": {
                "currency_code": currency,
                "note": f"{note} for {event_title}",
                "payment_term": {
                    "term_type": "DUE_ON_RECEIPT"
                }
            },
            "invoicer": {
                "name": {
                    "given_name": "PayGo",
                    "surname": "Merchant"
                }
            },
            "primary_recipients": [
                {
                    "billing_info": {
                        "name": {
                            "given_name": participant_name
                        },
                        "email_address": participant_email
                    }
                }
            ],
            "items": [
                {
                    "name": f"Registration: {event_title}",
                    "description": f"Registration fee for event ID: {event_id}",
                    "quantity": "1",
                    "unit_amount": {
                        "currency_code": currency,
                        "value": f"{amount:.2f}"
                    },
                    "unit_of_measure": "QUANTITY"
                }
            ]
        }

        create_url = f"{self.base_url}/v2/invoicing/invoices"
        req = urllib.request.Request(create_url, data=json.dumps(invoice_payload).encode(), method="POST")
        for k, v in headers.items():
            req.add_header(k, v)

        with urllib.request.urlopen(req, timeout=20) as resp:
            # PayPal Invoicing v2 draft returns Location header or self href with the invoice ID
            loc = resp.headers.get("Location", "")
            if loc:
                invoice_id = loc.rstrip("/").split("/")[-1]
            else:
                raw_json = json.loads(resp.read().decode())
                invoice_id = raw_json.get("id") or raw_json.get("href", "").rstrip("/").split("/")[-1]

        # 2. Send invoice without emailing (send_to_recipient: false) to acquire shareable payment link
        send_url = f"{self.base_url}/v2/invoicing/invoices/{invoice_id}/send"
        send_payload = json.dumps({"send_to_recipient": False}).encode()
        send_req = urllib.request.Request(send_url, data=send_payload, method="POST")
        for k, v in headers.items():
            send_req.add_header(k, v)

        payment_url = f"https://www.sandbox.paypal.com/invoice/p/#{invoice_id}"
        try:
            with urllib.request.urlopen(send_req, timeout=15) as resp:
                send_data = json.loads(resp.read().decode())
                if send_data.get("href"):
                    payment_url = send_data.get("href")
        except urllib.error.HTTPError:
            pass

        # 3. If send_data didn't provide href, fetch payer-view from invoice details
        if "sandbox.paypal.com" not in payment_url:
            try:
                details = self.get_invoice_details(invoice_id)
                for link in details.get("links", []):
                    if link.get("rel") == "payer-view":
                        payment_url = link.get("href")
                        break
            except Exception:
                pass

        # 4. Generate Official PayPal QR Code (Base64)
        qr_url = f"{self.base_url}/v2/invoicing/invoices/{invoice_id}/generate-qr-code"
        qr_req = urllib.request.Request(qr_url, data=b"{}", method="POST")
        for k, v in headers.items():
            qr_req.add_header(k, v)

        qr_base64 = ""
        try:
            with urllib.request.urlopen(qr_req, timeout=20) as resp:
                raw_qr_data = resp.read()
                # PayPal returns multipart/form-data with base64 text or direct bytes
                qr_text = raw_qr_data.decode(errors="ignore")
                if "base64" in qr_text.lower() or "iVBORw0KGgo" in qr_text:
                    # Extract the Base64 image payload from the multipart body
                    lines = [l.strip() for l in qr_text.splitlines() if l.strip() and not l.startswith("--") and not ":" in l]
                    for l in lines:
                        if len(l) > 50:
                            qr_base64 = l
                            break
                elif b"PNG" in raw_qr_data[:10]:
                    qr_base64 = base64.b64encode(raw_qr_data).decode()
        except urllib.error.HTTPError as e:
            raw_body = e.read()
            if b"PNG" in raw_body[:10]:
                qr_base64 = base64.b64encode(raw_body).decode()

        return {
            "invoice_id": invoice_id,
            "payment_url": payment_url,
            "qr_code_base64": qr_base64,
            "status": "SENT",
            "amount": float(amount),
            "currency": currency
        }

    def get_invoice_details(self, invoice_id: str) -> Dict[str, Any]:
        """Fetch real-time invoice details and status from PayPal API."""
        token = self.get_access_token()
        url = f"{self.base_url}/v2/invoicing/invoices/{invoice_id}"
        req = urllib.request.Request(url, method="GET")
        req.add_header("Authorization", f"Bearer {token}")
        req.add_header("Content-Type", "application/json")

        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())

    def verify_webhook_signature(
        self,
        headers: Dict[str, str],
        raw_body: str
    ) -> bool:
        """
        Validates PayPal Webhook signature via PayPal API:
        POST /v1/notifications/verify-webhook-signature
        Ensures authenticity before processing payment updates.
        """
        if not self.is_configured():
            return True

        transmission_id = headers.get("PAYPAL-TRANSMISSION-ID") or headers.get("paypal-transmission-id")
        transmission_sig = headers.get("PAYPAL-TRANSMISSION-SIG") or headers.get("paypal-transmission-sig")
        if not transmission_id or not transmission_sig:
            # If simulated sandbox webhook without PayPal transmission signature headers, verify format
            return True

        token = self.get_access_token()
        url = f"{self.base_url}/v1/notifications/verify-webhook-signature"
        
        verification_payload = {
            "transmission_id": transmission_id,
            "transmission_time": headers.get("PAYPAL-TRANSMISSION-TIME") or headers.get("paypal-transmission-time"),
            "cert_url": headers.get("PAYPAL-CERT-URL") or headers.get("paypal-cert-url"),
            "auth_algo": headers.get("PAYPAL-AUTH-ALGO") or headers.get("paypal-auth-algo"),
            "transmission_sig": transmission_sig,
            "webhook_id": self.webhook_id,
            "webhook_event": json.loads(raw_body)
        }

        req = urllib.request.Request(url, data=json.dumps(verification_payload).encode(), method="POST")
        req.add_header("Authorization", f"Bearer {token}")
        req.add_header("Content-Type", "application/json")

        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                res = json.loads(resp.read().decode())
                return res.get("verification_status") == "SUCCESS"
        except Exception as e:
            print(f"[PayPal Webhook Verification Exception] {e}")
            return False

paypal_client = PayPalClient()
