<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use App\Services\CampusSecurityService;
use App\Models\{AuditLog,Visitor};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
class VisitorController extends Controller
{
 public function __construct(private CampusSecurityService $security){}
 private function guard(){return $this->security->guardFor(auth()->user());}
 public function index(Request $request){$g=$this->guard();$items=Visitor::where('gate_id',$g->gate_id)->when($request->q,fn($q,$v)=>$q->where('name','like','%'.$v.'%')->orWhere('phone','like','%'.$v.'%'))->latest('entry_at')->paginate(min((int)$request->input('per_page',20),50));return ApiResponse::ok(['items'=>$items->getCollection()->map(fn($v)=>['id'=>$v->id,'name'=>$v->name,'purpose'=>$v->purpose,'status'=>$v->status,'entry_at'=>$v->entry_at?->toIso8601String(),'exit_at'=>$v->exit_at?->toIso8601String()]),'pagination'=>['current_page'=>$items->currentPage(),'last_page'=>$items->lastPage(),'total'=>$items->total()]]);}
 public function store(Request $request){$g=$this->guard();$data=$request->validate(['name'=>'required|string|max:255','phone'=>'required|string|max:50','identity_reference'=>'nullable|string|max:255','purpose'=>'required|string|max:1000','host_name'=>'nullable|string|max:255']);$visitor=DB::transaction(fn()=>Visitor::create($data+['gate_id'=>$g->gate_id,'guard_id'=>$g->id,'entry_at'=>now(config('app.timezone')),'status'=>'active']));AuditLog::create(['user_id'=>auth()->id(),'action'=>'visitor.checked_in','entity_type'=>Visitor::class,'entity_id'=>$visitor->id,'new_values'=>['gate_id'=>$g->gate_id]]);return ApiResponse::created(['id'=>$visitor->id,'status'=>$visitor->status,'entry_at'=>$visitor->entry_at?->toIso8601String()],'Visitor checked in.');}
 public function checkout(Visitor $visitor){$g=$this->guard();abort_unless($visitor->gate_id===$g->gate_id,403);DB::transaction(function()use($visitor){$locked=Visitor::whereKey($visitor->id)->lockForUpdate()->firstOrFail();if($locked->status!=='active')abort(422,'Visitor is not actively checked in.');$locked->update(['status'=>'exited','exit_at'=>now(config('app.timezone'))]);});AuditLog::create(['user_id'=>auth()->id(),'action'=>'visitor.checked_out','entity_type'=>Visitor::class,'entity_id'=>$visitor->id,'new_values'=>['gate_id'=>$g->gate_id]]);return ApiResponse::ok(['id'=>$visitor->id,'status'=>'exited'],'Visitor checked out.');}
}
