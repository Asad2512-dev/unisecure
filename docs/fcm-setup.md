# Firebase Cloud Messaging

FCM is intentionally disabled unless valid server configuration is supplied. Set `FCM_ENABLED=true`, `FCM_PROJECT_ID` and `FCM_CREDENTIALS_PATH` in an uncommitted environment file. Credentials must be outside version control and must never appear in logs, exports, screenshots or API responses.

The current safe default provider is unavailable when configuration is absent. Jobs record `provider_unavailable` rather than claiming delivery. FCM calls are queued, bounded to three attempts with backoff, and invalid tokens are deactivated. Live delivery has not been claimed or verified in this environment.

Administrative retries do not reset the attempt count and cannot retry permanent failures or exceed the configured maximum, preventing uncontrolled retry loops.
