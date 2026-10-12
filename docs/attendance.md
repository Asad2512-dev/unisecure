# Phase 5 attendance engine

Attendance is calculated only by `AttendanceService`. Statuses are `present`, `late`, and `absent`. Using the actual `class_sessions.scheduled_start_at` in the configured `Asia/Karachi` timezone, a mark strictly before start plus `attendance_grace_period` (default 20 minutes) is `present`; exactly at or after that boundary is `late`. Marks outside the scheduled interval, cancelled sessions, closed/finalized sessions, and ineligible students are rejected.

Eligibility requires an active student in the session section with an active or completed enrollment matching the session course, section, semester, and academic year. Dropped and cancelled enrollments are excluded. Teacher marking requires the authenticated user's linked Teacher profile to own the session. Administrators may mark, finalize, and correct according to the existing admin permission boundary.

The existing unique `(class_session_id, student_id)` constraint prevents duplicates. Marking uses a transaction and row lock; duplicate requests return a validation error and never overwrite an existing record. Finalization locks the session, inserts absent records only for eligible students without records, closes the session, and records `finalized_at`/`finalized_by`. Repeated finalization is idempotent. Cancelled sessions cannot be finalized.

Corrections require administrator authorization, a new valid status, and a non-empty reason. The previous value, new value, reason, actor, and timestamp are recorded in `audit_logs`; historical rows are not deleted. The summary service counts present and, when `late_counts_as_attended=true`, late records as attended. Future, cancelled, and unfinalized sessions are not counted by any percentage calculation introduced later.

Admin and teacher web rosters are available under `/admin/attendance` and `/teacher/attendance`. No mobile attendance API, Flutter workflow, face provider, NFC security workflow, or OTP functionality is part of this phase. Attendance percentage dashboards and broader reporting remain deferred where the current web surface does not yet provide a documented denominator query.
