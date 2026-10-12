<?php
namespace App\Jobs;
use App\Contracts\FcmDeliveryInterface;
use App\Models\{DeviceToken,NotificationDelivery};
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Bus\Queueable;
class DeliverNotificationJob implements ShouldQueue { use Dispatchable,InteractsWithQueue,Queueable,SerializesModels; public int $tries=3; public function __construct(public string $notificationId){} public function backoff():array{return [30,120,300];} public function handle(FcmDeliveryInterface $fcm):void{$deliveries=NotificationDelivery::where('notification_id',$this->notificationId)->with('deviceToken')->get();foreach($deliveries as $delivery){if($delivery->status==='accepted')continue;$delivery->increment('attempts');$delivery->update(['status'=>'attempted','attempted_at'=>now()]);$token=$delivery->deviceToken;if(!$token||$token->status!=='active'){$delivery->update(['status'=>'failed','error_category'=>'invalid_token']);continue;}if(!$fcm->available()){$delivery->update(['status'=>'failed','error_category'=>'provider_unavailable']);continue;}$result=$fcm->send($token->token,['notification_id'=>$this->notificationId]);$delivery->update(['status'=>$result->accepted?'accepted':'failed','error_category'=>$result->errorCategory,'accepted_at'=>$result->accepted?now():null]);if($result->errorCategory==='invalid_token')$token->update(['status'=>'inactive']);}} }
