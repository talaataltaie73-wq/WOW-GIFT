"""Comprehensive tests: orders, earnings, coupons, status transitions."""
from __future__ import annotations

import pytest
from httpx import AsyncClient

from tests.conftest import create_admin_user_directly, create_verified_customer_directly


# ── Helpers ──────────────────────────────────────────────────────────────

async def register_and_login(client: AsyncClient, email: str, role: str = "customer") -> str:
    """Register a user and return the JWT token.

    For admin/merchant roles, creates the user directly in the DB since
    merchant self-registration is no longer allowed via the public API.
    For customers, creates a phone-verified user directly so order tests pass.
    """
    if role in ("merchant", "admin"):
        return await create_admin_user_directly(email, f"User {email}")

    return await create_verified_customer_directly(email, f"User {email}")


async def create_product_as_admin(
    client: AsyncClient, token: str, name: str, price: float, store_id: str | None = None
) -> dict:
    """Create a product and return its data."""
    payload = {"name": name, "price": price}
    if store_id:
        payload["store_id"] = store_id
    resp = await client.post(
        "/api/v1/products/",
        headers={"Authorization": f"Bearer {token}"},
        json=payload,
    )
    assert resp.status_code == 201
    return resp.json()


# ── Order creation end-to-end ────────────────────────────────────────────

@pytest.mark.asyncio
async def test_order_creation_e2e(client: AsyncClient):
    # Setup: admin creates a product
    admin_token = await register_and_login(client, "order_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Gift Item", 30000.0)

    # Customer places an order
    customer_token = await register_and_login(client, "order_customer@test.com", "customer")
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={
            "items": [{"product_id": product["id"], "quantity": 2}],
            "payment_method": "cash_on_delivery",
            "recipient_name": "Ahmed",
            "recipient_phone": "+9647701234567",
            "address": "Baghdad, Al-Karrada",
            "latitude": 33.3,
            "longitude": 44.4,
            "delivery_date": "2026-08-01",
            "delivery_time": "14:00:00",
            "notes": "Ring the bell",
            "greeting_card_id": "card-001",
            "private_message": "Happy Birthday!",
            "is_anonymous": True,
            "sender_display_name": "A Friend",
        },
    )
    assert resp.status_code == 201
    order = resp.json()
    assert order["total"] == 60000.0
    assert order["currency"] == "IQD"
    assert order["status"] == "pending_approval"
    assert order["payment_method"] == "cash_on_delivery"
    assert order["recipient_name"] == "Ahmed"
    assert order["recipient_phone"] == "+9647701234567"
    assert order["address"] == "Baghdad, Al-Karrada"
    assert order["latitude"] == 33.3
    assert order["longitude"] == 44.4
    assert order["delivery_date"] == "2026-08-01"
    assert order["delivery_time"] == "14:00:00"
    assert order["notes"] == "Ring the bell"
    assert order["greeting_card_id"] == "card-001"
    assert order["private_message"] == "Happy Birthday!"
    assert order["is_anonymous"] is True
    assert order["sender_display_name"] == "A Friend"
    assert order["reward_points_used"] == 0
    assert len(order["items"]) == 1
    assert order["items"][0]["quantity"] == 2
    assert order["items"][0]["unit_price"] == 30000.0


# ── Order status transitions ────────────────────────────────────────────

