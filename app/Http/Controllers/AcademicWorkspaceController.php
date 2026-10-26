<?php

namespace App\Http\Controllers;

use App\Models\ClassSchedule;
use App\Models\ClassSession;
use Illuminate\Http\Request;

class AcademicWorkspaceController extends Controller
{
    public function index(Request $request, string $page = 'overview')
    {
        $teacher = $request->user()->hasRole('teacher');
        $role = $teacher ? 'teacher' : 'student';
        $allowed = ['overview', 'courses', 'timetable', 'profile', 'notifications'];
        if (! $teacher) {
            $allowed = [...$allowed, 'attendance', 'access', 'sessions'];
        }
        abort_unless(in_array($page, $allowed, true), 404);
        $profile = $teacher
            ? $request->user()->teacher()->with(['department', 'user'])->first()
            : $request->user()->student()->with(['department', 'program', 'semester', 'section', 'user'])->first();
        $schedules = ClassSchedule::with(['course', 'teacher.user', 'section', 'room'])
            ->where('status', 'active');
        $sessions = ClassSession::with(['course', 'teacher.user', 'section', 'room']);
        if ($teacher) {
            $schedules->where('teacher_id', $profile?->id ?? 0);
            $sessions->where('teacher_id', $profile?->id ?? 0);
        } else {
            $courseIds = $profile?->enrollments()->whereIn('status', ['active', 'completed'])->pluck('course_id') ?? collect();
            $schedules->where('section_id', $profile?->section_id ?? 0)->where('semester_id', $profile?->semester_id ?? 0)->whereIn('course_id', $courseIds);
            $sessions->where('section_id', $profile?->section_id ?? 0)->whereIn('course_id', $courseIds);
        }
        if ($profile && $profile->status !== 'active') {
            abort(403, 'An active academic profile is required.');
        }
        $stats = [
            'Active schedules' => (clone $schedules)->count(),
            'Upcoming sessions' => (clone $sessions)->whereDate('session_date', '>=', today())->whereIn('status', ['scheduled', 'open'])->count(),
            'Unread notifications' => $request->user()->unreadNotifications()->count(),
        ];
        $records = null;
        $rows = [];
        if ($page === 'courses') {
            if ($teacher) {
                $records = (clone $schedules)->orderBy('day_of_week')->paginate(12)->withQueryString();
                $rows = $records->getCollection()->map(fn ($item) => ['title' => $item->course?->name ?? 'Course', 'subtitle' => $item->course?->course_code, 'details' => ['Section' => $item->section?->code, 'Room' => $item->room?->name, 'Status' => ucfirst($item->status)]]);
            } else {
                $records = $profile?->enrollments()->with(['course', 'section', 'semester'])->latest()->paginate(12)->withQueryString();
                $rows = $records?->getCollection()->map(fn ($item) => ['title' => $item->course?->name ?? 'Course', 'subtitle' => $item->course?->course_code, 'details' => ['Section' => $item->section?->code, 'Academic year' => $item->academic_year, 'Status' => ucfirst($item->status)]]) ?? [];
            }
        } elseif ($page === 'attendance') {
            $records = $profile?->attendanceRecords()->with('session.course')->latest('marked_at')->paginate(15)->withQueryString();
            $rows = $records?->getCollection()->map(fn ($item) => ['title' => $item->session?->course?->name ?? 'Class session', 'subtitle' => $item->session?->session_date?->format('M j, Y'), 'details' => ['Status' => ucfirst($item->status), 'Marked at' => $item->marked_at?->format('M j, g:i A'), 'Course' => $item->session?->course?->course_code]]) ?? [];
        } elseif ($page === 'access') {
            $records = $profile?->entryExitLogs()->with('gate')->latest('event_at')->paginate(15)->withQueryString();
            $rows = $records?->getCollection()->map(fn ($item) => ['title' => ucfirst($item->action), 'subtitle' => $item->event_at?->format('M j, Y · g:i A'), 'details' => ['Gate' => $item->gate?->name, 'Verification' => ucfirst($item->verification_method)]]) ?? [];
        } elseif ($page === 'notifications') {
            $records = $request->user()->notifications()->latest()->paginate(15)->withQueryString();
        } elseif ($page === 'sessions') {
            $records = $sessions->latest('session_date')->paginate(15)->withQueryString();
            $rows = $records->getCollection()->map(fn ($item) => ['title' => $item->course?->name ?? 'Session', 'subtitle' => $item->session_date?->format('M j, Y'), 'details' => ['Starts' => $item->scheduled_start_at?->format('g:i A'), 'Room' => $item->room?->name, 'Status' => ucfirst($item->status)]]);
        }
        $timetable = $page === 'timetable' ? $schedules->orderBy('day_of_week')->orderBy('start_time')->get()->groupBy('day_of_week') : collect();
        $upcoming = $page === 'overview' ? $sessions->whereDate('session_date', '>=', today())->whereIn('status', ['scheduled', 'open'])->orderBy('scheduled_start_at')->limit(5)->get() : collect();
        $title = match ($page) {
            'overview' => 'Your campus, at a glance',
            'courses' => $teacher ? 'Teaching assignments' : 'My courses',
            'timetable' => 'Weekly timetable',
            'profile' => 'My profile',
            'notifications' => 'Notifications',
            'attendance' => 'My attendance',
            'access' => 'Campus access history',
            'sessions' => 'My class sessions',
        };

        return view('academic.workspace', compact('role', 'page', 'profile', 'teacher', 'stats', 'records', 'rows', 'timetable', 'upcoming', 'title'));
    }

    public function readNotification(Request $request, string $notification)
    {
        $request->user()->notifications()->findOrFail($notification)->markAsRead();

        return back()->with('status', 'Notification marked as read.');
    }

    public function readAll(Request $request)
    {
        $request->user()->unreadNotifications()->update(['read_at' => now()]);

        return back()->with('status', 'All notifications marked as read.');
    }
}
