# Authorization

Each user has one primary role through `users.role_id`. Roles use stable identifiers: `admin`, `student`, `teacher`, and `guard`. Permissions are many-to-many through `role_has_permissions` and are checked with `User::hasPermission()`; `EnsureRole` remains compatible with Phase 1 route middleware.

Policies provide the starting ownership and permission boundary for Student, Teacher, Guard, and SystemSetting resources. Students cannot change role, status, or academic assignments through the policy surface. Teachers and Guards are restricted to their own records unless an appropriate permission is present. Future controllers must call policies and must never trust client-supplied roles, gate assignments, or ownership identifiers.

Admin access is permission-controlled in application code. Protected settings require administrator authorization; credentials and private keys never belong in `system_settings`.
