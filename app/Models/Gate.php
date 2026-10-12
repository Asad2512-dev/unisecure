<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Gate extends Model { protected $fillable=['name','code','location','status']; public function guards(){return $this->hasMany(Guard::class);} public function entryExitLogs(){return $this->hasMany(EntryExitLog::class);} public function visitors(){return $this->hasMany(Visitor::class);} }
