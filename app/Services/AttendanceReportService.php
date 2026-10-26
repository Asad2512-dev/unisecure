<?php

namespace App\Services;

use App\Models\AttendanceRecord;
use App\Models\ClassSession;
use App\Models\CourseEnrollment;
use App\Models\Student;
use App\Models\SystemSetting;

class AttendanceReportService
{
    public function studentSummary(Student $student, ?string $from = null, ?string $to = null): array
    {
        $sessions = ClassSession::with('schedule')->whereNotNull('finalized_at')->where('status', '!=', 'cancelled')->where('section_id', $student->section_id)
            ->when($from, fn ($q) => $q->whereDate('session_date', '>=', $from))->when($to, fn ($q) => $q->whereDate('session_date', '<=', $to))->get();
        $eligible = $present = $late = $absent = 0;
        $lateCounts = (bool) SystemSetting::getValue('late_counts_as_attended', true);
        foreach ($sessions as $session) {
            $enrolled = CourseEnrollment::where('student_id', $student->id)->where('course_id', $session->course_id)->where('section_id', $session->section_id)->whereIn('status', ['active', 'completed'])->exists();
            if (! $enrolled) {
                continue;
            }
            $eligible++;
            $status = AttendanceRecord::where('class_session_id', $session->id)->where('student_id', $student->id)->value('status');
            if ($status === 'present') {
                $present++;
            } elseif ($status === 'late') {
                $late++;
            } else {
                $absent++;
            }
        }
        $attended = $present + ($lateCounts ? $late : 0);

        return ['eligible_sessions' => $eligible, 'present' => $present, 'late' => $late, 'absent' => $absent, 'attended' => $attended, 'late_counts_as_attended' => $lateCounts, 'percentage' => $eligible ? round(($attended / $eligible) * 100, 2) : null];
    }

    public function sessionCounts(ClassSession $session): array
    {
        return $session->attendanceRecords()->selectRaw('status, count(*) as total')->groupBy('status')->pluck('total', 'status')->all() + ['present' => 0, 'late' => 0, 'absent' => 0];
    }
}
