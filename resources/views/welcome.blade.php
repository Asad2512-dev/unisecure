<!doctype html>
<html lang="en" class="scroll-smooth">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="UniSecure brings university administration, academics, attendance and campus security together in one connected workspace.">
    <meta name="theme-color" content="#10233F">
    <title>UniSecure · A more connected campus</title>
    <link rel="icon" type="image/png" href="{{ asset('logo.png') }}">
    @vite(['resources/css/app.css'])
</head>
<body class="bg-brand-surface text-brand-navy antialiased">
<a href="#main" class="sr-only focus:not-sr-only focus:fixed focus:z-50 focus:bg-white focus:p-4">Skip to content</a>
<header class="border-b border-brand-navy/5 bg-white/90">
    <nav aria-label="Main navigation" class="mx-auto flex max-w-7xl items-center justify-between gap-5 px-6 py-5 lg:px-10">
        <a href="/" class="flex items-center gap-3"><img src="{{ asset('logo.png') }}" alt="" class="h-11 w-11 object-contain"><span class="text-2xl font-bold tracking-tight">UniSecure<span class="text-brand-teal">.</span></span></a>
        <div class="hidden items-center gap-8 text-sm font-medium text-slate-600 md:flex"><a href="#platform" class="hover:text-brand-teal">The platform</a><a href="#people" class="hover:text-brand-teal">Built for your campus</a><a href="#security" class="hover:text-brand-teal">Security</a></div>
        <a href="{{ route('login') }}" class="rounded-full bg-brand-navy px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-teal">Sign in <span aria-hidden="true" class="ml-2">↗</span></a>
    </nav>
