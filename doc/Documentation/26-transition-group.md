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

## 🚀 Basic Usage (Pure Pascal)

```html
<template>
  <div class="list-container">
    <div class="controls">
      <button class="bui-btn bui-btn-primary" @click="addItem">➕ Add Item</button>
      <button class="bui-btn bui-btn-danger" @click="removeLastItem">➖ Remove Item</button>
      <button class="bui-btn bui-btn-outline" @click="shuffleItems">🔀 Shuffle (JS Power-User)</button>
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
    // Pure Pascal: adding items smoothly slides into the list
    procedure addItem;
    var
      item: TJSObject;
    begin
      item := NewObject;
      item['id'] := NowTimestampStr;
      item['text'] := 'Item ' + IntToStr(TJSArray(this['items']).length + 1);
      TJSArray(this['items']).push(item);
    end;

    // Pure Pascal: removing items triggers exit animations
    procedure removeLastItem;
    begin
      if TJSArray(this['items']).length > 0 then
        TJSArray(this['items']).pop();
    end;

    // Power-User JavaScript Interop: reordering with JS sort
    procedure shuffleItems;
    begin
      asm
        this.items.sort(() => Math.random() - 0.5);
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
