<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\Gate;
use App\Models\Guard;
use App\Models\Program;
use App\Models\Role;
use App\Models\Section;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class PhaseNineIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    private function guardFixture(): array
    {
        $department = Department::create(['name' => 'Science', 'code' => 'SCI', 'status' => 'active']);
        $program = Program::create(['department_id' => $department->id, 'name' => 'Physics', 'code' => 'PHY', 'duration_years' => 4, 'status' => 'active']);
        $semester = Semester::create(['name' => 'Spring', 'number' => 2, 'academic_year' => '2026-2027', 'status' => 'active']);
        $section = Section::create(['program_id' => $program->id, 'semester_id' => $semester->id, 'name' => 'B', 'code' => 'PHYB', 'status' => 'active']);
        $gate = Gate::create(['name' => 'North Gate', 'code' => 'NORTH', 'status' => 'active']);
        $guardUser = User::factory()->create(['role_id' => Role::where('name', 'guard')->value('id')]);
        $guard = Guard::create(['user_id' => $guardUser->id, 'employee_id' => 'G-1', 'gate_id' => $gate->id, 'status' => 'active']);
        $studentUser = User::factory()->create(['role_id' => Role::where('name', 'student')->value('id')]);
        $student = Student::create(['user_id' => $studentUser->id, 'student_id' => 'PHY-1', 'department_id' => $department->id, 'program_id' => $program->id, 'semester_id' => $semester->id, 'section_id' => $section->id, 'official_email' => 'phy@test', 'status' => 'active']);

        return compact('guardUser', 'guard', 'student', 'gate');
    }

    public function test_guard_manual_workflow_derives_entry_and_exit_and_face_is_unavailable(): void
    {
        $f = $this->guardFixture();
        $api = $this->actingAs($f['guardUser'], 'sanctum');
        $api->postJson('/api/v1/guard/security/face', ['capture' => 'not-a-face'])->assertStatus(503)->assertJsonPath('errors.code', 'FACE_SERVICE_UNAVAILABLE');
        $this->assertDatabaseCount('entry_exit_logs', 0);
        $api->getJson('/api/v1/guard/students/search?q=PHY-1')->assertOk()->assertJsonPath('data.items.0.student_id', 'PHY-1');
        $api->postJson('/api/v1/guard/security/manual', ['student_id' => $f['student']->id, 'confirmed' => 'yes', 'reason' => 'Identity checked at gate'])->assertCreated()->assertJsonPath('data.action', 'entry');
        $api->postJson('/api/v1/guard/security/manual', ['student_id' => $f['student']->id, 'confirmed' => 'yes', 'reason' => 'Identity checked at gate'])->assertStatus(422);
        DB::table('entry_exit_logs')->where('student_id', $f['student']->id)->update(['event_at' => now()->subSeconds(11)]);
        $api->postJson('/api/v1/guard/security/manual', ['student_id' => $f['student']->id, 'confirmed' => 'yes', 'reason' => 'Exit identity checked'])->assertCreated()->assertJsonPath('data.action', 'exit');
        $this->assertDatabaseCount('entry_exit_logs', 2);
    }

    public function test_guard_cannot_use_another_gate_or_inactive_student_and_visitor_is_gate_scoped(): void
    {
        $f = $this->guardFixture();
        $otherGate = Gate::create(['name' => 'South Gate', 'code' => 'SOUTH', 'status' => 'inactive']);
        $f['guard']->update(['gate_id' => $otherGate->id]);
        $api = $this->actingAs($f['guardUser'], 'sanctum');
        $api->postJson('/api/v1/guard/security/manual', ['student_id' => $f['student']->id, 'confirmed' => 'yes', 'reason' => 'checked'])->assertForbidden();
        $f['guard']->update(['gate_id' => $f['gate']->id]);
        $f['student']->update(['status' => 'inactive']);
        $api->postJson('/api/v1/guard/security/manual', ['student_id' => $f['student']->id, 'confirmed' => 'yes', 'reason' => 'checked'])->assertUnprocessable();
        $api->postJson('/api/v1/guard/visitors', ['name' => 'Visitor', 'phone' => '03000000000', 'purpose' => 'Meeting'])->assertCreated();
        $this->assertDatabaseHas('visitors', ['gate_id' => $f['gate']->id, 'status' => 'active']);
    }

    public function test_role_boundaries_and_api_validation_are_enforced(): void
    {
        $student = User::factory()->create(['role_id' => Role::where('name', 'student')->value('id')]);
        $teacher = User::factory()->create(['role_id' => Role::where('name', 'teacher')->value('id')]);
        $this->actingAs($student, 'sanctum')->getJson('/api/v1/teacher/profile')->assertForbidden();
        $this->actingAs($teacher, 'sanctum')->getJson('/api/v1/guard/profile')->assertForbidden();
        $this->actingAs($student, 'sanctum')->postJson('/api/v1/device-tokens',['platform' => 'android'])->assertUnprocessable()->assertJsonPath('success',false);
    }
}
