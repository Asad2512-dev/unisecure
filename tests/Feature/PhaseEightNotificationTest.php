<?php

namespace Tests\Feature;

use App\Models\{AuditLog,DeviceToken,NotificationDelivery,Role,User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PhaseEightNotificationTest extends TestCase
{
    use RefreshDatabase;
    protected function setUp(): void { parent::setUp(); $this->seed(); }

    private function user(string $role='student'): User
    { return User::factory()->create(['role_id'=>Role::where('name',$role)->value('id'),'status'=>'active']); }

    public function test_device_token_lifecycle_is_owner_bound_and_safe(): void
    {
        $owner=$this->user(); $other=$this->user(); $value=str_repeat('a',32);
        $this->actingAs($owner,'sanctum')->postJson('/api/v1/device-tokens',['token'=>$value,'platform'=>'android'])->assertCreated()->assertJsonMissing(['token'=>$value]);
        $this->assertDatabaseHas('device_tokens',['user_id'=>$owner->id,'token'=>$value,'status'=>'active']);
        $this->actingAs($other,'sanctum')->deleteJson('/api/v1/device-tokens/'.DeviceToken::where('token',$value)->value('id'))->assertNotFound();
        $this->actingAs($owner,'sanctum')->deleteJson('/api/v1/device-tokens/'.DeviceToken::where('token',$value)->value('id'))->assertOk();
        $this->assertDatabaseHas('device_tokens',['user_id'=>$owner->id,'token'=>$value,'status'=>'revoked']);
        $this->actingAs($owner,'sanctum')->postJson('/api/v1/device-tokens',['token'=>'bad','platform'=>'android'])->assertUnprocessable();
    }

    public function test_notifications_are_private_and_sensitive_data_is_filtered(): void
    {
        $owner=$this->user(); $other=$this->user(); $id=(string)Str::uuid();
        DB::table('notifications')->insert(['id'=>$id,'type'=>'test','notifiable_type'=>User::class,'notifiable_id'=>$owner->id,'data'=>json_encode(['title'=>'Hello','secret'=>'do-not-return','device_token'=>'hidden']),'created_at'=>now(),'updated_at'=>now()]);
        $this->actingAs($owner,'sanctum')->getJson('/api/v1/notifications/'.$id)->assertOk()->assertJsonPath('data.data.title','Hello')->assertJsonMissingPath('data.data.secret')->assertJsonMissingPath('data.data.device_token');
        $this->actingAs($other,'sanctum')->getJson('/api/v1/notifications/'.$id)->assertNotFound();
        $this->actingAs($other,'sanctum')->postJson('/api/v1/notifications/'.$id.'/read')->assertNotFound();
    }

    public function test_student_notification_endpoint_uses_safe_serialization(): void
    {
        $owner=$this->user(); $id=(string)Str::uuid();
        DB::table('notifications')->insert(['id'=>$id,'type'=>'test','notifiable_type'=>User::class,'notifiable_id'=>$owner->id,'data'=>json_encode(['title'=>'Safe','provider_payload'=>'secret','device_token'=>'secret']),'created_at'=>now(),'updated_at'=>now()]);
        $this->actingAs($owner,'sanctum')->getJson('/api/v1/student/notifications')->assertOk()->assertJsonPath('data.items.0.data.title','Safe')->assertJsonMissingPath('data.items.0.data.provider_payload')->assertJsonMissingPath('data.items.0.data.device_token');
    }

    public function test_admin_retry_is_authorized_audited_bounded_and_permanent_failures_rejected(): void
    {
        $admin=$this->user('admin'); $id=(string)Str::uuid();
        DB::table('notifications')->insert(['id'=>$id,'type'=>'test','notifiable_type'=>User::class,'notifiable_id'=>$admin->id,'data'=>'{}','created_at'=>now(),'updated_at'=>now()]);
        $token=DeviceToken::create(['user_id'=>$admin->id,'token'=>str_repeat('b',32),'platform'=>'android','status'=>'active']);
        $delivery=NotificationDelivery::create(['notification_id'=>$id,'device_token_id'=>$token->id,'status'=>'failed','attempts'=>1,'error_category'=>'provider_unavailable']);
        $this->actingAs($this->user())->post('/admin/notifications/deliveries/'.$delivery->id.'/retry')->assertForbidden();
        $this->actingAs($admin)->post('/admin/notifications/deliveries/'.$delivery->id.'/retry')->assertRedirect();
        $this->assertDatabaseHas('audit_logs',['action'=>'notification_delivery_retry_queued','entity_id'=>$delivery->id]);
        $delivery->refresh(); $this->assertSame('failed',$delivery->status); $this->assertSame(2,$delivery->attempts);
        $delivery->update(['status'=>'failed','attempts'=>3,'error_category'=>'provider_unavailable']);
        $this->actingAs($admin)->post('/admin/notifications/deliveries/'.$delivery->id.'/retry')->assertStatus(409);
        $delivery->update(['attempts'=>1,'error_category'=>'invalid_token']);
        $this->actingAs($admin)->post('/admin/notifications/deliveries/'.$delivery->id.'/retry')->assertStatus(409);
    }
}
