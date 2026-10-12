<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Visitor extends Model { protected $fillable=['name','phone','identity_reference','purpose','host_name','host_user_id','gate_id','guard_id','entry_at','exit_at','status','photo_path']; protected $casts=['entry_at'=>'datetime','exit_at'=>'datetime']; public function host(){return $this->belongsTo(User::class,'host_user_id');} public function gate(){return $this->belongsTo(Gate::class);} public function guardProfile(){return $this->belongsTo(Guard::class,'guard_id');} }
