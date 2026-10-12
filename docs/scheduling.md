# Phase 4 scheduling

`class_schedules` represents an active or inactive weekly teaching arrangement. `day_of_week` uses ISO values 1–7 (Monday–Sunday). `effective_start_date` and `effective_end_date` bound the recurring arrangement; either may be open-ended. All schedule times are interpreted in `config('app.timezone')`, currently `Asia/Karachi`.

## Conflict rules

Active schedules conflict when they share a weekday, their effective date ranges overlap, their time intervals overlap, and they share a teacher, room, or section. The interval comparison is strict, so an arrangement ending at 10:00 may be followed by one beginning at 10:00. Conflict checks run in `ScheduleConflictService` on the server during create and update; browser behavior is not trusted.

## Session generation

`ClassSessionGenerationService` accepts one schedule and a bounded inclusive date range of at most 366 days. It skips dates outside the schedule's effective period or weekday, skips inactive schedules, and creates scheduled sessions in a transaction. `schedule_id + session_date` is unique, so repeated generation is idempotent and existing sessions are never overwritten. The required attendance timestamps are populated from the scheduled interval only; no attendance records or attendance rules are created.

The admin workflow is available from `/admin/schedules`, with schedule details, generation, generated-session inspection, and a weekly timetable. Generation reports created and skipped counts. Schedule changes, deactivation, and generation write append-oriented audit entries without secrets or biometric data.

Phase 5 remains responsible for attendance marking, grace-period logic, absence finalization, corrections, percentages, and teacher attendance APIs. Cross-midnight schedules are rejected because the current weekly schema uses a same-day time interval.
