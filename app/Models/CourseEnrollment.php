<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourseEnrollment extends Model
{
    protected $fillable = ['student_id', 'course_id', 'section_id', 'academic_year', 'semester_id', 'status'];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function section()
    {
        return $this->belongsTo(Section::class);
    }

    public function semester()
    {
        return $this->belongsTo(Semester::class);
    }
}
