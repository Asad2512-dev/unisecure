<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class RegisterDeviceTokenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return ['token' => ['required', 'string', 'min:20', 'max:2048'], 'platform' => ['nullable', 'string', 'in:android,ios,web'], 'device_name' => ['nullable', 'string', 'max:100']];
    }
}
