<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model; use Illuminate\Database\Eloquent\SoftDeletes;
class Course extends Model { use SoftDeletes; protected $fillable=['department_id','course_code','name','description','credit_hours','status']; public function department(){return $this->belongsTo(Department::class);} public function enrollments(){return $this->hasMany(CourseEnrollment::class);} public function schedules(){return $this->hasMany(ClassSchedule::class);} public function sessions(){return $this->hasMany(ClassSession::class);} }
