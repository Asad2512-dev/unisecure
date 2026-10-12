<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Section extends Model { protected $fillable=['program_id','semester_id','name','code','capacity','status']; public function program(){return $this->belongsTo(Program::class);} public function semester(){return $this->belongsTo(Semester::class);} public function students(){return $this->hasMany(Student::class);} public function enrollments(){return $this->hasMany(CourseEnrollment::class);} public function schedules(){return $this->hasMany(ClassSchedule::class);} }
