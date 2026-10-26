<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class StudentResource extends JsonResource
{
    public function toArray($request): array
    {
        return ['id' => $this->id, 'student_id' => $this->student_id, 'name' => $this->user?->name, 'official_email' => $this->official_email, 'phone' => $this->phone, 'status' => $this->status, 'department' => $this->department?->name, 'program' => $this->program?->name, 'semester' => $this->semester?->name, 'section' => $this->section?->code];
    }
}
