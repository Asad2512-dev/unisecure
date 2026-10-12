# UniSecure architecture

UniSecure uses Laravel 13, PHP 8.3+, MySQL, Blade/Tailwind/Alpine for the admin web panel, and Sanctum for the single Flutter mobile API used by Student, Teacher, and Guard.

HTTP controllers remain thin. Workflows belong in `app/Services`; persistence/query logic with real reuse belongs in `app/Repositories/Contracts` and `app/Repositories/Eloquent`; validation belongs in Form Requests; response shaping belongs in API Resources; authorization belongs in Policies and middleware. Domain reactions use Events/Listeners and slow work uses Jobs.

The API is versioned under `/api/v1` and uses `{success,message,data,meta}` for success and `{success,message,errors}` for errors. API requests receive a validated or generated `X-Request-ID`, which is available to logging context without logging sensitive payloads.

Face verification is provider-independent: `FaceVerificationInterface` -> `FaceVerificationService` -> configured provider. Enrollment and the real provider are later-phase work. Face verification is primary; manual student search/manual verification is the fallback. No fake matching, embeddings, confidence scores, client-supplied verification, or raw biometric data are implemented.

NFC is optional and feature-flagged by `NFC_ENABLED`/future `nfc_enabled`; the core system works with it disabled. OTP is explicitly not part of this architecture.
