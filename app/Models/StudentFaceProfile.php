<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class StudentFaceProfile extends Model { protected $fillable=['student_id','provider','external_reference','status','enrolled_at','last_verified_at','metadata']; protected $casts=['enrolled_at'=>'datetime','last_verified_at'=>'datetime','metadata'=>'array']; public function student(){return $this->belongsTo(Student::class);} }
