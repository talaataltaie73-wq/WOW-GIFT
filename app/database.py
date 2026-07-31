from __future__ import annotations


async def init_db() -> None:
    """Initialize database resources for the app.

    This lightweight implementation keeps the app runnable in development and
    on Render without requiring a live database connection.
    """
    return None
