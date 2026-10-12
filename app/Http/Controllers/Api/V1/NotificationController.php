<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $items = $request->user()->notifications()->latest()->paginate(min((int) $request->integer('per_page', 20), 50));
        return ApiResponse::ok($items->through(fn ($n) => $this->safe($n)), 'Notifications retrieved.', ['pagination' => ['current_page'=>$items->currentPage(),'last_page'=>$items->lastPage(),'per_page'=>$items->perPage(),'total'=>$items->total()]]);
    }

    public function show(Request $request, DatabaseNotification $notification)
    {
        abort_unless($this->owned($request, $notification), 404);
        return ApiResponse::ok($this->safe($notification), 'Notification retrieved.');
    }

    public function read(Request $request, DatabaseNotification $notification)
    {
        abort_unless($this->owned($request, $notification), 404);
        $notification->markAsRead();
        return ApiResponse::ok($this->safe($notification->fresh()), 'Notification marked as read.');
    }

    public function readAll(Request $request)
    {
        $request->user()->unreadNotifications()->update(['read_at' => now()]);
        return ApiResponse::ok([], 'Notifications marked as read.');
    }

    private function owned(Request $request, DatabaseNotification $notification): bool
    { return $notification->notifiable_type === $request->user()::class && (int) $notification->notifiable_id === (int) $request->user()->id; }

    private function safe(DatabaseNotification $notification): array
    {
        $data = is_array($notification->data) ? $notification->data : [];
        return ['id'=>$notification->id,'type'=>$notification->type,'data'=>array_intersect_key($data, array_flip(['title','body','message','event','session_id'])),'read_at'=>$notification->read_at?->toISOString(),'created_at'=>$notification->created_at?->toISOString()];
    }
}
