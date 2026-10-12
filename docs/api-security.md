# API security contract

Every protected API route uses `auth:sanctum` plus role middleware and derives identity from the authenticated token. Student, Teacher, and Guard controllers load only the linked profile. Guard gate authorization and campus state are enforced by `CampusSecurityService`; attendance rules remain in `AttendanceService`. Sensitive endpoints use the named `api` rate limiter (60 requests/minute per user or IP by default).

Face verification is deliberately unavailable until an approved provider adapter is configured. A face request returns `503 FACE_SERVICE_UNAVAILABLE` and cannot create a transaction. Manual verification is a separate, explicit, audited fallback. NFC is disabled by default and has no simulated API path. No password, token, raw biometric content, provider secret, or sensitive provider response is returned.
