<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    protected $fillable = ['name', 'building', 'floor', 'capacity', 'status'];

    public function schedules()
    {
        return $this->hasMany(ClassSchedule::class);
    }

    public function sessions()
    {
        return $this->hasMany(ClassSession::class);
    }
}
