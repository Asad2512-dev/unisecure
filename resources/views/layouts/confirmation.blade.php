<dialog id="confirm-dialog" aria-labelledby="confirm-dialog-title" aria-describedby="confirm-dialog-message" class="m-auto w-[calc(100%-2rem)] max-w-md rounded-3xl border border-slate-200 bg-white p-0 text-brand-navy shadow-2xl backdrop:bg-brand-navy/45 backdrop:backdrop-blur-sm">
    <div class="p-7 sm:p-8">
        <div class="flex items-center justify-between"><span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-indigo-50 text-2xl font-bold text-brand-teal" aria-hidden="true">?</span><span class="text-xs font-bold tracking-widest text-slate-400">UNISECURE</span></div>
        <h2 id="confirm-dialog-title" class="mt-6 text-xl font-bold tracking-tight">Confirm this action</h2>
        <p id="confirm-dialog-message" class="mt-3 text-sm leading-7 text-slate-500">Continue with this change?</p>
        <div class="mt-8 grid grid-cols-2 gap-3">
            <button id="confirm-dialog-cancel" type="button" autofocus class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-brand-teal">Cancel</button>
            <button id="confirm-dialog-action" type="button" class="rounded-xl bg-brand-teal px-4 py-3 text-sm font-bold text-white shadow-lg shadow-brand-teal/15 hover:bg-brand-navy focus-visible:outline-2 focus-visible:outline-brand-teal">Confirm</button>
        </div>
    </div>
</dialog>
