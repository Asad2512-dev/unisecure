<?php
namespace App\Http\Requests\Admin;
use Illuminate\Foundation\Http\FormRequest;
class GenerateSessionsRequest extends FormRequest { public function authorize():bool{return auth()->check()&&auth()->user()->isAdmin();} public function rules():array{return ['from'=>['required','date'],'to'=>['required','date','after_or_equal:from']];} }
