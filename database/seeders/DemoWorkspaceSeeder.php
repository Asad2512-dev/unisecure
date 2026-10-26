<?php

namespace Database\Seeders;

use App\Models\AttendanceRecord;
use App\Models\AuditLog;
use App\Models\ClassSchedule;
use App\Models\ClassSession;
use App\Models\Course;
use App\Models\CourseEnrollment;
use App\Models\Department;
use App\Models\DeviceToken;
use App\Models\EntryExitLog;
use App\Models\Gate;
use App\Models\Guard;
use App\Models\NfcCard;
use App\Models\NotificationDelivery;
use App\Models\Program;
use App\Models\Role;
use App\Models\Room;
use App\Models\Section;
use App\Models\Semester;
use App\Models\Student;
use App\Models\StudentFaceProfile;
use App\Models\Teacher;
use App\Models\User;
use App\Models\Visitor;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DemoWorkspaceSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment(['local', 'testing'])) {
            throw new \RuntimeException('Demo accounts may only be seeded locally or in tests.');
        }
        $this->call(DatabaseSeeder::class);
        DB::transaction(function (): void {
            $users = [];
            foreach (['admin', 'student', 'teacher', 'guard'] as $role) {
                $name = match ($role) {
                    'student' => 'Faizan Khan',
                    'teacher' => 'Dr. Evelyn Reed',
                    'guard' => 'Officer Tariq Khan',
                    default => 'UniSecure Administrator',
                };
                $users[$role] = User::updateOrCreate(['email' => $role.'@gmail.com'], [
                    'name' => $name, 'password' => '12345678',
                    'role_id' => Role::where('name', $role)->firstOrFail()->id, 'status' => 'active',
                ]);
            }
            $department = Department::firstOrCreate(['code' => 'IT'], ['name' => 'Department of Information Technology', 'description' => 'Information Technology Department', 'status' => 'active']);
            $program = Program::firstOrCreate(['code' => 'BSIT'], ['department_id' => $department->id, 'name' => 'BS Information Technology', 'duration_years' => 4, 'status' => 'active']);
            $semester = Semester::firstOrCreate(['number' => 4, 'academic_year' => '2026-2027'], ['name' => 'Fall 2026', 'status' => 'active']);
            $section = Section::firstOrCreate(['code' => 'BSIT-MC'], ['name' => 'Section MC', 'program_id' => $program->id, 'semester_id' => $semester->id, 'capacity' => 40, 'status' => 'active']);
            $gate = Gate::firstOrCreate(['code' => 'NUML-MAIN'], ['name' => 'NUML Main Gate', 'location' => 'Main entrance', 'status' => 'active']);
            $teacher = Teacher::updateOrCreate(['user_id' => $users['teacher']->id], ['employee_id' => 'TEA-IT-001', 'department_id' => $department->id, 'official_email' => $users['teacher']->email, 'phone' => '03000000002', 'status' => 'active']);
            $guard = Guard::updateOrCreate(['user_id' => $users['guard']->id], ['employee_id' => 'GRD-SEC-001', 'gate_id' => $gate->id, 'phone' => '03000000003', 'status' => 'active']);
            $student = Student::updateOrCreate(['user_id' => $users['student']->id], [
                'student_id' => 'BSIT-MC-0001', 'department_id' => $department->id,
                'program_id' => $program->id, 'semester_id' => $semester->id, 'section_id' => $section->id,
                'official_email' => $users['student']->email, 'phone' => '03000000001', 'status' => 'active', 'admission_date' => '2024-09-01',
            ]);
            $students = collect([$student]);
            foreach (['Amina Khan', 'Bilal Ahmed', 'Sara Ali'] as $index => $name) {
                $email = 'demo.student.'.($index + 2).'@unisecure.test';
                $user = User::firstOrCreate(['email' => $email], ['name' => $name, 'password' => '12345678', 'role_id' => $users['student']->role_id, 'status' => 'active']);
                $students->push(Student::firstOrCreate(['user_id' => $user->id], ['student_id' => 'DEMO-CLASS-'.($index + 2), 'official_email' => $email, 'department_id' => $department->id, 'program_id' => $program->id, 'semester_id' => $semester->id, 'section_id' => $section->id, 'status' => 'active']));
            }
            foreach (['Programming Fundamentals', 'Database Systems', 'Computer Networks'] as $index => $name) {
                $course = Course::firstOrCreate(['course_code' => 'DEMO-CS'.(101 + $index)], ['department_id' => $department->id, 'name' => $name, 'credit_hours' => 3, 'description' => 'Demo course for end-to-end testing.', 'status' => 'active']);
                $room = Room::firstOrCreate(['name' => 'Demo Room '.(101 + $index), 'building' => 'Computing Block'], ['floor' => '1', 'capacity' => 40, 'status' => 'active']);
                foreach ($students as $enrolledStudent) {
                    CourseEnrollment::firstOrCreate(['student_id' => $enrolledStudent->id, 'course_id' => $course->id, 'section_id' => $section->id, 'academic_year' => $semester->academic_year, 'semester_id' => $semester->id], ['status' => 'active']);
                }
                $schedule = ClassSchedule::firstOrCreate(['course_id' => $course->id, 'teacher_id' => $teacher->id, 'section_id' => $section->id, 'academic_year' => $semester->academic_year], [
                    'room_id' => $room->id, 'semester_id' => $semester->id, 'day_of_week' => $index + 1,
                    'start_time' => (9 + $index * 2).':00', 'end_time' => (10 + $index * 2).':00', 'grace_period_minutes' => 20, 'status' => 'active',
                    'effective_start_date' => today()->subMonth(), 'effective_end_date' => today()->addMonths(3),
                ]);
                foreach ([-14, -7, 7, 14] as $offset) {
                    $date = today()->startOfWeek()->addDays($index + $offset);
                    $start = $date->copy()->setTime(9 + $index * 2, 0);
                    $past = $start->isPast();
                    $session = ClassSession::whereDate('session_date', $date->toDateString())->firstOrCreate(['schedule_id' => $schedule->id], [
                        'session_date' => $date->toDateString(),
                        'course_id' => $course->id, 'teacher_id' => $teacher->id, 'section_id' => $section->id, 'room_id' => $room->id,
                        'scheduled_start_at' => $start, 'scheduled_end_at' => $start->copy()->addHour(),
                        'attendance_open_at' => $start, 'attendance_close_at' => $start->copy()->addHour(), 'status' => $past ? 'closed' : 'scheduled',
                        'finalized_at' => $past ? $start->copy()->addHour() : null, 'finalized_by' => $past ? $users['admin']->id : null,
                    ]);
                    if ($past) {
                        foreach ($students as $position => $enrolledStudent) {
                            AttendanceRecord::firstOrCreate(['class_session_id' => $session->id, 'student_id' => $enrolledStudent->id], [
                                'status' => ['present', 'late', 'absent'][($index + $position) % 3], 'marked_at' => $start->copy()->addMinutes(5),
                                'marked_by' => $users['teacher']->id, 'source' => 'teacher', 'notes' => 'Demo attendance record',
                            ]);
                        }
                    }
                }
                // A separate teaching slot gives testers an open attendance window now.
                if ($index === 0) {
                    $liveSchedule = ClassSchedule::firstOrCreate(['course_id' => $course->id, 'teacher_id' => $teacher->id, 'section_id' => $section->id, 'day_of_week' => today()->dayOfWeekIso, 'start_time' => '00:00:00'], [
                        'room_id' => $room->id, 'semester_id' => $semester->id, 'academic_year' => $semester->academic_year,
                        'end_time' => '23:59:59', 'status' => 'inactive', 'grace_period_minutes' => 20,
                    ]);
                    ClassSession::whereDate('session_date', today()->toDateString())->firstOrCreate(['schedule_id' => $liveSchedule->id], [
                        'session_date' => today()->toDateString(),
                        'course_id' => $course->id, 'teacher_id' => $teacher->id, 'section_id' => $section->id, 'room_id' => $room->id,
                        'scheduled_start_at' => today(), 'scheduled_end_at' => today()->endOfDay(), 'attendance_open_at' => today(),
                        'attendance_close_at' => today()->endOfDay(), 'status' => 'open',
                    ]);
                }
            }
            for ($day = 3; $day >= 0; $day--) {
                foreach (['entry', 'exit'] as $direction) {
                    EntryExitLog::firstOrCreate(['student_id' => $student->id, 'device_id' => 'demo-history', 'event_at' => today()->subDays($day)->setTime($direction === 'entry' ? 8 : 17, 0), 'action' => $direction], [
                        'gate_id' => $gate->id, 'guard_id' => $guard->id, 'verification_method' => 'manual', 'reason' => 'Demo identity check', 'metadata' => ['demo' => true],
                    ]);
                }
            }
            foreach (['Ayesha Visitor', 'Omar Visitor', 'Zara Visitor'] as $index => $name) {
                Visitor::firstOrCreate(['identity_reference' => 'DEMO-VISITOR-'.($index + 1)], [
                    'name' => $name, 'phone' => '0300000001'.$index, 'purpose' => ['Admissions enquiry', 'Parent meeting', 'Campus tour'][$index],
                    'host_name' => $teacher->user?->name, 'host_user_id' => $users['teacher']->id, 'gate_id' => $gate->id, 'guard_id' => $guard->id,
                    'entry_at' => now()->subHours(2), 'exit_at' => $index === 2 ? now()->subHour() : null, 'status' => $index === 2 ? 'exited' : 'active',
                ]);
            }
            StudentFaceProfile::firstOrCreate(['student_id' => $student->id, 'provider' => 'demo-unconfigured'], ['status' => 'pending', 'metadata' => ['demo' => true, 'note' => 'No biometric data or live verification provider.']]);
            NfcCard::firstOrCreate(['uid' => 'DEMO-NFC-NOT-A-REAL-CARD'], ['student_id' => $student->id, 'card_number' => 'DEMO-CARD-001', 'status' => 'blocked', 'issued_at' => now(), 'blocked_at' => now()]);
            foreach (array_values($users) as $index => $user) {
                $token = DeviceToken::firstOrCreate(['token' => 'demo-inactive-device-'.$user->id], ['user_id' => $user->id, 'platform' => 'android', 'device_name' => 'Demo device (not registered)', 'status' => 'inactive']);
                for ($number = 1; $number <= 3; $number++) {
                    $id = sprintf('de000000-0000-4000-8000-%012d', $index * 10 + $number);
                    DB::table('notifications')->updateOrInsert(['id' => $id], [
                        'type' => 'demo.workspace', 'notifiable_type' => User::class, 'notifiable_id' => $user->id,
                        'data' => json_encode(['title' => ['Welcome to your demo workspace', 'Your academic schedule is ready', 'Demo activity available'][$number - 1], 'body' => 'Local demo data is available for your role. Explore your workspace to test the connected workflows.']),
                        'read_at' => $number === 3 ? now() : null, 'created_at' => now()->subHours($number), 'updated_at' => now(),
                    ]);
                    NotificationDelivery::firstOrCreate(['notification_id' => $id, 'device_token_id' => $token->id], ['status' => 'failed', 'attempts' => 1, 'error_category' => 'provider_unavailable', 'attempted_at' => now()]);
                }
                AuditLog::firstOrCreate(['user_id' => $user->id, 'action' => 'demo.workspace_prepared', 'entity_type' => User::class, 'entity_id' => $user->id], ['new_values' => ['demo' => true, 'role' => $user->role?->name]]);
            }
        });
    }
}
