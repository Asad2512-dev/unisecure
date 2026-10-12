<?php
namespace App\Services;
use App\Models\ClassSchedule;
use Illuminate\Validation\ValidationException;

class ScheduleConflictService
{
 public function assertValid(array $data, ?int $ignoreId=null): void
 {
  if (($data['start_time'] ?? '') >= ($data['end_time'] ?? '')) throw ValidationException::withMessages(['end_time'=>'End time must be later than start time.']);
  if (!empty($data['effective_start_date']) && !empty($data['effective_end_date']) && $data['effective_start_date']>$data['effective_end_date']) throw ValidationException::withMessages(['effective_end_date'=>'The effective end date must be on or after the start date.']);
  $q=ClassSchedule::query()->where('status','active')->where('day_of_week',$data['day_of_week'])->where(function($q)use($data){$start=$data['effective_start_date']??'1000-01-01';$end=$data['effective_end_date']??'9999-12-31';$q->where(function($q)use($start,$end){$q->whereNull('effective_end_date')->orWhere('effective_end_date','>=',$start);})->where(function($q)use($start,$end){$q->whereNull('effective_start_date')->orWhere('effective_start_date','<=',$end);});});
  if($ignoreId)$q->whereKeyNot($ignoreId);$candidate=$q->with(['teacher.user','room','section','course'])->get();
  $candidateStart=$this->seconds($data['start_time']);$candidateEnd=$this->seconds($data['end_time']);foreach($candidate as $existing){if($candidateStart<$this->seconds($existing->end_time) && $candidateEnd>$this->seconds($existing->start_time)){$conflicts=[];if((int)$existing->teacher_id===(int)$data['teacher_id'])$conflicts[]='teacher';if((int)$existing->room_id===(int)$data['room_id'])$conflicts[]='room';if((int)$existing->section_id===(int)$data['section_id'])$conflicts[]='section';if($conflicts)throw ValidationException::withMessages(['start_time'=>'This schedule overlaps an existing '.implode(', ',$conflicts).' booking (schedule #'.$existing->id.').']);}}
 }
 private function seconds(mixed $time): int { $parts=array_map('intval',explode(':',(string)$time));return ($parts[0]??0)*3600+($parts[1]??0)*60+($parts[2]??0); }
}
