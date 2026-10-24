# 17. Component Lifecycle: From Birth to Destruction

If you have ever developed desktop software in **Delphi** or **Lazarus**, you already know how visual windows work:
- When a form is created in memory, Delphi runs `OnCreate`.
- When the form appears on your monitor, Delphi runs `OnShow`.
- When the form is closed and destroyed, Delphi runs `OnDestroy` or `OnClose`.

In **BlaiseVue**, components live a very similar life! From the moment a component is summoned to the browser screen until the moment the user navigates away, it goes through a well-defined **Lifecycle** (Ciclo de Vida).

Lifecycle hooks allow you to execute pure **Object Pascal** code automatically at these key moments.

---

## 🗺️ The 4 Moments of a Component's Life

```
  [1. Component Born in RAM]  ──>  created:    (Data & state ready, HTML not on screen yet)
              │
              ▼
  [2. HTML Drawn on Screen]   ──>  mounted:    (HTML is visible! Ready for timers & user focus)
              │
              ▼
  [3. User Interacts / Edits] ──>  updated:    (The HTML repainted because data changed)
              │
              ▼
  [4. Component Leaves Screen]──>  unmounted:  (User left the page! Time to stop timers & free RAM)
```

| Lifecycle Hook | Desktop Delphi Equivalent | Is the HTML Visible on Screen? | What should you do here? |
| :--- | :--- | :--- | :--- |
| **`created:`** | `TForm.OnCreate` | ❌ No (Only in RAM) | Fetch initial data from APIs, configure datasets, prepare lists. |
| **`mounted:`** | `TForm.OnShow` | ✅ Yes (Live on screen) | Start timers, show welcome toasts, set focus on input fields. |
| **`updated:`** | `TForm.OnPaint` | ✅ Yes (Repainted) | Audit UI changes or trigger animations after a repaint. |
| **`unmounted:`** | `TForm.OnDestroy` | ❌ No (Being destroyed) | Stop timers (`StopInterval`), cancel background tasks, free memory. |

---

## 🔍 Detailed Hook Breakdown (100% Pure Pascal)

### 1. `created:` — The Birth in Memory
This hook runs the instant BlaiseVue initializes your component and its `data:` variables in RAM. 

> [!IMPORTANT]
> At this exact moment, **the HTML has not yet been rendered** into the browser. Do not attempt to query buttons or focus inputs here, because they do not physically exist on the screen yet!

**What is it perfect for?**
- Loading initial data from the backend (`ApiFetch`, `$api`).
- Populating datasets (`DataSetLoad`).
- Initializing default configuration.

```pascal
created:
begin
  ConsoleLog('Component created in memory!');
  this['status'] := 'Carregando produtos...';
  
  // Call your Pascal method to fetch data from the server
  CarregarDadosIniciais();
end;
```

---

### 2. `mounted:` — The Arrival on Screen
This hook runs when the HTML template has been compiled, attached to the browser document, and is now **fully visible and interactive** to the user.

**What is it perfect for?**
- Displaying a welcome toast message (`ShowToast`).
- Starting real-time tickers, clocks, or polling intervals (`StartInterval`).
- Triggering component references (`$refs`).

```pascal
mounted:
begin
  ConsoleLog('Component is now live on screen!');
  ShowToast('Tela carregada com sucesso!');

  // Start a timer to refresh data every 5 seconds (Pure Pascal!)
  this['timerId'] := StartInterval(procedure
  begin
    AtualizarStatus();
  end, 5000);
end;
```

---

### 3. `updated:` — The Visual Refresh
Every time a reactive variable in your `data:` changes, BlaiseVue's reactive engine automatically repaints the relevant parts of the DOM. Immediately after that repaint completes, `updated:` runs.

**What is it perfect for?**
- Logging changes for debugging.
- Synchronizing external visual widgets with updated data.

```pascal
updated:
begin
  ConsoleLog('A tela foi atualizada com novos dados reativos!');
end;
```

---

### 4. `unmounted:` — The Farewell & Cleanup
When the user clicks a different link in the menu, navigates to another route, or closes a modal dialog, the current component is removed from the screen.

> [!WARNING]
> If you started a timer or interval in `mounted:`, you **must** stop it in `unmounted:`! Otherwise, the timer will keep running in the background, consuming browser memory and battery.

**What is it perfect for?**
- Stopping recurring timers (`StopInterval`).
- Saving draft state before leaving.
- Cleaning up resources.

