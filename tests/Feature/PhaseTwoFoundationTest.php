<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class PhaseTwoFoundationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_required_roles_and_permissions_are_seeded(): void
    {
        $this->assertSame(4, Role::count());
        $this->assertGreaterThanOrEqual(10, Permission::count());
        $this->assertSame(11, Role::where('name', 'admin')->firstOrFail()->permissions()->count());
    }

    public function test_user_role_and_student_relationships_are_available(): void
    {
        $role = Role::where('name', 'student')->firstOrFail();
        $user = User::factory()->create(['role_id' => $role->id]);
        $department = Department::create(['name' => 'Engineering', 'code' => 'ENG', 'status' => 'active']);
        $program = $department->programs()->create(['name' => 'Computer Science', 'code' => 'CS', 'duration_years' => 4, 'status' => 'active']);
        $this->assertTrue($user->hasRole('student'));
        $this->assertSame($role->id, $user->role->id);
        $this->assertSame($department->id, $program->department->id);
    }

    public function test_unique_role_identifier_is_database_enforced(): void
    {
        $this->expectException(QueryException::class);
        Role::create(['name' => 'admin', 'display_name' => 'Duplicate']);
    }

    public function test_otp_is_not_part_of_phase_two_schema(): void
    {
        $this->assertFalse(Schema::hasTable('otp_verifications'));
    }
}
