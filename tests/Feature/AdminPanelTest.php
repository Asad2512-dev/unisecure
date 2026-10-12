<?php
namespace Tests\Feature;

use App\Models\{Department,Role,User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPanelTest extends TestCase
{
    use RefreshDatabase;
    private function admin(): User { return User::factory()->create(['role_id'=>Role::where('name','admin')->firstOrFail()->id]); }

    protected function setUp(): void { parent::setUp(); $this->seed(); }

    public function test_guest_is_redirected_from_admin_panel(): void { $this->get('/admin')->assertRedirect('/login'); }

    public function test_non_admin_cannot_access_admin_panel(): void { $user=User::factory()->create(['role_id'=>Role::where('name','student')->firstOrFail()->id]); $this->actingAs($user)->get('/admin')->assertForbidden(); }

    public function test_authorized_admin_can_create_department_through_panel(): void
    {
        $response=$this->actingAs($this->admin())->post('/admin/resource/departments',['name'=>'Computer Science','code'=>'CS','status'=>'active']);
        $response->assertRedirect();
        // The redirect is asserted above; persistence is the acceptance check below.
        $this->assertDatabaseHas('departments',['code'=>'CS','name'=>'Computer Science']);
    }

    public function test_duplicate_department_code_is_rejected(): void
    {
        Department::create(['name'=>'Existing','code'=>'CS','status'=>'active']);
        $response=$this->actingAs($this->admin())->post('/admin/resource/departments',['name'=>'Duplicate','code'=>'CS','status'=>'active']);
        $response->assertSessionHasErrors();
    }
}
