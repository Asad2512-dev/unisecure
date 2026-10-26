<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClassSession extends Model
{
    protected $fillable = ['schedule_id', 'course_id', 'teacher_id', 'section_id', 'room_id', 'session_date', 'scheduled_start_at', 'scheduled_end_at', 'attendance_open_at', 'attendance_close_at', 'status', 'finalized_at', 'finalized_by'];

    protected $casts = ['session_date' => 'date', 'scheduled_start_at' => 'datetime', 'scheduled_end_at' => 'datetime', 'attendance_open_at' => 'datetime', 'attendance_close_at' => 'datetime', 'finalized_at' => 'datetime'];

    public function schedule()
    {
        return $this->belongsTo(ClassSchedule::class, 'schedule_id');
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function section()
    {
        return $this->belongsTo(Section::class);
    }

    public function attendanceRecords()
    {
        return $this->hasMany(AttendanceRecord::class);
    }

    public function finalizedBy()
    {
        return $this->belongsTo(User::class, 'finalized_by');
    }
}
