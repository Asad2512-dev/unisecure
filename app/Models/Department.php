<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model; use Illuminate\Database\Eloquent\SoftDeletes;
class Department extends Model { use SoftDeletes; protected $fillable=['name','code','description','status']; public function programs(){return $this->hasMany(Program::class);} public function students(){return $this->hasMany(Student::class);} public function teachers(){return $this->hasMany(Teacher::class);} public function courses(){return $this->hasMany(Course::class);} }
