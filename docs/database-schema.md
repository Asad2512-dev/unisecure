# Phase 2 database schema

The schema is split into ordered migrations:

1. RBAC and user extensions: `roles`, `permissions`, `role_has_permissions`, and user status/role fields.
2. Academic and people: departments, programs, semesters, sections, rooms, gates, students, teachers, guards, and courses.
3. Security and attendance: enrollments, provider-independent face profiles, optional NFC cards, schedules, sessions, attendance, entry/exit logs, and visitors.
4. Operations: device tokens, Laravel-compatible notifications, append-oriented audit logs, and system settings.

Foreign keys use restrictive deletion for academic and historical records. Optional references such as assigned gates, guards, visitors' hosts, NFC cards, and attendance markers use `nullOnDelete`. Soft deletes are used for users, departments, students, teachers, guards, and courses; historical records are not cascaded away.

Important uniqueness constraints include role/permission names, department/program/course/gate codes, student and employee identifiers, one profile per student/provider, NFC UID/card number, enrollment context, and one attendance record per session/student. Indexes cover status fields, academic lookups, dates, gates, students, and audit entities.

Academic years are stored as strings such as `2026-2027`; semester number plus academic year is unique. Recurring schedule generation is intentionally deferred. Face profiles store provider metadata only—never raw images or embeddings. NFC is optional and disabled by default.
