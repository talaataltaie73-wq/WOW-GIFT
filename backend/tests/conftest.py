"""Shared test fixtures."""
from __future__ import annotations

import asyncio
from typing import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.security import create_access_token, hash_password
from app.database import get_db
from app.models import Base
from app.models.user import User
from main import app

TEST_DB_URL = "sqlite+aiosqlite:///./test_wow_gift.db"

engine = create_async_engine(TEST_DB_URL, echo=False)
TestSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


async def _override_get_db() -> AsyncGenerator[AsyncSession, None]:
    async with TestSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise


app.dependency_overrides[get_db] = _override_get_db


@pytest_asyncio.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


async def create_admin_user_directly(email: str, name: str = "Admin User") -> str:
    """Create an admin user directly in the DB and return a JWT token.

    Since merchant self-registration is no longer allowed, tests that need
    admin/merchant-level access must create admin users directly.
    """
    async with TestSessionLocal() as session:
        user = User(
            email=email,
            hashed_password=hash_password("secret123"),
            full_name=name,
            role="admin",
            phone_verified=True,
        )
        session.add(user)
        await session.commit()
        await session.refresh(user)
        token = create_access_token({"sub": user.id, "role": user.role})
        return token


async def create_verified_customer_directly(email: str, name: str = "Customer") -> str:
    """Create a phone-verified customer directly in the DB and return a JWT token."""
    async with TestSessionLocal() as session:
        user = User(
            email=email,
            hashed_password=hash_password("secret123"),
            full_name=name,
            role="customer",
            phone="+9647701234567",
            phone_verified=True,
        )
        session.add(user)
        await session.commit()
        await session.refresh(user)
        token = create_access_token({"sub": user.id, "role": user.role})
        return token
