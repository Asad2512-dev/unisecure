<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DeviceTokenController;
use App\Http\Controllers\Api\V1\GuardController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\StudentController;
use App\Http\Controllers\Api\V1\TeacherController;
use App\Http\Controllers\Api\V1\VisitorController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('/health', HealthController::class)->name('api.v1.health');
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:api')->name('api.v1.auth.login');
    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('/auth/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');
        Route::get('/me', [AuthController::class, 'me'])->name('api.v1.me');
        Route::get('/notifications', [NotificationController::class, 'index'])->name('api.v1.notifications.index');
        Route::post('/notifications/read-all', [NotificationController::class, 'readAll'])->name('api.v1.notifications.read-all');
        Route::get('/notifications/{notification}', [NotificationController::class, 'show'])->name('api.v1.notifications.show');
        Route::post('/notifications/{notification}/read', [NotificationController::class, 'read'])->name('api.v1.notifications.read');
        Route::post('/device-tokens', [DeviceTokenController::class, 'store'])->name('api.v1.device-tokens.store');
        Route::delete('/device-tokens/{deviceToken}', [DeviceTokenController::class, 'destroy'])->name('api.v1.device-tokens.destroy');
        Route::middleware('role:student')->prefix('student')->name('api.v1.student.')->group(function (): void {
            Route::get('/profile', [StudentController::class, 'profile'])->name('profile');
            Route::get('/academic', [StudentController::class, 'academic'])->name('academic');
            Route::get('/courses', [StudentController::class, 'courses'])->name('courses');
            Route::get('/timetable', [StudentController::class, 'timetable'])->name('timetable');
            Route::get('/sessions', [StudentController::class, 'sessions'])->name('sessions');
            Route::get('/attendance', [StudentController::class, 'attendance'])->name('attendance');
            Route::get('/attendance/summary', [StudentController::class, 'attendanceSummary'])->name('attendance.summary');
            Route::get('/security/transactions', [StudentController::class, 'security'])->name('security');
            Route::get('/notifications', [StudentController::class, 'notifications'])->name('notifications');
        });
        Route::middleware('role:teacher')->prefix('teacher')->name('api.v1.teacher.')->group(function (): void {
            Route::get('/profile', [TeacherController::class, 'profile'])->name('profile');
            Route::get('/courses', [TeacherController::class, 'courses'])->name('courses');
            Route::get('/sections', [TeacherController::class, 'sections'])->name('sections');
            Route::get('/timetable', [TeacherController::class, 'timetable'])->name('timetable');
            Route::get('/sessions', [TeacherController::class, 'sessions'])->name('sessions');
            Route::get('/sessions/{session}', [TeacherController::class, 'show'])->name('sessions.show');
            Route::get('/sessions/{session}/students', [TeacherController::class, 'students'])->name('sessions.students');
            Route::get('/sessions/{session}/attendance', [TeacherController::class, 'attendance'])->name('sessions.attendance');
            Route::post('/sessions/{session}/attendance', [TeacherController::class, 'mark'])->name('sessions.attendance.mark');
            Route::post('/sessions/{session}/finalize', [TeacherController::class, 'finalize'])->name('sessions.finalize');
        });
        Route::middleware('role:guard')->prefix('guard')->name('api.v1.guard.')->group(function (): void {
            Route::get('/profile', [GuardController::class, 'profile'])->name('profile');
            Route::get('/gate', [GuardController::class, 'gate'])->name('gate');
            Route::get('/students/search', [GuardController::class, 'search'])->middleware('throttle:api')->name('students.search');
            Route::get('/security/transactions', [GuardController::class, 'transactions'])->name('security.transactions');
            Route::post('/security/face', [GuardController::class, 'face'])->middleware('throttle:api')->name('security.face');
            Route::post('/security/manual', [GuardController::class, 'manual'])->middleware('throttle:api')->name('security.manual');
            Route::get('/visitors', [VisitorController::class, 'index'])->name('visitors');
            Route::post('/visitors', [VisitorController::class, 'store'])->middleware('throttle:api')->name('visitors.store');
            Route::post('/visitors/{visitor}/checkout',[VisitorController::class, 'checkout'])->middleware('throttle:api')->name('visitors.checkout');
        });
    });
});
