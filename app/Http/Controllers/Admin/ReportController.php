<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\{AttendanceRecord,ClassSession,CourseEnrollment,EntryExitLog,Student,Teacher,Guard,Visitor,NotificationDelivery};
use App\Services\AttendanceReportService;
use App\Support\CsvExport;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function __construct(private AttendanceReportService $reports) {}
    public function attendance(Request $request)
    {
        $records=AttendanceRecord::with(['student.user','session.course','session.section','session.teacher.user'])->when($request->filled('status'),fn($q)=>$q->where('status',$request->status))->when($request->filled('from'),fn($q)=>$q->whereHas('session',fn($x)=>$x->whereDate('session_date','>=',$request->from)))->when($request->filled('to'),fn($q)=>$q->whereHas('session',fn($x)=>$x->whereDate('session_date','<=',$request->to)))->latest('marked_at')->paginate(25)->withQueryString();
        return view('admin.reports.attendance',compact('records')+['title'=>'Attendance reports']);
    }
    public function attendanceCsv(Request $request)
    {
        $rows=AttendanceRecord::with(['student','session.course'])->when($request->filled('status'),fn($q)=>$q->where('status',$request->status))->latest('marked_at')->limit(5000)->get()->map(fn($r)=>[$r->student?->student_id,$r->session?->course?->code,$r->status,$r->marked_at?->toISOString()]);
        return CsvExport::response('unisecure-attendance.csv',['student_id','course','status','marked_at'],$rows);
    }
    public function analytics(Request $request)
    {
        $from=$request->input('from',now()->subDays(30)->toDateString()); $to=$request->input('to',now()->toDateString());
        return view('admin.reports.analytics',['title'=>'Analytics','from'=>$from,'to'=>$to,'stats'=>['students'=>Student::where('status','active')->count(),'teachers'=>Teacher::where('status','active')->count(),'guards'=>Guard::where('status','active')->count(),'enrollments'=>CourseEnrollment::count(),'sessions'=>ClassSession::whereBetween('session_date',[$from,$to])->where('status','!=','cancelled')->whereNotNull('finalized_at')->count(),'attendance'=>AttendanceRecord::whereHas('session',fn($q)=>$q->whereBetween('session_date',[$from,$to])->where('status','!=','cancelled')->whereNotNull('finalized_at'))->selectRaw('status,count(*) total')->groupBy('status')->pluck('total','status'),'transactions'=>EntryExitLog::whereBetween('event_at',[$from.' 00:00:00',$to.' 23:59:59'])->count(),'notifications'=>NotificationDelivery::whereBetween('created_at',[$from.' 00:00:00',$to.' 23:59:59'])->selectRaw('status,count(*) total')->groupBy('status')->pluck('total','status')]]);
    }
}
