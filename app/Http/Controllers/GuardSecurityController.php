<?php
namespace App\Http\Controllers;
use App\Models\{EntryExitLog,Student,StudentFaceProfile};
use App\Services\{CampusSecurityService,FaceVerificationService};
use App\Http\Requests\ManualVerificationRequest;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
class GuardSecurityController extends Controller
{
 public function __construct(private CampusSecurityService $security,private FaceVerificationService $faces){}
 private function guard(){return $this->security->guardFor(auth()->user());}
 public function index(Request $request){$guard=$this->guard();$students=Student::with('user')->where('status','active')->when($request->q,fn($q,$v)=>$q->where('student_id','like','%'.$v.'%')->orWhereHas('user',fn($x)=>$x->where('name','like','%'.$v.'%')))->limit(25)->get();$logs=EntryExitLog::with(['student.user'])->where('guard_id',$guard->id)->latest('event_at')->paginate(15);return view('security.guard',compact('guard','students','logs')+['title'=>'Guard security desk']);}
 public function manual(ManualVerificationRequest $request){$this->guard();$student=Student::findOrFail($request->validated('student_id'));$event=$this->security->transaction(auth()->user(),$student,'manual',$request->validated('reason'));return back()->with('status','Manual verification recorded: '.strtoupper($event->action).'.');}
 public function face(Request $request):Response{$this->guard();$request->validate(['capture'=>'required|string|max:200000']);if(!$this->faces->available())return response()->json(['success'=>false,'message'=>'Face verification provider is unavailable. Manual verification is the authorized fallback.','errors'=>['code'=>'FACE_SERVICE_UNAVAILABLE']],503);return response()->json(['success'=>false,'message'=>'Face verification could not be completed safely.','errors'=>['code'=>'FACE_VERIFICATION_UNSUPPORTED']],503);}
}