@pytest.mark.asyncio
async def test_order_status_transitions(client: AsyncClient):
    admin_token = await register_and_login(client, "status_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Status Item", 10000.0)

    customer_token = await register_and_login(client, "status_customer@test.com", "customer")
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={"items": [{"product_id": product["id"], "quantity": 1}]},
    )
    assert resp.status_code == 201
    order_id = resp.json()["id"]
    assert resp.json()["status"] == "pending_approval"

    # Valid transitions: pending_approval -> accepted -> preparing -> out_for_delivery -> delivered
    # Order status changes now require admin
    for new_status in ["accepted", "preparing", "out_for_delivery", "delivered"]:
        resp = await client.patch(
            f"/api/v1/orders/{order_id}/status",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={"status": new_status, "note": f"Moved to {new_status}"},
        )
        assert resp.status_code == 200, f"Failed transition to {new_status}: {resp.json()}"
        assert resp.json()["status"] == new_status

    # Verify status history has all transitions
    resp = await client.get(
        f"/api/v1/orders/{order_id}",
        headers={"Authorization": f"Bearer {customer_token}"},
    )
    assert resp.status_code == 200
    history = resp.json()["status_history"]
    statuses = [h["status"] for h in history]
    assert "pending_approval" in statuses
    assert "accepted" in statuses
    assert "preparing" in statuses
    assert "out_for_delivery" in statuses
    assert "delivered" in statuses


@pytest.mark.asyncio
async def test_invalid_status_transition(client: AsyncClient):
    admin_token = await register_and_login(client, "invalid_status_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Invalid Status Item", 5000.0)

    customer_token = await register_and_login(client, "invalid_status_customer@test.com", "customer")
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={"items": [{"product_id": product["id"], "quantity": 1}]},
    )
    order_id = resp.json()["id"]

    # Try to skip from pending_approval directly to delivered (invalid)
    resp = await client.patch(
        f"/api/v1/orders/{order_id}/status",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"status": "delivered"},
    )
    assert resp.status_code == 400
    assert "Cannot transition" in resp.json()["detail"]


@pytest.mark.asyncio
async def test_cancel_from_pending(client: AsyncClient):
    admin_token = await register_and_login(client, "cancel_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Cancel Item", 8000.0)

    customer_token = await register_and_login(client, "cancel_customer@test.com", "customer")
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={"items": [{"product_id": product["id"], "quantity": 1}]},
    )
    order_id = resp.json()["id"]

    resp = await client.patch(
        f"/api/v1/orders/{order_id}/status",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"status": "cancelled", "note": "Changed my mind"},
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "cancelled"


# ── Coupon application ───────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_coupon_application(client: AsyncClient):
    # Create admin + product
    admin_token = await register_and_login(client, "coupon_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Coupon Product", 50000.0)

    customer_token = await register_and_login(client, "coupon_customer@test.com", "customer")

    # Test with invalid coupon code
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={
            "items": [{"product_id": product["id"], "quantity": 1}],
            "coupon_code": "INVALID_CODE",
        },
    )
    assert resp.status_code == 400
    assert "Invalid coupon" in resp.json()["detail"]

    # Test order without coupon works fine
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={
            "items": [{"product_id": product["id"], "quantity": 1}],
        },
    )
    assert resp.status_code == 201
    assert resp.json()["total"] == 50000.0
    assert resp.json()["discount_amount"] == 0.0


# ── Merchant earnings with 10% commission ────────────────────────────────

