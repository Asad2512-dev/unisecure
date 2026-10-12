<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\SystemSetting;
use Illuminate\Http\Request;
class SettingsController extends Controller
{
 public function edit(){abort_unless(auth()->user()->isAdmin()||auth()->user()->hasPermission('settings.manage'),403);return view('admin.settings.edit',['title'=>'System settings','settings'=>SystemSetting::orderBy('key')->get()]);}
 public function update(Request $request){abort_unless(auth()->user()->isAdmin()||auth()->user()->hasPermission('settings.manage'),403);$settings=SystemSetting::all()->keyBy('key');$rules=[];foreach($settings as $key=>$setting){if(!$setting->is_protected)$rules[$key]=$setting->type==='integer'?'required|integer|min:0':($setting->type==='boolean'?'nullable|boolean':'required|string|max:255');}$data=$request->validate($rules);foreach($data as $key=>$value){if(isset($settings[$key]))$settings[$key]->update(['value'=>$settings[$key]->type==='boolean'?($request->boolean($key)?'true':'false'):(string)$value]);}return back()->with('status','Settings updated successfully.');}
}
