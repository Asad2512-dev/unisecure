# UniSecure

## Local testing accounts

Use the shared `/login` page for every role. These accounts already exist in the local database and have active profiles.

| Role | Email | Password | Web workspace after login |
| --- | --- | --- | --- |
| Student | student@gmail.com | `12345678` | `/student` |
| Teacher | teacher@gmail.com | `12345678` | `/teacher` |
| Guard | guard@gmail.com | `12345678` | `/security` |
| Administrator | admin@gmail.com | `12345678` | `/admin` |

Sign out before testing another role, or use a separate private browser session. The three demo role passwords above were configured for this local database; they are not automatically created by a fresh migration or seed.

These are local development credentials. Change them before deploying to a shared or production environment.

## Demo workspace data

Run `php artisan db:seed --class=DemoWorkspaceSeeder` to populate connected demo records for all four accounts. Rerunning it reuses the demo records and restores their documented passwords.

The dataset includes three courses, four enrolled students, teaching schedules, historical attendance, upcoming sessions, a session open today, gate activity, active/exited visitors, notifications, delivery history and audit records. Demo NFC cards are blocked, face profiles are pending, and device tokens are inactive. No biometric data or real push credentials are seeded.

The open testing session lasts until the end of the day. Rerun the demo seeder on another day to create a new open session. Framework tables such as sessions, cache, jobs and access tokens are populated by normal application use, rather than with fake credentials or queued tasks. The demo seeder only runs in local/testing environments.
