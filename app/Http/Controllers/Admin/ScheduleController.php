<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\GenerateSessionsRequest;
use App\Http\Requests\Admin\ScheduleRequest;
use App\Models\AuditLog;
use App\Models\ClassSchedule;
use App\Models\Course;
use App\Models\Room;
use App\Models\Section;
use App\Models\Semester;
use App\Models\Teacher;
use App\Services\ClassSessionGenerationService;
use App\Services\ScheduleConflictService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ScheduleController extends Controller
{
    public function __construct(private ScheduleConflictService $conflicts, private ClassSessionGenerationService $generator) {}

    private function authorizeAdmin(): void
    {
        abort_unless(auth()->user()->isAdmin() || auth()->user()->hasPermission('academic.manage'), 403);
    }

    private function lookups(): array
    {
        return ['courses' => Course::where('status', 'active')->orderBy('name')->get(), 'teachers' => Teacher::with('user')->where('status', 'active')->orderBy('employee_id')->get(), 'sections' => Section::where('status', 'active')->orderBy('name')->get(), 'rooms' => Room::where('status', 'active')->orderBy('name')->get(), 'semesters' => Semester::where('status', 'active')->orderByDesc('academic_year')->get()];
    }

    public function index(Request $request)
    {
        $this->authorizeAdmin();
        $q = ClassSchedule::with(['course', 'teacher.user', 'section', 'room', 'semester'])->when($request->q, fn ($q, $v) => $q->whereHas('course', fn ($x) => $x->where('name', 'like', '%'.$v.'%')->orWhere('course_code', 'like', '%'.$v.'%')))->when($request->status, fn ($q, $v) => $q->where('status', $v))->when($request->teacher_id, fn ($q, $v) => $q->where('teacher_id', $v))->latest();

        return view('admin.schedules.index', ['schedules' => $q->paginate(15)->withQueryString(), 'title' => 'Class schedules', 'teachers' => Teacher::with('user')->orderBy('employee_id')->get()]);
    }

    public function create()
    {
        $this->authorizeAdmin();

        return view('admin.schedules.form', array_merge(['title' => 'Create class schedule', 'schedule' => null], $this->lookups()));
    }

    public function store(ScheduleRequest $request)
    {
        $this->authorizeAdmin();
        $data = $request->validated();
        $this->conflicts->assertValid($data);
        $schedule = DB::transaction(fn () => ClassSchedule::create($data));
        AuditLog::create(['user_id' => auth()->id(), 'action' => 'schedule.created', 'entity_type' => ClassSchedule::class, 'entity_id' => $schedule->id, 'new_values' => $data]);

        return redirect()->route('admin.schedules.show', $schedule)->with('status', 'Schedule created successfully.');
    }

    public function show(ClassSchedule $schedule)
    {
        $this->authorizeAdmin();
        $schedule->load(['course', 'teacher.user', 'section', 'room', 'semester']);

        return view('admin.schedules.show', compact('schedule') + ['title' => 'Schedule details']);
    }

    public function edit(ClassSchedule $schedule)
    {
        $this->authorizeAdmin();

        return view('admin.schedules.form', array_merge(['title' => 'Edit class schedule', 'schedule' => $schedule], $this->lookups()));
    }

    public function update(ScheduleRequest $request, ClassSchedule $schedule)
    {
        $this->authorizeAdmin();
        $data = $request->validated();
        $this->conflicts->assertValid($data, $schedule->id);
        $schedule->update($data);
        AuditLog::create(['user_id' => auth()->id(), 'action' => 'schedule.updated', 'entity_type' => ClassSchedule::class, 'entity_id' => $schedule->id, 'old_values' => $schedule->getOriginal(), 'new_values' => $data]);

        return redirect()->route('admin.schedules.show', $schedule)->with('status', 'Schedule updated successfully.');
    }

    public function deactivate(ClassSchedule $schedule)
    {
        $this->authorizeAdmin();
        $schedule->update(['status' => 'inactive']);
        AuditLog::create(['user_id' => auth()->id(), 'action' => 'schedule.deactivated', 'entity_type' => ClassSchedule::class, 'entity_id' => $schedule->id]);

        return back()->with('status', 'Schedule deactivated. Existing sessions were preserved.');
    }

    public function generateForm(ClassSchedule $schedule)
    {
        $this->authorizeAdmin();

        return view('admin.schedules.generate', compact('schedule') + ['title' => 'Generate class sessions']);
    }

    public function generate(GenerateSessionsRequest $request, ClassSchedule $schedule)
    {
        $this->authorizeAdmin();
        $result = $this->generator->generate($schedule, $request->validated('from'), $request->validated('to'));

        return redirect()->route('admin.schedules.sessions', $schedule)->with('status', "Generation complete: {$result['created']} created, {$result['skipped']} skipped.");
    }

    public function sessions(Request $request, ClassSchedule $schedule)
    {
        $this->authorizeAdmin();
        $sessions = $schedule->sessions()->with(['course', 'teacher.user', 'section', 'room'])->when($request->status, fn ($q, $v) => $q->where('status', $v))->orderBy('session_date')->paginate(20)->withQueryString();

        return view('admin.schedules.sessions', compact('schedule', 'sessions') + ['title' => 'Generated sessions']);
    }

    public function timetable(Request $request)
    {
        $this->authorizeAdmin();
        $schedules = ClassSchedule::with(['course', 'teacher.user', 'section', 'room'])->where('status', 'active')->when($request->semester_id, fn ($q, $v) => $q->where('semester_id', $v))->orderBy('day_of_week')->orderBy('start_time')->get()->groupBy('day_of_week');

        return view('admin.schedules.timetable',compact('schedules') + ['title' => 'Weekly timetable', 'semesters' => Semester::orderByDesc('academic_year')->get()]);
    }
}
