<?php
namespace App\Http\Controllers;
use App\Models\{AuditLog,Visitor};
use App\Services\CampusSecurityService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
class VisitorController extends Controller
{
 public function __construct(private CampusSecurityService $security){}
 private function guard(){return $this->security->guardFor(auth()->user());}
 public function index(Request $request){$guard=$this->guard();$visitors=Visitor::with(['gate','guard.user'])->where('gate_id',$guard->gate_id)->when($request->q,fn($q,$v)=>$q->where('name','like','%'.$v.'%')->orWhere('phone','like','%'.$v.'%'))->latest('entry_at')->paginate(20);return view('security.visitors',compact('visitors','guard')+['title'=>'Visitors']);}
 public function store(Request $request){$guard=$this->guard();$data=$request->validate(['name'=>'required|string|max:255','phone'=>'required|string|max:50','identity_reference'=>'nullable|string|max:255','purpose'=>'required|string|max:1000','host_name'=>'nullable|string|max:255']);$visitor=DB::transaction(fn()=>Visitor::create($data+['gate_id'=>$guard->gate_id,'guard_id'=>$guard->id,'entry_at'=>now(config('app.timezone')),'status'=>'active']));AuditLog::create(['user_id'=>auth()->id(),'action'=>'visitor.checked_in','entity_type'=>Visitor::class,'entity_id'=>$visitor->id,'new_values'=>['gate_id'=>$guard->gate_id]]);return back()->with('status','Visitor checked in successfully.');}
 public function checkout(Visitor $visitor){$guard=$this->guard();abort_unless($visitor->gate_id===$guard->gate_id,403);if($visitor->status!=='active')return back()->withErrors(['visitor'=>'This visitor is not actively checked in.']);DB::transaction(function()use($visitor){$locked=Visitor::whereKey($visitor->id)->lockForUpdate()->firstOrFail();if($locked->status!=='active')abort(422,'Visitor is no longer active.');$locked->update(['status'=>'exited','exit_at'=>now(config('app.timezone'))]);});AuditLog::create(['user_id'=>auth()->id(),'action'=>'visitor.checked_out','entity_type'=>Visitor::class,'entity_id'=>$visitor->id,'new_values'=>['gate_id'=>$guard->gate_id]]);return back()->with('status','Visitor checked out successfully.');}
}
