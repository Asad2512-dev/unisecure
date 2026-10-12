<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class NfcCard extends Model { protected $fillable=['student_id','uid','card_number','status','issued_at','blocked_at','replaced_at','replacement_for']; protected $casts=['issued_at'=>'datetime','blocked_at'=>'datetime','replaced_at'=>'datetime']; public function student(){return $this->belongsTo(Student::class);} public function replacementFor(){return $this->belongsTo(self::class,'replacement_for');} public function replacements(){return $this->hasMany(self::class,'replacement_for');} public function entryExitLogs(){return $this->hasMany(EntryExitLog::class);} }
