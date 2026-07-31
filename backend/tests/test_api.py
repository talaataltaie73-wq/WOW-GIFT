"""Smoke tests for the Wow Gift API."""
from __future__ import annotations

import pytest
from httpx import AsyncClient

from tests.conftest import create_admin_user_directly


@pytest.mark.asyncio
async def test_health(client: AsyncClient):
    resp = await client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "ok"


@pytest.mark.asyncio
async def test_register_and_login(client: AsyncClient):
    # Register
    resp = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@example.com",
            "password": "secret123",
            "full_name": "Test User",
        },
    )
    assert resp.status_code == 201
    user = resp.json()
    assert user["email"] == "test@example.com"
    assert user["role"] == "customer"

    # Login
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": "test@example.com", "password": "secret123"},
    )
    assert resp.status_code == 200
    token_data = resp.json()
    assert "access_token" in token_data


@pytest.mark.asyncio
async def test_duplicate_register(client: AsyncClient):
    resp = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "dup@example.com",
            "password": "secret123",
            "full_name": "Dup User",
        },
    )
    assert resp.status_code == 201

    resp2 = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "dup@example.com",
            "password": "secret123",
            "full_name": "Dup User",
        },
    )
    assert resp2.status_code == 400


@pytest.mark.asyncio
async def test_invalid_login(client: AsyncClient):
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": "nobody@example.com", "password": "wrong"},
    )
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_get_me_unauthorized(client: AsyncClient):
    resp = await client.get("/api/v1/users/me")
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_get_me_authorized(client: AsyncClient):
    # Register + login
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": "me@example.com",
            "password": "secret123",
            "full_name": "Me User",
        },
    )
    login = await client.post(
        "/api/v1/auth/login",
        json={"email": "me@example.com", "password": "secret123"},
    )
    token = login.json()["access_token"]

    resp = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200
    assert resp.json()["email"] == "me@example.com"


@pytest.mark.asyncio
async def test_update_profile(client: AsyncClient):
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": "update@example.com",
            "password": "secret123",
            "full_name": "Old Name",
        },
    )
    login = await client.post(
        "/api/v1/auth/login",
        json={"email": "update@example.com", "password": "secret123"},
    )
    token = login.json()["access_token"]

    resp = await client.patch(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"full_name": "New Name"},
    )
    assert resp.status_code == 200
    assert resp.json()["full_name"] == "New Name"


@pytest.mark.asyncio
async def test_list_categories_empty(client: AsyncClient):
    resp = await client.get("/api/v1/categories/")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_list_products_empty(client: AsyncClient):
    resp = await client.get("/api/v1/products/")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_list_gift_boxes_empty(client: AsyncClient):
    resp = await client.get("/api/v1/gift-boxes/")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_list_stores_empty(client: AsyncClient):
    resp = await client.get("/api/v1/stores/")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_addresses_crud(client: AsyncClient):
    # Register + login
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": "addr@example.com",
            "password": "secret123",
            "full_name": "Addr User",
        },
    )
    login = await client.post(
        "/api/v1/auth/login",
        json={"email": "addr@example.com", "password": "secret123"},
    )
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Create
    resp = await client.post(
        "/api/v1/addresses/",
        headers=headers,
        json={"city": "Riyadh", "label": "Home"},
    )
    assert resp.status_code == 201
    addr = resp.json()
    assert addr["city"] == "Riyadh"

    # List
    resp = await client.get("/api/v1/addresses/", headers=headers)
    assert resp.status_code == 200
    assert len(resp.json()) >= 1

    # Delete
    resp = await client.delete(f"/api/v1/addresses/{addr['id']}", headers=headers)
    assert resp.status_code == 204


@pytest.mark.asyncio
async def test_favorites_crud(client: AsyncClient):
    # Create admin user to create a product (merchant self-registration removed)
    token = await create_admin_user_directly("favadmin@example.com", "Fav Admin")
    headers = {"Authorization": f"Bearer {token}"}

    # Create a product first
    prod_resp = await client.post(
        "/api/v1/products/",
        headers=headers,
        json={"name": "Test Product", "price": 50.0},
    )
    assert prod_resp.status_code == 201
    product_id = prod_resp.json()["id"]

    # Add favorite
    resp = await client.post(
        "/api/v1/favorites/",
        headers=headers,
        json={"product_id": product_id},
    )
    assert resp.status_code == 201

    # List favorites
    resp = await client.get("/api/v1/favorites/", headers=headers)
    assert resp.status_code == 200
    assert len(resp.json()) >= 1


@pytest.mark.asyncio
async def test_reminders_crud(client: AsyncClient):
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": "reminder@example.com",
            "password": "secret123",
            "full_name": "Reminder User",
        },
    )
    login = await client.post(
        "/api/v1/auth/login",
        json={"email": "reminder@example.com", "password": "secret123"},
    )
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/reminders/",
        headers=headers,
        json={
            "title": "Mom's Birthday",
            "title_ar": "عيد ميلاد أمي",
            "occasion_date": "2025-03-15T00:00:00Z",
            "recipient_name": "Mom",
        },
    )
    assert resp.status_code == 201
    reminder = resp.json()
    assert reminder["title"] == "Mom's Birthday"

    # List
    resp = await client.get("/api/v1/reminders/", headers=headers)
    assert resp.status_code == 200
    assert len(resp.json()) >= 1


# ── New endpoint tests ────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_best_sellers_endpoint(client: AsyncClient):
    resp = await client.get("/api/v1/products/best-sellers")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_latest_products_endpoint(client: AsyncClient):
    resp = await client.get("/api/v1/products/latest")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_best_deals_endpoint(client: AsyncClient):
    resp = await client.get("/api/v1/products/best-deals")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_featured_stores_endpoint(client: AsyncClient):
    resp = await client.get("/api/v1/stores/featured")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_banners_endpoint(client: AsyncClient):
    resp = await client.get("/api/v1/banners/")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


@pytest.mark.asyncio
async def test_best_sellers_with_products(client: AsyncClient):
    """Verify best-sellers returns products when they exist."""
    token = await create_admin_user_directly("bsadmin@example.com", "BS Admin")
    headers = {"Authorization": f"Bearer {token}"}

    # Create a product
    resp = await client.post(
        "/api/v1/products/",
        headers=headers,
        json={"name": "Best Seller Product", "price": 100.0},
    )
    assert resp.status_code == 201

    # Best sellers should include it
    resp = await client.get("/api/v1/products/best-sellers")
    assert resp.status_code == 200
    products = resp.json()
    assert len(products) >= 1


@pytest.mark.asyncio
async def test_latest_returns_newest_first(client: AsyncClient):
    """Verify latest products are ordered by creation time."""
    token = await create_admin_user_directly("latadmin@example.com", "Lat Admin")
    headers = {"Authorization": f"Bearer {token}"}

    # Create two products
    resp1 = await client.post(
        "/api/v1/products/",
        headers=headers,
        json={"name": "Older Product", "price": 50.0},
    )
    assert resp1.status_code == 201

    resp2 = await client.post(
        "/api/v1/products/",
        headers=headers,
        json={"name": "Newer Product", "price": 75.0},
    )
    assert resp2.status_code == 201

    resp = await client.get("/api/v1/products/latest")
    assert resp.status_code == 200
    products = resp.json()
    assert len(products) >= 2
    # The newest should come first
    names = [p["name"] for p in products]
    newer_idx = next((i for i, n in enumerate(names) if n == "Newer Product"), None)
    older_idx = next((i for i, n in enumerate(names) if n == "Older Product"), None)
    if newer_idx is not None and older_idx is not None:
        assert newer_idx < older_idx
