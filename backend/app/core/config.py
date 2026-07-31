from __future__ import annotations

import os
from pathlib import Path

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # ── App ──────────────────────────────────────────────────────────────
    APP_NAME: str = "Wow Gift API"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = True

    # ── Database ─────────────────────────────────────────────────────────
    DATABASE_URL: str = "sqlite+aiosqlite:///./wow_gift.db"

    # ── JWT ──────────────────────────────────────────────────────────────
    SECRET_KEY: str = "change-me-in-production-use-openssl-rand-hex-32"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day

    # ── CORS ─────────────────────────────────────────────────────────────
    CORS_ORIGINS: list[str] = ["*"]

    # ── i18n / RTL ───────────────────────────────────────────────────────
    DEFAULT_LOCALE: str = "ar"

    # ── Currency (Iraq) ──────────────────────────────────────────────────
    DEFAULT_CURRENCY: str = "IQD"

    # ── Merchant Payout ──────────────────────────────────────────────────
    MERCHANT_COMMISSION_RATE: float = 10.0  # percentage of each successful sale
    MERCHANT_PAYOUT_DAY: str = "sunday"  # weekly payout day
    MERCHANT_MIN_PAYOUT_THRESHOLD: float = 50_000.0  # minimum payout in IQD

    # ── OTP / Phone Verification ─────────────────────────────────────────
    OTP_LENGTH: int = 6
    OTP_TTL_SECONDS: int = 300
    OTP_MAX_ATTEMPTS: int = 5
    OTP_RESEND_COOLDOWN_SECONDS: int = 60
    OTP_MAX_REQUESTS_PER_PHONE_PER_HOUR: int = 5
    OTP_DEV_MODE: bool = True  # MUST be False in production — exposes dev_code in response
    OTP_PROVIDER: str = "mock"  # "mock" | "twilio"

    # ── Twilio (only needed when OTP_PROVIDER="twilio") ──────────────────
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_SMS_FROM: str = ""
    TWILIO_WHATSAPP_FROM: str = ""

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8", "extra": "ignore"}


settings = Settings()
