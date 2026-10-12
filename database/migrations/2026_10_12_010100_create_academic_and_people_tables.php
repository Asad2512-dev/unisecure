<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void {
  Schema::create('departments', function(Blueprint $t){$t->id();$t->string('name');$t->string('code')->unique();$t->text('description')->nullable();$t->string('status')->default('active')->index();$t->softDeletes();$t->timestamps();});
  Schema::create('programs', function(Blueprint $t){$t->id();$t->foreignId('department_id')->constrained()->restrictOnDelete();$t->string('name');$t->string('code')->unique();$t->unsignedTinyInteger('duration_years');$t->string('status')->default('active')->index();$t->timestamps();});
  Schema::create('semesters', function(Blueprint $t){$t->id();$t->string('name');$t->unsignedTinyInteger('number');$t->string('academic_year',9);$t->string('status')->default('active')->index();$t->timestamps();$t->unique(['number','academic_year']);});
  Schema::create('sections', function(Blueprint $t){$t->id();$t->foreignId('program_id')->constrained()->restrictOnDelete();$t->foreignId('semester_id')->constrained()->restrictOnDelete();$t->string('name');$t->string('code')->unique();$t->unsignedInteger('capacity')->nullable();$t->string('status')->default('active')->index();$t->timestamps();});
  Schema::create('rooms', function(Blueprint $t){$t->id();$t->string('name');$t->string('building');$t->string('floor')->nullable();$t->unsignedInteger('capacity');$t->string('status')->default('active')->index();$t->timestamps();});
  Schema::create('gates', function(Blueprint $t){$t->id();$t->string('name');$t->string('code')->unique();$t->string('location')->nullable();$t->string('status')->default('active')->index();$t->timestamps();});
  Schema::create('students', function(Blueprint $t){$t->id();$t->foreignId('user_id')->unique()->constrained()->restrictOnDelete();$t->string('student_id')->unique();$t->foreignId('department_id')->constrained()->restrictOnDelete();$t->foreignId('program_id')->constrained()->restrictOnDelete();$t->foreignId('semester_id')->constrained()->restrictOnDelete();$t->foreignId('section_id')->constrained()->restrictOnDelete();$t->string('official_email')->unique();$t->string('phone')->nullable();$t->date('date_of_birth')->nullable();$t->string('gender')->nullable();$t->string('status')->default('active')->index();$t->date('admission_date')->nullable();$t->softDeletes();$t->timestamps();});
  Schema::create('teachers', function(Blueprint $t){$t->id();$t->foreignId('user_id')->unique()->constrained()->restrictOnDelete();$t->string('employee_id')->unique();$t->foreignId('department_id')->constrained()->restrictOnDelete();$t->string('official_email')->unique();$t->string('phone')->nullable();$t->string('status')->default('active')->index();$t->softDeletes();$t->timestamps();});
  Schema::create('guards', function(Blueprint $t){$t->id();$t->foreignId('user_id')->unique()->constrained()->restrictOnDelete();$t->string('employee_id')->unique();$t->foreignId('gate_id')->nullable()->constrained()->nullOnDelete();$t->string('phone')->nullable();$t->string('status')->default('active')->index();$t->softDeletes();$t->timestamps();});
  Schema::create('courses', function(Blueprint $t){$t->id();$t->foreignId('department_id')->constrained()->restrictOnDelete();$t->string('course_code')->unique();$t->string('name');$t->text('description')->nullable();$t->unsignedTinyInteger('credit_hours');$t->string('status')->default('active')->index();$t->softDeletes();$t->timestamps();});
 }
 public function down(): void { foreach(['courses','guards','teachers','students','gates','rooms','sections','semesters','programs','departments'] as $table) Schema::dropIfExists($table); }
};
