# API integration

The base URL is supplied with `--dart-define=API_BASE_URL` and defaults to `http://127.0.0.1:8000/api/v1`. `ApiClient` attaches the Sanctum bearer token from `flutter_secure_storage` and normalizes Laravel response errors without logging credentials.

Integrated endpoints: `/auth/login`, `/auth/logout`, `/me`. Endpoint constants for the existing student, teacher, guard, notification and device-token APIs are centralized in `lib/app/config/api_endpoints.dart` for incremental feature implementation.
