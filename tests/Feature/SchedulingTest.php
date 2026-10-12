<?php
namespace Tests\Feature;
use App\Models\{ClassSchedule,ClassSession,Course,Department,Program,Room,Section,Semester,Teacher,User};
use App\Services\{ClassSessionGenerationService,ScheduleConflictService};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class SchedulingTest extends TestCase
{
 use RefreshDatabase;
 private function schedule(array $overrides=[]): ClassSchedule { $department=Department::create(['name'=>'Engineering','code'=>'ENG'.uniqid(),'status'=>'active']);$program=Program::create(['department_id'=>$department->id,'name'=>'CS','code'=>'CS'.uniqid(),'duration_years'=>4,'status'=>'active']);$semester=Semester::create(['name'=>'Fall','number'=>1,'academic_year'=>'2026-2027','status'=>'active']);$section=Section::create(['program_id'=>$program->id,'semester_id'=>$semester->id,'name'=>'A','code'=>'A'.uniqid(),'status'=>'active']);$course=Course::create(['department_id'=>$department->id,'course_code'=>'C'.uniqid(),'name'=>'Networks','credit_hours'=>3,'status'=>'active']);$user=User::factory()->create();$teacher=Teacher::create(['user_id'=>$user->id,'employee_id'=>'E'.uniqid(),'department_id'=>$department->id,'official_email'=>$user->email,'status'=>'active']);$room=Room::create(['name'=>'Room '.uniqid(),'building'=>'A','capacity'=>30,'status'=>'active']);return ClassSchedule::create(array_merge(['course_id'=>$course->id,'teacher_id'=>$teacher->id,'section_id'=>$section->id,'room_id'=>$room->id,'day_of_week'=>1,'start_time'=>'09:00','end_time'=>'10:00','grace_period_minutes'=>20,'status'=>'active','academic_year'=>'2026-2027','semester_id'=>$semester->id,'effective_start_date'=>'2026-01-01','effective_end_date'=>'2026-12-31'],$overrides)); }
 public function test_generation_respects_weekday_and_is_idempotent():void{$schedule=$this->schedule();$service=app(ClassSessionGenerationService::class);$first=$service->generate($schedule,'2026-01-05','2026-01-18');$second=$service->generate($schedule,'2026-01-05','2026-01-18');$this->assertSame(2,$first['created']);$this->assertSame(2,$second['skipped']);$this->assertSame(2,ClassSession::count());}
 public function test_generation_rejects_unbounded_ranges():void{$this->expectException(ValidationException::class);$this->service()->generate($this->schedule(),'2026-01-01','2028-01-01');}
 public function test_teacher_conflicts_are_rejected_but_adjacent_times_are_allowed():void{$one=$this->schedule();$data=$one->toArray();$data['start_time']='10:00';$data['end_time']='11:00';$this->serviceConflict()->assertValid($data);$data['start_time']='09:30';$data['end_time']='10:30';$this->expectException(ValidationException::class);$this->serviceConflict()->assertValid($data);}
 private function service(){return app(ClassSessionGenerationService::class);} private function serviceConflict(){return app(ScheduleConflictService::class);}
}
