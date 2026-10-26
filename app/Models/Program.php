<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Program extends Model
{
    protected $fillable = ['department_id', 'name', 'code', 'duration_years', 'status'];

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function sections()
    {
        return $this->hasMany(Section::class);
    }

    public function students()
    {
        return $this->hasMany(Student::class);
    }
}
