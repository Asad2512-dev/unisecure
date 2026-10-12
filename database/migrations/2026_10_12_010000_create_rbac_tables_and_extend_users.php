<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void {
  Schema::create('roles', function (Blueprint $t) { $t->id(); $t->string('name')->unique(); $t->string('display_name'); $t->text('description')->nullable(); $t->timestamps(); });
  Schema::create('permissions', function (Blueprint $t) { $t->id(); $t->string('name')->unique(); $t->string('display_name'); $t->text('description')->nullable(); $t->timestamps(); });
  Schema::create('role_has_permissions', function (Blueprint $t) { $t->foreignId('role_id')->constrained()->cascadeOnDelete(); $t->foreignId('permission_id')->constrained()->cascadeOnDelete(); $t->primary(['role_id','permission_id']); });
  Schema::table('users', function (Blueprint $t) { $t->foreignId('role_id')->nullable()->after('id')->constrained('roles')->restrictOnDelete(); $t->string('status')->default('active')->index(); $t->timestamp('last_login_at')->nullable(); $t->softDeletes(); });
 }
 public function down(): void { Schema::table('users', fn (Blueprint $t) => $t->dropForeign(['role_id'])->dropColumn(['role_id','status','last_login_at','deleted_at'])); Schema::dropIfExists('role_has_permissions'); Schema::dropIfExists('permissions'); Schema::dropIfExists('roles'); }
};
