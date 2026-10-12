<?php
namespace App\Policies;
use App\Models\{Student,User};
class StudentPolicy { public function viewAny(User $user): bool{return $user->hasPermission('academic.view')||$user->isAdmin();} public function view(User $user,Student $student): bool{return $user->isAdmin()||$student->user_id===$user->id||$user->hasPermission('academic.view');} public function update(User $user,Student $student): bool{return $user->isAdmin()||$user->hasPermission('academic.manage');} }
