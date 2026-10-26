<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\ApiAttendanceMarkRequest;
use App\Models\ClassSession;
use App\Models\Student;
use App\Models\Teacher;
use App\Services\AttendanceService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    private function teacher(): Teacher
    {
        $teacher = auth()->user()->teacher;
        abort_unless($teacher && $teacher->status === 'active', 403);

        return $teacher;
    }

    public function profile()
    {
        return ApiResponse::ok($this->teacher()->load(['user', 'department'])->only(['id', 'employee_id', 'official_email', 'phone', 'status']) + ['name' => $this->teacher()->user?->name, 'department' => $this->teacher()->department?->name]);
    }

    public function courses()
    {
        $teacher = $this->teacher();
        $items = $teacher->schedules()->with('course')->get()->pluck('course')->unique('id')->values()->map(fn ($c) => ['id' => $c->id, 'code' => $c->course_code, 'name' => $c->name]);

        return ApiResponse::ok(['items' => $items]);
    }

    public function sections()
    {
        $teacher = $this->teacher();
        $items = $teacher->schedules()->with('section')->get()->pluck('section')->unique('id')->values()->map(fn ($s) => ['id' => $s->id, 'name' => $s->name, 'code' => $s->code]);

        return ApiResponse::ok(['items' => $items]);
    }

    public function timetable()
    {
        $items = $this->teacher()->schedules()->with(['course', 'section', 'room'])->where('status', 'active')->orderBy('day_of_week')->orderBy('start_time')->get()->map(fn ($s) => ['id' => $s->id, 'day_of_week' => $s->day_of_week, 'start_time' => $s->start_time, 'end_time' => $s->end_time, 'course' => $s->course?->course_code, 'section' => $s->section?->code, 'room' => $s->room?->name]);

        return ApiResponse::ok(['items' => $items]);
    }

    private function session(ClassSession $session): ClassSession
    {
        $teacher = $this->teacher();
        abort_unless((int) $session->teacher_id === (int) $teacher->id, 403);

        return $session->load(['course', 'section', 'room']);
    }

    public function sessions(Request $request)
    {
        $teacher = $this->teacher();
        $items = $teacher->sessions()->with(['course', 'section', 'room'])->latest('session_date')->paginate(min((int) $request->input('per_page', 20), 50));

        return ApiResponse::ok(['items' => $items->getCollection()->map(fn ($s) => ['id' => $s->id, 'date' => $s->session_date?->toDateString(), 'start_at' => $s->scheduled_start_at?->toIso8601String(), 'end_at' => $s->scheduled_end_at?->toIso8601String(), 'status' => $s->status, 'course' => $s->course?->course_code, 'section' => $s->section?->code, 'room' => $s->room?->name]), 'pagination' => ['current_page' => $items->currentPage(), 'last_page' => $items->lastPage(), 'total' => $items->total()]]);
    }

    public function show(ClassSession $session)
    {
        $session = $this->session($session);

        return ApiResponse::ok(['session' => ['id' => $session->id, 'date' => $session->session_date?->toDateString(), 'start_at' => $session->scheduled_start_at?->toIso8601String(), 'end_at' => $session->scheduled_end_at?->toIso8601String(), 'status' => $session->status, 'course' => $session->course?->course_code, 'section' => $session->section?->code, 'room' => $session->room?->name]]);
    }

    public function students(ClassSession $session)
    {
        $session = $this->session($session);
        $items = Student::with('user')->where('section_id', $session->section_id)->where('status', 'active')->whereHas('enrollments', fn ($q) => $q->where('course_id', $session->course_id)->whereIn('status', ['active', 'completed']))->get()->map(fn ($s) => ['id' => $s->id, 'student_id' => $s->student_id, 'name' => $s->user?->name]);

        return ApiResponse::ok(['items' => $items]);
    }

    public function attendance(ClassSession $session)
    {
        $session = $this->session($session);

        return ApiResponse::ok(['summary' => app(AttendanceService::class)->summary($session), 'records' => $session->attendanceRecords()->with('student.user')->get()->map(fn ($r) => ['id' => $r->id, 'student_id' => $r->student_id, 'student' => $r->student?->user?->name, 'status' => $r->status, 'marked_at' => $r->marked_at?->toIso8601String()])]);
    }

    public function mark(ApiAttendanceMarkRequest $request, ClassSession $session)
    {
        $session = $this->session($session);
        $record = app(AttendanceService::class)->mark($session, (int) $request->validated('student_id'), auth()->user(), 'teacher');

        return ApiResponse::created(['id' => $record->id, 'status' => $record->status, 'marked_at' => $record->marked_at?->toIso8601String()], 'Attendance recorded.');
    }

    public function finalize(ClassSession $session)
    {
        $session = $this->session($session);
        $result = app(AttendanceService::class)->finalize($session, auth()->user());

        return ApiResponse::ok($result,'Session finalization completed.');
    }
}
