from __future__ import annotations

from ...core.config import settings
from .base import OtpProvider


class TwilioOtpProvider(OtpProvider):
    """Twilio provider for SMS and WhatsApp OTP delivery.

    The ``twilio`` SDK is imported lazily so the application can run without
    it installed.  A clear error is raised if credentials are absent.
    """

    def __init__(self) -> None:
        if not settings.TWILIO_ACCOUNT_SID or not settings.TWILIO_AUTH_TOKEN:
            raise RuntimeError(
                "Twilio credentials are not configured. "
                "Set TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN in your environment."
            )

    async def send(self, phone: str, code: str, channel: str) -> None:
        try:
            from twilio.rest import Client  # type: ignore[import-untyped]
        except ImportError as exc:
            raise RuntimeError(
                "The 'twilio' package is not installed. "
                "Install it with: pip install twilio"
            ) from exc

        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        body = f"Your Wow Gift verification code is: {code}"

        if channel == "whatsapp":
            from_number = f"whatsapp:{settings.TWILIO_WHATSAPP_FROM}"
            to_number = f"whatsapp:{phone}"
        else:
            from_number = settings.TWILIO_SMS_FROM
            to_number = phone

        client.messages.create(body=body, from_=from_number, to=to_number)
