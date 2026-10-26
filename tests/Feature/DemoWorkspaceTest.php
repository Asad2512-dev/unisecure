<?php

namespace Tests\Feature;

use App\Models\ClassSession;
use App\Models\User;
use Database\Seeders\DemoWorkspaceSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class DemoWorkspaceTest extends TestCase
{
    use RefreshDatabase;

    public function test_teacher_can_select_attendance_but_cannot_change_finalized_sessions(): void
    {
        $this->seed(DemoWorkspaceSeeder::class);
        $teacher = User::where('email', 'teacher@gmail.com')->firstOrFail();
        $student = User::where('email', 'student@gmail.com')->firstOrFail()->student;
        $session = ClassSession::where('teacher_id', $teacher->teacher->id)->where('status', 'open')->firstOrFail();
        foreach (['present', 'absent', 'late'] as $status) {
            $this->actingAs($teacher)->post('/teacher/attendance/'.$session->id.'/mark', ['student_id' => $student->id, 'status' => $status])->assertRedirect()->assertSessionHasNoErrors();
            $this->assertDatabaseHas('attendance_records', ['class_session_id' => $session->id, 'student_id' => $student->id, 'status' => $status]);
        }
        $other = User::factory()->create(['role_id' => $teacher->role_id, 'status' => 'active']);
        $this->actingAs($other)->post('/teacher/attendance/'.$session->id.'/mark', ['student_id' => $student->id, 'status' => 'absent'])->assertForbidden();
        $session->update(['finalized_at' => now(), 'status' => 'closed']);
        $this->actingAs($teacher)->post('/teacher/attendance/'.$session->id.'/mark', ['student_id' => $student->id, 'status' => 'present'])->assertSessionHasErrors('session');
        $this->assertDatabaseHas('attendance_records', ['class_session_id' => $session->id, 'student_id' => $student->id, 'status' => 'late']);
        $this->assertDatabaseHas('audit_logs', ['user_id' => $teacher->id, 'action' => 'attendance.manually_selected']);
    }

    public function test_demo_seed_is_repeatable_and_populates_role_workflows(): void
    {
        $this->seed(DemoWorkspaceSeeder::class);
        $tables = ['users', 'departments', 'programs', 'semesters', 'sections', 'rooms', 'gates', 'teachers', 'guards', 'students', 'courses', 'course_enrollments', 'class_schedules', 'class_sessions', 'attendance_records', 'entry_exit_logs', 'visitors', 'student_face_profiles', 'nfc_cards', 'device_tokens', 'notifications', 'notification_deliveries', 'audit_logs'];
        $counts = collect($tables)->mapWithKeys(fn ($table) => [$table => DB::table($table)->count()])->all();
        $this->seed(DemoWorkspaceSeeder::class);
        foreach ($counts as $table => $count) {
            $this->assertGreaterThan(0, $count, $table);
            $this->assertDatabaseCount($table, $count);
        }
        $teacher = User::where('email', 'teacher@gmail.com')->firstOrFail();
        $this->actingAs($teacher)->get('/teacher')->assertOk()->assertSee('Programming Fundamentals');
        $live = ClassSession::where('teacher_id', $teacher->teacher->id)->where('status', 'open')->firstOrFail();
        $this->get('/teacher/attendance/'.$live->id)->assertOk()->assertSee('Faizan Khan');
        $student = User::where('email', 'student@gmail.com')->firstOrFail();
        $this->post('/teacher/attendance/'.$live->id.'/mark', ['student_id' => $student->student->id])->assertRedirect();
        $this->assertDatabaseHas('attendance_records', ['class_session_id' => $live->id, 'student_id' => $student->student->id]);
        foreach (['courses', 'timetable', 'attendance', 'access', 'notifications'] as $page) {
            $this->actingAs($student)->get('/student/'.$page)->assertOk();
        }
        $guard = User::where('email', 'guard@gmail.com')->firstOrFail();
        $this->actingAs($guard)->get('/security?q='.$student->student->student_id)->assertOk()->assertSee('Faizan Khan');
        $this->get('/security/visitors')->assertOk()->assertSee('Ayesha Visitor');
        $this->get('/security/transactions')->assertOk();
        $admin = User::where('email', 'admin@gmail.com')->firstOrFail();
        $this->actingAs($admin)->get('/admin')->assertOk();
    }
}
