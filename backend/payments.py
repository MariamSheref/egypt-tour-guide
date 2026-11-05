"""Paymob hosted-checkout integration; requires merchant keys and a PUBLIC HTTPS webhook.

Plans are 30-day manual-renewal access, NOT automatic recurring billing.
Never grant access based on redirect/checkout-open events.
"""
from __future__ import annotations

import hashlib
import hmac
import json
import os
import sqlite3
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import urlencode

import httpx
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel, EmailStr, Field

router = APIRouter(prefix="/payments", tags=["payments"])
DB_PATH = Path(__file__).with_name("payments.sqlite3")
PLANS = {
    # Illustrative prices only. Set your own prices before taking payments.
    "explorer": {"name": "Explorer", "price_egp": 99, "days": 30},
    "family": {"name": "Family", "price_egp": 199, "days": 30},
    "premium": {"name": "Premium", "price_egp": 299, "days": 30},
}


def db():
    connection = sqlite3.connect(DB_PATH, timeout=10)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA journal_mode=WAL")
    connection.executescript("""
        CREATE TABLE IF NOT EXISTS payment_orders (
          id TEXT PRIMARY KEY, plan TEXT NOT NULL,
          amount_cents INTEGER NOT NULL,
          paymob_order_id TEXT UNIQUE, status TEXT NOT NULL DEFAULT 'pending',
          paid_at TEXT, access_until TEXT
        );
        CREATE TABLE IF NOT EXISTS payment_events (
          provider_transaction_id TEXT PRIMARY KEY
        );
    """)
    return connection


class CheckoutRequest(BaseModel):
    plan_id: str
    first_name: str = Field(min_length=2, max_length=80)
    last_name: str = Field(min_length=2, max_length=80)
    email: EmailStr
    phone: str = Field(min_length=7, max_length=22)


@router.get("/plans")
def plans():
    return [{"id": key, **value, "renewal": "manual"} for key, value in PLANS.items()]


@router.get("/config")
def config():
    fields = ("PAYMOB_SECRET_KEY", "PAYMOB_PUBLIC_KEY", "PAYMOB_INTEGRATION_ID", "PUBLIC_BACKEND_URL", "PAYMOB_HMAC_SECRET")
    return {"checkout_configured": all(os.getenv(x, "").strip() for x in fields),
            "renewal": "manual", "live_payments_enabled": os.getenv('ENABLE_LIVE_PAYMENTS') == 'true'}


@router.post("/checkout")
async def create_checkout(request: CheckoutRequest):
    if request.plan_id not in PLANS:
        raise HTTPException(400, "Unknown plan")
    required = ("PAYMOB_SECRET_KEY", "PAYMOB_PUBLIC_KEY", "PAYMOB_INTEGRATION_ID", "PUBLIC_BACKEND_URL", "PAYMOB_HMAC_SECRET")
    if not all(os.getenv(key, "").strip() for key in required):
        raise HTTPException(503, "Checkout not configured. Add Paymob test keys and public HTTPS webhook URL.")
    key = os.environ["PAYMOB_SECRET_KEY"]
    if not key.startswith("sk_test_") and os.getenv('ENABLE_LIVE_PAYMENTS') != 'true':
        raise HTTPException(503, "Live charges disabled. Test keys only until merchant launch is approved.")
    origin = os.environ["PUBLIC_BACKEND_URL"].rstrip("/")
    if not origin.startswith("https://"):
        raise HTTPException(503, "PUBLIC_BACKEND_URL must be a public HTTPS URL")
    plan = PLANS[request.plan_id]
    amount = plan["price_egp"] * 100
    ref = uuid.uuid4().hex
    with db() as conn:
        conn.execute("INSERT INTO payment_orders(id, plan, amount_cents) VALUES (?, ?, ?)", (ref, request.plan_id, amount))
    payload = {
        "amount": amount, "currency": "EGP",
        "payment_methods": [int(os.environ["PAYMOB_INTEGRATION_ID"])],
        "items": [{"name": f"{plan['name']} 30-day access", "amount": amount, "quantity": 1,
                   "description": "Manual renewal, not automatic recurring billing"}],
        "billing_data": {
            "first_name": request.first_name, "last_name": request.last_name,
            "email": str(request.email), "phone_number": request.phone,
            "country": "EG", "city": "NA", "state": "NA", "street": "NA",
            "building": "NA", "apartment": "NA", "floor": "NA"
        },
        "special_reference": ref,
        "notification_url": f"{origin}/payments/webhook",
        "redirection_url": f"{origin}/payments/return?ref={ref}",
        "expiration": 3600,
    }
    try:
        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.post("https://accept.paymob.com/v1/intention/",
                json=payload, headers={"Authorization": f"Token {key}"})
            response.raise_for_status()
            intention = response.json()
    except (httpx.HTTPError, ValueError) as exc:
        raise HTTPException(502, "Payment provider could not create checkout; try later") from exc
    client_secret = intention.get("client_secret")
    order_id = intention.get("intention_order_id")
    if not client_secret or order_id is None:
        raise HTTPException(502, "Incomplete response from payment provider")
    with db() as conn:
        conn.execute("UPDATE payment_orders SET paymob_order_id=? WHERE id=?", (str(order_id), ref))
    checkout_url = "https://accept.paymob.com/unifiedcheckout/?" + urlencode({
        "publicKey": os.environ["PAYMOB_PUBLIC_KEY"], "clientSecret": client_secret})
    return {"order_id": ref, "checkout_url": checkout_url, "status": "pending"}


