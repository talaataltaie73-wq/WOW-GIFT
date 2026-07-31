from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..schemas.user import LoginRequest, RegisterRequest, TokenResponse, UserOut
from ..services.auth_service import authenticate_user, create_token_for_user, register_user

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserOut, status_code=201)
async def register(data: RegisterRequest, db: AsyncSession = Depends(get_db)):
    user = await register_user(db, data)
    return user


@router.post("/login")
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    user = await authenticate_user(db, data.email, data.password)
    token = create_token_for_user(user)
    # Return both legacy `access_token` and frontend-friendly `token` + `user` object
    return {
        "access_token": token,
        "token_type": "bearer",
        "token": token,
        "user": user,
    }


@router.post("/admin/login")
async def admin_login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    user = await authenticate_user(db, data.email, data.password)
    if user.role != "admin":
        from fastapi import HTTPException, status

        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    token = create_token_for_user(user)
    return {
        "access_token": token,
        "token_type": "bearer",
        "token": token,
        "user": user,
    }
