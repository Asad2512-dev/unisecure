<?php

namespace App\Console\Commands;

use App\Models\{ClassSession,CourseEnrollment};
use App\Services\NotificationService;
use Illuminate\Console\Command;

class SendClassReminders extends Command
{
    protected $signature = 'notifications:class-reminders';
    protected $description = 'Queue reminders for upcoming non-cancelled class sessions';
    public function handle(NotificationService $notifications): int
    {
        $lead=(int)\App\Models\SystemSetting::getValue('class_reminder_lead_minutes', \App\Models\SystemSetting::getValue('class_reminder_minutes',15));
        $now=now(); $until=$now->copy()->addMinutes(max(1,$lead));
        ClassSession::with('course')->whereIn('status',['scheduled','open'])->whereBetween('scheduled_start_at',[$now,$until])->each(function($session) use($notifications){
            CourseEnrollment::with('student.user')->where('course_id',$session->course_id)->where('section_id',$session->section_id)->whereIn('status',['active','completed'])->each(function($enrollment) use($session,$notifications){
                $user=$enrollment->student?->user; if(!$user) return;
                $already=$user->notifications()->where('type','class_reminder')->where('data','like','%"session_id":'.$session->id.'%')->exists();
                if(!$already) $notifications->create($user,'class_reminder',['event'=>'class_reminder','session_id'=>$session->id,'title'=>'Upcoming class','body'=>'Your '.$session->course?->course_code.' class starts soon.']);
            });
        });
        return self::SUCCESS;
    }
}
