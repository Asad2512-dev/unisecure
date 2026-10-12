# Phase 6 security workflows

## Face verification

`FaceVerificationInterface` is provider-independent and is bound to `UnavailableFaceVerificationProvider` until an approved real provider is configured. `FaceVerificationService` returns a controlled unavailable result; `POST /security/face` returns HTTP 503 with `FACE_SERVICE_UNAVAILABLE` and never creates a transaction. No uploaded capture, embedding, provider payload, secret, or confidence value is stored or logged. A real adapter must be explicitly bound in the container and must be the only component allowed to produce a verified student identity.

Face profile administration remains metadata-only. Institutional consent, retention, deletion, provider security, and privacy requirements must be approved before a real enrollment provider is connected. This project does not claim legal compliance automatically.

## Guards and gates

The existing schema assigns one `gate_id` to each Guard. Security operations require an authenticated user with an active Guard profile and an active assigned Gate. Submitted guard or gate identifiers are not trusted. Inactive guards and gates are rejected.

## Campus state machine

`CampusSecurityService` locks the Student row in a transaction, reads the latest historical `entry_exit_logs` record, derives `OUTSIDE` or `INSIDE`, and creates the opposite action. No prior valid transaction means `OUTSIDE`; latest `entry` means `INSIDE`; latest `exit` means `OUTSIDE`. The server stores the authenticated guard, assigned gate, method, server timestamp, and derived action. The 10-second `entry_exit_duplicate_cooldown` setting is enforced server-side.

Manual verification is an explicit fallback at `/security`: the guard must confirm the institution's manual identity check and provide a reason. The result is always recorded as `manual`, never `face`, and is audited. Face-provider unavailability does not fabricate a face result.

NFC remains optional and disabled by default. No NFC transaction path is implemented without a genuine reader/provider integration; client-supplied UIDs cannot produce a transaction.

## Visitors and audit

Guard visitor check-in/check-out is gate-bound, transactional, and lock-protected. Active visitors can be checked out once; exited history is preserved and repeat visits create separate visitor rows. Entry/exit, manual verification, visitor changes, and sensitive profile changes are recorded with minimal audit metadata. Passwords, tokens, biometric material, provider secrets, and raw provider payloads are never logged.

Phase 7 remains responsible for the general mobile REST API. OTP is not part of the architecture.
