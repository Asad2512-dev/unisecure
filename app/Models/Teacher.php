<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Teacher extends Model
{
    use SoftDeletes;

    protected $fillable = ['user_id', 'employee_id', 'department_id', 'official_email', 'phone', 'status'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function schedules()
    {
        return $this->hasMany(ClassSchedule::class);
    }

    public function sessions()
    {
        return $this->hasMany(ClassSession::class);
    }
}
