<?php

namespace App\Services;

use App\Jobs\DeliverNotificationJob;
use App\Models\DeviceToken;
use App\Models\NotificationDelivery;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class NotificationService
{
    public function create(User $user, string $type, array $data): string
    {
        $id = (string) Str::uuid();
        DB::table('notifications')->insert(['id' => $id, 'type' => $type, 'notifiable_type' => User::class, 'notifiable_id' => $user->id, 'data' => json_encode($data), 'created_at' => now(), 'updated_at' => now()]);
        $tokens = DeviceToken::where('user_id', $user->id)->where('status', 'active')->get();
        foreach ($tokens as $token) {
            NotificationDelivery::firstOrCreate(['notification_id' => $id, 'device_token_id' => $token->id], ['status' => 'queued']);
        }DeliverNotificationJob::dispatch($id)->afterCommit();

        return $id;
    }
}
