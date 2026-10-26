@php($locked = $session->finalized_at || in_array($session->status, ['cancelled','closed']) || now()->lt($session->scheduled_start_at) || now()->gt($session->scheduled_end_at))
<form method="POST" action="{{ route(auth()->user()->isAdmin() ? 'admin.attendance.mark' : 'teacher.attendance.mark', $session) }}" class="flex flex-wrap gap-2" data-confirm-title="Confirm attendance" data-confirm="Save the selected attendance status for {{ $student->user?->name }}?">
    @csrf
    <input type="hidden" name="student_id" value="{{ $student->id }}">
    @foreach(['present' => ['Present', 'attendance-present'], 'absent' => ['Absent', 'attendance-absent'], 'late' => ['Late', 'attendance-late']] as $status => [$label, $tone])
        <button type="submit" name="status" value="{{ $status }}" @disabled($locked) aria-pressed="{{ $record?->status === $status ? 'true' : 'false' }}" class="attendance-choice {{ $tone }}" title="{{ $locked ? 'Attendance is locked or outside the class window' : 'Mark as '.$label }}">@if($record?->status === $status)<span aria-hidden="true">✓</span>@endif {{ $label }}</button>
    @endforeach
</form>
