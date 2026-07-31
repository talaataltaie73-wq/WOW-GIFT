from __future__ import annotations

from abc import ABC, abstractmethod


class OtpProvider(ABC):
    """Abstract base for OTP delivery providers.

    Every concrete provider must support both SMS and WhatsApp channels.
    """

    @abstractmethod
    async def send(self, phone: str, code: str, channel: str) -> None:
        """Send *code* to *phone* via the given *channel* ("sms" | "whatsapp")."""
        ...
