<div class="mb-8">
    <div class="flex flex-wrap items-center justify-between gap-4">
        <div><p class="text-xs font-bold uppercase tracking-[.2em] text-brand-teal">Campus protection</p><h1 class="mt-2 text-3xl font-bold tracking-tight">{{ $title }}</h1><p class="mt-2 text-sm text-slate-500">{{ $guard->user?->name }} · {{ $guard->gate?->name }} <span class="mx-2 text-slate-300">/</span> {{ now()->format('l, M j') }}</p></div>
        <span class="inline-flex items-center gap-2 rounded-full border border-brand-teal/20 bg-white px-4 py-2 text-xs font-semibold text-brand-teal"><span class="h-2 w-2 rounded-full bg-brand-teal"></span>Authorized gate access</span>
    </div>
    <nav aria-label="Security workspace" class="mt-7 flex flex-wrap gap-2 border-b border-slate-200 pb-4">
        @foreach([['security.desk','Overview & verification'],['security.visitors.index','Visitors'],['security.transactions','My transactions'],['security.profile','Profile & gate']] as [$route,$label])
            <a href="{{ route($route) }}" @if(request()->routeIs($route)) aria-current="page" @endif class="rounded-xl px-4 py-2.5 text-sm font-semibold transition {{ request()->routeIs($route) ? 'bg-brand-navy text-white shadow-sm' : 'text-slate-500 hover:bg-white hover:text-brand-navy' }}">{{ $label }}</a>
        @endforeach
    </nav>
</div>
