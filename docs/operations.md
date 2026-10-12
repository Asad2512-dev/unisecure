# Operations

Run queue work with `php artisan queue:work --tries=3`. Run the scheduler locally with `php artisan schedule:work`; production should invoke Laravel's scheduler every minute. `php artisan notifications:class-reminders` can be run manually for diagnosis.

FCM is optional and safe to leave disabled. Attendance and campus-security transactions do not depend on push delivery. Never log passwords, access tokens, device tokens, Firebase credentials, biometric data or raw provider payloads.
