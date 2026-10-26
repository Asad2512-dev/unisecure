@if(session('status') || $errors->any())
<div class="pointer-events-none fixed inset-x-0 bottom-6 z-[90] flex flex-col items-center gap-3 px-4" style="padding-bottom: env(safe-area-inset-bottom)">
    @foreach(array_filter(['success' => session('status'), 'error' => $errors->any() ? $errors->first() : null]) as $kind => $message)
    <div data-snackbar data-kind="{{ $kind }}" role="{{ $kind === 'error' ? 'alert' : 'status' }}" class="pointer-events-auto flex w-full max-w-lg items-start gap-3 rounded-2xl border border-white/10 bg-brand-navy px-5 py-4 text-white shadow-2xl">
        <span aria-hidden="true" class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full {{ $kind === 'error' ? 'bg-rose-500/20 text-rose-300' : 'bg-brand-teal text-white' }}">{{ $kind === 'error' ? '!' : '✓' }}</span>
        <p class="min-w-0 flex-1 break-words pt-1 text-sm leading-6">{{ $message }}</p>
        <button type="button" data-dismiss-snackbar aria-label="Dismiss notification" class="rounded-lg px-2 py-1 text-lg text-white/60 hover:bg-white/10 hover:text-white">×</button>
    </div>
    @endforeach
</div>
@endif
