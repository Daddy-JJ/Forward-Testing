const pages = [
  ["Home", "index.html"],
  ["Features", "features.html"],
  ["Pricing", "pricing.html"],
  ["FAQ", "faq.html"],
  ["About", "about.html"],
];

function navLink(label, href, active, mobile = false) {
  const base = mobile
    ? "block rounded-md px-3 py-2 text-base font-medium"
    : "rounded-md px-3 py-2 text-sm font-medium";
  const state = active === label
    ? "bg-blue-50 text-blue-700"
    : "text-slate-600 hover:bg-slate-50 hover:text-slate-950";
  return `<a href="${href}" class="${base} ${state}"${active === label ? ' aria-current="page"' : ""}>${label}</a>`;
}

function renderHeader() {
  const root = document.querySelector("[data-site-header]");
  if (!root) return;
  const active = document.body.dataset.page;
  root.innerHTML = `
    <header class="border-b border-slate-200 bg-white">
      <nav class="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8" aria-label="Primary navigation">
        <a href="index.html" class="flex items-center gap-2 text-sm font-semibold text-slate-950">
          <span class="flex h-8 w-8 items-center justify-center rounded-md bg-blue-600 text-white"><i data-lucide="chart-no-axes-combined" class="h-5 w-5" aria-hidden="true"></i></span>
          <span>Forward Testing</span>
        </a>
        <div class="hidden items-center gap-1 md:flex">${pages.map(([label, href]) => navLink(label, href, active)).join("")}</div>
        <div class="hidden items-center gap-2 md:flex header-action-area">
          <a href="login.html" class="rounded-md px-3 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50">Log in</a>
          <a href="register.html" class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2">Create account</a>
        </div>
        <button type="button" data-menu-button class="flex h-10 w-10 items-center justify-center rounded-md text-slate-700 hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-600 md:hidden" aria-expanded="false" aria-controls="mobile-menu" aria-label="Open navigation">
          <i data-menu-icon data-lucide="menu" class="h-5 w-5" aria-hidden="true"></i>
        </button>
      </nav>
      <div id="mobile-menu" data-mobile-menu class="hidden border-t border-slate-200 px-4 py-4 md:hidden">
        <div class="space-y-1">${pages.map(([label, href]) => navLink(label, href, active, true)).join("")}</div>
        <div class="mt-4 grid grid-cols-2 gap-2 border-t border-slate-200 pt-4" data-mobile-actions>
          <a href="login.html" class="rounded-md border border-slate-300 px-4 py-2 text-center text-sm font-semibold text-slate-700">Log in</a>
          <a href="register.html" class="rounded-md bg-blue-600 px-4 py-2 text-center text-sm font-semibold text-white">Create account</a>
        </div>
      </div>
    </header>`;

  const button = root.querySelector("[data-menu-button]");
  const menu = root.querySelector("[data-mobile-menu]");
  button.addEventListener("click", () => {
    const open = button.getAttribute("aria-expanded") === "true";
    button.setAttribute("aria-expanded", String(!open));
    button.setAttribute("aria-label", open ? "Open navigation" : "Close navigation");
    menu.classList.toggle("hidden", open);
    button.querySelector("[data-menu-icon]").setAttribute("data-lucide", open ? "menu" : "x");
    lucide.createIcons();
  });
}

function renderFooter() {
  const root = document.querySelector("[data-site-footer]");
  if (!root) return;
  root.innerHTML = `
    <footer class="border-t border-slate-200 bg-white">
      <div class="mx-auto flex max-w-7xl flex-col gap-6 px-4 py-10 sm:px-6 md:flex-row md:items-center md:justify-between lg:px-8">
        <div>
          <a href="index.html" class="flex items-center gap-2 text-sm font-semibold text-slate-950">
            <span class="flex h-7 w-7 items-center justify-center rounded-md bg-blue-600 text-white"><i data-lucide="chart-no-axes-combined" class="h-4 w-4" aria-hidden="true"></i></span>
            Forward Testing
          </a>
          <p class="mt-2 text-sm text-slate-500">Build confidence before committing capital.</p>
        </div>
        <nav class="flex flex-wrap gap-x-5 gap-y-2" aria-label="Footer navigation">
          ${pages.slice(1).map(([label, href]) => `<a href="${href}" class="text-sm text-slate-600 hover:text-slate-950">${label}</a>`).join("")}
        </nav>
      </div>
    </footer>`;
}

const AUTH_KEY = "forwardTestingAuth";
const dummyAccounts = [
  { role: "User", email: "user@example.com", password: "userpass123" },
  { role: "Admin", email: "admin@example.com", password: "adminpass123" },
];

function getFeedbackElement(id) {
  return document.getElementById(id);
}

