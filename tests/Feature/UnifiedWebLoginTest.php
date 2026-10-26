<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class UnifiedWebLoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_academic_workspaces_render_and_enforce_role_boundaries(): void
    {
        foreach (['teacher', 'student'] as $role) {
            $record = Role::create(['name' => $role, 'display_name' => ucfirst($role)]);
            $user = User::factory()->create(['role_id' => $record->id, 'status' => 'active']);
            $this->actingAs($user)->get('/'.$role)->assertOk()->assertSee('Your campus, at a glance');
            foreach (['courses', 'timetable', 'profile', 'notifications'] as $page) {
                $this->get($role === 'teacher' ? '/teacher/workspace/'.$page : '/student/'.$page)->assertOk();
            }
            $this->get($role === 'teacher' ? '/student' : '/teacher')->assertForbidden();
        }
        foreach (['attendance', 'access', 'sessions'] as $page) {
            $this->get('/student/'.$page)->assertOk();
        }
        $this->get('/student/not-a-page')->assertNotFound();
    }

    public function test_notifications_are_private_and_can_be_marked_as_read(): void
    {
        $role = Role::create(['name' => 'student', 'display_name' => 'Student']);
        $owner = User::factory()->create(['role_id' => $role->id]);
        $other = User::factory()->create(['role_id' => $role->id]);
        $id = (string) Str::uuid();
        $otherId = (string) Str::uuid();
        foreach ([$id => $owner, $otherId => $other] as $notificationId => $user) {
            $user->notifications()->create(['id' => $notificationId, 'type' => 'test', 'data' => ['title' => $user->id === $owner->id ? 'My notification' : 'Private notification']]);
        }
        $this->actingAs($owner)->get('/student/notifications')->assertOk()->assertSee('My notification')->assertDontSee('Private notification');
        $this->post('/workspace/notifications/'.$otherId.'/read')->assertNotFound();
        $this->post('/workspace/notifications/'.$id.'/read')->assertRedirect();
        $this->assertNotNull($owner->notifications()->findOrFail($id)->read_at);
        $this->assertNull($other->notifications()->findOrFail($otherId)->read_at);
    }

    public function test_all_roles_can_sign_in_and_sign_out(): void
    {
        foreach (['admin' => '/admin', 'teacher' => '/teacher', 'guard' => '/security', 'student' => '/student'] as $role => $path) {
            $record = Role::create(['name' => $role, 'display_name' => ucfirst($role)]);
            $user = User::factory()->create(['role_id' => $record->id, 'status' => 'active']);
            $this->withSession(['url.intended' => '/admin/resource/users'])->post('/login', ['email' => $user->email, 'password' => 'password'])->assertRedirect($path);
            $this->assertAuthenticatedAs($user);
            $this->get('/login')->assertRedirect($path);
            if ($role === 'teacher' || $role === 'student') {
                $this->get($path)->assertOk()->assertDontSee('Campus command center');
                $this->get('/admin')->assertForbidden();
            }
            $this->post('/logout')->assertRedirect('/login');
            $this->assertGuest();
        }
    }

    public function test_inactive_accounts_and_wrong_passwords_cannot_sign_in(): void
    {
        $role = Role::create(['name' => 'student', 'display_name' => 'Student']);
        $user = User::factory()->create(['role_id' => $role->id, 'status' => 'inactive']);
        $this->from('/login')->post('/login', ['email' => $user->email, 'password' => 'password'])->assertSessionHasErrors('email');
        $this->assertGuest();
        $user->update(['status' => 'active']);
        $this->from('/login')->post('/login', ['email' => $user->email, 'password' => 'incorrect'])->assertSessionHasErrors('email');
        $this->assertGuest();
    }

    public function test_legacy_login_redirects_to_the_shared_page(): void
    {
        $this->get('/admin/login')->assertRedirect('/login');
        $this->get('/login')->assertOk()->assertSee('Your role determines your workspace.');
    }
}
