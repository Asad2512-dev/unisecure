<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AuthController extends Controller
{
    private function destination(User $user): string
    {
        return match ($user->role?->name) {
            'admin' => 'admin.dashboard',
            'teacher' => 'teacher.home',
            'guard' => 'security.desk',
            'student' => 'student.home',
            default => 'login',
        };
    }

    public function show(Request $request): View|RedirectResponse
    {
        if ($request->user()) {
            $destination = $this->destination($request->user());
            if ($request->user()->status === 'active' && $destination !== 'login') {
                return redirect()->route($destination);
            }
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();
        }

        return view('admin.login', ['title' => 'Sign in']);
    }

    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate(['email' => 'required|email', 'password' => 'required|string']);
        if (! Auth::attempt([...$credentials, 'status' => 'active'], $request->boolean('remember'))) {
            return back()->withErrors(['email' => 'The credentials are invalid or the account is inactive.'])->onlyInput('email');
        }

        $destination = $this->destination($request->user());
        if ($destination === 'login') {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()->route('login')->withErrors(['email' => 'Your account does not have a supported role.']);
        }

        $request->session()->regenerate();
        $request->session()->forget('url.intended');
        $request->user()->forceFill(['last_login_at' => now()])->save();

        return redirect()->route($destination)->with('status', 'Welcome back.');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login')->with('status', 'You have been signed out.');
    }
}
