<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void {
  Schema::create('device_tokens', function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->string('token')->unique();$t->string('platform');$t->string('device_name')->nullable();$t->timestamp('last_used_at')->nullable();$t->string('status')->default('active')->index();$t->timestamps();});
  Schema::create('notifications', function(Blueprint $t){$t->uuid('id')->primary();$t->string('type');$t->morphs('notifiable');$t->text('data');$t->timestamp('read_at')->nullable();$t->timestamps();$t->index(['notifiable_type','notifiable_id','read_at']);});
  Schema::create('audit_logs', function(Blueprint $t){$t->id();$t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();$t->string('action');$t->string('entity_type');$t->unsignedBigInteger('entity_id')->nullable();$t->json('old_values')->nullable();$t->json('new_values')->nullable();$t->ipAddress('ip_address')->nullable();$t->text('user_agent')->nullable();$t->timestamp('created_at')->useCurrent();$t->index(['entity_type','entity_id']);$t->index(['user_id','created_at']);});
  Schema::create('system_settings', function(Blueprint $t){$t->id();$t->string('key')->unique();$t->text('value')->nullable();$t->string('type')->default('string');$t->boolean('is_protected')->default(false);$t->timestamps();});
 }
 public function down(): void { foreach(['system_settings','audit_logs','notifications','device_tokens'] as $table) Schema::dropIfExists($table); }
};
