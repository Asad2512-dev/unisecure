<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\RegisterDeviceTokenRequest;
use App\Models\DeviceToken;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    public function store(RegisterDeviceTokenRequest $request)
    {
        $token = DeviceToken::updateOrCreate(['token'=>$request->string('token')->toString()], ['user_id'=>$request->user()->id,'platform'=>$request->input('platform'),'device_name'=>$request->input('device_name'),'status'=>'active','last_used_at'=>now()]);
        return ApiResponse::created(['id'=>$token->id,'platform'=>$token->platform,'device_name'=>$token->device_name], 'Device token registered.');
    }
    public function destroy(Request $request, DeviceToken $deviceToken)
    {
        abort_unless((int)$deviceToken->user_id === (int)$request->user()->id, 404);
        $deviceToken->update(['status'=>'revoked']);
        return ApiResponse::ok([], 'Device token removed.');
    }
}