@pytest.mark.asyncio
async def test_merchant_earnings_10_percent_commission(client: AsyncClient):
    # Setup: admin creates merchant profile, store, and products
    admin_token = await register_and_login(client, "earnings_merchant@test.com", "admin")

    # Create merchant profile
    resp = await client.post(
        "/api/v1/merchants/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"business_name": "Earnings Test Store"},
    )
    assert resp.status_code == 201
    merchant_id = resp.json()["id"]

    # Create store
    resp = await client.post(
        "/api/v1/stores/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "Earnings Store"},
    )
    assert resp.status_code == 201
    store_id = resp.json()["id"]

    # Create product under the store
    product = await create_product_as_admin(
        client, admin_token, "Earnings Product", 100000.0, store_id=store_id
    )

    # Customer places order
    customer_token = await register_and_login(client, "earnings_customer@test.com", "customer")
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={"items": [{"product_id": product["id"], "quantity": 1}]},
    )
    assert resp.status_code == 201
    order_id = resp.json()["id"]

    # Before delivery: earnings should be 0
    resp = await client.get(
        f"/api/v1/merchants/{merchant_id}/earnings",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert resp.status_code == 200
    earnings = resp.json()
    assert earnings["gross_sales"] == 0.0
    assert earnings["net_earnings"] == 0.0
    assert earnings["total_delivered_orders"] == 0

    # Transition order to delivered (admin only)
    for status in ["accepted", "preparing", "out_for_delivery", "delivered"]:
        resp = await client.patch(
            f"/api/v1/orders/{order_id}/status",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={"status": status},
        )
        assert resp.status_code == 200

    # After delivery: earnings should reflect 10% commission
    resp = await client.get(
        f"/api/v1/merchants/{merchant_id}/earnings",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert resp.status_code == 200
    earnings = resp.json()
    assert earnings["merchant_id"] == merchant_id
    assert earnings["total_delivered_orders"] == 1
    assert earnings["gross_sales"] == 100000.0
    assert earnings["commission_rate"] == 10.0
    assert earnings["commission_amount"] == 10000.0  # 10% of 100,000
    assert earnings["net_earnings"] == 90000.0  # 100,000 - 10,000
    assert earnings["currency"] == "IQD"
    assert earnings["min_payout_threshold"] == 50000.0
    assert earnings["eligible_for_payout"] is True  # 90,000 >= 50,000


@pytest.mark.asyncio
async def test_merchant_earnings_below_threshold(client: AsyncClient):
    admin_token = await register_and_login(client, "low_earnings_merchant@test.com", "admin")

    resp = await client.post(
        "/api/v1/merchants/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"business_name": "Low Earnings Store"},
    )
    assert resp.status_code == 201
    merchant_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/stores/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "Low Store"},
    )
    assert resp.status_code == 201
    store_id = resp.json()["id"]

    product = await create_product_as_admin(
        client, admin_token, "Cheap Product", 10000.0, store_id=store_id
    )

    customer_token = await register_and_login(client, "low_earnings_customer@test.com", "customer")
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={"items": [{"product_id": product["id"], "quantity": 1}]},
    )
    order_id = resp.json()["id"]

    for status in ["accepted", "preparing", "out_for_delivery", "delivered"]:
        await client.patch(
            f"/api/v1/orders/{order_id}/status",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={"status": status},
        )

    resp = await client.get(
        f"/api/v1/merchants/{merchant_id}/earnings",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert resp.status_code == 200
    earnings = resp.json()
    assert earnings["net_earnings"] == 9000.0  # 10,000 - 1,000
    assert earnings["eligible_for_payout"] is False  # 9,000 < 50,000


# ── Payment method enum validation ──────────────────────────────────────

@pytest.mark.asyncio
async def test_payment_methods(client: AsyncClient):
    admin_token = await register_and_login(client, "pay_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Pay Item", 20000.0)
    customer_token = await register_and_login(client, "pay_customer@test.com", "customer")

    valid_methods = ["cash_on_delivery", "zain_cash", "asia_hawala", "mastercard", "visa", "e_wallet"]
    for method in valid_methods:
        resp = await client.post(
            "/api/v1/orders/",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "items": [{"product_id": product["id"], "quantity": 1}],
                "payment_method": method,
            },
        )
        assert resp.status_code == 201, f"Failed for payment method: {method}"
        assert resp.json()["payment_method"] == method

    # Invalid payment method
    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={
            "items": [{"product_id": product["id"], "quantity": 1}],
            "payment_method": "bitcoin",
        },
    )
    assert resp.status_code == 422  # Validation error


# ── Reward points ────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_reward_points_on_order(client: AsyncClient):
    admin_token = await register_and_login(client, "reward_merchant@test.com", "admin")
    product = await create_product_as_admin(client, admin_token, "Reward Item", 15000.0)
    customer_token = await register_and_login(client, "reward_customer@test.com", "customer")

    resp = await client.post(
        "/api/v1/orders/",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={
            "items": [{"product_id": product["id"], "quantity": 1}],
            "reward_points_used": 500,
        },
    )
    assert resp.status_code == 201
    assert resp.json()["reward_points_used"] == 500