function setFeedback(element, message, variant = "info") {
  if (!element) return;
  const base = "mt-4 rounded-md px-4 py-3 text-sm";
  const style = variant === "success"
    ? "border border-emerald-200 bg-emerald-50 text-emerald-900"
    : variant === "error"
    ? "border border-rose-200 bg-rose-50 text-rose-900"
    : "border border-slate-200 bg-slate-50 text-slate-700";
  element.className = `${base} ${style}`;
  element.textContent = message;
}

function getAuthState() {
  try {
    return JSON.parse(localStorage.getItem(AUTH_KEY));
  } catch (error) {
    return null;
  }
}

function setAuthState(state) {
  localStorage.setItem(AUTH_KEY, JSON.stringify(state));
}

function clearAuthState() {
  localStorage.removeItem(AUTH_KEY);
}

function redirectToDashboard(role) {
  if (role === "Admin") {
    window.location.href = "admin-dashboard.html";
    return;
  }
  window.location.href = "user-dashboard.html";
}

function renderAuthLinks(auth) {
  if (auth) {
    return `
      <a href="${auth.role === "Admin" ? "admin-dashboard.html" : "user-dashboard.html"}" class="rounded-md px-3 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50">Dashboard</a>
      <button type="button" id="sign-out-button" class="rounded-md bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-200">Sign out</button>
    `;
  }

  return `
    <a href="login.html" class="rounded-md px-3 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50">Log in</a>
    <a href="register.html" class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2">Create account</a>
  `;
}

function updateHeaderActions() {
  const auth = getAuthState();
  const root = document.querySelector("[data-site-header]");
  if (!root) return;

  const actionArea = root.querySelector(".header-action-area");
  const mobileActions = root.querySelector("[data-mobile-actions]");
  if (actionArea) {
    actionArea.innerHTML = renderAuthLinks(auth);
  }
  if (mobileActions) {
    mobileActions.innerHTML = renderAuthLinks(auth);
  }

  const signOutButton = document.getElementById("sign-out-button");
  if (signOutButton) {
    signOutButton.addEventListener("click", () => {
      clearAuthState();
      window.location.href = "login.html";
    });
  }
}

function redirectIfAlreadyAuthenticated() {
  const auth = getAuthState();
  if (!auth) return;
  if (window.location.pathname.endsWith("login.html") || window.location.pathname.endsWith("register.html")) {
    redirectToDashboard(auth.role);
  }
}

function handleLoginSubmit(event) {
  event.preventDefault();
  const email = event.target.email.value.trim();
  const password = event.target.password.value;
  const feedback = getFeedbackElement("login-feedback");
  const account = dummyAccounts.find(
    (item) => item.email.toLowerCase() === email.toLowerCase() && item.password === password
  );

  if (account) {
    setAuthState({ email: account.email, role: account.role });
    setFeedback(feedback, `Berhasil login sebagai ${account.role}. Mengarahkan ke dashboard...`, "success");
    setTimeout(() => redirectToDashboard(account.role), 600);
    return;
  }

  setFeedback(feedback, "Email atau password tidak cocok. Gunakan akun dummy yang tersedia.", "error");
}

function handleRegisterSubmit(event) {
  event.preventDefault();
  setFeedback(
    getFeedbackElement("register-feedback"),
    "Registrasi tidak aktif dalam demo ini. Silakan gunakan akun dummy pada halaman login.",
    "info"
  );
}

function enforcePageAccess() {
  const allowed = document.body.dataset.allowedRoles;
  if (!allowed) return;

  const auth = getAuthState();
  const feedback = getFeedbackElement("auth-feedback");
  const allowedRoles = allowed.split(",").map((role) => role.trim());

  if (!auth) {
    if (feedback) {
      setFeedback(feedback, "Anda harus login terlebih dahulu untuk melihat halaman ini.", "error");
    }
    setTimeout(() => {
      window.location.href = "login.html";
    }, 1200);
    return;
  }

  if (!allowedRoles.includes(auth.role)) {
    if (feedback) {
      setFeedback(feedback, `Akses ditolak. Anda login sebagai ${auth.role}.`, "error");
    }
    setTimeout(() => {
      window.location.href = auth.role === "Admin" ? "admin-dashboard.html" : "user-dashboard.html";
    }, 1200);
    return;
  }

  if (feedback) {
    setFeedback(feedback, `Masuk sebagai ${auth.role}.`, "success");
  }
}

function initAuthForms() {
  const loginForm = document.getElementById("login-form");
  if (loginForm) {
    loginForm.addEventListener("submit", handleLoginSubmit);
  }

  const registerForm = document.getElementById("register-form");
  if (registerForm) {
    registerForm.addEventListener("submit", handleRegisterSubmit);
  }
}

function initApp() {
  renderHeader();
  renderFooter();
  initAuthForms();
  updateHeaderActions();
  enforcePageAccess();
  redirectIfAlreadyAuthenticated();
  lucide.createIcons();
}

initApp();
