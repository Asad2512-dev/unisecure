# Architecture

## What this is

UniSecure. The repository is a Laravel application.

## Layout

- `app/` — `Console`, `Contracts`, `Http`, `Jobs`, `Models`, `Policies`, `Providers`, `Repositories` (+2 more)
- `bootstrap/`
- `config/`
- `database/`
- `docs/`
- `postman/`
- `public/`
- `resources/`
- `routes/` — `api.php`, `console.php`, `web.php`
- `storage/`
- `tests/`
- `unisecure_app/`
- Tooling: `.agents`, `.amp`, `.claude`, `.github`, `.junie`, `.editorconfig`, `.env.example`, `.gitattributes`…
- Root files: `AGENTS.md`, `artisan`, `boost.json`, `CLAUDE.md`, `composer.json`, `composer.lock`, `package-lock.json`, `package.json`, `phpunit.xml`, `README.md`, `vite.config.js`

## How the pieces fit

Laravel application: `artisan` and `composer.json` are at the root, and PHP code is under `app/` (Console, Contracts, Http, Jobs, Models, Policies, Providers, Repositories, Services, Support). Route files: `routes/api.php`, `routes/console.php`, `routes/web.php`. Views and frontend source are under `resources/`. Migrations and seeders are under `database/`. Composer requires Laravel Sanctum. The root `package.json` builds frontend assets with Vite. `unisecure_app/` is a Flutter package `unisecure_app`. Libraries named in that pubspec: `dio`, `get`.

## How to run

Scripts in the root `package.json`:

- `build` — `vite build`
- `dev` — `vite`

Composer scripts: `dev`, `test`.

## External services named in the repo

- Redis — `REDIS_CLIENT` in `.env.example`
- Firebase — `FIREBASE_PROJECT_ID` in `.env.example`
- AWS — `AWS_ACCESS_KEY_ID` in `.env.example`
