from __future__ import annotations

from app.core.config import settings
from app.services.otp.base import OtpProvider


def get_otp_provider() -> OtpProvider:
    """Return the OTP provider configured via ``settings.OTP_PROVIDER``.

    Adding a new provider requires only a new file and one entry here.
    """
    provider_name = settings.OTP_PROVIDER.lower()

    if provider_name == "mock":
        from app.services.otp.mock_provider import MockOtpProvider

        return MockOtpProvider()

    if provider_name == "twilio":
        from app.services.otp.twilio_provider import TwilioOtpProvider

        return TwilioOtpProvider()

    raise ValueError(
        f"Unknown OTP_PROVIDER '{settings.OTP_PROVIDER}'. "
        "Supported values: 'mock', 'twilio'."
    )
