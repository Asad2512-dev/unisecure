<?php
namespace App\Policies;
use App\Models\{Guard,User};
class GuardPolicy { public function viewAny(User $user): bool{return $user->isAdmin()||$user->hasPermission('security.view');} public function view(User $user,Guard $guard): bool{return $user->isAdmin()||$guard->user_id===$user->id||$user->hasPermission('security.view');} public function update(User $user,Guard $guard): bool{return $user->isAdmin()||$user->hasPermission('security.manage');} }
