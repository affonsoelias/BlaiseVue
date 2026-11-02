# 🛰️ Module 07: Communication & Events ($emit)
**Making components communicate with each other and react to user actions.**

In the real world, when a visitor presses the doorbell outside your house:
1. The **doorbell button** does not know who is inside the house or what you will do. It simply rings: *Ding-Dong!*
2. **You**, inside the house, hear the chime and decide what action to take: answer the door, look through the peep-hole, or check the camera.

In BlaiseVue, this is the foundational pattern of component communication:
- **Props go DOWN:** The parent passes data down to the child.
- **Events go UP ($emit):** The child notifies the parent when an action occurs!

---

## 👂 1. Listening to Events with `@` (or `b-on:`)

To make buttons and inputs react to user actions, we prepend the `@` symbol before the event name:

| Syntax | When Does It Fire? | Example |
| :--- | :--- | :--- |
| `@click` | When the user clicks or taps the element | `@click="saveRecord"` |
| `@input` | Every time a character is typed into a field | `@input="validateEntry"` |
| `@keyup.enter` | When the user presses the **Enter** key | `@keyup.enter="submitComment"` |
| `@mouseenter` | When the mouse pointer hovers over an element | `@mouseenter="showTooltip"` |

The logic executed by these listeners is declared in the `methods:` section of your Pascal code:

```pascal
<script>
  methods:
    procedure saveRecord;
    begin
      WriteLn('Saving record to database...');
    end;
</script>
```

---

## 📢 2. What is `$emit` (The Child Calling the Parent)?

A child component (such as a custom button, shopping item, or form widget) should never directly modify its parent's variables. Instead, it dispatches an event up the tree using `$emit`:

```pascal
// The child emits an event named 'purchase' carrying the item title:
TJSFunction(this['$emit']).apply(this, ['purchase', 'Pascal Blade']);
```

And in the parent component, we listen to that custom event with `@purchase`:
```html
<store-item @purchase="addToCart"></store-item>
```

---

## 🚀 3. Full Step-by-Step Example: Community Upvoting System

Let's build a practical two-component voting system:
1. A reusable child button component (`LikeButton.bv`) with its own click count and heart animation.
2. A parent dashboard view that renders three vote buttons and tracks the **Total Community Votes** in a master scoreboard!

---

### Step 1: Create the Child Component (`src/components/LikeButton.bv`)

Create `LikeButton.bv` inside `demo-app/src/components/`:

```html
<template>
  <button class="btn-like" :class="{ 'liked': hasLiked }" @click="triggerLike">
    <span class="heart-icon">{{ hasLiked ? '❤️' : '🤍' }}</span>
    <span class="label">{{ label }}</span>
    <span class="count-badge">{{ count }}</span>
  </button>
</template>

<script>
  props:
    label: string = 'Like';

  data:
    count: integer = 0;
    hasLiked: boolean = false;

  methods:
    procedure triggerLike;
    begin
      // 1. Update internal component state
      this['count'] := Integer(this['count']) + 1;
      this['hasLiked'] := true;

      // 2. Notify parent component that a like occurred!
      // Emits 'vote-cast' carrying the label parameter
      TJSFunction(this['$emit']).apply(this, ['vote-cast', this['label']]);
    end;
</script>

<style>
  .btn-like {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: #f7fafc;
    border: 2px solid #e2e8f0;
    border-radius: 20px;
    cursor: pointer;
    font-weight: bold;
    font-size: 14px;
    transition: all 0.2s ease;
  }
  .btn-like:hover {
    border-color: #cbd5e0;
    transform: translateY(-2px);
  }
  .liked {
    border-color: #feb2b2;
    background: #fff5f5;
  }
  .count-badge {
    background: #edf2f7;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 12px;
  }
</style>
```

---

### Step 2: Listen to Events in the Parent View (`src/views/Home.bv`)

Open `src/views/Home.bv` and assemble the master scoreboard:

```html
<template>
  <div class="voting-panel">
    <h2>🏆 Community Technology Poll</h2>
    
    <!-- Central Scoreboard that aggregates child events -->
    <div class="total-scoreboard">
      <p class="score-number">{{ totalVotes }}</p>
      <span class="score-legend">Total Votes Cast</span>
    </div>

    <p class="latest-alert" b-if="latestMessage != ''">
      📢 Activity: {{ latestMessage }}
    </p>

    <div class="buttons-grid">
      <!-- We listen to the @vote-cast custom event emitted by the child! -->
      <like-button 
        label="BlaiseVue Framework" 
        @vote-cast="recordVote">
      </like-button>

      <like-button 
        label="Free Pascal Compiler" 
        @vote-cast="recordVote">
      </like-button>

      <like-button 
        label="Lazarus IDE" 
        @vote-cast="recordVote">
      </like-button>
    </div>

  </div>
</template>

<script>
  data:
    totalVotes: integer = 0;
    latestMessage: string = '';

  methods:
    // This procedure receives the argument passed via $emit!
    procedure recordVote(itemName: string);
    begin
      // 1. Increment grand total
      this['totalVotes'] := Integer(this['totalVotes']) + 1;
      
      // 2. Display activity message
      this['latestMessage'] := 'Someone just upvoted "' + itemName + '"!';
    end;
</script>

<style>
  .voting-panel {
    max-width: 560px;
    margin: 30px auto;
    background: #ffffff;
    padding: 24px;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    text-align: center;
    font-family: sans-serif;
  }
  .total-scoreboard {
    background: #ebf8ff;
    padding: 20px;
    border-radius: 12px;
    margin: 20px 0;
  }
  .score-number {
    font-size: 48px;
    font-weight: bold;
    color: #2b6cb0;
    margin: 0;
  }
  .score-legend {
    font-size: 13px;
    color: #4a5568;
    text-transform: uppercase;
    font-weight: bold;
    letter-spacing: 1px;
  }
  .latest-alert {
    font-size: 13px;
    color: #2f855a;
    background: #f0fff4;
    padding: 8px;
    border-radius: 6px;
    margin-bottom: 20px;
  }
  .buttons-grid {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
  }
</style>
```

---

## 🎯 4. Practical Exercise: Module 07

1. Click any of the three vote buttons. Notice how the individual count increases, the heart turns red (`❤️`), and the master scoreboard simultaneously increments!
2. **Challenge**: Add a fourth button for `"mORMot 2 Framework"`. With zero plumbing, it integrates into the master scoreboard seamlessly!

---

## 🏆 What You Learned Today
- How to listen to browser events using `@click`, `@input`, and `@keyup.enter`.
- How to structure business procedures within the `methods:` section.
- How child components communicate with parent components cleanly via `$emit`.

**Now that components communicate, how do we build multi-page apps without refreshing? Let's explore [Module 08: Flicker-Free Navigation (SPA Router)](08-routing.md)!** ⚔️🛡️✨
