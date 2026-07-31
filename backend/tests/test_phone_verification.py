"""Tests for phone verification (OTP) feature."""
from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy import select

from app.core.security import hash_password, create_access_token
from app.models.phone_verification import PhoneVerification
from app.models.user import User
from tests.conftest import (
    TestSessionLocal,
    create_admin_user_directly,
    create_verified_customer_directly,
)


# ── Helpers ──────────────────────────────────────────────────────────────

async def _register_and_login(client: AsyncClient, email: str) -> str:
    """Register a customer via the API and return the JWT token."""
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "secret123",
            "full_name": f"User {email}",
        },
    )
    login = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "secret123"},
    )
    return login.json()["access_token"]


async def _create_unverified_customer(email: str) -> str:
    """Create an unverified customer directly in the DB and return a JWT."""
    async with TestSessionLocal() as session:
        user = User(
            email=email,
            hashed_password=hash_password("secret123"),
            full_name=f"User {email}",
            role="customer",
            phone_verified=False,
        )
        session.add(user)
        await session.commit()
        await session.refresh(user)
        return create_access_token({"sub": user.id, "role": user.role})


# ── Happy path: request + verify ─────────────────────────────────────────

@pytest.mark.asyncio
async def test_otp_happy_path(client: AsyncClient):
    token = await _register_and_login(client, "otp_happy@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    # Request OTP
    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647701234567", "channel": "sms"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert "request_id" in data
    assert data["phone"] == "+9647701234567"
    assert data["channel"] == "sms"
    assert data["expires_in_seconds"] == 300
    assert data["resend_after_seconds"] == 60
    assert data["dev_code"] is not None
    assert len(data["dev_code"]) == 6

    # Verify OTP
    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": data["request_id"], "code": data["dev_code"]},
    )
    assert resp.status_code == 200
    verify_data = resp.json()
    assert verify_data["verified"] is True
    assert verify_data["phone"] == "+9647701234567"
    assert verify_data["phone_verified_at"] is not None


# ── Wrong code decrements attempts ───────────────────────────────────────

@pytest.mark.asyncio
async def test_wrong_code_decrements_attempts(client: AsyncClient):
    token = await _register_and_login(client, "otp_wrong@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647702222222", "channel": "sms"},
    )
    assert resp.status_code == 200
    request_id = resp.json()["request_id"]

    # Submit wrong code
    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": "000000"},
    )
    assert resp.status_code == 400
    body = resp.json()
    assert "attempts_remaining" in body
    assert body["attempts_remaining"] == 4  # 5 max - 1 attempt


# ── Exceeding max attempts ───────────────────────────────────────────────

@pytest.mark.asyncio
async def test_exceeding_max_attempts(client: AsyncClient):
    token = await _register_and_login(client, "otp_maxattempts@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647703333333", "channel": "sms"},
    )
    request_id = resp.json()["request_id"]
    correct_code = resp.json()["dev_code"]

    # Exhaust all attempts with wrong codes
    for i in range(5):
        resp = await client.post(
            "/api/v1/auth/phone/verify-otp",
            headers=headers,
            json={"request_id": request_id, "code": "000000"},
        )
        assert resp.status_code == 400

    # Even the correct code should now be rejected
    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": correct_code},
    )
    assert resp.status_code == 400
    assert resp.json()["attempts_remaining"] == 0


# ── Expired code returns 410 ─────────────────────────────────────────────

@pytest.mark.asyncio
async def test_expired_code_returns_410(client: AsyncClient):
    token = await _register_and_login(client, "otp_expired@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647704444444", "channel": "sms"},
    )
    request_id = resp.json()["request_id"]
    dev_code = resp.json()["dev_code"]

    # Manually expire the request
    from datetime import datetime, timezone
    async with TestSessionLocal() as session:
        result = await session.execute(
            select(PhoneVerification).where(PhoneVerification.id == request_id)
        )
        verification = result.scalar_one()
        verification.expires_at = datetime(2020, 1, 1, tzinfo=timezone.utc)
        await session.commit()

    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": dev_code},
    )
    assert resp.status_code == 410


