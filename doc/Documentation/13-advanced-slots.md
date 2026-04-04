# 🏛️ Advanced Slots (Named Slots)

BlaiseVue 1.0 introduces support for **Named Slots**, allowing you to define multiple content insertion points in a single component.

## What are Slots?
Imagine a "Layout" or "Card" component. You want the structure to be the same, but the title, body, and footer to change depending on where it's used. Slots allow you to "open holes" in the child component that the parent fills.

### 1. Defining Slots in the Child
In your `.bv` file, use the `<slot>` tag (or `<b-slot>`):

```html
<!-- Card.bv -->
<template>
  <div class="card">
    <div class="header">
       <slot name="header">Default Title (Fallback)</slot>
    </div>
    <div class="body">
       <slot></slot> <!-- Default Slot (unnamed) -->
    </div>
    <div class="footer">
       <slot name="footer"></slot>
    </div>
  </div>
</template>
```

### 2. Filling Slots in the Parent
When using the component, use the `<template slot="name">` tag to direct the content:

```html
<card>
  <!-- Content for the "header" slot -->
  <template slot="header">
    <h3>My Trip ✈️</h3>
  </template>

  <!-- Content without a slot goes to the default slot -->
  <p>Photos from the trip to France.</p>

  <!-- Content for the "footer" slot -->
  <template slot="footer">
    <button>Share</button>
  </template>
</card>
```

## Benefits
- **Component Composition**: Create generic and reusable layout components.
- **Style Isolation**: The child component's CSS manages the frame, while the parent manages the content.
- **Data Context**: The content injected into the slot **retains access to the parent's methods and data**, allowing complex interactions in a natural way.