</header>
<main id="main">
    <section class="relative overflow-hidden">
        <div aria-hidden="true" class="pointer-events-none absolute -right-44 top-10 h-[38rem] w-[38rem] rounded-full bg-brand-teal/8 blur-3xl"></div>
        <div class="relative mx-auto grid max-w-7xl items-center gap-14 px-6 py-16 lg:grid-cols-2 lg:px-10 lg:py-24">
            <div>
                <p class="mb-7 inline-flex items-center gap-2 rounded-full border border-brand-teal/20 bg-white px-4 py-2 text-xs font-semibold text-brand-teal"><span class="h-1.5 w-1.5 rounded-full bg-brand-teal"></span> A smarter way to run your university</p>
                <h1 class="max-w-xl text-5xl font-semibold leading-[1.08] tracking-[-.045em] sm:text-6xl lg:text-7xl">One campus.<br>Every connection.<br><span class="text-brand-teal">Secure.</span></h1>
                <p class="mt-7 max-w-md text-base leading-8 text-slate-600">Bring your people, academics and campus security together. Less administrative friction. More room for education.</p>
                <div class="mt-9 flex flex-wrap items-center gap-5"><a href="{{ route('login') }}" class="rounded-full bg-brand-teal px-7 py-4 text-sm font-bold text-white shadow-lg shadow-brand-teal/15 transition hover:bg-brand-navy">Enter your workspace <span aria-hidden="true" class="ml-3">→</span></a><a href="#platform" class="text-sm font-semibold">Explore the platform <span aria-hidden="true" class="ml-2">↓</span></a></div>
                <div class="mt-10 flex flex-wrap gap-5 text-xs font-medium text-slate-500"><span>✓ Role-based access</span><span>✓ Connected workflows</span><span>✓ Web & mobile</span></div>
            </div>
            <div class="relative min-w-0">
                <div class="rounded-[2rem] border border-white bg-white/60 p-3 shadow-2xl shadow-brand-navy/10 sm:p-5">
                    <div class="overflow-hidden rounded-2xl border border-brand-navy/10 bg-white">
                        <div class="flex items-center justify-between border-b border-slate-100 px-5 py-4"><span class="text-xs font-bold">Campus overview</span><span class="rounded-full bg-brand-surface px-2 py-1 text-[10px] text-slate-500">Platform preview</span></div>
                        <div class="p-5 sm:p-7"><div class="mb-6 flex items-center gap-3"><img src="{{ asset('logo.png') }}" alt="UniSecure" class="h-11 w-11 object-contain"><div><p class="text-lg font-bold">Everything, connected.</p><p class="text-xs text-slate-500">Your university at a glance</p></div></div>
                            <div class="grid grid-cols-2 gap-3">@foreach([['01','People & profiles'],['02','Academic planning'],['03','Attendance'],['04','Campus access']] as [$number,$label])<div class="rounded-xl border border-slate-100 bg-brand-surface/70 p-4"><span class="text-xs font-semibold text-brand-teal">{{ $number }}</span><p class="mt-3 text-sm font-bold">{{ $label }}</p></div>@endforeach</div>
                            <div class="mt-5 rounded-xl bg-brand-navy p-5 text-white"><div class="flex items-center justify-between gap-3"><p class="text-sm font-semibold">Connected campus workflow</p><span class="text-brand-teal" aria-hidden="true">●</span></div><div class="mt-5 flex items-end gap-2" aria-hidden="true">@foreach([35,55,42,72,62,85,74,95,82,100,88,110] as $height)<div class="flex-1 rounded-t bg-brand-teal/80" style="height: {{ $height }}px"></div>@endforeach</div><p class="mt-3 text-[10px] text-slate-300">Illustrative platform overview</p></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <section id="platform" class="scroll-mt-8 bg-white px-6 py-20 lg:px-10">
        <div class="mx-auto max-w-7xl"><div class="flex flex-col justify-between gap-5 md:flex-row md:items-end"><div><p class="text-xs font-bold uppercase tracking-[.2em] text-brand-teal">One connected platform</p><h2 class="mt-4 max-w-xl text-3xl font-semibold tracking-tight sm:text-4xl">Less complexity.<br>More campus clarity.</h2></div><p class="max-w-sm text-sm leading-7 text-slate-500">From the first class of the day to the last visitor checkout, keep essential university operations in sync.</p></div>
            <div class="mt-12 grid gap-6 md:grid-cols-3">@foreach([['01','People, organized','Manage students, teachers, guards and administrative accounts with clear roles and organized profiles.'],['02','Academics, aligned','Connect departments, programs, courses, rooms and schedules in a single administrative workspace.'],['03','Attendance, visible','Review class sessions, record attendance and use reports to understand participation.']] as [$number,$heading,$description])<article class="rounded-2xl border border-slate-200/70 bg-brand-surface/50 p-7"><div class="flex h-11 w-11 items-center justify-center rounded-xl bg-white text-sm font-bold text-brand-teal shadow-sm">{{ $number }}</div><h3 class="mt-8 text-lg font-bold">{{ $heading }}</h3><p class="mt-3 text-sm leading-7 text-slate-500">{{ $description }}</p></article>@endforeach</div>
        </div>
    </section>
    <section id="people" class="mx-auto max-w-7xl scroll-mt-8 px-6 py-20 lg:px-10">
        <p class="text-xs font-bold uppercase tracking-[.2em] text-brand-teal">Designed around people</p><h2 class="mt-4 text-3xl font-semibold tracking-tight sm:text-4xl">Different roles. One UniSecure.</h2>
        <div class="mt-10 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">@foreach([['Administrators','A central web workspace for university records, schedules, reports and settings.','Web workspace'],['Teachers','Stay connected to teaching schedules, class sessions and attendance tools.','Mobile experience'],['Students','Access academic information, timetables, attendance and notifications.','Mobile experience'],['Guards','Support gate verification, campus entry and exit, and visitor management.','Mobile experience']] as [$role,$description,$channel])<article class="border-t-2 border-brand-teal/30 pt-6"><p class="text-[10px] font-bold uppercase tracking-widest text-brand-teal">{{ $channel }}</p><h3 class="mt-3 text-xl font-bold">{{ $role }}</h3><p class="mt-3 text-sm leading-7 text-slate-500">{{ $description }}</p></article>@endforeach</div>
    </section>
    <section id="security" class="mx-4 rounded-[2rem] bg-brand-navy px-6 py-16 text-white sm:mx-6 lg:mx-auto lg:max-w-7xl lg:px-14">
        <div class="grid items-center gap-12 md:grid-cols-2"><div><p class="text-xs font-bold uppercase tracking-[.2em] text-teal-300">A considered approach to access</p><h2 class="mt-5 text-3xl font-semibold leading-tight tracking-tight sm:text-4xl">A welcoming campus.<br>A clearer picture of security.</h2><p class="mt-5 text-sm leading-7 text-slate-300">Give authorized teams the tools to manage access, review activity and maintain visitor records alongside university operations.</p></div><div class="grid gap-4">@foreach([['Role-based permissions','Access aligned with each person’s responsibilities.'],['Campus activity records','Entry, exit and visitor history in one connected workflow.'],['Administrative visibility','Review recorded actions and operational reports.']] as [$heading,$description])<div class="flex gap-4 rounded-2xl border border-white/10 bg-white/5 p-5"><span class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-brand-teal/20 text-teal-300" aria-hidden="true">✓</span><div><h3 class="text-sm font-semibold">{{ $heading }}</h3><p class="mt-1 text-xs leading-6 text-slate-300">{{ $description }}</p></div></div>@endforeach</div></div>
    </section>
    <section class="px-6 py-20 text-center"><p class="text-xs font-bold uppercase tracking-[.2em] text-brand-teal">Your campus starts here</p><h2 class="mt-4 text-3xl font-semibold tracking-tight sm:text-4xl">Ready for a more connected day?</h2><p class="mx-auto mt-4 max-w-md text-sm leading-7 text-slate-500">Sign in with your university account to open your role’s workspace.</p><a href="{{ route('login') }}" class="mt-7 inline-flex rounded-full bg-brand-teal px-7 py-4 text-sm font-bold text-white transition hover:bg-brand-navy">Sign in <span class="ml-4" aria-hidden="true">→</span></a></section>
</main>
<footer class="border-t border-brand-navy/10 px-6 py-7"><div class="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 text-xs text-slate-500 sm:flex-row"><a href="/" class="flex items-center gap-2 text-base font-bold text-brand-navy"><img src="{{ asset('logo.png') }}" alt="" class="h-7 w-7 object-contain">UniSecure</a><p>© {{ date('Y') }} UniSecure. A more connected campus.</p><a href="#main" class="font-semibold hover:text-brand-teal">Back to top ↑</a></div></footer>
</body>
</html>
