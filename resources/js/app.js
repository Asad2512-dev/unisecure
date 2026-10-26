import { icon } from '@fortawesome/fontawesome-svg-core';
import { faGaugeHigh, faUsers, faUserGraduate, faChalkboardUser, faUserShield, faBuildingColumns, faGraduationCap, faCalendarDays, faLayerGroup, faBookOpen, faDoorOpen, faToriiGate, faCalendarCheck, faClipboardCheck, faChartLine, faFileLines, faBell, faGear, faShieldHalved } from '@fortawesome/free-solid-svg-icons';

const loader = () => { const element = document.getElementById('global-loader'); element?.classList.remove('hidden'); element?.classList.add('flex'); };

document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('[data-snackbar]').forEach((snackbar) => {
        snackbar.querySelector('[data-dismiss-snackbar]')?.addEventListener('click', () => snackbar.remove());
        if (snackbar.dataset.kind === 'success') {
            let timeout;
            const scheduleDismiss = () => { timeout = window.setTimeout(() => snackbar.remove(), 6000); };
            snackbar.addEventListener('mouseenter', () => window.clearTimeout(timeout));
            snackbar.addEventListener('focusin', () => window.clearTimeout(timeout));
            snackbar.addEventListener('mouseleave', scheduleDismiss);
            snackbar.addEventListener('focusout', scheduleDismiss);
            scheduleDismiss();
        }
    });
    const password = document.getElementById('password');
    const passwordToggle = password?.parentElement.querySelector('button[type="button"]');
    if (password && passwordToggle) {
        passwordToggle.textContent = 'Show';
        passwordToggle.addEventListener('click', () => {
            password.type = password.type === 'password' ? 'text' : 'password';
            passwordToggle.textContent = password.type === 'password' ? 'Show' : 'Hide';
        });
    }
    const sidebar = document.querySelector('aside');
    if (sidebar) {
        const currentPath = window.location.pathname.replace(/\/$/, '');
        const links = [...sidebar.querySelectorAll('nav a[href]')];
        const navigationIcons = {
            Dashboard: faGaugeHigh, Users: faUsers, Students: faUserGraduate,
            Teachers: faChalkboardUser, Guards: faUserShield, Departments: faBuildingColumns,
            Programs: faGraduationCap, Semesters: faCalendarDays, Sections: faLayerGroup,
            Courses: faBookOpen, Rooms: faDoorOpen, Gates: faToriiGate,
            Schedules: faCalendarCheck, Attendance: faClipboardCheck, Analytics: faChartLine,
            Reports: faFileLines, Notifications: faBell, Settings: faGear, 'Security desk': faShieldHalved,
        };
        links.forEach((link) => {
            const mark = link.querySelector('span');
            const label = [...link.childNodes].filter((node) => node.nodeType === Node.TEXT_NODE).map((node) => node.textContent).join('').trim();
            const definition = navigationIcons[label];
            if (mark && definition) {
                mark.replaceChildren(icon(definition).node[0]);
                mark.classList.add('navigation-icon');
                mark.setAttribute('aria-hidden', 'true');
                link.title = label;
                link.setAttribute('aria-label', label);
            }
        });
        const activeLink = links
            .filter((link) => {
                const path = new URL(link.href).pathname.replace(/\/$/, '');
                return currentPath === path || (path !== '/admin' && currentPath.startsWith(`${path}/`));
            })
            .sort((left, right) => new URL(right.href).pathname.length - new URL(left.href).pathname.length)[0];
        links.forEach((link) => link.setAttribute('title', link.textContent.trim()));
        activeLink?.setAttribute('aria-current', 'page');
        const brand = sidebar.firstElementChild;
        brand?.classList.add('sidebar-brand');
        const logoControl = document.createElement('button');
        logoControl.type = 'button';
        logoControl.className = 'sidebar-logo-control';
        const originalMark = brand?.firstElementChild;
        if (originalMark) {
            originalMark.before(logoControl);
            logoControl.appendChild(originalMark);
        }
        const toggle = document.createElement('button');
        toggle.type = 'button';
        toggle.id = 'sidebar-toggle';
        toggle.setAttribute('aria-label', 'Collapse sidebar');
        toggle.className = 'sidebar-toggle hidden md:flex';
        toggle.innerHTML = '<span>‹</span>';
        brand?.appendChild(toggle);
        sidebar.querySelectorAll(':scope > div').forEach((section) => {
            if (section !== brand && section.classList.contains('px-3')) section.classList.add('sidebar-section-label');
        });
        const setCollapsed = (collapsed) => {
            document.body.classList.toggle('sidebar-collapsed', collapsed);
            toggle.setAttribute('aria-label', collapsed ? 'Expand sidebar' : 'Collapse sidebar');
            toggle.innerHTML = `<span>${collapsed ? '›' : '‹'}</span>`;
            logoControl.setAttribute('aria-label', collapsed ? 'Expand sidebar' : 'UniSecure');
            logoControl.title = collapsed ? 'Expand sidebar' : 'UniSecure';
            logoControl.setAttribute('aria-expanded', String(!collapsed));
            localStorage.setItem('unisecure.sidebar.collapsed', collapsed ? '1' : '0');
        };
        toggle.addEventListener('click', () => setCollapsed(!document.body.classList.contains('sidebar-collapsed')));
        logoControl.addEventListener('click', () => {
            if (document.body.classList.contains('sidebar-collapsed')) setCollapsed(false);
        });
        setCollapsed(localStorage.getItem('unisecure.sidebar.collapsed') === '1');
    }

    const favicon = document.createElement('link');
    favicon.rel = 'icon';
    favicon.type = 'image/png';
    favicon.href = '/logo.png';
    document.head.appendChild(favicon);

    const brandMark = document.querySelector('aside .flex.h-10.w-10');
    if (brandMark) {
        brandMark.textContent = '';
        const logo = document.createElement('img');
        logo.src = '/logo.png';
        logo.alt = 'UniSecure logo';
        logo.className = 'h-full w-full rounded-xl object-cover';
        brandMark.appendChild(logo);
    }

    const headerActions = document.querySelector('header > div:last-child');
    const existingUser = headerActions?.querySelector('div.text-right');
    const existingLogout = headerActions?.querySelector('form[action*="logout"]');
    if (headerActions && existingUser && existingLogout) {
        const name = existingUser.querySelector('p')?.textContent?.trim() || 'Administrator';
        const initials = name.split(/\s+/).map((part) => part[0]).join('').slice(0, 2).toUpperCase();
        existingUser.classList.add('hidden');
        existingLogout.classList.add('hidden');
        existingUser.style.display = 'none';
        existingLogout.style.display = 'none';
        const profile = document.createElement('div');
        profile.className = 'relative';
        profile.innerHTML = `<button type="button" id="profile-menu-button" aria-expanded="false" aria-haspopup="true" class="flex items-center gap-2 rounded-2xl border border-slate-200 bg-white p-1.5 pr-3 text-left shadow-sm transition hover:border-indigo-200 hover:shadow-md"><span class="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-violet-600 text-xs font-bold text-white shadow-lg shadow-indigo-500/20">${initials}</span><span class="hidden sm:block"><span class="block max-w-32 truncate text-xs font-bold text-slate-800">${name}</span><span class="block text-[10px] font-medium text-slate-400">Administrator</span></span><span class="ml-1 text-xs text-slate-400">⌄</span></button><div id="profile-menu" class="absolute right-0 top-14 z-50 hidden w-64 overflow-hidden rounded-2xl border border-slate-200 bg-white p-2 shadow-2xl shadow-slate-950/10"><div class="flex items-center gap-3 rounded-xl bg-slate-50 p-3"><span class="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-violet-600 text-xs font-bold text-white">${initials}</span><div class="min-w-0"><p class="truncate text-sm font-bold text-slate-900">${name}</p><p class="text-xs text-slate-500">UniSecure Administrator</p></div></div><div class="my-2 border-t border-slate-100"></div><div class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs text-slate-600"><span class="h-2 w-2 rounded-full bg-emerald-500"></span>Account active and secure</div><button type="button" id="profile-signout" class="mt-1 flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-semibold text-rose-600 transition hover:bg-rose-50">↪ <span>Sign out</span></button></div>`;
        headerActions.appendChild(profile);
        profile.querySelector('#profile-menu-button > span:nth-child(2)')?.remove();
        const menuButton = profile.querySelector('#profile-menu-button');
        const menu = profile.querySelector('#profile-menu');
        menuButton.addEventListener('click', () => { const open = !menu.classList.contains('hidden'); menu.classList.toggle('hidden', open); menuButton.setAttribute('aria-expanded', String(!open)); });
        profile.querySelector('#profile-signout').addEventListener('click', () => existingLogout.requestSubmit());
        document.addEventListener('click', (event) => { if (!profile.contains(event.target)) { menu.classList.add('hidden'); menuButton.setAttribute('aria-expanded', 'false'); } });
    }

    const dialog = document.getElementById('confirm-dialog');
    const dialogTitle = document.getElementById('confirm-dialog-title');
    const dialogMessage = document.getElementById('confirm-dialog-message');
    const confirmButton = document.getElementById('confirm-dialog-action');
    let pendingForm = null;
    let pendingSubmitter = null;
    const approvedForms = new WeakSet();

    document.querySelectorAll('form').forEach((form) => form.addEventListener('submit', (event) => {
        const action = form.getAttribute('action') || '';
        const method = (form.getAttribute('method') || 'get').toLowerCase();
        const isMutation = method !== 'get' && !/\/login(?:$|\/)/i.test(action);
        const needsConfirmation = form.dataset.confirm || isMutation || /checkout|finalize|deactivate|destroy|delete|logout/i.test(action);
        if (!needsConfirmation) return;
        if (!dialog) return;
        if (approvedForms.has(form)) { approvedForms.delete(form); return; }
        event.preventDefault();
        pendingForm = form;
        pendingSubmitter = event.submitter;
        if (dialogTitle) dialogTitle.textContent = form.dataset.confirmTitle || 'Confirm this action';
        const effectiveMethod = form.querySelector('[name="_method"]')?.value.toUpperCase() || method.toUpperCase();
        const destructive = effectiveMethod === 'DELETE' || /deactivate/i.test(action);
        if (dialogMessage) dialogMessage.textContent = form.dataset.confirm || (/logout/i.test(action) ? 'Are you sure you want to sign out of your UniSecure session?' : destructive ? 'Confirm that you want to remove or deactivate this record.' : ['PUT', 'PATCH'].includes(effectiveMethod) ? 'Save these updates to this record?' : 'Continue and submit this change?');
        confirmButton.textContent = /logout/i.test(action) ? 'Sign out' : destructive ? 'Confirm removal' : 'Confirm';
        dialog.showModal();
        document.getElementById('confirm-dialog-cancel')?.focus();
    }));

    confirmButton?.addEventListener('click', () => {
        if (!pendingForm) return;
        const form = pendingForm;
        const submitter = pendingSubmitter;
        approvedForms.add(form);
        dialog.close();
        form.requestSubmit(submitter);
    });
    document.getElementById('confirm-dialog-cancel')?.addEventListener('click', () => dialog.close());
    dialog?.addEventListener('close', () => { pendingForm = null; pendingSubmitter = null; });
    dialog?.addEventListener('click', (event) => {
        const bounds = dialog.getBoundingClientRect();
        if (event.target === dialog && (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom)) dialog.close();
    });

    document.querySelectorAll('a[href]').forEach((link) => {
        link.addEventListener('click', (event) => {
            if (event.defaultPrevented || link.target === '_blank' || link.href.startsWith('javascript:')) return;
            const url = new URL(link.href, window.location.href);
            if (url.origin === window.location.origin) loader();
        });
    });

    document.querySelectorAll('form').forEach((form) => form.addEventListener('submit', (event) => { if (!event.defaultPrevented) loader(); }));
});

window.addEventListener('pageshow', () => document.getElementById('global-loader')?.classList.add('hidden'));
