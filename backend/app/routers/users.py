from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.security import verify_password
from ..database import get_db
from ..dependencies import get_current_user, require_admin
from ..models.address import Address
from ..models.favorite import Favorite
from ..models.notification import Notification
from ..models.occasion_reminder import OccasionReminder
from ..models.phone_verification import PhoneVerification
from ..models.user import User
from ..schemas.user import (
    AdminUserOut,
    DeleteAccountRequest,
    DeleteAccountResponse,
    UserOut,
    UserUpdate,
)
from ..services.user_service import update_user

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserOut)
async def read_current_user(current_user: User = Depends(get_current_user)):
    return current_user


@router.patch("/me", response_model=UserOut)
async def update_current_user(
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await update_user(db, current_user.id, data)


@router.delete("/me", response_model=DeleteAccountResponse)
async def delete_current_user(
    data: DeleteAccountRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Soft-delete the authenticated customer's account.

    Requires the user's current password for confirmation.
    Admins cannot delete themselves through this endpoint.
    """
    # Block admins from deleting themselves via this endpoint
    if current_user.role == "admin":
        raise HTTPException(
            status_code=403,
            detail="Admin accounts cannot be deleted through this endpoint",
        )

    # Verify password
    if not verify_password(data.password, current_user.hashed_password):
        raise HTTPException(status_code=403, detail="Incorrect password")

    now = datetime.now(timezone.utc)

    # Cascade-clean personal data: favorites, reminders, notifications,
    # addresses, phone verifications
    await db.execute(delete(Favorite).where(Favorite.user_id == current_user.id))
    await db.execute(
        delete(OccasionReminder).where(OccasionReminder.user_id == current_user.id)
    )
    await db.execute(
        delete(Notification).where(Notification.user_id == current_user.id)
    )
    await db.execute(delete(Address).where(Address.user_id == current_user.id))
    await db.execute(
        delete(PhoneVerification).where(PhoneVerification.user_id == current_user.id)
    )

    # Anonymise personal fields and soft-delete
    deleted_tag = f"deleted_{current_user.id}"
    current_user.email = f"{deleted_tag}@deleted.local"
    current_user.full_name = "Deleted User"
    current_user.phone = None
    current_user.phone_verified = False
    current_user.phone_verified_at = None
    current_user.avatar_url = None
    current_user.is_active = False
    current_user.is_deleted = True
    current_user.deleted_at = now

    await db.flush()

    return DeleteAccountResponse(
        detail="Account deleted successfully",
        deleted_at=now,
    )


# ── Admin: list users ────────────────────────────────────────────────────

@router.get("/", response_model=list[AdminUserOut])
async def list_users(
    include_deleted: bool = Query(False, description="Include soft-deleted users"),
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    """Admin-only: list all users. Deleted users excluded by default."""
    stmt = select(User)
    if not include_deleted:
        stmt = stmt.where(User.is_deleted == False)
    result = await db.execute(stmt)
    return result.scalars().all()
