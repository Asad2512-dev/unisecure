# Reports and exports

Admin attendance reporting is available at `/admin/reports/attendance`; it supports status/date filters and a bounded CSV export. CSV cells beginning with `=`, `+`, `-`, or `@` are prefixed with an apostrophe to reduce spreadsheet formula injection risk. Export rows contain only student identifier, course code, status and timestamp.

Exports are server-side, filtered through the same report query and limited to 5,000 rows in this phase. Larger asynchronous export tracking can be added later without weakening authorization.

The Phase 8 tests cover formula-triggering prefixes, safe values, and protected report access. Sensitive notification delivery data is not included in report exports.

CSV protection also covers formula characters preceded by spaces, tabs, and control characters. This is defensive escaping, not a universal guarantee for every spreadsheet application.
