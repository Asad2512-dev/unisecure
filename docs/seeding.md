# Seeding

Set a development-only administrator password in the environment before seeding:

```bash
ADMIN_EMAIL=admin@unisecure.test ADMIN_PASSWORD='use-a-local-secret' php artisan db:seed
```

`DatabaseSeeder` is idempotent for roles, permissions, role assignments, settings, and the administrator. It creates no student face profiles, biometric data, NFC cards, or fake operational transactions. The default settings include a 20-minute attendance grace period, `late_counts_as_attended=true`, a 10-minute duplicate entry/exit cooldown, `nfc_enabled=false`, and `face_verification_enabled=true`.

The test suite uses isolated in-memory SQLite configuration. Local development uses the verified MAMP MySQL connection documented in `docs/setup.md`. Never commit the administrator password or production credentials.
