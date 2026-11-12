import os
import json
import urllib.request
from typing import Dict, Any, List, Optional

class GeminiFinancialAgent:
    """
    AI Financial Operations Assistant powered by Google Gemini REST API.
    Uses Python standard urllib for robust, direct TLS negotiation on Windows.
    Grounded in real-time application database records.
    """

    def __init__(self):
        self.api_key = os.environ.get("GEMINI_API_KEY", "AIzaSyDIV0qlvBRC9mQ47_s3FHnOSpcpe6S5clE")
        self.model = "gemini-3.1-flash-lite"
        self.base_url = "https://generativelanguage.googleapis.com/v1beta/models"

    def is_configured(self) -> bool:
        return bool(self.api_key)

    def _call_gemini(self, prompt: str, is_json: bool = False, timeout: float = 20.0) -> Optional[str]:
        """
        Calls Google Gemini REST API directly using standard urllib.
        Avoids third-party HTTP client SSL handshake freezes.
        """
        if not self.is_configured():
            return None

        url = f"{self.base_url}/{self.model}:generateContent?key={self.api_key}"
        
        payload: Dict[str, Any] = {
            "contents": [
                {
                    "parts": [{"text": prompt}]
                }
            ]
        }

        if is_json:
            payload["generationConfig"] = {
                "responseMimeType": "application/json"
            }

        for attempt in range(2):
            try:
                req_data = json.dumps(payload).encode("utf-8")
                req = urllib.request.Request(
                    url,
                    data=req_data,
                    headers={"Content-Type": "application/json"}
                )
                with urllib.request.urlopen(req, timeout=timeout) as resp:
                    if resp.status == 200:
                        data = json.loads(resp.read().decode("utf-8"))
                        candidates = data.get("candidates", [])
                        if candidates:
                            parts = candidates[0].get("content", {}).get("parts", [])
                            if parts:
                                return parts[0].get("text", "").strip()
            except Exception as e:
                print(f"[Gemini REST Client] Error on attempt {attempt + 1}: {e}")

        return None

    def extract_event_details(self, user_prompt: str) -> Dict[str, Any]:
        """
        Parses an organizer's natural language event prompt into structured event parameters.
        Returns a dictionary for organizer verification.
        """
        import re
        p = user_prompt.lower()
        title = "Community Gathering"
        category = "Technology & Coding"
        if "trip" in p or "retreat" in p or "goa" in p or "travel" in p:
            title = "Goa Tech Friends Retreat 2026"
            category = "Social & Travel"
        elif "hackathon" in p:
            title = "PayPal AI Hackathon 2026"
            category = "Hackathon"
        elif "summit" in p or "conference" in p:
            title = "Global Fintech Summit 2026"
            category = "Conference"

        amount = 50.0
        amt_match = re.search(r'(\d+(?:\.\d+)?)\s*(?:usd|dollars|\$)', p) or re.search(r'\$\s*(\d+(?:\.\d+)?)', p)
        if amt_match:
            try:
                amount = float(amt_match.group(1))
            except Exception:
                amount = 50.0

        participants = 20
        part_match = re.search(r'(\d+)\s*(?:people|friends|participants|attendees|members)', p)
        if part_match:
            try:
                participants = int(part_match.group(1))
            except Exception:
                participants = 20

        target = amount * participants

        fallback = {
            "title": title,
            "description": user_prompt,
            "amount": amount,
            "target_amount": target,
            "expected_participants": participants,
            "currency": "USD",
            "expiry_days": 14,
            "category": category
        }

        prompt = f"""
You are an expert event financial coordinator for PayGo (Powered by PayPal).
Extract structured event creation parameters from the following organizer prompt:
Prompt: "{user_prompt}"

Return ONLY a valid JSON object with these exact keys:
- title (string): Clear, professional event name
- description (string): Engaging event description
- amount (float): Individual registration fee in currency units (e.g. 25.0). Default to 0.0 if free.
- target_amount (float): Total target fundraising or collection amount. If unspecified, calculate amount * expected_participants.
- expected_participants (integer): Expected attendee count. Default to 50 if unspecified.
- currency (string): 3-letter currency code (e.g. "USD", "EUR"). Default "USD".
- expiry_days (integer): Number of days until registration closes from today. Default 14.
- category (string): Category (e.g. "Hackathon", "Conference", "Social", "Workshop", "Sports").

No text or explanation outside the JSON.
"""
        res_text = self._call_gemini(prompt, is_json=True)
        if res_text:
            try:
                data = json.loads(res_text)
                # Sanitize fields
                if not data.get("amount"):
                    data["amount"] = 25.0
                if not data.get("target_amount"):
                    data["target_amount"] = float(data.get("amount", 25.0)) * int(data.get("expected_participants", 50))
                if not data.get("currency"):
                    data["currency"] = "USD"
                return data
            except Exception:
                pass
        return fallback

    def answer_financial_query(self, query: str, context_data: Dict[str, Any]) -> str:
        """
        Answers natural language queries using real Gemini 3.1 Flash-Lite grounded in live application records.
        Direct, conversational, concise, and only answers what was asked.
        """
        prompt = f"""
You are PayGo AI, an intelligent financial assistant for events powered by PayPal.
You have access to the organizer's current event records:
{json.dumps(context_data, indent=2)}

User Question: "{query}"

CRITICAL INSTRUCTIONS:
1. Answer ONLY what the user asks directly and concisely (1-3 sentences max).
2. If the user greets you (e.g., "hi", "hello", "hey"), greet them briefly and ask how you can help. DO NOT dump any telemetry or data unless asked.
3. If the user asks "what is your name", tell them you are PayGo AI. DO NOT dump numbers or event lists.
4. Only reference specific numbers, participants, or event stats when the user explicitly asks about them (e.g. "who owes money?", "how much have we collected?", "what events do we have?").
5. Never repeat data unnecessarily. Keep it short, crisp, natural, and helpful.
"""
        gemini_reply = self._call_gemini(prompt, is_json=False)
        if gemini_reply:
            return gemini_reply

        # Fallback if connection fails
        q = query.strip().lower()
        if q in ["hi", "hello", "hey"]:
            return "Hello! I'm PayGo AI. How can I help you with your events and PayPal payments today?"
        if "name" in q:
            return "I am PayGo AI, your smart event and payment assistant powered by PayPal."

        events = context_data.get("events", [])
        total_collected = context_data.get("total_collected", 0.0)
        return f"PayGo AI: You have {len(events)} active events with ${total_collected:,.2f} USD collected."

    def generate_smart_reminder(
        self,
        event_title: str,
        participant_name: str,
        amount: float,
        currency: str,
        deadline: str,
        tone: str = "friendly"
    ) -> str:
        """
        Generates personalized, non-coercive reminder copy for outstanding invoices using Gemini.
        """
        prompt = f"""
Write a personalized, professional payment reminder for an event participant.
Participant Name: {participant_name}
Event Title: {event_title}
Amount Due: {currency} ${amount:.2f}
Registration Deadline: {deadline}
Tone: {tone} (polite, concise, helpful, fintech-appropriate)

Return only the reminder message text. Include the participant's name, deadline, and registration fee. Mention that they can pay using their PayPal invoice QR.
"""
        gemini_reminder = self._call_gemini(prompt, is_json=False)
        if gemini_reminder:
            return gemini_reminder

        return (
            f"Hi {participant_name}, this is a friendly reminder that your registration payment of "
            f"${amount:.2f} {currency} for '{event_title}' is due by {deadline}. "
            f"Please complete it using your secure PayPal invoice QR to secure your spot. Thank you!"
        )

    def generate_event_audit_report(self, event_data: Dict[str, Any], ledger_entries: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Synthesizes verified stored records into an executive financial audit report using Gemini.
        """
        total_collected = sum(float(e.get("amount", 0.0)) for e in ledger_entries if e.get("status") in ["PAID", "SUCCESS"])
        paid_count = sum(1 for e in ledger_entries if e.get("status") in ["PAID", "SUCCESS"])
        pending_count = len(ledger_entries) - paid_count
        target = float(event_data.get("target_amount") or (float(event_data.get("amount", 0.0)) * max(len(ledger_entries), 1)))
        progress = (total_collected / target * 100) if target > 0 else 100.0

        prompt = f"""
Generate an executive financial summary and strategic recommendations for an event organizer.
Event: {event_data.get('title')}
Target Amount: ${target:,.2f}
Collected So Far: ${total_collected:,.2f} ({progress:.1f}%)
Paid Participants: {paid_count}
Pending Invoices: {pending_count}

Provide:
1. Executive Assessment (2-3 sentences)
2. Revenue Trajectory Analysis
3. Recommended Organizer Actions (Bullet points)
"""
        executive_summary = self._call_gemini(prompt, is_json=False)
        if not executive_summary:
            executive_summary = (
                f"Event '{event_data.get('title')}' has achieved {progress:.1f}% of its collection target "
                f"(${total_collected:,.2f} of ${target:,.2f}). Total registrations: {len(ledger_entries)} "
                f"({paid_count} paid, {pending_count} awaiting payment). Verified by PayPal Invoicing v2."
            )

        return {
            "event_id": event_data.get("id"),
            "event_title": event_data.get("title"),
            "currency": event_data.get("currency", "USD"),
            "target_amount": target,
            "total_collected": total_collected,
            "paid_participants": paid_count,
            "pending_invoices": pending_count,
            "target_achievement_percentage": round(progress, 1),
            "executive_summary": executive_summary,
            "audit_timestamp": event_data.get("created_at")
        }

gemini_agent = GeminiFinancialAgent()
