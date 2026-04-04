# ✨ Native CSS Transitions (`<transition>`)

Bring your interfaces to life with automatic animations! BlaiseVue Pro now natively processes the `<transition>` tag, inspired by the visual power of Vue.js.

## The Challenge: Animating Dynamic Elements
When using `b-if` or `b-show`, elements appear or disappear instantly. With the `<transition>` tag, BlaiseVue injects special CSS classes into the mount and unmount lifecycle, allowing for full smoothness in movement.

## How to Use

### 1. In your Template (.bv)
Wrap any element that uses `b-if` or `b-show` with the `<transition>` tag. The `name` attribute defines the CSS class prefix:

```html
<transition name="mastery">
  <div b-show="panelVisible" class="panel">
     I appear with mastery! 🛡️
  </div>
</transition>

<button @click="toggle">Toggle Panel</button>
```

### 2. In your Style (<style>)
You need to define the classes that BlaiseVue will apply. The animation engine injects the following classes:

- **`x-enter-active`**: Active throughout the enter animation.
- **`x-leave-active`**: Active throughout the leave animation.
- **`x-enter-from`**: Starting point of the enter animation (e.g., `opacity: 0`).
- **`x-enter-to`**: Ending point of the enter animation (e.g., `opacity: 1`).
- **`x-leave-to`**: Ending point of the leave animation (e.g., `opacity: 0`).

#### Vertical Fade Example:
```css
<style>
  .mastery-enter-active, .mastery-leave-active {
     transition: opacity 0.5s, transform 0.5s;
  }
  .mastery-enter-from, .mastery-leave-to {
     opacity: 0;
     transform: translateY(-20px);
  }
  .mastery-enter-to, .mastery-leave-from {
     opacity: 1;
     transform: translateY(0);
  }
</style>
```

## Benefits
- **Reactive Mounting**: BlaiseVue detects when the element finishes the animation to completely remove it from the DOM (in the case of `b-if`).
- **Native Performance**: The engine uses `requestAnimationFrame` to ensure the browser does the heavy GPU work optimally.
- **Micro-interactions**: Perfect for modals, sidebars, and temporary notifications.
