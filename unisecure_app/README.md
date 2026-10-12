# UniSecure Flutter app

This Flutter client uses GetX with an MVC-oriented feature structure and integrates with the existing Laravel `/api/v1` contract.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

For an Android emulator use the host address reachable from that emulator, commonly `http://10.0.2.2:8000/api/v1`. A physical device must use the development machine's LAN address. Do not use these development URLs for production.

## Current scope

Implemented: light-mode shell, GetX dependency binding, login/logout, Sanctum token storage, current-user restoration, centralized API endpoints, typed user model, API error normalization, responsive login and authenticated home shell.

The backend supports student, teacher and guard routes; role-specific feature screens and workflows remain incremental work. Face verification remains unavailable without a genuine provider, NFC remains disabled/optional, FCM is not required, and OTP is not part of the application.
