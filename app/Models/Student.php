<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Student extends Model
{
    use SoftDeletes;

    protected $fillable = ['user_id', 'student_id', 'department_id', 'program_id', 'semester_id', 'section_id', 'official_email', 'phone', 'date_of_birth', 'gender', 'status', 'admission_date'];

    protected $casts = ['date_of_birth' => 'date', 'admission_date' => 'date'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function program()
    {
        return $this->belongsTo(Program::class);
    }

    public function semester()
    {
        return $this->belongsTo(Semester::class);
    }

    public function section()
    {
        return $this->belongsTo(Section::class);
    }

    public function enrollments()
    {
        return $this->hasMany(CourseEnrollment::class);
    }

    public function attendanceRecords()
    {
        return $this->hasMany(AttendanceRecord::class);
    }

    public function faceProfiles()
    {
        return $this->hasMany(StudentFaceProfile::class);
    }

    public function nfcCards()
    {
        return $this->hasMany(NfcCard::class);
    }

    public function entryExitLogs()
    {
        return $this->hasMany(EntryExitLog::class);
    }
}
