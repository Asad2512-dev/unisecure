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
use App\Models\StudentFaceProfile;
use App\Models\User;
use App\Models\Visitor;
use App\Services\CampusSecurityService;
use App\Services\FaceVerificationService;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class SecurityWorkflowTest extends TestCase
{
    public function test_guard_workspace_renders_and_history_is_scoped_to_the_guard(): void
    {
        [$user,$guard] = $this->guard();
        [$otherUser] = $this->guard();
        $student = $this->student();
        app(CampusSecurityService::class)->transaction($otherUser, $student, 'manual', 'Identity confirmed');
        $this->actingAs($user)->get('/security')->assertOk()->assertSee('Student verification');
        $this->get('/security?q='.$student->student_id)->assertOk()->assertSee($student->student_id);
        $this->get('/security/transactions')->assertOk()->assertDontSee($student->student_id);
        $this->get('/security/profile')->assertOk()->assertSee($guard->employee_id);
        $this->get('/security/visitors')->assertOk()->assertSee('Check in a visitor');
    }

    public function test_visitor_phone_search_does_not_expose_another_gate(): void
    {
        [$user,$guard] = $this->guard();
        [$otherUser,$otherGuard] = $this->guard();
        Visitor::create(['name' => 'Private visitor', 'phone' => '555123456', 'purpose' => 'Meeting', 'gate_id' => $otherGuard->gate_id, 'guard_id' => $otherGuard->id, 'entry_at' => now(), 'status' => 'active']);
        $this->actingAs($user)->get('/security/visitors?q=555123456')->assertOk()->assertDontSee('Private visitor');
    }

    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_unconfigured_face_provider_is_unavailable(): void
    {
        $service = app(FaceVerificationService::class);
        $this->assertFalse($service->available());
        $this->assertSame('FACE_SERVICE_UNAVAILABLE', $service->verify('opaque-capture', new StudentFaceProfile(['student_id' => 1, 'provider' => 'none']))->code);
    }

    private function student(): Student
    {
        $d = Department::create(['name' => 'Security', 'code' => 'SEC'.uniqid(), 'status' => 'active']);
        $p = Program::create(['department_id' => $d->id, 'name' => 'Security Studies', 'code' => 'SS'.uniqid(), 'duration_years' => 4, 'status' => 'active']);
        $sem = Semester::create(['name' => 'Fall', 'number' => 1, 'academic_year' => '2026-2027', 'status' => 'active']);
        $sec = Section::create(['program_id' => $p->id, 'semester_id' => $sem->id, 'name' => 'A', 'code' => 'S'.uniqid(), 'status' => 'active']);
        $u = User::factory()->create(['role_id' => Role::where('name', 'student')->value('id')]);

        return Student::create(['user_id' => $u->id, 'student_id' => 'ST'.uniqid(), 'department_id' => $d->id, 'program_id' => $p->id, 'semester_id' => $sem->id, 'section_id' => $sec->id, 'official_email' => $u->email, 'status' => 'active']);
    }

    private function guard(): array
    {
        $gate = Gate::create(['name' => 'Main', 'code' => 'G'.uniqid(), 'status' => 'active']);
        $u = User::factory()->create(['role_id' => Role::where('name', 'guard')->value('id')]);
        $guard = Guard::create(['user_id' => $u->id, 'employee_id' => 'G'.uniqid(), 'gate_id' => $gate->id, 'status' => 'active']);

        return [$u, $guard, $gate];
    }

    public function test_manual_transaction_derives_entry_then_exit_and_rejects_cooldown(): void
    {
        $student = $this->student();
        [$user,$guard] = $this->guard();
        $service = app(CampusSecurityService::class);
        Carbon::setTestNow('2026-01-01 10:00:00');
        $entry = $service->transaction($user, $student, 'manual', 'Face provider unavailable');
        $this->assertSame('entry', $entry->action);
        Carbon::setTestNow('2026-01-01 10:11:00');
        $exit = $service->transaction($user, $student, 'manual', 'Manual check');
        $this->assertSame('exit', $exit->action);
        Carbon::setTestNow();
    }

    public function test_duplicate_cooldown_is_enforced(): void
    {
        $student = $this->student();
        [$user] = $this->guard();
        Carbon::setTestNow('2026-01-01 10:00:00');
        app(CampusSecurityService::class)->transaction($user, $student, 'manual', 'first');
        Carbon::setTestNow('2026-01-01 10:00:05');
        $this->expectException(ValidationException::class);
        app(CampusSecurityService::class)->transaction($user, $student, 'manual', 'duplicate');
        Carbon::setTestNow();
    }

    public function test_nonsensical_verification_method_is_rejected(): void
    {
        $student = $this->student();
        [$user] = $this->guard();
        $this->expectException(ValidationException::class);
        app(CampusSecurityService::class)->transaction($user, $student, 'nfc', 'client supplied');
    }

    public function test_inactive_guard_cannot_transact(): void
    {
        $student = $this->student();
        [$user,$guard] = $this->guard();
        $guard->update(['status' => 'inactive']);
        $this->expectException(HttpException::class);
        app(CampusSecurityService::class)->transaction($user, $student, 'manual', 'reason');
    }
}
