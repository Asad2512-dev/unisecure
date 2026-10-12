<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ResourceController;
use App\Http\Controllers\Admin\OperationsController;
use App\Http\Controllers\Admin\SettingsController;
use App\Http\Controllers\Admin\ScheduleController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\GuardSecurityController;
use App\Http\Controllers\VisitorController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\NotificationController;

Route::view('/', 'welcome');
Route::redirect('/login', '/admin/login')->name('login');
Route::get('/admin/login', fn () => view('admin.login'))->name('admin.login');
Route::post('/admin/login', [AuthController::class,'login'])->name('admin.login.submit');
Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function (): void {
    Route::post('/logout', [AuthController::class,'logout'])->name('logout');
    Route::get('/', DashboardController::class)->name('dashboard');
    Route::get('/resource/{resource}', [ResourceController::class,'index'])->name('resource.index');
    Route::get('/resource/{resource}/create', [ResourceController::class,'create'])->name('resource.create');
    Route::post('/resource/{resource}', [ResourceController::class,'store'])->name('resource.store');
    Route::get('/resource/{resource}/{id}', [ResourceController::class,'show'])->name('resource.show');
    Route::get('/resource/{resource}/{id}/edit', [ResourceController::class,'edit'])->name('resource.edit');
    Route::put('/resource/{resource}/{id}', [ResourceController::class,'update'])->name('resource.update');
    Route::delete('/resource/{resource}/{id}', [ResourceController::class,'destroy'])->name('resource.destroy');
    Route::get('/operations/{type}', [OperationsController::class,'index'])->name('operations.index');
    Route::get('/settings', [SettingsController::class,'edit'])->name('settings.edit');
    Route::put('/settings', [SettingsController::class,'update'])->name('settings.update');
    Route::get('/schedules/timetable', [ScheduleController::class,'timetable'])->name('schedules.timetable');
    Route::get('/schedules', [ScheduleController::class,'index'])->name('schedules.index');
    Route::get('/schedules/create', [ScheduleController::class,'create'])->name('schedules.create');
    Route::post('/schedules', [ScheduleController::class,'store'])->name('schedules.store');
    Route::get('/schedules/{schedule}', [ScheduleController::class,'show'])->name('schedules.show');
    Route::get('/schedules/{schedule}/edit', [ScheduleController::class,'edit'])->name('schedules.edit');
    Route::put('/schedules/{schedule}', [ScheduleController::class,'update'])->name('schedules.update');
    Route::post('/schedules/{schedule}/deactivate', [ScheduleController::class,'deactivate'])->name('schedules.deactivate');
    Route::get('/schedules/{schedule}/generate', [ScheduleController::class,'generateForm'])->name('schedules.generate.form');
    Route::post('/schedules/{schedule}/generate', [ScheduleController::class,'generate'])->name('schedules.generate');
    Route::get('/schedules/{schedule}/sessions', [ScheduleController::class,'sessions'])->name('schedules.sessions');
    Route::get('/attendance', [AttendanceController::class,'sessions'])->name('attendance.sessions');
    Route::get('/attendance/{session}', [AttendanceController::class,'roster'])->name('attendance.roster');
    Route::post('/attendance/{session}/mark', [AttendanceController::class,'mark'])->name('attendance.mark');
    Route::post('/attendance/{session}/finalize', [AttendanceController::class,'finalize'])->name('attendance.finalize');
    Route::post('/attendance/record/{record}/correct', [AttendanceController::class,'correct'])->name('attendance.correct');
    Route::get('/reports/attendance', [ReportController::class,'attendance'])->name('reports.attendance');
    Route::get('/reports/attendance.csv', [ReportController::class,'attendanceCsv'])->name('reports.attendance.csv');
    Route::get('/reports/analytics', [ReportController::class,'analytics'])->name('reports.analytics');
    Route::get('/notifications', [NotificationController::class,'index'])->name('notifications.index');
    Route::get('/notifications/{notification}', [NotificationController::class,'show'])->name('notifications.show');
    Route::post('/notifications/deliveries/{delivery}/retry', [NotificationController::class,'retry'])->name('notifications.deliveries.retry');
});
Route::middleware(['auth','role:teacher'])->prefix('teacher')->name('teacher.')->group(function():void {
    Route::get('/attendance',[AttendanceController::class,'sessions'])->name('attendance.sessions');
    Route::get('/attendance/{session}',[AttendanceController::class,'roster'])->name('attendance.roster');
    Route::post('/attendance/{session}/mark',[AttendanceController::class,'mark'])->name('attendance.mark');
});
Route::middleware(['auth','role:guard,admin'])->prefix('security')->name('security.')->group(function():void {
    Route::get('/',[GuardSecurityController::class,'index'])->name('desk');
    Route::post('/manual',[GuardSecurityController::class,'manual'])->name('manual');
    Route::post('/face',[GuardSecurityController::class,'face'])->name('face');
    Route::get('/visitors',[VisitorController::class,'index'])->name('visitors.index');
    Route::post('/visitors',[VisitorController::class,'store'])->name('visitors.store');
    Route::post('/visitors/{visitor}/checkout',[VisitorController::class,'checkout'])->name('visitors.checkout');
});
