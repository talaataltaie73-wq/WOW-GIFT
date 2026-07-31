from __future__ import annotations

import re
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import hash_password, verify_password
from app.models.phone_verification import PhoneVerification
from app.models.user import User
from app.services.otp.factory import get_otp_provider
from app.services.otp.mock_provider import MockOtpProvider


class OtpRateLimitError(Exception):
    """Raised when OTP rate limit is hit."""

    def __init__(self, detail: str, retry_after_seconds: int):
        self.detail = detail
        self.retry_after_seconds = retry_after_seconds


class OtpVerificationError(Exception):
    """Raised when OTP verification fails with a structured body."""

    def __init__(self, status_code: int, body: dict):
        self.status_code = status_code
        self.body = body

# E.164 regex — must start with + and have 7-15 digits total
_E164_RE = re.compile(r"^\+[1-9]\d{6,14}$")

# Iraq-specific: accept local numbers starting with 07 and normalise to +964
_IRAQ_LOCAL_RE = re.compile(r"^07\d{8,9}$")


def normalise_phone(phone: str) -> str:
    """Validate and normalise a phone number to E.164.

    Accepts:
    - Full E.164 (``+9647XXXXXXXXX``)
    - Iraqi local format (``07XXXXXXXXX`` → ``+9647XXXXXXXXX``)

    Raises ``HTTPException(422)`` for clearly malformed numbers.
    """
    phone = phone.strip().replace(" ", "").replace("-", "")

    # Iraqi local → E.164
    if _IRAQ_LOCAL_RE.match(phone):
        phone = "+964" + phone[1:]  # drop leading 0

    if not _E164_RE.match(phone):
        raise HTTPException(
            status_code=422,
            detail="Invalid phone number. Use E.164 format, e.g. +9647XXXXXXXXX.",
        )
    return phone


def _generate_code() -> str:
    """Generate a cryptographically random numeric OTP code."""
    upper = 10 ** settings.OTP_LENGTH
    return str(secrets.randbelow(upper)).zfill(settings.OTP_LENGTH)


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


async def _invalidate_outstanding(db: AsyncSession, user_id: str, phone: str) -> None:
    """Mark all outstanding (unconsumed, unexpired) requests for this phone as consumed."""
    now = _utcnow()
    result = await db.execute(
        select(PhoneVerification).where(
            PhoneVerification.user_id == user_id,
            PhoneVerification.phone == phone,
            PhoneVerification.consumed_at.is_(None),
            PhoneVerification.expires_at > now,
        )
    )
    for row in result.scalars().all():
        row.consumed_at = now


async def _check_rate_limit(db: AsyncSession, phone: str) -> None:
    """Enforce per-phone-per-hour rate limit."""
    one_hour_ago = _utcnow() - timedelta(hours=1)
    result = await db.execute(
        select(func.count()).select_from(PhoneVerification).where(
            PhoneVerification.phone == phone,
            PhoneVerification.created_at >= one_hour_ago,
        )
    )
    count = result.scalar() or 0
    if count >= settings.OTP_MAX_REQUESTS_PER_PHONE_PER_HOUR:
        raise OtpRateLimitError(
            detail="Too many OTP requests. Please try again later.",
            retry_after_seconds=3600,
        )


async def _check_resend_cooldown(db: AsyncSession, user_id: str, phone: str) -> None:
    """Enforce resend cooldown — reject if the last request was too recent."""
    cooldown_boundary = _utcnow() - timedelta(seconds=settings.OTP_RESEND_COOLDOWN_SECONDS)
    result = await db.execute(
        select(PhoneVerification).where(
            PhoneVerification.user_id == user_id,
            PhoneVerification.phone == phone,
            PhoneVerification.created_at >= cooldown_boundary,
        ).order_by(PhoneVerification.created_at.desc()).limit(1)
    )
    recent = result.scalar_one_or_none()
    if recent:
        elapsed = (_utcnow() - recent.created_at.replace(tzinfo=timezone.utc)).total_seconds()
        retry_after = max(1, int(settings.OTP_RESEND_COOLDOWN_SECONDS - elapsed))
        raise OtpRateLimitError(
            detail="Please wait before requesting a new code.",
            retry_after_seconds=retry_after,
        )


async def request_otp(
    db: AsyncSession,
    user: User,
    phone: str,
    channel: str,
    ip: str | None = None,
) -> dict:
    """Create a new OTP request and send the code via the configured provider."""
    phone = normalise_phone(phone)

    if channel not in ("sms", "whatsapp"):
        raise HTTPException(status_code=422, detail="channel must be 'sms' or 'whatsapp'")

    # If the user already has this phone verified, skip
    if user.phone == phone and user.phone_verified:
        raise HTTPException(status_code=400, detail="This phone number is already verified.")

    await _check_rate_limit(db, phone)
    await _check_resend_cooldown(db, user.id, phone)

    # Invalidate previous outstanding requests
    await _invalidate_outstanding(db, user.id, phone)

    code = _generate_code()
    code_hash = hash_password(code)

    verification = PhoneVerification(
        user_id=user.id,
        phone=phone,
        channel=channel,
        code_hash=code_hash,
        attempts=0,
        max_attempts=settings.OTP_MAX_ATTEMPTS,
        expires_at=_utcnow() + timedelta(seconds=settings.OTP_TTL_SECONDS),
        ip=ip,
    )
    db.add(verification)
    await db.flush()

    # Send via provider
    provider = get_otp_provider()
    await provider.send(phone, code, channel)

    # Build response
    dev_code = None
    if settings.OTP_DEV_MODE:
        if isinstance(provider, MockOtpProvider):
            dev_code = provider.last_code
        else:
            dev_code = code

    return {
        "request_id": verification.id,
        "phone": phone,
        "channel": channel,
        "expires_in_seconds": settings.OTP_TTL_SECONDS,
        "resend_after_seconds": settings.OTP_RESEND_COOLDOWN_SECONDS,
        "dev_code": dev_code,
    }


async def verify_otp(db: AsyncSession, user: User, request_id: str, code: str) -> dict:
    """Verify an OTP code against a request."""
    result = await db.execute(
        select(PhoneVerification).where(
            PhoneVerification.id == request_id,
            PhoneVerification.user_id == user.id,
        )
    )
    verification = result.scalar_one_or_none()
    if not verification:
        raise HTTPException(status_code=404, detail="Verification request not found.")

    now = _utcnow()

    # Check expiry
    expires_at = verification.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if now > expires_at:
        raise HTTPException(status_code=410, detail="Verification request has expired.")

    # Check already consumed
    if verification.consumed_at is not None:
        raise HTTPException(status_code=410, detail="Verification request has expired.")

    # Check max attempts
    if verification.attempts >= verification.max_attempts:
        raise OtpVerificationError(
            status_code=400,
            body={"detail": "Maximum verification attempts exceeded. Please request a new code.", "attempts_remaining": 0},
        )

    # Verify code
    if not verify_password(code, verification.code_hash):
        verification.attempts += 1
        remaining = verification.max_attempts - verification.attempts
        await db.flush()
        raise OtpVerificationError(
            status_code=400,
            body={"detail": "Invalid verification code.", "attempts_remaining": remaining},
        )

    # Success — consume the request
    verification.consumed_at = now
    await db.flush()

    # Update user's phone and verification status
    user.phone = verification.phone
    user.phone_verified = True
    user.phone_verified_at = now
    await db.flush()

    return {
        "verified": True,
        "phone": verification.phone,
        "phone_verified_at": now.isoformat(),
    }
