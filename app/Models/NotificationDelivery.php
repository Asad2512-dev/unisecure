<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationDelivery extends Model
{
    protected $fillable = ['notification_id', 'device_token_id', 'status', 'attempts', 'error_category', 'attempted_at', 'accepted_at'];

    protected $casts = ['attempted_at' => 'datetime', 'accepted_at' => 'datetime'];

    public function deviceToken()
    {
        return $this->belongsTo(DeviceToken::class);
    }
}
