<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void { Schema::table('class_schedules', function(Blueprint $t){$t->date('effective_start_date')->nullable()->after('semester_id');$t->date('effective_end_date')->nullable()->after('effective_start_date');$t->index(['semester_id','day_of_week','effective_start_date','effective_end_date'],'schedule_conflict_lookup');}); Schema::table('class_sessions', function(Blueprint $t){$t->unique(['schedule_id','session_date'],'schedule_occurrence_unique');$t->index(['scheduled_start_at','scheduled_end_at'],'session_time_lookup');}); }
 public function down(): void { Schema::table('class_sessions',fn(Blueprint $t)=>$t->dropUnique('schedule_occurrence_unique')->dropIndex('session_time_lookup')); Schema::table('class_schedules',fn(Blueprint $t)=>$t->dropIndex('schedule_conflict_lookup')->dropColumn(['effective_start_date','effective_end_date'])); }
};