# ── Resend cooldown returns 429 ──────────────────────────────────────────

@pytest.mark.asyncio
async def test_resend_cooldown_returns_429(client: AsyncClient):
    token = await _register_and_login(client, "otp_cooldown@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    # First request
    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647705555555", "channel": "sms"},
    )
    assert resp.status_code == 200

    # Immediate second request — should be rate limited
    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647705555555", "channel": "sms"},
    )
    assert resp.status_code == 429
    body = resp.json()
    assert "retry_after_seconds" in body


# ── Per-hour rate limit returns 429 ──────────────────────────────────────

@pytest.mark.asyncio
async def test_per_hour_rate_limit(client: AsyncClient):
    token = await _register_and_login(client, "otp_ratelimit@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    phone = "+9647706666666"

    # Create 5 requests by backdating cooldowns
    from datetime import datetime, timedelta, timezone
    for i in range(5):
        async with TestSessionLocal() as session:
            from app.core.security import hash_password as hp
            v = PhoneVerification(
                user_id="dummy",  # will be overridden
                phone=phone,
                channel="sms",
                code_hash=hp("123456"),
                attempts=0,
                max_attempts=5,
                expires_at=datetime.now(timezone.utc) + timedelta(minutes=5),
            )
            # We need the actual user_id. Get it from the token.
            from app.core.security import decode_access_token
            payload = decode_access_token(token.split(" ")[-1] if " " in token else token)
            v.user_id = payload["sub"]
            # Backdate created_at so cooldown doesn't trigger
            v.created_at = datetime.now(timezone.utc) - timedelta(minutes=10 - i)
            v.updated_at = v.created_at
            session.add(v)
            await session.commit()

    # Now the 6th request should be rate limited
    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": phone, "channel": "sms"},
    )
    assert resp.status_code == 429


# ── Code cannot be reused after success ──────────────────────────────────

@pytest.mark.asyncio
async def test_code_cannot_be_reused(client: AsyncClient):
    token = await _register_and_login(client, "otp_reuse@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647707777777", "channel": "sms"},
    )
    request_id = resp.json()["request_id"]
    dev_code = resp.json()["dev_code"]

    # First verify — success
    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": dev_code},
    )
    assert resp.status_code == 200

    # Second verify — should fail (consumed)
    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": dev_code},
    )
    assert resp.status_code == 410


# ── Order creation returns 403 PHONE_NOT_VERIFIED when unverified ────────

@pytest.mark.asyncio
async def test_order_blocked_without_phone_verification(client: AsyncClient):
    # Create admin + product
    admin_token = await create_admin_user_directly("otp_order_admin@test.com")
    resp = await client.post(
        "/api/v1/products/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "OTP Gate Product", "price": 10000.0},
    )
    assert resp.status_code == 201
    product_id = resp.json()["id"]

    # Create unverified customer
    customer_token = await _create_unverified_customer("otp_unverified_customer@test.com")
    headers = {"Authorization": f"Bearer {customer_token}"}

    # Try to place order — should be blocked
    resp = await client.post(
        "/api/v1/orders/",
        headers=headers,
        json={"items": [{"product_id": product_id, "quantity": 1}]},
    )
    assert resp.status_code == 403
    body = resp.json()
    assert body["detail"] == "phone_not_verified"
    assert body["code"] == "PHONE_NOT_VERIFIED"


# ── Order succeeds once verified ─────────────────────────────────────────

