from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from .core.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    future=True,
)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db() -> AsyncSession:  # type: ignore[misc]
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise


async def init_db() -> None:
    """Create all tables (dev convenience – use Alembic in production)."""
    from .models import Base  # noqa: F811

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    await ensure_default_admin_user()


async def ensure_default_admin_user() -> None:
    from sqlalchemy import select

    from .core.security import hash_password
    from .models.user import User

    async with async_session_factory() as session:
        result = await session.execute(select(User).where(User.email == "admin@wowgift.app"))
        existing_admin = result.scalar_one_or_none()
        if existing_admin is None:
            admin = User(
                email="admin@wowgift.app",
                hashed_password=hash_password("admin123"),
                full_name="مدير النظام",
                phone=None,
                role="admin",
                is_active=True,
                locale="ar",
            )
            session.add(admin)
            await session.commit()
