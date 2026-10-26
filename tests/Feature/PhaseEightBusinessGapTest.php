<?php

namespace Tests\Feature;

use App\Models\AttendanceRecord;
use App\Models\ClassSchedule;
use App\Models\ClassSession;
use App\Models\Course;
use App\Models\CourseEnrollment;
use App\Models\Department;
use App\Models\Program;
use App\Models\Role;
use App\Models\Room;
use App\Models\Section;
use App\Models\Semester;
use App\Models\Student;
use App\Models\SystemSetting;
use App\Models\Teacher;
use App\Models\User;
use App\Services\AttendanceReportService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PhaseEightBusinessGapTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    private function academicFixture(): array
    {
        $department = Department::create(['name' => 'Engineering', 'code' => 'ENG', 'status' => 'active']);
        $program = Program::create(['department_id' => $department->id, 'name' => 'Computer Science', 'code' => 'CS', 'duration_years' => 4, 'status' => 'active']);
        $semester = Semester::create(['name' => 'Fall', 'number' => 1, 'academic_year' => '2026-2027', 'status' => 'active']);
        $section = Section::create(['program_id' => $program->id, 'semester_id' => $semester->id, 'name' => 'A', 'code' => 'CSA', 'status' => 'active']);
        $room = Room::create(['name' => 'Room 1', 'building' => 'Main', 'capacity' => 40, 'status' => 'active']);
        $course = Course::create(['department_id' => $department->id, 'course_code' => 'CS101', 'name' => 'Foundations', 'credit_hours' => 3, 'status' => 'active']);
        $teacherUser = User::factory()->create(['role_id' => Role::where('name', 'teacher')->value('id')]);
        $teacher = Teacher::create(['user_id' => $teacherUser->id, 'employee_id' => 'T-1', 'department_id' => $department->id, 'official_email' => 'teacher@test', 'status' => 'active']);
        $studentUser = User::factory()->create(['role_id' => Role::where('name', 'student')->value('id')]);
        $student = Student::create(['user_id' => $studentUser->id, 'student_id' => 'S-1', 'department_id' => $department->id, 'program_id' => $program->id, 'semester_id' => $semester->id, 'section_id' => $section->id, 'official_email' => 'student@test', 'status' => 'active']);
        CourseEnrollment::create(['student_id' => $student->id, 'course_id' => $course->id, 'section_id' => $section->id, 'academic_year' => '2026-2027', 'semester_id' => $semester->id, 'status' => 'active']);
        $schedule = ClassSchedule::create(['course_id' => $course->id, 'teacher_id' => $teacher->id, 'section_id' => $section->id, 'room_id' => $room->id, 'day_of_week' => 1, 'start_time' => '09:00', 'end_time' => '10:00', 'grace_period_minutes' => 20, 'status' => 'active', 'academic_year' => '2026-2027', 'semester_id' => $semester->id]);

        return compact('department', 'program', 'semester', 'section', 'room', 'course', 'teacher', 'student', 'schedule');
    }

    private function makeSession(array $f, string $date, string $status = 'scheduled', bool $finalized = true): ClassSession
    {
        $start = $date.' 09:00:00';
        $end = $date.' 10:00:00';

        return ClassSession::create(['schedule_id' => $f['schedule']->id, 'course_id' => $f['course']->id, 'teacher_id' => $f['teacher']->id, 'section_id' => $f['section']->id, 'room_id' => $f['room']->id, 'session_date' => $date, 'scheduled_start_at' => $start, 'scheduled_end_at' => $end, 'attendance_open_at' => $start, 'attendance_close_at' => $end, 'status' => $status, 'finalized_at' => $finalized ? now() : null]);
    }

    public function test_reporting_counts_only_eligible_finalized_sessions_and_respects_late_setting(): void
    {
        $f = $this->academicFixture();
        $present = $this->makeSession($f, '2026-10-01');
        $late = $this->makeSession($f, '2026-10-02');
        $absent = $this->makeSession($f, '2026-10-03');
        $cancelled = $this->makeSession($f, '2026-10-04', 'cancelled');
        $open = $this->makeSession($f, '2026-10-05', 'open', false);
        AttendanceRecord::create(['class_session_id' => $present->id, 'student_id' => $f['student']->id, 'status' => 'present', 'marked_at' => now(), 'source' => 'teacher']);
        AttendanceRecord::create(['class_session_id' => $late->id, 'student_id' => $f['student']->id, 'status' => 'late', 'marked_at' => now(), 'source' => 'teacher']);
        AttendanceRecord::create(['class_session_id' => $absent->id, 'student_id' => $f['student']->id, 'status' => 'absent', 'marked_at' => now(), 'source' => 'system']);
        AttendanceRecord::create(['class_session_id' => $cancelled->id, 'student_id' => $f['student']->id, 'status' => 'present', 'marked_at' => now(), 'source' => 'teacher']);
        $service = app(AttendanceReportService::class);
        $withLate = $service->studentSummary($f['student'], '2026-10-01', '2026-10-03');
        $this->assertSame(3, $withLate['eligible_sessions']);
        $this->assertSame(1, $withLate['present']);
        $this->assertSame(1, $withLate['late']);
        $this->assertSame(1, $withLate['absent']);
        $this->assertSame(2, $withLate['attended']);
        $this->assertSame(66.67, $withLate['percentage']);
        SystemSetting::where('key', 'late_counts_as_attended')->update(['value' => 'false']);
        $withoutLate = $service->studentSummary($f['student'], '2026-10-01', '2026-10-03');
        $this->assertSame(1, $withoutLate['attended']);
        $this->assertSame(33.33, $withoutLate['percentage']);
        $this->assertSame(1, $service->studentSummary($f['student'], '2026-10-02', '2026-10-02')['eligible_sessions']);
        $this->assertSame(0, $service->studentSummary($f['student'], '2030-01-01', '2030-01-02')['eligible_sessions']);
    }

    public function test_reminder_command_is_idempotent_and_skips_cancelled_sessions(): void
    {
        $f = $this->academicFixture();
        $start = now()->addMinutes(10);
        $date = $start->toDateString();
        $session = $this->makeSession($f, $date);
        $session->update(['scheduled_start_at' => $start, 'scheduled_end_at' => $start->copy()->addHour(), 'attendance_open_at' => $start, 'attendance_close_at' => $start->copy()->addHour()]);
        SystemSetting::updateOrCreate(['key' => 'class_reminder_lead_minutes'], ['value' => '15', 'type' => 'integer']);
        $this->artisan('notifications:class-reminders')->assertExitCode(0);
        $this->assertDatabaseCount('notifications', 1);
        $this->artisan('notifications:class-reminders')->assertExitCode(0);
        $this->assertDatabaseCount('notifications', 1);
        $cancelled = $this->makeSession($f, $start->copy()->addDay()->toDateString(), 'cancelled');
        $cancelled->update(['scheduled_start_at' => $start->copy()->addMinutes(5), 'scheduled_end_at' => $start->copy()->addMinutes(65)]);
        $this->artisan('notifications:class-reminders')->assertExitCode(0);
        $this->assertDatabaseCount('notifications', 1);
    }

    public function test_no_qualifying_reminders_is_harmless_and_analytics_requires_admin(): void
    {
        $this->artisan('notifications:class-reminders')->assertExitCode(0);
        $this->assertDatabaseCount('notifications', 0);
        $this->get('/admin/reports/analytics')->assertRedirect('/login');
        $student = User::factory()->create(['role_id' => Role::where('name', 'student')->value('id')]);
        $this->actingAs($student)->get('/admin/reports/analytics')->assertForbidden();
    }

    public function test_analytics_uses_exact_persisted_finalized_non_cancelled_counts(): void
    {
        $f = $this->academicFixture();
        $included = $this->makeSession($f, '2026-10-10');
        $this->makeSession($f, '2026-10-11', 'cancelled');
        $this->makeSession($f, '2026-10-12', 'open', false);
        AttendanceRecord::create(['class_session_id' => $included->id, 'student_id' => $f['student']->id, 'status' => 'present', 'marked_at' => now(), 'source' => 'teacher']);
        $admin = User::factory()->create(['role_id' => Role::where('name', 'admin')->value('id')]);
        $response = $this->actingAs($admin)->get('/admin/reports/analytics?from=2026-10-10&to=2026-10-12')->assertOk();
        $response->assertViewHas('stats',fn ($stats) => $stats['sessions'] === 1 && $stats['attendance']->get('present') === 1 && $stats['attendance']->get('absent',0) === 0);
    }
}
