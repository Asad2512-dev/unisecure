# Security foundation

Laravel password hashing, session authentication, CSRF protection, Sanctum bearer-token authentication, request validation, authorization middleware, rate-limit conventions, and production-safe exception rendering remain enabled. Secrets belong only in environment configuration. Never log passwords, tokens, private keys, biometric data, or sensitive request bodies.

Admin routes use session middleware plus server-side `role:admin` authorization. Mobile routes use `auth:sanctum`. Policies are required for resource ownership checks in later phases. OTP is not implemented or planned. Face verification must be implemented through the provider-independent boundary documented in `architecture.md`; manual verification is the fallback and NFC is optional.
