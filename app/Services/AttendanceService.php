<?php

namespace App\Services;

use App\Models\AttendanceRecord;
use App\Models\AuditLog;
use App\Models\ClassSession;
use App\Models\CourseEnrollment;
use App\Models\Student;
use App\Models\SystemSetting;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AttendanceService
{
    public function markSelected(ClassSession $session, int $studentId, User $actor, string $status): AttendanceRecord
    {
        if (! in_array($status, ['present', 'absent', 'late'], true)) {
            throw ValidationException::withMessages(['status' => 'Choose Present, Absent or Late.']);
        }

        return DB::transaction(function () use ($session, $studentId, $actor, $status) {
            $locked = ClassSession::whereKey($session->id)->lockForUpdate()->firstOrFail();
            $this->assertCanMark($locked, $actor);
            if (! $this->eligibleStudent($locked, $studentId)) {
                throw ValidationException::withMessages(['student_id' => 'This student is not eligible for the selected class session.']);
            }
            $now = now(config('app.timezone'));
            if ($now->lt($locked->scheduled_start_at) || $now->gt($locked->scheduled_end_at)) {
                throw ValidationException::withMessages(['session' => 'Attendance is not currently open for this session.']);
            }
            $record = AttendanceRecord::firstOrNew(['class_session_id' => $locked->id, 'student_id' => $studentId]);
            $old = $record->exists ? $record->only(['status', 'marked_at', 'marked_by', 'source']) : null;
            $record->fill(['status' => $status, 'marked_at' => $now, 'marked_by' => $actor->id, 'source' => $actor->isAdmin() ? 'admin' : 'teacher'])->save();
            AuditLog::create(['user_id' => $actor->id, 'action' => 'attendance.manually_selected', 'entity_type' => AttendanceRecord::class, 'entity_id' => $record->id, 'old_values' => $old, 'new_values' => ['status' => $status, 'class_session_id' => $locked->id]]);

            return $record;
        });
    }

    public function eligibleStudent(ClassSession $session, int $studentId): ?Student
    {
        return Student::whereKey($studentId)->where('section_id', $session->section_id)->where('status', 'active')->whereHas('enrollments', fn ($q) => $q->where('student_id', $studentId)->where('course_id', $session->course_id)->where('section_id', $session->section_id)->where('semester_id', $session->schedule?->semester_id)->where('academic_year', $session->schedule?->academic_year)->whereIn('status', ['active', 'completed']))->first();
    }

    public function mark(ClassSession $session, int $studentId, User $actor, string $source = 'teacher'): AttendanceRecord
    {
        $this->assertCanMark($session, $actor);
        $student = $this->eligibleStudent($session, $studentId);
        if (! $student) {
            throw ValidationException::withMessages(['student_id' => 'This student is not eligible for the selected class session.']);
        }$now = CarbonImmutable::now(config('app.timezone'));
        if ($now->lt($session->scheduled_start_at) || $now->gt($session->scheduled_end_at)) {
            throw ValidationException::withMessages(['session' => 'Attendance is not currently open for this session.']);
        }$grace = (int) SystemSetting::getValue('attendance_grace_period', 20);
        $boundary = $session->scheduled_start_at->copy()->addMinutes($grace);
        $status = $now->lt($boundary) ? 'present' : 'late';
        try {
            return DB::transaction(function () use ($session, $student, $actor, $source, $now, $status) {
                $existing = AttendanceRecord::where('class_session_id', $session->id)->where('student_id', $student->id)->lockForUpdate()->first();
                if ($existing) {
                    throw ValidationException::withMessages(['attendance' => 'Attendance has already been recorded and cannot be overwritten by a duplicate request.']);
                }

                return AttendanceRecord::create(['class_session_id' => $session->id, 'student_id' => $student->id, 'status' => $status, 'marked_at' => $now, 'marked_by' => $actor->id, 'source' => $source]);
            });
        } catch (UniqueConstraintViolationException) {
            throw ValidationException::withMessages(['attendance' => 'Attendance was already recorded by another request.']);
        }
    }

    public function finalize(ClassSession $session, User $actor): array
    {
        $this->assertCanFinalize($session, $actor);
        $created = 0;
        $alreadyFinalized = false;
        DB::transaction(function () use ($session, $actor, &$created, &$alreadyFinalized) {
            $locked = ClassSession::whereKey($session->id)->lockForUpdate()->with('schedule')->firstOrFail();
            if ($locked->status === 'cancelled') {
                throw ValidationException::withMessages(['session' => 'Cancelled sessions cannot be finalized.']);
            }if ($locked->finalized_at) {
                $alreadyFinalized = true;

                return;
            }$enrolled = CourseEnrollment::where('course_id', $locked->course_id)->where('section_id', $locked->section_id)->where('semester_id', $locked->schedule?->semester_id)->where('academic_year', $locked->schedule?->academic_year)->whereIn('status', ['active', 'completed'])->pluck('student_id');
            foreach ($enrolled->chunk(100) as $ids) {
                $students = Student::whereIn('id', $ids)->where('status', 'active')->pluck('id');
                foreach ($students as $studentId) {
                    $inserted = AttendanceRecord::insertOrIgnore(['class_session_id' => $locked->id, 'student_id' => $studentId, 'status' => 'absent', 'marked_at' => now(config('app.timezone')), 'marked_by' => $actor->id, 'source' => 'system', 'created_at' => now(), 'updated_at' => now()]);
                    $created += (int) $inserted;
                }
            }$locked->update(['status' => 'closed', 'finalized_at' => now(config('app.timezone')), 'finalized_by' => $actor->id]);
            AuditLog::create(['user_id' => $actor->id, 'action' => 'attendance.finalized', 'entity_type' => ClassSession::class, 'entity_id' => $locked->id, 'new_values' => ['absent_created' => $created]]);
        });

        return ['absent_created' => $created, 'already_finalized' => $alreadyFinalized];
    }

    public function correct(AttendanceRecord $record, string $status, string $reason, User $actor): AttendanceRecord
    {
        abort_unless($actor->isAdmin() || $actor->hasPermission('attendance.manage'), 403);
        if (trim($reason) === '') {
            throw ValidationException::withMessages(['reason' => 'A correction reason is required.']);
        }if (! in_array($status, ['present', 'late', 'absent'], true)) {
            throw ValidationException::withMessages(['status' => 'Invalid attendance status.']);
        }$old = $record->only(['status', 'marked_at', 'marked_by', 'source']);
        $record->update(['status' => $status, 'marked_at' => now(config('app.timezone')), 'marked_by' => $actor->id, 'source' => 'admin']);
        AuditLog::create(['user_id' => $actor->id, 'action' => 'attendance.corrected', 'entity_type' => AttendanceRecord::class, 'entity_id' => $record->id, 'old_values' => $old, 'new_values' => ['status' => $status, 'reason' => $reason]]);

        return $record->refresh();
    }

    public function summary(ClassSession $session): array
    {
        $counts = $session->attendanceRecords()->selectRaw('status,count(*) as total')->groupBy('status')->pluck('total', 'status');
        $attended = ($counts['present'] ?? 0) + (SystemSetting::getValue('late_counts_as_attended', true) ? ($counts['late'] ?? 0) : 0);

        return ['present' => (int) ($counts['present'] ?? 0), 'late' => (int) ($counts['late'] ?? 0), 'absent' => (int) ($counts['absent'] ?? 0), 'attended' => (int) $attended];
    }

    private function assertCanMark(ClassSession $session, User $actor): void
    {
        abort_unless($actor->isAdmin() || ($actor->hasRole('teacher') && $session->teacher()->where('user_id', $actor->id)->exists()), 403);
        if (in_array($session->status, ['cancelled', 'closed'], true) || $session->finalized_at) {
            throw ValidationException::withMessages(['session' => 'This session is not accepting attendance.']);
        }
    }

    private function assertCanFinalize(ClassSession $session, User $actor): void
    {
        abort_unless($actor->isAdmin() || $actor->hasPermission('attendance.manage'), 403);
    }
}
