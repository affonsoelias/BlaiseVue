# 9. SPA Router

BlaiseVue includes an advanced Single Page Application router designed for scalable enterprise web applications. It supports **HTML5 History Mode**, **Hash Mode**, **Nested Sub-Routes**, **Navigation Guards**, and **Dynamic Code-Splitting**.

---

## 🧭 1. Router Modes: History vs. Hash

You can configure the navigation mode in your `app.bv` router definition:

### Mode 1: HTML5 History Mode (`mode: 'history'`)
Uses the modern HTML5 History API (`pushState` and `popstate`). URLs look clean and natural without `#` (e.g., `https://myapp.com/dashboard/users`).

```pascal
router:
  mode: 'history';
  routes:
    '/': 'home-page';
    '/about': 'about-page';
    '/dashboard': 'dashboard-page';
```

> [!NOTE]
> When using `mode: 'history'`, your web server (Nginx, Apache, or `bv serve`) must route all 404 fallback requests back to `index.html` so BlaiseVue can handle client-side rendering.

### Mode 2: Hash Mode (`mode: 'hash'`)
The default mode. Uses URL fragments with `#` (e.g., `https://myapp.com/#/about`). Works on any static file server without special server configuration.

---

## 🏗️ 2. Route Definition & Basic Navigation

In `src/app.bv`, define your routes and place the `<router-view>` tag where page components should render:

```html
<template>
  <div class="app-layout">
    <nav class="main-nav">
      <a href="/home" @click.prevent="navigate('/home')">Home</a>
      <a href="/about" @click.prevent="navigate('/about')">About</a>
      <a href="/users/42" @click.prevent="navigate('/users/42')">User 42</a>
    </nav>

    <!-- Active route component is rendered here -->
    <router-view></router-view>
  </div>
</template>

<script>
  router:
    mode: 'history';
    routes:
      '/': 'home-page';
      '/home': 'home-page';
      '/about': 'about-page';
      '/users/:id': 'user-profile-page';

  methods:
    procedure navigate(url: string);
    begin
      this['$router'].push(url);
    end;
</script>
```

---

## 🗂️ 3. Nested Routes (Sub-Layouts)

In large applications, pages often share sub-layouts (such as a sidebar navigation in an admin dashboard) where only the inner content changes. BlaiseVue supports nested `<router-view>` components.

### Configuration with `children`
```pascal
router:
  mode: 'history';
  routes:
    '/': 'home-page';
    '/admin': {
      component: 'admin-layout-page',
      children: [
        { path: '', component: 'admin-dashboard-page' },
        { path: 'users', component: 'admin-users-page' },
        { path: 'settings', component: 'admin-settings-page' }
      ]
    };
```

### Parent Layout (`src/views/AdminLayout.bv`)
```html
<template>
  <div class="admin-container">
    <aside class="admin-sidebar">
      <ul>
        <li><a href="/admin">Overview</a></li>
        <li><a href="/admin/users">Manage Users</a></li>
        <li><a href="/admin/settings">System Settings</a></li>
      </ul>
    </aside>

    <main class="admin-content">
      <!-- Nested sub-route rendered here! -->
      <router-view></router-view>
    </main>
  </div>
</template>
```

When navigating from `/admin/users` to `/admin/settings`, the `AdminLayout` remains intact and mounted while only the inner `<router-view>` transitions!

---

## ⚡ 4. Dynamic Code-Splitting (Lazy Loading)

To optimize initial page load time, components can be loaded on demand when the user accesses the route:

```pascal
router:
  routes:
    '/': 'home-page';
    '/analytics': function() begin Result := import('./views/Analytics.js'); end;
```

When combined with `<suspense>`, the router displays a loading fallback while downloading the chunk.

---

## 🛡️ 5. Navigation Guards

Navigation guards protect routes, handle authentication redirects, or perform analytics tracking.

### Return Values for Guards
- **`true`** (or undefined): Navigation is approved and proceeds.
- **`false`**: Navigation is canceled; the user remains on the previous route.
- **`'/path'`** (string): Redirects the user to a different route.

---

### Global Guard: `beforeEach(to, from)`
Runs before any route transition across the entire application:

```pascal
router:
  beforeEach: function(to, from)
    begin
      // Protect admin routes if not authenticated
      if (to.path.indexOf('/admin') = 0) and not isAuthenticated then
      begin
        console.warn('Unauthorized access. Redirecting to login...');
        Result := '/login';
      end
      else
        Result := true;
    end;
```

---

### Per-Route Guard: `beforeEnter(to, from)`
Runs only when navigating to a specific route:

```pascal
router:
  routes:
    '/billing': {
      component: 'billing-page',
      beforeEnter: function(to, from)
        begin
          if not userHasPermission('billing') then
            Result := '/unauthorized'
          else
            Result := true;
        end
    };
```

---

### Global Hook: `afterEach(to, from)`
Executed after the route transition has finished and the component has mounted:

```pascal
router:
  afterEach: procedure(to, from)
    begin
      console.log('Successfully navigated to: ' + to.path);
      // Example: send pageview to analytics
      trackPageView(to.path);
    end;
```

---

## 🔍 6. Route Params and Query Strings

### Dynamic URL Parameters (`:name`)
```pascal
router:
  routes:
    '/users/:id': 'user-profile-page';
```
When navigating to `/users/42`, the value `42` is automatically injected into the component's `data:`:

```html
<!-- src/views/UserProfile.bv -->
<template>
  <div>
    <h2>User Profile #{{ id }}</h2>
  </div>
</template>

<script>
  data:
    id: string = '';
</script>
```

### Query Strings (`?param=value`)
Query strings are parsed into key-value pairs:
```text
URL: /products?category=hardware&sort=desc
```
If `category` and `sort` exist in the target component's `data:`, they are automatically populated.

---

## 🕹️ 7. Programmatic Navigation API (`$router`)

Access `$router` anywhere in your templates or Pascal methods:

| Method | Description |
|---|---|
| `$router.push(path)` | Navigates to a new route, adding an entry to browser history |
| `$router.replace(path)` | Replaces the current history entry without pushing a new one |
| `$router.back()` | Navigates backward in the browser history |
| `$router.currentRoute` | Returns the active route object (`path`, `params`, `query`) |

**Pascal Example:**
```pascal
methods:
  procedure onCheckoutComplete;
  begin
    // Programmatic redirect
    this['$router'].push('/order-confirmation?id=9928');
  end;
```
