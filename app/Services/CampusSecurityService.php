<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\EntryExitLog;
use App\Models\Guard;
use App\Models\Student;
use App\Models\SystemSetting;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class CampusSecurityService
{
    public function guardFor(User $user, ?int $gateId = null): Guard
    {
        $guard = Guard::where('user_id', $user->id)->where('status', 'active')->first();
        abort_unless($guard, 403, 'An active guard profile is required.');
        $gate = $guard->gate;
        if (! $gate || $gate->status !== 'active' || ($gateId !== null && $gate->id !== $gateId)) {
            abort(403, 'This guard is not authorized for the selected gate.');
        }

return $guard;
    }

    public function transaction(User $actor, Student $student, string $method, ?string $reason = null): EntryExitLog
    {
        $guard = $this->guardFor($actor);
        if (! in_array($method, ['manual', 'face', 'admin'], true)) {
            throw ValidationException::withMessages(['verification_method' => 'Unsupported verification method.']);
        }if ($method === 'admin' && ! $actor->isAdmin()) {
            abort(403);
        }if ($student->status !== 'active') {
            throw ValidationException::withMessages(['student' => 'This student is not eligible for campus access.']);
        }

return DB::transaction(function () use ($actor, $student, $method, $reason, $guard) {
            $locked = Student::whereKey($student->id)->lockForUpdate()->firstOrFail();
            $last = EntryExitLog::where('student_id', $locked->id)->latest('event_at')->latest('id')->first();
            $state = $last ? strtoupper($last->action) === 'ENTRY' ? 'INSIDE' : 'OUTSIDE' : 'OUTSIDE';
            $action = $state === 'INSIDE' ? 'exit' : 'entry';
            $cooldown = (int) SystemSetting::getValue('entry_exit_duplicate_cooldown', 10);
            if ($last && $last->event_at && $last->event_at->diffInSeconds(now(config('app.timezone'))) < $cooldown) {
                throw ValidationException::withMessages(['transaction' => 'A duplicate security transaction is blocked during the cooldown window.']);
            }$event = EntryExitLog::create(['student_id' => $locked->id, 'gate_id' => $guard->gate_id, 'guard_id' => $guard->id, 'action' => $action, 'verification_method' => $method, 'event_at' => now(config('app.timezone')), 'reason' => $reason]);
            AuditLog::create(['user_id' => $actor->id, 'action' => 'security.transaction_created', 'entity_type' => EntryExitLog::class, 'entity_id' => $event->id, 'new_values' => ['action' => $action, 'verification_method' => $method, 'gate_id' => $guard->gate_id, 'student_id' => $locked->id]]);

            return $event;
        });
    }

    public function state(Student $student): string
    {
        $last = $student->entryExitLogs()->latest('event_at')->latest('id')->first();

        return $last && strtoupper($last->action) === 'ENTRY' ? 'INSIDE' : 'OUTSIDE';
    }
}
