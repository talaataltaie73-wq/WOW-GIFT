"""Tests for account deletion (soft-delete / anonymise)."""
from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy import select

from app.models.order import Order
from app.models.user import User
from tests.conftest import (
    TestSessionLocal,
    create_admin_user_directly,
    create_verified_customer_directly,
)


# ── Helpers ──────────────────────────────────────────────────────────────

async def _register_login(client: AsyncClient, email: str) -> tuple[str, str]:
    """Register a customer, login, return (token, email)."""
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
    return login.json()["access_token"], email


# ── 1. Delete succeeds with correct password ─────────────────────────────

@pytest.mark.asyncio
async def test_delete_account_success(client: AsyncClient):
    token, _ = await _register_login(client, "del_ok@test.com")
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"password": "secret123"},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["detail"] == "Account deleted successfully"
    assert "deleted_at" in body


# ── 2. Delete fails with wrong password (403) ───────────────────────────

@pytest.mark.asyncio
async def test_delete_account_wrong_password(client: AsyncClient):
    token, _ = await _register_login(client, "del_wrongpw@test.com")
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"password": "wrongpassword"},
    )
    assert resp.status_code == 403
    assert resp.json()["detail"] == "Incorrect password"


# ── 3. Delete fails without a token (401) ────────────────────────────────

@pytest.mark.asyncio
async def test_delete_account_no_token(client: AsyncClient):
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        json={"password": "secret123"},
    )
    assert resp.status_code == 401


# ── 4. After deletion, login with old credentials fails ─────────────────

@pytest.mark.asyncio
async def test_login_fails_after_deletion(client: AsyncClient):
    token, email = await _register_login(client, "del_login@test.com")
    # Delete
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"password": "secret123"},
    )
    assert resp.status_code == 200

    # Try login with original email — email was anonymised, so login fails
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "secret123"},
    )
    assert resp.status_code == 401


# ── 5. After deletion, the previously issued token is rejected ───────────

@pytest.mark.asyncio
async def test_old_token_rejected_after_deletion(client: AsyncClient):
    token, _ = await _register_login(client, "del_token@test.com")
    # Delete
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"password": "secret123"},
    )
    assert resp.status_code == 200

    # Use old token
    resp = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 401


# ── 6. User with existing orders can be deleted; orders still exist ──────

@pytest.mark.asyncio
async def test_delete_user_with_orders_preserves_orders(client: AsyncClient):
    # Create admin + product
    admin_token = await create_admin_user_directly("del_order_admin@test.com")
    resp = await client.post(
        "/api/v1/products/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "Del Order Product", "price": 10000.0},
    )
    assert resp.status_code == 201
    product_id = resp.json()["id"]

    # Create verified customer and place order
    customer_token = await create_verified_customer_directly("del_order_cust@test.com")
    headers = {"Authorization": f"Bearer {customer_token}"}

    resp = await client.post(
        "/api/v1/orders/",
        headers=headers,
        json={"items": [{"product_id": product_id, "quantity": 1}]},
    )
    assert resp.status_code == 201
    order_id = resp.json()["id"]

    # Delete account
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers=headers,
        json={"password": "secret123"},
    )
    assert resp.status_code == 200

    # Verify order still exists in DB
    async with TestSessionLocal() as session:
        result = await session.execute(select(Order).where(Order.id == order_id))
        order = result.scalar_one_or_none()
        assert order is not None
        assert order.total == 10000.0


# ── 7. Freed email can be used to register a new account ─────────────────

@pytest.mark.asyncio
async def test_freed_email_can_reregister(client: AsyncClient):
    email = "del_reuse@test.com"
    token, _ = await _register_login(client, email)

    # Delete
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"password": "secret123"},
    )
    assert resp.status_code == 200

    # Re-register with same email
    resp = await client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "newpassword123",
            "full_name": "New User",
        },
    )
    assert resp.status_code == 201
    assert resp.json()["email"] == email


# ── 8. Deleted users do not appear in admin user listing ─────────────────

@pytest.mark.asyncio
async def test_deleted_users_excluded_from_admin_listing(client: AsyncClient):
    # Create a customer and delete them
    email = "del_listing@test.com"
    token, _ = await _register_login(client, email)
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"password": "secret123"},
    )
    assert resp.status_code == 200

    # Admin lists users (default: exclude deleted)
    admin_token = await create_admin_user_directly("del_listing_admin@test.com")
    resp = await client.get(
        "/api/v1/users/",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert resp.status_code == 200
    emails = [u["email"] for u in resp.json()]
    # The original email was anonymised, so it won't appear anyway,
    # but is_deleted users should be excluded
    for u in resp.json():
        assert u["is_deleted"] is False

    # With include_deleted=true, the deleted user should appear
    resp = await client.get(
        "/api/v1/users/?include_deleted=true",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert resp.status_code == 200
    deleted_users = [u for u in resp.json() if u["is_deleted"] is True]
    assert len(deleted_users) >= 1


# ── 9. Admin cannot delete themselves via this endpoint ──────────────────

@pytest.mark.asyncio
async def test_admin_cannot_delete_self(client: AsyncClient):
    admin_token = await create_admin_user_directly("del_admin_self@test.com")
    resp = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"password": "secret123"},
    )
    assert resp.status_code == 403
    assert "Admin accounts cannot be deleted" in resp.json()["detail"]