```pascal
unmounted:
begin
  ConsoleLog('Component leaving screen. Cleaning up...');

  // Stop the timer so it doesn't leak memory (Pure Pascal!)
  StopInterval(Integer(this['timerId']));
end;
```

---

## 🎯 Common Question: When to use `watch:` vs `mounted:`?

Beginners often ask: *"When should I use a Lifecycle hook, and when should I use a Watcher (`watch:`)?"*

Here is the simple rule of thumb:
* **Lifecycle Hooks (`created`, `mounted`, `unmounted`)** are about **TIMING IN THE COMPONENT'S EXISTENCE**:
  - *"Run this once when the screen opens"* $\rightarrow$ use **`mounted:`**.
  - *"Run this once when the screen closes"* $\rightarrow$ use **`unmounted:`**.
* **Watchers (`watch:`)** are about **VARIABLE CHANGES**:
  - *"Run this every time the user types in the search box"* $\rightarrow$ use **`watch:`**.
  - *"Run this whenever the cart total crosses \$100"* $\rightarrow$ use **`watch:`**.

---

## ❓ Do I ever need to write `asm ... end`?

**No!** 

In BlaiseVue, application code—your forms, business logic, calculations, API calls, and lifecycle hooks—is written in **100% pure Object Pascal**.

You do not need to know JavaScript, and you do not need to write inline `asm` blocks. The framework provides clean Pascal helpers like `ShowToast`, `Confirm`, `ConsoleLog`, `StartInterval`, `StopInterval`, and `ApiFetch` in `BVPascalDX` so that your code remains completely idiomatic Pascal.

`asm` is only an optional tool intended for framework internals or when wrapping advanced external third-party JavaScript libraries.

---

## 💻 Complete Runnable Example: Live Clock (`LiveClock.bv`)

Here is a complete, friendly Single File Component demonstrating the full lifecycle in pure Pascal:

```html
<template>
  <div class="clock-card">
    <h2>⏰ Relógio em Tempo Real</h2>
    <p class="time-display">{{ currentTime }}</p>
    <p class="status-badge">Status: {{ statusText }}</p>
    
    <button class="bui-btn bui-btn-primary" @click="doPing">
      🔔 Testar Ação
    </button>
  </div>
</template>

<script>
  data:
    currentTime: string = '--:--:--';
    statusText: string = 'Iniciando...';
    timerId: Integer = 0;
    pingCount: Integer = 0;

  created:
    begin
      // 1. Momento de criação na memória: dados preparados
      this['statusText'] := 'Componente carregado na memória!';
      ConsoleLog('LiveClock: created');
    end;

  mounted:
    begin
      // 2. Momento de chegada na tela: inicia o relógio a cada 1 segundo
      this['statusText'] := 'Relógio ativo na tela.';
      ShowToast('Relógio iniciado!');
      ConsoleLog('LiveClock: mounted');

      // Atualiza a hora imediatamente
      this.atualizarHora();

      // Dispara atualização contínua a cada 1000ms (1 segundo)
      this['timerId'] := StartInterval(procedure
      begin
        this.atualizarHora();
      end, 1000);
    end;

  unmounted:
    begin
      // 3. Momento de saída da tela: para o relógio e libera memória
      ConsoleLog('LiveClock: unmounted - parando timer');
      StopInterval(Integer(this['timerId']));
    end;

  methods:
    procedure atualizarHora;
    begin
      this['currentTime'] := NowTimestampStr;
    end;

    procedure doPing;
    begin
      Inc(this['pingCount']);
      ShowToast('Você clicou ' + String(this['pingCount']) + ' vez(es)!');
    end;
</script>

<style>
  .clock-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 24px;
    max-width: 360px;
    text-align: center;
    box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
  }
  .time-display {
    font-size: 32px;
    font-weight: 700;
    color: #2563eb;
    margin: 16px 0;
    font-family: monospace;
  }
  .status-badge {
    font-size: 13px;
    color: #64748b;
    margin-bottom: 16px;
  }
</style>
```

---

## 🏆 Summary Checklist

When building your components, remember these 3 simple rules:
1. **Initialize data in `created:`** (APIs, lists, default values).
2. **Start visual timers and toasts in `mounted:`** (HTML is ready).
3. **Always stop intervals in `unmounted:`** (Keeps your application fast and leak-free). 🛡️✨🔄
