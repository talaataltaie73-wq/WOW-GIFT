from __future__ import annotations

from datetime import datetime, timedelta, timezone

try:
    from jose import JWTError, jwt
except Exception:  # pragma: no cover - optional dependency in some envs
    JWTError = Exception
    jwt = None
from passlib.context import CryptContext

from .config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    if jwt is None:
        # Fallback token for environments without `python-jose` installed.
        # This token is non-verifiable and decode_access_token will return None.
        import secrets

        return secrets.token_urlsafe(24)
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_access_token(token: str) -> dict | None:
    try:
        if jwt is None:
            return None
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        return None
