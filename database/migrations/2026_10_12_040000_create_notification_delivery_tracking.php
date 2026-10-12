<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration { public function up():void{Schema::create('notification_deliveries',function(Blueprint $t){$t->id();$t->uuid('notification_id');$t->foreignId('device_token_id')->nullable()->constrained('device_tokens')->nullOnDelete();$t->string('status')->default('queued')->index();$t->unsignedTinyInteger('attempts')->default(0);$t->string('error_category')->nullable();$t->timestamp('attempted_at')->nullable();$t->timestamp('accepted_at')->nullable();$t->timestamps();$t->unique(['notification_id','device_token_id']);$t->index(['status','created_at']);});} public function down():void{Schema::dropIfExists('notification_deliveries');} };
