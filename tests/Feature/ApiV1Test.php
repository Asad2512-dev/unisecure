<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ApiV1Test extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_login_issues_sanctum_token_without_exposing_password(): void
    {
        $role = Role::where('name', 'student')->firstOrFail();
        $user = User::factory()->create(['role_id' => $role->id, 'email' => 'mobile@example.test', 'password' => Hash::make('correct-password-123')]);
        $response = $this->postJson('/api/v1/auth/login', ['email' => $user->email, 'password' => 'correct-password-123']);
        $response->assertOk()->assertJsonPath('success', true)->assertJsonMissing(['password' => $user->password]);
        $this->assertNotEmpty($response->json('data.token'));
    }

    public function test_protected_api_rejects_guests(): void
    {
        $this->getJson('/api/v1/me')->assertUnauthorized();
    }

    public function test_student_cannot_access_teacher_api(): void
    {
        $role = Role::where('name', 'student')->firstOrFail();
        $user = User::factory()->create(['role_id' => $role->id]);
        $this->actingAs($user, 'sanctum')->getJson('/api/v1/teacher/profile')->assertForbidden();
    }

    public function test_me_returns_safe_role_profile(): void
    {
        $role = Role::where('name', 'student')->firstOrFail();
        $user = User::factory()->create(['role_id' => $role->id]);
        $this->actingAs($user, 'sanctum')->getJson('/api/v1/me')->assertOk()->assertJsonPath('data.user.role', 'student')->assertJsonMissingPath('data.user.password');
    }
}
