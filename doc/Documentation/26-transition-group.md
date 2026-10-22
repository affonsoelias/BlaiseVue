# 26. Reactive List Transitions (`<transition-group>`)

BlaiseVue includes `<transition-group>`, enabling smooth CSS animations for entering, leaving, and reordering elements inside dynamic lists (`b-for`).

---

## 🎬 How it Works: The FLIP Algorithm

Unlike single-element `<transition>`, lists require special animation handling when items move their coordinates on screen (e.g. shuffling, sorting, filtering, or deleting).

BlaiseVue uses the **FLIP (*First, Last, Invert, Play*)** animation technique:
1. **First**: The runtime records the initial bounding box (`getBoundingClientRect`) of each list item before a DOM change.
2. **Last**: The reactive engine applies the list modification, and the new layout coordinates are calculated.
3. **Invert**: If an element moved (`dx` or `dy`), the engine inverts it back to its original position using `transform: translate(dx, dy)` with `transition: none`.
4. **Play**: Reflow is forced, the inline transform is removed, and the `[name]-move` CSS transition class is applied, smoothly sliding the item into its destination!

---

## 🚀 Basic Usage

```html
<template>
  <div class="list-container">
    <div class="controls">
      <button @click="shuffleItems">Shuffle</button>
      <button @click="addItem">Add Number</button>
      <button @click="removeItem">Remove Random</button>
    </div>

    <!-- Wrap list in transition-group -->
    <transition-group name="list" tag="ul" class="animated-list">
      <li b-for="item in items" class="list-item">
        {{ item.text }}
      </li>
    </transition-group>
  </div>
</template>

<script>
  data:
    items: TJSArray = TJSArray.new;

  methods:
    procedure shuffleItems;
    begin
      // Reordering items automatically triggers FLIP animations!
      asm
        this.items.sort(() => Math.random() - 0.5);
      end;
    end;

    procedure addItem;
    begin
      asm
        this.items.splice(Math.floor(Math.random() * this.items.length), 0, {
          id: Date.now(),
          text: 'Item ' + Math.floor(Math.random() * 100)
        });
      end;
    end;
</script>

<style>
  /* Transition classes */
  .list-move {
    transition: transform 0.5s cubic-bezier(0.25, 1, 0.5, 1);
  }
  .list-enter-active, .list-leave-active {
    transition: all 0.5s ease;
  }
  .list-enter-from {
    opacity: 0;
    transform: translateY(20px);
  }
  .list-leave-to {
    opacity: 0;
    transform: translateY(-20px);
  }
</style>
```

---

## ⚙️ Properties and Tag Customization

| Prop / Attribute | Type | Default | Description |
|---|---|---|---|
| `tag` | `string` | `'div'` | The HTML tag to render as the wrapper container (`ul`, `ol`, `div`, etc.). |
| `name` | `string` | `'v'` | The prefix for generated transition CSS classes (`v-move`, `list-move`, etc.). |

All standard HTML attributes (`id`, `class`, `style`) passed to `<transition-group>` are automatically copied to the generated wrapper element.