@pytest.mark.asyncio
async def test_order_succeeds_after_verification(client: AsyncClient):
    admin_token = await create_admin_user_directly("otp_order_admin2@test.com")
    resp = await client.post(
        "/api/v1/products/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "OTP Gate Product 2", "price": 15000.0},
    )
    product_id = resp.json()["id"]

    # Create customer, verify phone, then order
    customer_token = await _register_and_login(client, "otp_verified_customer@test.com")
    headers = {"Authorization": f"Bearer {customer_token}"}

    # Request + verify OTP
    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647708888888", "channel": "sms"},
    )
    request_id = resp.json()["request_id"]
    dev_code = resp.json()["dev_code"]

    resp = await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": dev_code},
    )
    assert resp.status_code == 200

    # Now place order — should succeed
    resp = await client.post(
        "/api/v1/orders/",
        headers=headers,
        json={"items": [{"product_id": product_id, "quantity": 1}]},
    )
    assert resp.status_code == 201


# ── /users/me exposes phone_verified ─────────────────────────────────────

@pytest.mark.asyncio
async def test_users_me_exposes_phone_verified(client: AsyncClient):
    token = await _register_and_login(client, "otp_me@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    # Before verification
    resp = await client.get("/api/v1/users/me", headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "phone_verified" in data
    assert data["phone_verified"] is False
    assert data["phone_verified_at"] is None

    # Verify phone
    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647709999999", "channel": "sms"},
    )
    request_id = resp.json()["request_id"]
    dev_code = resp.json()["dev_code"]

    await client.post(
        "/api/v1/auth/phone/verify-otp",
        headers=headers,
        json={"request_id": request_id, "code": dev_code},
    )

    # After verification
    resp = await client.get("/api/v1/users/me", headers=headers)
    data = resp.json()
    assert data["phone_verified"] is True
    assert data["phone_verified_at"] is not None
    assert data["phone"] == "+9647709999999"


# ── dev_code is absent when OTP_DEV_MODE is False ────────────────────────

@pytest.mark.asyncio
async def test_dev_code_absent_when_dev_mode_off(client: AsyncClient, monkeypatch):
    monkeypatch.setattr("app.services.otp_service.settings.OTP_DEV_MODE", False)

    token = await _register_and_login(client, "otp_nodev@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647711111111", "channel": "sms"},
    )
    assert resp.status_code == 200
    assert resp.json()["dev_code"] is None


# ── WhatsApp channel is accepted ─────────────────────────────────────────

@pytest.mark.asyncio
async def test_whatsapp_channel_accepted(client: AsyncClient):
    token = await _register_and_login(client, "otp_whatsapp@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647712222222", "channel": "whatsapp"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["channel"] == "whatsapp"
    assert data["dev_code"] is not None


# ── Invalid phone format returns 422 ─────────────────────────────────────

@pytest.mark.asyncio
async def test_invalid_phone_format_returns_422(client: AsyncClient):
    token = await _register_and_login(client, "otp_badphone@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "not-a-phone", "channel": "sms"},
    )
    assert resp.status_code == 422


# ── Raw code is never persisted ──────────────────────────────────────────

@pytest.mark.asyncio
async def test_raw_code_not_persisted(client: AsyncClient):
    token = await _register_and_login(client, "otp_rawcode@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "+9647713333333", "channel": "sms"},
    )
    assert resp.status_code == 200
    request_id = resp.json()["request_id"]
    dev_code = resp.json()["dev_code"]

    # Read the stored verification record
    async with TestSessionLocal() as session:
        result = await session.execute(
            select(PhoneVerification).where(PhoneVerification.id == request_id)
        )
        verification = result.scalar_one()
        # The stored code_hash must differ from the raw code
        assert verification.code_hash != dev_code
        # The code_hash should be a bcrypt hash (starts with $2b$)
        assert verification.code_hash.startswith("$2")


# ── Iraqi local phone format normalisation ───────────────────────────────

@pytest.mark.asyncio
async def test_iraqi_local_phone_normalised(client: AsyncClient):
    token = await _register_and_login(client, "otp_local@test.com")
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/phone/request-otp",
        headers=headers,
        json={"phone": "07701234567", "channel": "sms"},
    )
    assert resp.status_code == 200
    assert resp.json()["phone"] == "+9647701234567"
