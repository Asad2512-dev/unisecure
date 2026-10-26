<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\ClassSchedule;
use App\Models\ClassSession;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ClassSessionGenerationService
{
    public function generate(ClassSchedule $schedule, string $from, string $to): array
    {
        $tz = config('app.timezone', 'UTC');
        $start = CarbonImmutable::parse($from, $tz)->startOfDay();
        $end = CarbonImmutable::parse($to, $tz)->startOfDay();
        if ($end->lt($start)) {
            throw ValidationException::withMessages(['to' => 'The end date must be on or after the start date.']);
        }if ($start->diffInDays($end) > 366) {
            throw ValidationException::withMessages(['to' => 'Generation is limited to 366 days per request.']);
        }if ($schedule->status !== 'active') {
            return ['created' => 0, 'skipped' => 0, 'message' => 'Inactive schedules are not generated.'];
        }
        $created = 0;
        $skipped = 0;
        DB::transaction(function () use ($schedule, $start, $end, $tz, &$created, &$skipped) {
            for ($date = $start; $date->lte($end); $date = $date->addDay()) {
                if ($date->dayOfWeekIso !== (int) $schedule->day_of_week) {
                    continue;
                }if ($schedule->effective_start_date && $date->lt(CarbonImmutable::parse($schedule->effective_start_date, $tz))) {
                    continue;
                }if ($schedule->effective_end_date && $date->gt(CarbonImmutable::parse($schedule->effective_end_date, $tz))) {
                    continue;
                }$existing = ClassSession::where('schedule_id', $schedule->id)->whereDate('session_date', $date->toDateString())->exists();
                if ($existing) {
                    $skipped++;

                    continue;
                }$startAt = CarbonImmutable::parse($date->toDateString().' '.$schedule->start_time, $tz);
                $endAt = CarbonImmutable::parse($date->toDateString().' '.$schedule->end_time, $tz);
                ClassSession::create(['schedule_id' => $schedule->id, 'course_id' => $schedule->course_id, 'teacher_id' => $schedule->teacher_id, 'section_id' => $schedule->section_id, 'room_id' => $schedule->room_id, 'session_date' => $date->toDateString(), 'scheduled_start_at' => $startAt, 'scheduled_end_at' => $endAt, 'attendance_open_at' => $startAt, 'attendance_close_at' => $endAt, 'status' => 'scheduled']);
                $created++;
            }
        });
        AuditLog::create(['user_id' => auth()->id(), 'action' => 'schedule.sessions_generated', 'entity_type' => ClassSchedule::class, 'entity_id' => $schedule->id, 'new_values' => ['from' => $from, 'to' => $to, 'created' => $created, 'skipped' => $skipped]]);

        return compact('created','skipped');
    }
}
