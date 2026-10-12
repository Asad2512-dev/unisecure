# Backend capability notes

The current backend exposes role-specific API routes, but this initial mobile slice implements the shared authentication contract and authenticated shell. Face verification intentionally returns `FACE_SERVICE_UNAVAILABLE` until a genuine provider is configured. Manual verification is the supported fallback. NFC is optional and disabled by default. FCM delivery is optional and remains safely unavailable without configuration. OTP is explicitly prohibited.
