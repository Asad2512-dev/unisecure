<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\{AuditLog,Course,Department,EntryExitLog,Gate,Guard,Program,Student,Teacher};
class DashboardController extends Controller
{
 public function __invoke(){return view('admin.dashboard',['title'=>'Overview','stats'=>[
  ['label'=>'Students','value'=>Student::count(),'route'=>'admin.resource.index','resource'=>'students','tone'=>'indigo'],['label'=>'Teachers','value'=>Teacher::count(),'route'=>'admin.resource.index','resource'=>'teachers','tone'=>'emerald'],['label'=>'Guards','value'=>Guard::count(),'route'=>'admin.resource.index','resource'=>'guards','tone'=>'amber'],['label'=>'Departments','value'=>Department::count(),'route'=>'admin.resource.index','resource'=>'departments','tone'=>'sky'],['label'=>'Programs','value'=>Program::count(),'route'=>'admin.resource.index','resource'=>'programs','tone'=>'violet'],['label'=>'Courses','value'=>Course::count(),'route'=>'admin.resource.index','resource'=>'courses','tone'=>'rose'],['label'=>'Gates','value'=>Gate::count(),'route'=>'admin.resource.index','resource'=>'gates','tone'=>'slate'],
 ],'recentLogs'=>EntryExitLog::with(['student.user','gate'])->latest('event_at')->limit(8)->get(),'auditLogs'=>AuditLog::with('user')->latest('created_at')->limit(8)->get()]);}
}
