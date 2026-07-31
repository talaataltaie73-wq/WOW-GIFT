from __future__ import annotations

import logging

from .base import OtpProvider

logger = logging.getLogger(__name__)


class MockOtpProvider(OtpProvider):
    """Development provider that logs the OTP code instead of sending it.

    Stores the last sent code so the API can return ``dev_code`` when
    ``OTP_DEV_MODE`` is enabled.
    """

    def __init__(self) -> None:
        self.last_code: str | None = None

    async def send(self, phone: str, code: str, channel: str) -> None:
        self.last_code = code
        logger.info(
            "MockOtpProvider: code=%s  phone=%s  channel=%s",
            code,
            phone,
            channel,
        )
