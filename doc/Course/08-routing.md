# 🛰️ Module 08: Routing and SPAs
**Navigating Without Reloading.**

The greatest magic of a modern framework is being an **SPA (Single Page Application)**. BlaiseVue has its own integrated router that manages URLs for you.

## ⚔️ The Hash-Router
Navigating in BlaiseVue is as simple as changing the URL hash:
```html
<a href="#/home">Home</a>
<a href="#/about">About Us</a>
```

## 👁️ Automatic Routing
The router watches the URL and, when it changes, it injects the corresponding component into your main `#app`.

- **URL: `#/home`** ➔ Displays the `uHome` component.
- **URL: `#/about`** ➔ Displays the `uAbout` component. ✨🛡️✨

---

**The Secret of Fluidity:**
Your pages load instantly because BlaiseVue already has them registered in the reactive engine when the application starts! 🛡️✨🏆

---

**Next Step: Grab whatever you want on the screen in Module 09!** ⚔️
