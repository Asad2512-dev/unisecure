<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Jobs\DeliverNotificationJob;
use App\Models\{AuditLog, NotificationDelivery};
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;

class NotificationController extends Controller
{
    private function authorizeAdmin(): void
    { abort_unless(auth()->user()->isAdmin() || auth()->user()->hasPermission('users.view'), 403); }

    public function index(Request $request)
    {
        $this->authorizeAdmin();
        $notifications = DatabaseNotification::query()->with('notifiable')->when($request->filled('type'), fn($q)=>$q->where('type',$request->string('type')))->when($request->filled('from'), fn($q)=>$q->whereDate('created_at','>=',$request->date('from')))->when($request->filled('to'), fn($q)=>$q->whereDate('created_at','<=',$request->date('to')))->latest()->paginate(25)->withQueryString();
        $types=DatabaseNotification::query()->select('type')->distinct()->orderBy('type')->pluck('type');
        $deliveryStates=NotificationDelivery::whereIn('notification_id',$notifications->getCollection()->pluck('id'))->get()->groupBy('notification_id')->map(fn($items)=>$items->pluck('status')->unique()->implode(', '));
        return view('admin.notifications.index', compact('notifications','types','deliveryStates')+['title'=>'Notification management']);
    }

    public function show(string $notification)
    {
        $this->authorizeAdmin();
        $record=DatabaseNotification::with('notifiable')->findOrFail($notification);
        $deliveries=NotificationDelivery::with('deviceToken')->where('notification_id',$record->id)->get();
        return view('admin.notifications.show', compact('record','deliveries')+['title'=>'Notification detail']);
    }

    public function retry(Request $request, NotificationDelivery $delivery)
    {
        $this->authorizeAdmin();
        abort_unless(in_array($delivery->status,['failed'],true) && in_array($delivery->error_category,['provider_unavailable','transient'],true) && $delivery->attempts < (int)config('fcm.max_attempts',3), 409, 'This delivery is not eligible for retry.');
        $delivery->update(['status'=>'queued','error_category'=>null]);
        DeliverNotificationJob::dispatch($delivery->notification_id)->afterCommit();
        AuditLog::create(['user_id'=>auth()->id(),'action'=>'notification_delivery_retry_queued','entity_type'=>NotificationDelivery::class,'entity_id'=>$delivery->id,'new_values'=>['attempts'=>$delivery->attempts],'ip_address'=>$request->ip(),'user_agent'=>$request->userAgent()]);
        return back()->with('status','Retry queued. Provider acceptance will be tracked separately.');
    }
}
