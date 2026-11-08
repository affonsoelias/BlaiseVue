# 🔐 Module 17: Full-Stack JWT Authentication & Route Guards
**Implement enterprise-grade identity, salted password hashing, JWT tokens, and reactive route guards.**

Security is the cornerstone of every production web application. Modern systems need to securely hash passwords, generate and verify cryptographic JSON Web Tokens (JWT), maintain authenticated user sessions, and prevent unauthorized access to sensitive pages.

In BlaiseVue, you don't need to assemble third-party OAuth libraries or configure external identity providers. With **`bv mormot auth`**, you get a complete, native, RFC-compliant authentication stack implemented entirely in Object Pascal!

---

## 🛠️ 1. Scaffolding Authentication with `bv mormot auth`

In your project directory, execute:

```bash
bv mormot auth
```

The CLI executes an automated 5-step security pipeline:
1. **Verifies Environment**: Confirms the `server/` directory and mORMot 2 architecture are present.
2. **Registers Auth Models**: Injects `TAuthUser`, `TUserWithPassword`, and `TAuthToken` records into `server/ServerModels.pas`.
3. **Generates Native Security Engine**: Creates `server/AuthService.pas`, featuring:
   - Salted SHA-256 password hashing.
   - RFC 7519 HMAC-SHA256 JWT generation and validation without any external libraries.
4. **Wires Backend Endpoints**: Injects `/api/auth/login`, `/api/auth/register`, `/api/auth/logout`, and `/api/auth/me` into `server/ServerApp.pas` with real-time WebSocket session events.
5. **Creates Frontend Views & Guards**: Scaffolds `src/views/LoginView.bv`, wires the global `$auth` helper, and registers route guards in `src/app.bv`.

---

## 👥 2. Out-of-the-Box Seed Accounts

For instant local development and testing, `bv mormot auth` provisions pre-seeded accounts:

| Role | Email | Password | Permissions |
|---|---|---|---|
| **Admin** | `admin@blaisevue.dev` | `admin123` | Full administrative access; inherits all roles |
| **Manager** | `manager@blaisevue.dev` | `manager123` | Department management & record modification |
| **User** | `user@blaisevue.dev` | `user123` | Standard authenticated user |

---

## 🔑 3. The Global `$auth` Helper API

In your BlaiseVue components, authentication state and methods are accessible everywhere through the global `$auth` helper:

```typescript
// Authentication Actions
$auth.login(email, password): Promise<{ success: boolean, token: string, user: TAuthUser }>
$auth.logout(): void

// Reactive Session Properties
$auth.isAuthenticated: boolean
$auth.user: { id: number, name: string, email: string, role: string, createdAt: string } | null
$auth.token: string

// Role-Based Access Control (RBAC)
$auth.hasRole('admin' | 'manager' | 'user'): boolean
```

### Automatic Token Synchronization
When a user logs in via `$auth.login()`:
1. The token is securely stored in `localStorage.getItem('bv_auth_token')`.
2. The global HTTP client (`$api`) is automatically configured with the header:  
   `Authorization: Bearer <token>` for all subsequent requests.
3. The WebSocket connection automatically passes the token in its handshake headers.

---

## 🛡️ 4. Protecting Routes with Pascal Route Guards

Securing pages against unauthenticated or unauthorized users is declarative. In your router configuration (`src/app.bv`):

```pascal
router:
  routes:
    '/': (component: 'home-view');
    '/login': (component: 'login-view-page');

    // Protected Route: Requires any authenticated user
    '/dashboard': (
      component: 'dashboard-page', 
      meta: (requiresAuth: true)
    );

    // Restricted Route: Requires 'admin' role
    '/admin': (
      component: 'admin-page', 
      meta: (requiresAuth: true, roles: ['admin'])
    );
```

### The Redirect-After-Login UX Pattern:
If an unauthenticated visitor tries to navigate directly to `http://localhost:8090/#/admin`:
1. The route guard intercepts the navigation.
2. The guard saves the intended destination (`/admin`) into `$auth.redirectAfterLogin`.
3. The visitor is redirected to `#/login` with an informational notice: *"Please sign in to access this page."*
4. Upon successful sign-in, the application **automatically navigates the user back to `/admin`**!

---

## 💻 5. Building an Authenticated Navigation Bar

Here is how you can render conditional navigation controls based on `$auth` state:

```html
<template>
  <nav class="navbar">
    <div class="brand">🚀 BlaiseVue Enterprise</div>

    <div class="nav-links">
      <router-link to="/">Home</router-link>
      <router-link b-if="$auth.isAuthenticated" to="/dashboard">Dashboard</router-link>
      <router-link b-if="$auth.hasRole('admin')" to="/admin">Admin Panel</router-link>
    </div>

    <!-- Auth Controls -->
    <div class="auth-box">
      <!-- State A: User is logged in -->
      <div b-if="$auth.isAuthenticated" class="user-profile">
        <span>👤 {{ $auth.user.name }} (<em>{{ $auth.user.role }}</em>)</span>
        <button @click="handleLogout" class="btn-logout">Logout</button>
      </div>

      <!-- State B: User is a guest -->
      <div b-else>
        <router-link to="/login" class="btn-login">Sign In</router-link>
      </div>
    </div>
  </nav>
</template>

<script>
methods:
  procedure handleLogout;
  begin
    $auth.logout;
    $router.push('/login');
  end;
</script>

<style>
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  background: #1e293b;
  color: #fff;
}
.nav-links a {
  color: #cbd5e1;
  text-decoration: none;
  margin-right: 18px;
  font-weight: 500;
}
.nav-links a.active { color: #38bdf8; }
.auth-box { display: flex; align-items: center; gap: 12px; }
.btn-login {
  background: #2563eb;
  color: #fff;
  padding: 6px 14px;
  border-radius: 6px;
  text-decoration: none;
}
.btn-logout {
  background: #475569;
  color: #fff;
  border: none;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
}
</style>
```

---

## 🏋️ Practical Exercise

1. In your project, run `bv mormot auth` to scaffold the authentication system.
2. Start the server with `bv mormot run`.
3. In your browser, open `http://localhost:8090/#/login`.
4. Sign in using the seed account `user@blaisevue.dev` / `user123`.
5. Try navigating manually to `#/admin` and verify that access is blocked because standard users lack the `'admin'` role.
6. Log out, sign back in as `admin@blaisevue.dev` / `admin123`, and confirm that the Admin Panel is now unlocked!

---

## 📖 Deeper Technical Reference

- **[Enterprise Authentication & Security in mORMot 2](../Documentation/37-mormot2-backend.md)**: HMAC-SHA256 signature algorithms, token refresh mechanisms, and custom claim injection.
- **[Router & Navigation Guards Guide](../Documentation/09-router.md)**: Global guards (`BeforeEach`), per-route guards, and asynchronous authentication redirects.

---

[⬅️ Module 16: Scaffolding Enterprise CRUD & Reactive DataGrid](16-mormot-crud.md) | [🏠 Course Index](README.md) | [Module 18: High-Performance RPC & SOA Client Proxies ➡️](18-mormot-rpc.md)
