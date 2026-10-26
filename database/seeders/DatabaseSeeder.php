<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use App\Models\SystemSetting;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $permissions = collect([
            'users.view', 'users.manage', 'academic.view', 'academic.manage', 'attendance.view', 'attendance.manage',
            'security.view', 'security.manage', 'visitors.manage', 'settings.manage', 'reports.view',
        ])->mapWithKeys(fn ($name) => [$name => Permission::updateOrCreate(['name' => $name], ['display_name' => str($name)->replace('.', ' ')->title(), 'description' => 'Phase 2 permission.'])]);
        $roles = collect(['admin', 'student', 'teacher', 'guard'])->mapWithKeys(fn ($name) => [$name => Role::updateOrCreate(['name' => $name], ['display_name' => str($name)->title()])]);
        $roles['admin']->permissions()->sync($permissions->keys()->map(fn ($key) => $permissions[$key]->id)->all());
        foreach (['student', 'teacher', 'guard'] as $role) {
            $roles[$role]->permissions()->sync([]);
        }

        $email = env('ADMIN_EMAIL', 'admin@unisecure.test');
        $password = env('ADMIN_PASSWORD');
        if ($password) {
            User::updateOrCreate(['email' => $email], ['name' => 'UniSecure Administrator', 'password' => $password, 'role_id' => $roles['admin']->id, 'status' => 'active']);
        }

        foreach ([
            'university_name' => ['NUML University', 'string', false], 'university_email_domain' => ['numl.edu.pk', 'string', false],
            'timezone' => ['Asia/Karachi', 'string', false], 'academic_year' => ['2026-2027', 'string', false],
            'attendance_grace_period' => ['20', 'integer', false], 'late_counts_as_attended' => ['true', 'boolean', false],
            'attendance_warning_threshold' => ['3', 'integer', false], 'entry_exit_duplicate_cooldown' => ['10', 'integer', true],
            'nfc_enabled' => ['false', 'boolean', true], 'face_verification_enabled' => ['true', 'boolean', true],
            'class_reminder_minutes' => ['15', 'integer', false],
        ] as $key => [$value,$type,$protected]) {
            SystemSetting::updateOrCreate(['key' => $key], ['value' => $value, 'type' => $type, 'is_protected' => $protected]);
        }
    }
}
