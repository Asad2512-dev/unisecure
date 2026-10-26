@extends('layouts.portal')
@section('content')
<p class="text-sm font-semibold text-brand-teal">Student workspace</p><h1 class="mt-2 text-3xl font-bold">Welcome, {{ auth()->user()->name }}</h1><p class="mt-3 text-slate-500">Your university profile at a glance.</p>
<div class="mt-8 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
@foreach(['Student ID' => $student?->student_id, 'Email' => auth()->user()->email, 'Department' => $student?->department?->name, 'Program' => $student?->program?->name, 'Section' => $student?->section?->name, 'Status' => $student?->status] as $label => $value)
<div class="rounded-2xl border border-slate-200 bg-white p-6"><p class="text-xs font-semibold uppercase text-slate-500">{{ $label }}</p><p class="mt-3 break-words font-semibold">{{ $value ?? 'Not assigned' }}</p></div>
@endforeach</div>
@endsection
