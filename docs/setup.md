# Local setup

Requirements: PHP 8.3+, Composer, Node/npm, and MySQL. This environment uses MAMP MySQL on `127.0.0.1:8889`; confirm the port in MAMP before connecting.

1. Copy `.env.example` to `.env` and set `APP_KEY`, MySQL credentials, and environment-specific mail/queue settings.
2. Run `composer install`, `php artisan key:generate`, `npm install`, and `npm run build`.
3. Verify the database target before running `php artisan migrate`. Do not use `migrate:fresh` against a developer database.
4. Run `php artisan serve` for local HTTP, `php artisan queue:work` for queued work, and `php artisan schedule:work` for scheduled work.

Mail defaults to the log driver and Firebase credentials are optional placeholders, so basic tests do not require external services.