def _value(v):
    if isinstance(v, bool):
        return str(v).lower()
    return "" if v is None else str(v)


def _signature(obj):
    source = obj.get("source_data") or {}
    order = obj.get("order") or {}
    fields = (
        obj.get("amount_cents"), obj.get("created_at"), obj.get("currency"),
        obj.get("error_occured"), obj.get("has_parent_transaction"), obj.get("id"),
        obj.get("integration_id"), obj.get("is_3d_secure"), obj.get("is_auth"),
        obj.get("is_capture"), obj.get("is_refunded"),
        obj.get("is_standalone_payment"), obj.get("is_voided"), order.get("id"),
        obj.get("owner"), obj.get("pending"), source.get("pan"),
        source.get("sub_type"), source.get("type"), obj.get("success"),
    )
    return hmac.new(os.environ["PAYMOB_HMAC_SECRET"].encode(),
        "".join(map(_value, fields)).encode(), hashlib.sha512).hexdigest()


@router.post("/webhook")
async def webhook(request: Request):
    provided = request.query_params.get("hmac", "")
    if not provided or not os.getenv("PAYMOB_HMAC_SECRET"):
        raise HTTPException(401, "Missing signature")
    payload = await request.json()
    obj = payload.get("obj")
    if not isinstance(obj, dict) or not hmac.compare_digest(_signature(obj), provided.lower()):
        raise HTTPException(401, "Invalid signature")
    txn = str(obj.get("id", ""))
    provider_order = str((obj.get("order") or {}).get("id", ""))
    if not txn or not provider_order:
        raise HTTPException(400, "Missing transaction identifier")
    success = obj.get("success") is True and obj.get("pending") is False
    with db() as conn:
        try:
            conn.execute("INSERT INTO payment_events(provider_transaction_id) VALUES (?)", (txn,))
        except sqlite3.IntegrityError:
            return {"received": True, "duplicate": True}
        order = conn.execute("SELECT * FROM payment_orders WHERE paymob_order_id=?", (provider_order,)).fetchone()
        if order is not None and success and obj.get("currency") == "EGP" and int(obj.get("amount_cents", -1)) == order["amount_cents"]:
            if order["status"] != "paid":
                now = datetime.now(timezone.utc)
                until = now + timedelta(days=PLANS[order["plan"]]["days"])
                conn.execute("UPDATE payment_orders SET status='paid', paid_at=?, access_until=? WHERE id=? AND status='pending'",
                    (now.isoformat(), until.isoformat(), order["id"]))
    return {"received": True}


@router.get("/orders/{order_id}")
def order_status(order_id: str):
    with db() as conn:
        row = conn.execute("SELECT plan,status,paid_at,access_until FROM payment_orders WHERE id=?", (order_id,)).fetchone()
    if row is None:
        raise HTTPException(404, "Order not found")
    return dict(row)


@router.get("/return")
def checkout_return(ref: str = ""):
    from fastapi.responses import HTMLResponse
    return HTMLResponse("<html><body style='font-family:sans-serif;text-align:center;margin:3em'>"
        "<h2>Payment submitted</h2><p>Return to the app and tap Check status. "
        "Only a verified webhook can confirm payment.</p></body></html>")
