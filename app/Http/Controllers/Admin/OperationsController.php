<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AttendanceRecord;
use App\Models\AuditLog;
use App\Models\ClassSchedule;
use App\Models\ClassSession;
use App\Models\EntryExitLog;
use App\Models\NfcCard;
use App\Models\StudentFaceProfile;
use App\Models\Visitor;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification as Notification;

class OperationsController extends Controller
{
    private array $map = ['face-profiles' => [StudentFaceProfile::class, 'Face profiles', 'academic.view'], 'nfc-cards' => [NfcCard::class, 'NFC cards', 'security.view'], 'schedules' => [ClassSchedule::class, 'Class schedules', 'academic.view'], 'sessions' => [ClassSession::class, 'Class sessions', 'academic.view'], 'attendance' => [AttendanceRecord::class, 'Attendance records', 'attendance.view'], 'entry-exit' => [EntryExitLog::class, 'Entry and exit logs', 'security.view'], 'visitors' => [Visitor::class, 'Visitors', 'security.view'], 'notifications' => [Notification::class, 'Notifications', 'users.view'], 'audit-logs' => [AuditLog::class, 'Audit logs', 'users.view']];

    public function index(Request $request, string $type)
    {
        abort_unless(isset($this->map[$type]), 404);
        [$class,$title,$permission] = $this->map[$type];
        abort_unless(auth()->user()->isAdmin() || auth()->user()->hasPermission($permission), 403);
        $records = $class::query()->latest()->paginate(20)->withQueryString();

        return view('admin.operations.index', compact('type', 'title', 'records'));
    }
}
