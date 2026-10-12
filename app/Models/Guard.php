<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model; use Illuminate\Database\Eloquent\SoftDeletes;
class Guard extends Model { use SoftDeletes; protected $fillable=['user_id','employee_id','gate_id','phone','status']; public function user(){return $this->belongsTo(User::class);} public function gate(){return $this->belongsTo(Gate::class);} public function entryExitLogs(){return $this->hasMany(EntryExitLog::class);} public function visitors(){return $this->hasMany(Visitor::class);} }
