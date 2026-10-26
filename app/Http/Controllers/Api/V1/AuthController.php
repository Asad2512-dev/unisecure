<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate(['email' => 'required|email', 'password' => 'required|string']);
        $user = User::where('email', $data['email'])->first();
        if (! $user || $user->status !== 'active' || ! Hash::check($data['password'], $user->password)) {
            return ApiResponse::error('The credentials are invalid or the account is inactive.', ['code' => 'INVALID_CREDENTIALS'], 401);
        }if ($user->isAdmin()) {
            return ApiResponse::error('Administrator access uses the web session login.', ['code' => 'ADMIN_WEB_ONLY'], 403);
        }$token = $user->createToken('mobile')->plainTextToken;

        return ApiResponse::ok(['token' => $token, 'user' => (new UserResource($user->load('role')))->resolve()], 'Authenticated successfully.');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return ApiResponse::ok([], 'Logged out successfully.');
    }

    public function me(Request $request)
    {
        return ApiResponse::ok(['user' => (new UserResource($request->user()->load('role')))->resolve()], 'Authenticated user.');
    }
}
