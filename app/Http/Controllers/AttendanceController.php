<?php

namespace App\Http\Controllers;

use App\Models\AttendanceRecord;
use App\Models\ClassSession;
use App\Models\Student;
use App\Services\AttendanceService;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function __construct(private AttendanceService $attendance) {}

    private function allowed(): void
    {
        abort_unless(auth()->user()->isAdmin() || auth()->user()->hasRole('teacher'), 403);
    }

    public function sessions(Request $request)
    {
        $this->allowed();
        $q = ClassSession::with(['course', 'teacher.user', 'section'])->whereIn('status', ['scheduled', 'open', 'closed'])->when(auth()->user()->hasRole('teacher') && ! auth()->user()->isAdmin(), fn ($q) => $q->whereHas('teacher', fn ($x) => $x->where('user_id', auth()->id())))->latest('session_date');

        return view(auth()->user()->hasRole('teacher') ? 'academic.sessions' : 'admin.attendance.sessions', ['title' => 'Attendance sessions', 'sessions' => $q->paginate(15)->withQueryString()]);
    }

    public function roster(ClassSession $session)
    {
        $this->allowed();
        if (auth()->user()->hasRole('teacher') && ! auth()->user()->isAdmin() && ! $session->teacher()->where('user_id', auth()->id())->exists()) {
            abort(403);
        }$students = Student::with(['user', 'attendanceRecords' => fn ($q) => $q->where('class_session_id', $session->id)])->where('section_id', $session->section_id)->where('status', 'active')->whereHas('enrollments', fn ($q) => $q->where('course_id', $session->course_id)->where('section_id', $session->section_id)->whereIn('status', ['active', 'completed']))->paginate(50);
        $view = auth()->user()->hasRole('teacher') && ! auth()->user()->isAdmin() ? 'admin.attendance.teacher-roster' : 'admin.attendance.roster';

        return view($view, compact('session', 'students') + ['title' => 'Attendance roster', 'summary' => $this->attendance->summary($session)]);
    }

    public function mark(Request $request, ClassSession $session)
    {
        $this->allowed();
        $data = $request->validate(['student_id' => 'required|integer', 'source' => 'nullable|in:teacher,admin', 'status' => 'sometimes|required|in:present,absent,late']);
        if (isset($data['status'])) {
            $this->attendance->markSelected($session, (int) $data['student_id'], $request->user(), $data['status']);
        } else {
            $this->attendance->mark($session, (int) $data['student_id'], auth()->user(), auth()->user()->isAdmin() ? 'admin' : 'teacher');
        }

        return back()->with('status', isset($data['status']) ? 'Attendance saved: '.ucfirst($data['status']).'.' : 'Attendance recorded by the server.');
    }

    public function finalize(ClassSession $session)
    {
        $this->attendance->finalize($session, auth()->user());

        return back()->with('status', 'Session finalized. Eligible students without attendance were marked absent.');
    }

    public function correct(Request $request, AttendanceRecord $record)
    {
        $data = $request->validate(['status' => 'required|in:present,late,absent', 'reason' => 'required|string|min:3|max:1000']);
        $this->attendance->correct($record, $data['status'], $data['reason'], auth()->user());

        return back()->with('status', 'Attendance correction saved and audited.');
    }
}
