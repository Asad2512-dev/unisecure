@php($academicRole = auth()->user()->hasRole('teacher') ? 'teacher' : 'student')
<div class="mb-8 flex flex-wrap gap-2 rounded-2xl border border-slate-200/70 bg-white p-2 shadow-sm" role="navigation" aria-label="Academic workspace">
@foreach(['overview'=>'Overview', 'courses'=>'Courses', 'timetable'=>'Timetable', 'sessions'=>'Class sessions', 'attendance'=>'Attendance', 'notifications'=>'Notifications', 'access'=>'Campus access', 'profile'=>'My profile'] as $key=>$label)
@continue($academicRole === 'teacher' && in_array($key, ['sessions','access']))
@php($target = $key === 'overview' ? route($academicRole.'.home') : ($academicRole === 'teacher' && $key === 'attendance' ? route('teacher.attendance.sessions') : route($academicRole.'.workspace', $key)))
@php($selected = ($page ?? 'attendance') === $key)
<a href="{{ $target }}" @if($selected) aria-current="page" @endif class="rounded-xl px-4 py-2.5 text-xs font-bold transition {{ $selected ? 'bg-brand-navy text-white shadow-sm' : 'text-slate-500 hover:bg-indigo-50 hover:text-brand-teal' }}">{{ $label }}</a>
@endforeach
</div>
