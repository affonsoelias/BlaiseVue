# ⚔️ Module 10: The Terminal Maestro (CLI bv)
**Master the simple commands that run, test, and package your applications.**

If you have never worked with the command line before (that black terminal window with white text), it might feel intimidating at first glance. But don't worry: the terminal is simply a way to speak directly to your operating system using clear text commands!

To make life easy, BlaiseVue provides a unified command-line tool called **`bv`** (or `bv.exe` on Windows). It serves as your automated co-pilot: handling compilation, testing, and configuration with single-word commands.

---

## 💻 1. How to Open Your Terminal

- **Inside your editor (VS Code / Antigravity IDE):**  
  Press the keyboard shortcut **`Ctrl + '`** (or navigate to *Terminal $\rightarrow$ New Terminal*). A terminal will open directly inside your project folder!
- **On Windows:** Open *PowerShell* or *Command Prompt*.
- **On Linux or macOS:** Open your system *Terminal* app.

> [!TIP]
> **Two Essential Terminal Shortcuts:**
> 1. **Repeat previous command:** Press the **Up Arrow ($\uparrow$)** key. The terminal retypes your last command for you!
> 2. **Stop a running server:** Press **`Ctrl + C`** to gracefully terminate a process.

---

## 🧰 2. Essential Commands Catalog

Here are the commands you will use most often:

### 1. Start the Development Server
Launches the local development server with live Hot Module Replacement (HMR) on port `8080`:
```bash
bv run dev
# (or simply:)
bv dev
```
Open your browser at `http://localhost:8080` and start coding with live reload!

### 2. Environment Health Check (`bv doctor`)
Performs a comprehensive diagnostic scan to ensure all required compilers and scripting engines are healthy:
```bash
bv doctor
```
It validates:
- **Git**: For version control and automated framework updates.
- **Free Pascal (FPC) & InstantFPC**: The Pascal compiler and script runner.
- **Python 3**: Recommended for executing dynamic tool package scripts.
- **Pas2JS & mORMot 2**: The embedded web and backend Pascal frameworks.
- **Node.js**: For running the Vitest automated testing suite and HMR server.

### 3. Run Automated Unit Tests
Compiles and validates your test suites (`.test.pas`):
```bash
bv test
```

### 4. Build for Production (`bv build`)
When your application is ready to be published to the internet, run:
```bash
bv build
```
This produces a production-ready `dist/` directory with optimized, minified HTML, CSS, and JavaScript. You can host this folder on any web server or static host (Vercel, Netlify, GitHub Pages, Apache, NGINX)!

### 5. Clean Temporary Build Artifacts
Wipes temporary caches and stale compilation files:
```bash
bv clean
```

---

## 🎨 3. Managing Extensions and Visual Themes

The `bv` CLI also manages developer extensions and theme styling:

### Developer Tools & Extensions (`bv extension`)
```bash
# View available extension packages and their installation status:
bv extension list

# Install the official extension for VS Code / Antigravity IDE:
bv extension install blaise-vscode

# Show instructions for installing the browser DevTools in Chrome/Firefox:
bv extension install blaise-devtools
```

### Ready-to-Use UI Themes & Bundle Optimization (Bootswatch)
Tired of styling everything from scratch? BlaiseVue includes an enterprise theme system with built-in bundle optimization:
```bash
# List configured and available themes (darkly, flatly, cosmo, pulse, etc.):
bv theme list

# Switch to a modern dark theme with 1 command:
bv theme use darkly

# Optimize your production build: include only the themes you actually use!
bv theme add darkly
bv theme add flatly

# Switch back to a clean corporate light theme:
bv theme use flatly
```
When you run `bv build`, only the themes registered with `bv theme add` are bundled into `dist/`, slashing up to 90% of unused CSS from your final production release!

---

## 🎯 4. Practical Exercise: Module 10

1. Open your terminal in the BlaiseVue directory.
2. Run `bv doctor` and verify all green `[v]` status indicators.
3. Run `bv extension list` to inspect your tool packages.
4. Try switching your theme with `bv theme use darkly`, add it with `bv theme add darkly`, and inspect how easy it is to keep production builds lean!

---

## 🏆 What You Learned Today
- Why the command-line interface boosts developer productivity.
- How to start live dev mode with `bv dev`.
- How `bv doctor` maintains environment reliability.
- How to build production bundles with `bv build`.
- How to manage and optimize application themes with `bv theme` (`list`, `add`, `use`).

**Ready to level up to senior architectural concepts? Advance to [Module 11: Pro Architectural Features](11-pro-features.md)!** ⚔️🛡️✨
