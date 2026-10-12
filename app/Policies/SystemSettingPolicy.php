<?php
namespace App\Policies;
use App\Models\{SystemSetting,User};
class SystemSettingPolicy { public function viewAny(User $user): bool{return $user->isAdmin()||$user->hasPermission('settings.manage');} public function update(User $user,SystemSetting $setting): bool{return $user->isAdmin()||(!$setting->is_protected&&$user->hasPermission('settings.manage'));} }
