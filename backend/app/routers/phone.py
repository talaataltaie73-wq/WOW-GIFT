from __future__ import annotations

from fastapi import APIRouter, Depends, Request
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import get_current_user
from ..models.user import User
from ..schemas.user import OtpRequestBody, OtpVerifyBody
from ..services.otp_service import (
    OtpRateLimitError,
    OtpVerificationError,
    request_otp,
    verify_otp,
)

router = APIRouter(prefix="/auth/phone", tags=["phone-verification"])


@router.post("/request-otp")
async def request_otp_endpoint(
    data: OtpRequestBody,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    ip = request.client.host if request.client else None
    try:
        result = await request_otp(db, current_user, data.phone, data.channel, ip=ip)
    except OtpRateLimitError as exc:
        return JSONResponse(
            status_code=429,
            content={"detail": exc.detail, "retry_after_seconds": exc.retry_after_seconds},
        )
    return result


@router.post("/verify-otp")
async def verify_otp_endpoint(
    data: OtpVerifyBody,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await verify_otp(db, current_user, data.request_id, data.code)
    except OtpVerificationError as exc:
        return JSONResponse(status_code=exc.status_code, content=exc.body)
    return result
