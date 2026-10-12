<?php

namespace App\Services;

use App\Jobs\DeliverNotificationJob;
use App\Models\{AuditLog,NotificationDelivery,User};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationRetryService
{
    public function retry(NotificationDelivery $delivery, User $actor, Request $request): void
    {
        DB::transaction(function () use ($delivery, $actor, $request): void {
            $locked=NotificationDelivery::whereKey($delivery->id)->lockForUpdate()->firstOrFail();
            abort_unless($locked->status==='failed' && in_array($locked->error_category,['provider_unavailable','transient'],true) && $locked->attempts < (int)config('fcm.max_attempts',3),409,'This delivery is not eligible for retry.');
            $locked->update(['status'=>'queued','error_category'=>null]);
            DeliverNotificationJob::dispatch($locked->notification_id)->afterCommit();
            AuditLog::create(['user_id'=>$actor->id,'action'=>'notification_delivery_retry_queued','entity_type'=>NotificationDelivery::class,'entity_id'=>$locked->id,'new_values'=>['attempts'=>$locked->attempts],'ip_address'=>$request->ip(),'user_agent'=>$request->userAgent()]);
        });
    }
}
