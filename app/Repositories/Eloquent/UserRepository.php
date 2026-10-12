<?php
namespace App\Repositories\Eloquent;
use App\Models\User; use App\Repositories\Contracts\UserRepository as Contract;
class UserRepository implements Contract { public function findByEmail(string $email): ?User{return User::where('email',$email)->first();} public function updateLastLogin(User $user): User{$user->forceFill(['last_login_at'=>now()])->save();return $user->refresh();} }
