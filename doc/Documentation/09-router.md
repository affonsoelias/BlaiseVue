# 9. SPA Router

BlaiseVue includes an SPA router based on **hash** (`#/route`).

## Basic Configuration

In `app.bv`, define the routes in the `router:` section:

```html
<template>
  <div>
    <nav>
      <a href="#/">Home</a>
      <a href="#/about">About</a>
    </nav>
    <router-view></router-view>
  </div>
</template>

<script>
  router:
    routes:
      '/': 'home-page';
      '/about': 'about-page';
</script>
```

The `<router-view></router-view>` tag is where the active page content is rendered.

## Navigation

Use links with `href="#/route"`:

```html
<a href="#/">Home</a>
<a href="#/about">About</a>
<a href="#/user/42">User 42</a>
```

Or navigate via Pascal:
 ```pascal
 methods:
   procedure goToHome;
   begin
     window.location.hash := '#/';
   end;
 ```
 
 ## Dynamic Params
 
 Define dynamic segments with `:name`:
 
 ```
 router:
   routes:
     '/user/:id': 'user-profile-page';
 ```
 
 The param value is automatically injected into the component data by the compiler:
 
 ```html
 <!-- src/views/UserProfile.bv -->
 <template>
   <div>
     <h1>User #{{ id }}</h1>
   </div>
 </template>
 
 <script>
   data:
     id: string = '';
 </script>
 ```
 
 When navigating to `#/user/42`, `{{ id }}` displays `42`.
 
 ## Query Strings
 
 Query strings are automatically parsed:
 
 ```
 URL: #/user/7?tab=config&theme=dark
 ```
 
 Values are injected into the component data if the keys exist in `data:`:
 
 ```html
 <template>
   <div>
     <p>ID: {{ id }}</p>
     <p>Tab: {{ tab }}</p>
     <p>Theme: {{ theme }}</p>
   </div>
 </template>
 
 <script>
   data:
     id: string = '';
     tab: string = '';
     theme: string = '';
 </script>
 ```
 
 ## Accessing Route Data in Pascal
 
 Since BlaiseVue injects params and query strings directly into the data object, you can access them in any method using `this` (or `State`) in pure Pascal:
 
 ```pascal
 methods:
   procedure checkProfile;
   var
     userId: string;
   begin
     userId := string(this['id']);
     console.log('Viewing user profile: ' + userId);
   end;
 ```
 
 ## Navigation Guards (Route Protection)
 
 You can protect routes by defining global or local guards. These guards are executed **before** the new component is mounted.
 
 ### 📜 Return Values
 - **`true`** (or undefined): Allow navigation.
 - **`false`**: Cancel navigation (the user stays on the current page).
 - **`'/path'`** (string): Redirect to another route.
 
 ### Global Guard: `beforeEach`
 Define a global guard in the `router:` section of your `app.bv`:
 
 ```pascal
 router:
   beforeEach: function(to, from)
     begin
       if (to.path = '/admin') and not isLoggedIn then
         Result := '/login'
       else
         Result := true;
     end;
   routes:
     '/': 'home';
     '/login': 'login';
 ```
 
 ### Local Guard: `beforeEnter`
 You can also protect a specific route in the route definition:
 
 ```pascal
 router:
   routes:
     '/dashboard': { component: 'dash', beforeEnter: checkAuth };
 ```
 
 ## Full Example
 
 ```html
 <template>
   <div>
     <nav>
       <a href="#/">Home</a>
       <a href="#/user/1">User 1</a>
       <a href="#/user/42?tab=posts">User 42</a>
     </nav>
     <router-view></router-view>
   </div>
 </template>
 
 <script>
   data:
     title: string = 'My SPA App';
 
   router:
     routes:
       '/': 'home-page';
       '/user/:id': 'user-profile-page';
 </script>
 ```
