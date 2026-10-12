# Phase 3 admin panel

The admin panel uses Laravel session authentication at `/admin`. Sign in at `/admin/login` with an authorized administrator account. Set `ADMIN_EMAIL` and a local-only `ADMIN_PASSWORD`, then run `php artisan db:seed` to create or update the development administrator.

Directory CRUD is implemented for users, students, teachers, guards, departments, programs, semesters, sections, courses, rooms, and gates. Listings use server-side search and pagination; forms use CSRF protection, validation, relationship selectors, authorization checks, duplicate constraints, and persisted database writes.

The dashboard is database-backed and handles empty datasets. Face profiles, NFC cards, schedules, sessions, attendance, entry/exit logs, visitors, notifications, and audit logs are restricted read-only operational views where supported. System settings can be edited only by authorized administrators and protected settings cannot be changed from the UI.

Scheduling engines, attendance marking/finalization, real face-provider integration, campus transaction processing, FCM delivery, mobile APIs, and Flutter work are deferred. Face verification remains primary, manual verification remains the fallback, and NFC remains optional and disabled by default. OTP is not part of the system.

Run `php artisan test`, `php artisan route:list`, `php artisan optimize:clear`, and `npm run build` when validating changes. Tests use isolated SQLite; local development uses the verified MAMP MySQL database on port 8889.
