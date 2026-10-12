<?php
namespace App\Http\Requests\Admin;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
class ScheduleRequest extends FormRequest { public function authorize(): bool{return auth()->check()&&auth()->user()->isAdmin();} public function rules():array{return ['course_id'=>['required','exists:courses,id'],'teacher_id'=>['required','exists:teachers,id'],'section_id'=>['required','exists:sections,id'],'room_id'=>['required','exists:rooms,id'],'day_of_week'=>['required','integer','between:1,7'],'start_time'=>['required','date_format:H:i'],'end_time'=>['required','date_format:H:i','after:start_time'],'grace_period_minutes'=>['required','integer','min:0','max:240'],'status'=>['required',Rule::in(['active','inactive'])],'academic_year'=>['required','string','max:9'],'semester_id'=>['required','exists:semesters,id'],'effective_start_date'=>['nullable','date'],'effective_end_date'=>['nullable','date','after_or_equal:effective_start_date']];} }
