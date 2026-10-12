<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable(['name', 'email', 'password', 'role_id', 'status', 'last_login_at'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    public function role() { return $this->belongsTo(Role::class); }
    public function hasRole(string $role): bool { return $this->role?->name === $role; }
    public function isAdmin(): bool { return $this->hasRole('admin'); }
    public function hasPermission(string $permission): bool { return $this->role?->permissions()->where('name', $permission)->exists() ?? false; }
    public function student(){return $this->hasOne(Student::class);}
    public function teacher(){return $this->hasOne(Teacher::class);}
    public function guardProfile(){return $this->hasOne(Guard::class);}

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
