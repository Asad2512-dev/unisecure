<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate(['email'=>'required|email','password'=>'required|string']);
        if (!Auth::attempt($credentials, $request->boolean('remember'))) return back()->withErrors(['email'=>'These credentials are not valid for an admin account.'])->onlyInput('email');
        if (!Auth::user()->isAdmin()) { Auth::logout(); return back()->withErrors(['email'=>'This account is not authorized for the admin panel.'])->onlyInput('email'); }
        $request->session()->regenerate();
        Auth::user()->forceFill(['last_login_at'=>now()])->save();
        return redirect()->intended(route('admin.dashboard'))->with('status','Welcome back.');
    }
    public function logout(Request $request) { Auth::logout(); $request->session()->invalidate(); $request->session()->regenerateToken(); return redirect()->route('admin.login')->with('status','You have been signed out.'); }
}
