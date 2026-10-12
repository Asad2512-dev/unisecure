# Attendance reporting

Student percentages count only finalized, non-cancelled sessions for which the student has an active or completed enrollment matching the session course and section. Future, cancelled and unfinalized sessions are excluded. `late_counts_as_attended` controls whether late records contribute to attended totals. A zero eligible-session denominator returns `null` percentage.

The reporting service reuses the existing attendance records and does not implement a second attendance engine. Admin attendance reports are paginated and can be exported as bounded CSV.
