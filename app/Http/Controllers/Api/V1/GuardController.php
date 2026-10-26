<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\ManualVerificationRequest;
use App\Models\EntryExitLog;
use App\Models\Student;
use App\Services\CampusSecurityService;
use App\Services\FaceVerificationService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class GuardController extends Controller
{
    public function __construct(private CampusSecurityService $security, private FaceVerificationService $faces) {}

    private function guard()
    {
        return $this->security->guardFor(auth()->user());
    }

    public function profile()
    {
        $g = $this->guard()->load(['user', 'gate']);

        return ApiResponse::ok(['id' => $g->id, 'employee_id' => $g->employee_id, 'name' => $g->user?->name, 'status' => $g->status, 'gate' => ['id' => $g->gate?->id, 'name' => $g->gate?->name, 'code' => $g->gate?->code]]);
    }

    public function gate()
    {
        $g = $this->guard();

        return ApiResponse::ok(['id' => $g->gate->id, 'name' => $g->gate->name, 'code' => $g->gate->code, 'status' => $g->gate->status]);
    }

    public function search(Request $request)
    {
        $this->guard();
        $data = $request->validate(['q' => 'required|string|min:2|max:100']);
        $students = Student::with('user')->where('status', 'active')->where(fn ($q) => $q->where('student_id', 'like', '%'.$data['q'].'%')->orWhereHas('user', fn ($x) => $x->where('name', 'like', '%'.$data['q'].'%')))->limit(25)->get()->map(fn ($s) => ['id' => $s->id, 'student_id' => $s->student_id, 'name' => $s->user?->name]);

        return ApiResponse::ok(['items' => $students]);
    }

    public function transactions(Request $request)
    {
        $g = $this->guard();
        $logs = EntryExitLog::with('student.user')->where('guard_id', $g->id)->latest('event_at')->paginate(min((int) $request->input('per_page', 20), 50));

        return ApiResponse::ok(['items' => $logs->getCollection()->map(fn ($l) => ['id' => $l->id, 'student_id' => $l->student_id, 'student' => $l->student?->user?->name, 'action' => $l->action, 'verification_method' => $l->verification_method, 'event_at' => $l->event_at?->toIso8601String()]), 'pagination' => ['current_page' => $logs->currentPage(), 'last_page' => $logs->lastPage(), 'total' => $logs->total()]]);
    }

    public function face(Request $request)
    {
        $this->guard();
        $request->validate(['capture' => 'required|string|max:200000']);
        if (! $this->faces->available()) {
            return ApiResponse::error('Face verification provider is unavailable.', ['code' => 'FACE_SERVICE_UNAVAILABLE'], 503);
        }

return ApiResponse::error('Face verification is not available.', ['code' => 'FACE_VERIFICATION_UNSUPPORTED'], 503);
    }

    public function manual(ManualVerificationRequest $request)
    {
        $this->guard();
        $student = Student::findOrFail($request->validated('student_id'));
        $event = $this->security->transaction(auth()->user(), $student, 'manual', $request->validated('reason'));

        return ApiResponse::created(['id' => $event->id, 'action' => $event->action, 'state' => $event->action === 'entry' ? 'INSIDE' : 'OUTSIDE', 'verification_method' => 'manual', 'event_at' => $event->event_at?->toIso8601String()], 'Manual verification recorded.');
    }
}
