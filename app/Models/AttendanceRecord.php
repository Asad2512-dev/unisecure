<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AttendanceRecord extends Model
{
    protected $fillable = ['class_session_id', 'student_id', 'status', 'marked_at', 'marked_by', 'source', 'notes'];

    protected $casts = ['marked_at' => 'datetime'];

    public function session()
    {
        return $this->belongsTo(ClassSession::class, 'class_session_id');
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function markedBy()
    {
        return $this->belongsTo(User::class, 'marked_by');
    }
}
