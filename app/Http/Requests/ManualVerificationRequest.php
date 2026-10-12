<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;
class ManualVerificationRequest extends FormRequest { public function authorize():bool{return auth()->check()&&(auth()->user()->isAdmin()||auth()->user()->hasRole('guard'));} public function rules():array{return ['student_id'=>'required|integer|exists:students,id','confirmed'=>'accepted','reason'=>'required|string|min:5|max:500'];} }
