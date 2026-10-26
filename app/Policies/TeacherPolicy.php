<?php

namespace App\Policies;

use App\Models\Teacher;
use App\Models\User;

class TeacherPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isAdmin() || $user->hasPermission('academic.view');
    }

    public function view(User $user, Teacher $teacher): bool
    {
        return $user->isAdmin() || $teacher->user_id === $user->id || $user->hasPermission('academic.view');
    }

    public function update(User $user, Teacher $teacher): bool
    {
        return $user->isAdmin() || ($teacher->user_id === $user->id && $user->hasPermission('academic.manage'));
    }
}
