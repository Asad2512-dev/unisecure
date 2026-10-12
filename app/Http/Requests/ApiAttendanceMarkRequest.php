<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;
class ApiAttendanceMarkRequest extends FormRequest { public function authorize():bool{return auth()->check()&&auth()->user()->hasRole('teacher');} public function rules():array{return ['student_id'=>'required|integer','status'=>'prohibited','marked_at'=>'prohibited'];} }
