# UniSecure API v1

Base URL: `/api/v1`. JSON success responses use `{success:true,message,data,meta}` and failures use `{success:false,message,errors}`. API requests receive an `X-Request-ID` response header. Timestamps are ISO 8601 values generated from the configured application timezone.

## Authentication

`POST /auth/login` accepts `email` and `password` and returns a short-lived-use Sanctum bearer token. Inactive accounts and invalid credentials return `401` without revealing which condition failed. Send `Authorization: Bearer {access_token}` for protected routes. `POST /auth/logout` revokes the current token. `/me` returns only safe user/role fields.

## Role groups

Student routes are under `/student` and derive the authenticated student's profile; route IDs cannot select another student. Teacher routes are under `/teacher` and only expose sessions owned by the authenticated Teacher profile. Guard routes are under `/guard` and require an active assigned Guard and Gate. The guard face endpoint returns `503` with `FACE_SERVICE_UNAVAILABLE` until a real provider is configured. Manual verification requires `student_id`, `confirmed=1`, and a reason; the server derives the entry/exit action.

Teacher attendance writes call the existing `AttendanceService`; Guard security writes call `CampusSecurityService`; visitor mutations are gate-bound and transactional. No client-submitted status, timestamp, role, gate, guard, action, or face result is trusted.

Paginated collections return `data.items` and `data.pagination`. Use `per_page` up to 50. No device tokens, passwords, biometric data, provider payloads, or raw secrets are serialized. FCM delivery, NFC integration, Flutter, and real face-provider integration remain deferred.
