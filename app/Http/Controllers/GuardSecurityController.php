<?php

namespace App\Http\Controllers;

use App\Http\Requests\ManualVerificationRequest;
use App\Models\EntryExitLog;
use App\Models\Student;
use App\Models\Visitor;
use App\Services\CampusSecurityService;
use App\Services\FaceVerificationService;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class GuardSecurityController extends Controller
{
    public function __construct(private CampusSecurityService $security, private FaceVerificationService $faces) {}

    public function index(Request $request)
    {
        $guard = $this->security->guardFor($request->user())->load(['user', 'gate']);
        $data = $request->validate(['q' => 'nullable|string|max:100']);
        $search = trim($data['q'] ?? '');
        $students = Student::with(['user', 'department', 'section'])
            ->where('status', 'active')
            ->whereHas('user', fn ($query) => $query->where('status', 'active'))
            ->when($search !== '', fn ($query) => $query->where(fn ($query) => $query
                ->where('student_id', 'like', '%'.$search.'%')
                ->orWhereHas('user', fn ($query) => $query->where('name', 'like', '%'.$search.'%'))))
            ->when($search === '', fn ($query) => $query->whereRaw('1 = 0'))
            ->limit(20)->get();
        $latestEvents = EntryExitLog::whereIn('student_id', $students->pluck('id'))
            ->select('student_id')->selectRaw('MAX(id) as last_id')->groupBy('student_id');
        $studentStates = EntryExitLog::whereIn('id', $latestEvents->pluck('last_id'))->pluck('action', 'student_id');
        $logs = EntryExitLog::with('student.user')->where('guard_id', $guard->id)->latest('event_at')->limit(6)->get();
        $today = EntryExitLog::where('guard_id', $guard->id)->whereDate('event_at', today());
        $stats = [
            'Entries today' => (clone $today)->where('action', 'entry')->count(),
            'Exits today' => (clone $today)->where('action', 'exit')->count(),
            'Visitors inside' => Visitor::where('gate_id', $guard->gate_id)->where('status', 'active')->count(),
            'Visitor check-ins today' => Visitor::where('gate_id', $guard->gate_id)->whereDate('entry_at', today())->count(),
        ];

        return view('security.guard', compact('guard', 'students', 'studentStates', 'logs', 'stats', 'search') + ['title' => 'Security overview']);
    }

    public function transactions(Request $request)
    {
        $guard = $this->security->guardFor($request->user())->load(['user', 'gate']);
        $filters = $request->validate(['q' => 'nullable|string|max:100', 'action' => 'nullable|in:entry,exit', 'date' => 'nullable|date']);
        $logs = EntryExitLog::with(['student.user', 'gate'])->where('guard_id', $guard->id)
            ->when($filters['q'] ?? null, fn ($query, $value) => $query->whereHas('student', fn ($query) => $query->where(fn ($query) => $query->where('student_id', 'like', '%'.$value.'%')->orWhereHas('user', fn ($query) => $query->where('name', 'like', '%'.$value.'%')))))
            ->when($filters['action'] ?? null, fn ($query, $value) => $query->where('action', $value))
            ->when($filters['date'] ?? null, fn ($query, $value) => $query->whereDate('event_at', $value))
            ->latest('event_at')->paginate(15)->withQueryString();

        return view('security.transactions', compact('guard', 'logs') + ['title' => 'My transactions']);
    }

    public function profile(Request $request)
    {
        $guard = $this->security->guardFor($request->user())->load(['user', 'gate']);

        return view('security.profile', compact('guard') + ['title' => 'Profile & gate']);
    }

    public function manual(ManualVerificationRequest $request)
    {
        $student = Student::whereHas('user', fn ($query) => $query->where('status', 'active'))->findOrFail($request->validated('student_id'));
        $event = $this->security->transaction($request->user(), $student, 'manual', $request->validated('reason'));

        return back()->with('status', 'Manual verification recorded: '.strtoupper($event->action).'.');
    }

    public function face(Request $request): Response
    {
        $this->security->guardFor($request->user());
        $request->validate(['capture' => 'required|string|max:200000']);

        return response()->json(['success' => false, 'message' => 'Face verification is unavailable. Use manual verification.', 'errors' => ['code' => 'FACE_SERVICE_UNAVAILABLE']], 503);
    }
}
