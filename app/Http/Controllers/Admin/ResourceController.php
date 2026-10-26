<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\CourseEnrollment;
use App\Models\Department;
use App\Models\Gate;
use App\Models\Guard;
use App\Models\Program;
use App\Models\Room;
use App\Models\Section;
use App\Models\Semester;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class ResourceController extends Controller
{
    private array $map = [
        'users' => [User::class, 'Users', 'users.view', 'users.manage', ['name', 'email', 'password', 'role_id', 'status']], 'students' => [Student::class, 'Students', 'academic.view', 'academic.manage', ['student_id', 'official_email', 'user_id', 'department_id', 'program_id', 'semester_id', 'section_id', 'status', 'phone', 'date_of_birth', 'gender', 'admission_date']],
        'teachers' => [Teacher::class, 'Teachers', 'academic.view', 'academic.manage', ['employee_id', 'official_email', 'user_id', 'department_id', 'status', 'phone']], 'guards' => [Guard::class, 'Guards', 'security.view', 'security.manage', ['employee_id', 'user_id', 'gate_id', 'status', 'phone']],
        'departments' => [Department::class, 'Departments', 'academic.view', 'academic.manage', ['name', 'code', 'description', 'status']], 'programs' => [Program::class, 'Programs', 'academic.view', 'academic.manage', ['name', 'code', 'department_id', 'duration_years', 'status']],
        'semesters' => [Semester::class, 'Semesters', 'academic.view', 'academic.manage', ['name', 'number', 'academic_year', 'status']], 'sections' => [Section::class, 'Sections', 'academic.view', 'academic.manage', ['name', 'code', 'program_id', 'semester_id', 'capacity', 'status']],
        'courses' => [Course::class, 'Courses', 'academic.view', 'academic.manage', ['course_code', 'name', 'department_id', 'credit_hours', 'description', 'status']], 'course-enrollments' => [CourseEnrollment::class, 'Course enrollments', 'academic.view', 'academic.manage', ['student_id', 'course_id', 'section_id', 'academic_year', 'semester_id', 'status']], 'rooms' => [Room::class, 'Rooms', 'academic.view', 'academic.manage', ['name', 'building', 'floor', 'capacity', 'status']], 'gates' => [Gate::class, 'Gates', 'security.view', 'security.manage', ['name', 'code', 'location', 'status']],
    ];

    private function config(string $resource): array
    {
        abort_unless(isset($this->map[$resource]), 404);

        return $this->map[$resource];
    }

    private function authorize(string $resource, string $permission): void
    {
        abort_unless(auth()->user()->isAdmin() || auth()->user()->hasPermission($permission), 403);
    }

    private function lookups(string $resource): array
    {
        return match ($resource) {
            'users' => ['roles' => DB::table('roles')->orderBy('display_name')->get()], 'students' => ['users' => User::orderBy('name')->get(), 'departments' => Department::orderBy('name')->get(), 'programs' => Program::orderBy('name')->get(), 'semesters' => Semester::orderBy('academic_year', 'desc')->get(), 'sections' => Section::orderBy('name')->get()], 'teachers' => ['users' => User::orderBy('name')->get(), 'departments' => Department::orderBy('name')->get()], 'guards' => ['users' => User::orderBy('name')->get(), 'gates' => Gate::orderBy('name')->get()], 'programs' => ['departments' => Department::orderBy('name')->get()], 'sections' => ['programs' => Program::orderBy('name')->get(), 'semesters' => Semester::orderBy('academic_year', 'desc')->get()], 'courses' => ['departments' => Department::orderBy('name')->get()], 'course-enrollments' => ['students' => Student::orderBy('student_id')->get(), 'courses' => Course::orderBy('course_code')->get(), 'sections' => Section::orderBy('code')->get(), 'semesters' => Semester::orderBy('academic_year', 'desc')->get()], default => []
        };
    }

    public function index(Request $request, string $resource)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $viewPermission);
        $q = $class::query();
        if ($resource === 'users') {
            $q->with('role');
        }$search = trim((string) $request->query('q'));
        if ($search) {
            $q->where(function ($x) use ($search, $resource) {
                foreach (match ($resource) {
                    'users' => ['name', 'email'],'students' => ['student_id', 'official_email'],'teachers' => ['employee_id', 'official_email'],'guards' => ['employee_id'],'departments' => ['name', 'code'],'programs' => ['name', 'code'],'semesters' => ['name', 'academic_year'],'sections' => ['name', 'code'],'courses' => ['course_code', 'name'],'rooms' => ['name', 'building'],'gates' => ['name', 'code'],default => ['name']
                } as $field) {
                    $x->orWhere($field, 'like', '%'.$search.'%');
                }
            });
        }$records = $q->latest()->paginate(15)->withQueryString();

        return view('admin.resources.index', compact('resource', 'title', 'records', 'fields', 'managePermission', 'search'));
    }

    public function create(string $resource)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $managePermission);

        return view('admin.resources.form', array_merge(compact('resource', 'title', 'fields'), $this->lookups($resource), ['record' => null]));
    }

    public function store(Request $request, string $resource)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $managePermission);
        $data = $this->validated($request, $resource);
        $record = $class::create($data);

        return redirect()->route('admin.resource.show', [$resource, $record])->with('status', "{$title} record created successfully.");
    }

    public function show(string $resource, int $id)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $viewPermission);
        $record = $class::findOrFail($id);

        return view('admin.resources.show', compact('resource', 'title', 'record', 'fields', 'managePermission'));
    }

    public function edit(string $resource, int $id)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $managePermission);
        $record = $class::findOrFail($id);

        return view('admin.resources.form', array_merge(compact('resource', 'title', 'fields', 'record'), $this->lookups($resource)));
    }

    public function update(Request $request, string $resource, int $id)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $managePermission);
        $record = $class::findOrFail($id);
        $record->update($this->validated($request, $resource, $record));

        return redirect()->route('admin.resource.show', [$resource, $record])->with('status', "{$title} record updated successfully.");
    }

    public function destroy(string $resource, int $id)
    {
        [$class,$title,$viewPermission,$managePermission,$fields] = $this->config($resource);
        $this->authorize($resource, $managePermission);
        $record = $class::findOrFail($id);
        if (in_array('status', $fields, true)) {
            $record->update(['status' => 'inactive']);
        } elseif (method_exists($record, 'delete')) {
            $record->delete();
        }

        return redirect()->route('admin.resource.index', $resource)->with('status', "{$title} record deactivated.");
    }

    private function validated(Request $request, string $resource, $record = null): array
    {
        $rules = [];
        foreach ($this->config($resource)[4] as $field) {
            $rules[$field] = in_array($field, ['name', 'code', 'student_id', 'employee_id', 'course_code', 'official_email', 'email']) ? 'required|string|max:255' : 'nullable';
        } if ($resource === 'users') {
            $rules['email'] = 'required|email|max:255';
            $rules['password'] = $record ? 'nullable|string|min:12' : 'required|string|min:12';
        } $rules['role_id'] = 'nullable|exists:roles,id';
        $rules['user_id'] = 'nullable|exists:users,id';
        foreach (['department_id', 'program_id', 'semester_id', 'section_id', 'gate_id'] as $f) {
            $rules[$f] = 'nullable|integer';
        }$rules['duration_years'] = 'nullable|integer|min:1|max:10';
        $rules['credit_hours'] = 'nullable|integer|min:1|max:20';
        $rules['capacity'] = 'nullable|integer|min:1';
        $rules['number'] = 'nullable|integer|min:1';
        $unique = match ($resource) {
            'departments' => 'code','programs' => 'code','sections' => 'code','courses' => 'course_code','gates' => 'code','students' => 'student_id','teachers' => 'employee_id','guards' => 'employee_id',default => null
        };
        if ($unique) {
            $rules[$unique] = ['required', 'string', 'max:255', Rule::unique($this->config($resource)[0], $unique)->ignore($record?->id)];
        }$data = $request->validate($rules);
        if (empty($data['password'])) {
            unset($data['password']);
        }

        return array_intersect_key($data, array_flip($this->config($resource)[4]));
    }
}
