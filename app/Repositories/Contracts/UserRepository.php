<?php

namespace App\Repositories\Contracts;

use App\Models\User;

interface UserRepository
{
    public function findByEmail(string $email): ?User;

    public function updateLastLogin(User $user): User;
}
