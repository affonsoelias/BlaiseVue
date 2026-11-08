# 🎓 BlaiseVue Complete Course: From Zero to Ninja
**Build Modern, Reactive Web, Mobile, and Full-Stack Applications with the Power and Clarity of Object Pascal.**

Welcome to the official **BlaiseVue** training course! This curriculum is designed for **anyone who wants to build web, mobile, and enterprise full-stack applications**, even if you have never programmed before or have only basic knowledge of Pascal or HTML.

You do not need years of JavaScript study, complex build toolchains, or messy configurations. We build your knowledge step-by-step with simple explanations, everyday analogies, and practical, runnable examples! 🛡️✨🚀

---

## 🧭 What is BlaiseVue? (For Complete Beginners)

Imagine you want to build a modern web application — the kind that updates on the fly when you click a button without refreshing the entire page (what the industry calls a **Single Page Application** or **SPA**).

Historically, doing this required mastering dozens of complex JavaScript libraries and build tools. **BlaiseVue changes that**:
1. **You write in Object Pascal**: A globally trusted language known for its clean readability, strong typing, speed, and safety.
2. **BlaiseVue compiles and connects everything for you**: It takes your Pascal code and produces an ultra-fast web application that runs natively in any modern browser (Chrome, Firefox, Edge, Safari), on mobile devices (Android & iOS), and on native desktops!
3. **Instant Reactivity**: When you update a variable in Pascal, the user interface updates automatically, just like a spreadsheet formula in Microsoft Excel!

---

## 🗺️ The Learning Roadmap (28 Practical Modules)

The curriculum is organized into 6 progressive learning tracks that take you step-by-step from beginner fundamentals to universal enterprise architecture:

### 🏛️ Track 1: Reactive Foundations & Core Frontend (Modules 01 - 08)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **01** | [The Beginning of the Journey](01-introduction.md) | How the web works, anatomy of a `.bv` file, CLI first steps (`bv dev`, `bv doctor`). |
| **02** | [The Reactive Engine](02-reactivity.md) | Pascal data types, reactive proxy tracking, and building an interactive counter. |
| **03** | [Essential Directives](03-directives.md) | Conditional branching (`b-if`, `b-else-if`, `b-else`, `b-show`) and list rendering (`b-for`). |
| **04** | [Synchronization with b-model](04-synchronization.md) | Two-way form data binding with text inputs, selects, switches, checkboxes, radios, and sliders. |
| **05** | [The Brain: Computed Properties](05-computed.md) | Derived data, cached computations, and real-time checkout calculations. |
| **06** | [The Art of Components](06-components.md) | Component modularity, `props:` contracts, bound attributes (`:`), and Vue 3 fragments. |
| **07** | [Events & Communication](07-events.md) | Event listeners (`@click`, `@input`), Pascal `methods:`, and parent notifications (`$emit`). |
| **08** | [Flicker-Free SPA Routing](08-routing.md) | Client-side routing, `<router-view>` outlets, URL parameters, and menu navigation. |

### ⚡ Track 2: Advanced Component Architecture & State (Modules 09 - 13)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **09** | [DOM Access with $refs & Lifecycles](09-refs.md) | Autofocusing inputs, mounted/created lifecycle hooks, and direct element access via `b-ref`. |
| **10** | [The CLI Scaffolding Maestro](10-cli.md) | Instant code generation: `bv g c`, `bv g v`, `bv g s`, `bv list`, `bv remove`, `bv rename`. |
| **11** | [Pro Architectural Features](11-pro-features.md) | Flexible slots, scoped slots, FLIP list transitions, and provide/inject dependency injection. |
| **12** | [Declarative Form Validation (b-validate)](12-validation.md) | Rules (`required`, `email`, `min:N`), reactive `$errors`, touch states (`$v`), and `$validate()`. |
| **13** | [BlaiseX 2.0 & Finite State Machines](13-blaisex-fsm.md) | Domain slices (`bv g store`), FSM flows (`bv g fsm`), atomic mutations, and time-travel undo/redo. |

### 🗄️ Track 3: Enterprise Data & Full-Stack mORMot 2 (Modules 14 - 18)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **14** | [In-Browser Database: TBVDataSet & LiveBindings](14-dataset.md) | `TDataSet` in the browser, cursor navigation, transactional buffering, and `b-field`. |
| **15** | [Full-Stack mORMot 2 Setup & Architecture](15-mormot-init.md) | Standalone Pascal server: `bv mormot init`, `bv mormot run`, `bv mormot build`, `bv mormot status`, `bv mormot kill`. |
| **16** | [Scaffolding Enterprise CRUD & Reactive DataGrid](16-mormot-crud.md) | One-command full-stack generation: `bv mormot crud <Model>` (ORM model, REST API, reactive DataGrid). |
| **17** | [Full-Stack JWT Authentication & Route Guards](17-mormot-auth.md) | Automated auth suite: `bv mormot auth` (JWT tokens, route guards `requiresAuth`, role control). |
| **18** | [High-Performance RPC & SOA Client Proxies](18-mormot-rpc.md) | `bv mormot rpc` client proxies, compile-time API validation, and `bv mormot docs` Swagger UI. |

### 📱 Track 4: Mobile & Multi-Platform Development (Modules 19 - 21)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **19** | [Mobile Architecture & Capacitor Setup](19-mobile-architecture.md) | Cross-platform mobile architecture: `bv mobile init`, `bv mobile sync`, native hardware APIs (Camera, Haptics). |
| **20** | [Mobile UI Components & Touch Gestures](20-mobile-ui.md) | Official `@blaise-ui-mobile` suite (inputs, toggles, checkboxes, selects, pull-to-refresh, searchbars, FABs, back buttons), adaptive Material Design / Cupertino styling, safe areas, and `BlaiseIonic.pas`. |
| **21** | [Emulation, Live Debugging & Device Build](21-mobile-build.md) | Android emulators (`bv mobile emulator`), device debugging via ADB, release APKs, and Google Play AAB bundles. |

### 🎨 Track 5: Official Packages & Ecosystem (Modules 22 - 25)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **22** | [Blaise UI Design System & Themes](22-themes.md) | Official `@blaise-ui` 30+ component suite (switches, sliders, dropdowns, skeletons, datagrid), Bootswatch theme catalog (`@blaise-themes`), and CLI theme management. |
| **23** | [Data Visualization with Blaise Charts](23-charts.md) | Hardware-accelerated 60 FPS charts (`@blaise-charts`): Bar, Line, Pie, Doughnut bound to Pascal datasets. |
| **24** | [Enterprise Reporting with Blaise Reports](24-reports.md) | Native Vector PDF 1.4, Excel `.xlsx`, and thermal POS receipts in 100% Object Pascal (`@blaise-reports`). |
| **25** | [Visual Development with Blaise Studio](25-studio.md) | Developer cockpit (`bv studio`): Component AST inspection, live WebSocket telemetry, and 1-click test runners. |

### 🛡️ Track 6: Production Engineering, Quality Assurance & Capstone (Modules 26 - 28)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **26** | [Unit & E2E Testing Automation](26-testing.md) | Pure Pascal unit tests (`Describe`, `It`, `Expect`, `Mount`) with `bv test` and headless browser tests with `bv test e2e`. |
| **27** | [Micro-Containers, CI/CD & Deployment](27-deployment.md) | Ultra-lean sub-20MB Alpine micro-containers (`bv mormot docker`), multi-stage Dockerfiles, and GitHub Actions. |
| **28** | [The Capstone Enterprise Challenge](28-capstone.md) | Build, test, and deploy a complete Universal Logistics ERP Hub connecting all 28 modules, bridging to the 55 Technical Manuals. |

---

## 💡 Pro Tips for Your Success

- **Do not just memorize — type and practice**: Coding is learned through your fingers. Open the files, modify values, change colors, and see what happens!
- **Never fear mistakes**: If something does not appear on screen, press `F12` to open your browser developer tools. BlaiseVue gives clear diagnostics to help you.
- **Run the system doctor**: At any time, open your terminal and type `bv doctor`. It verifies that Free Pascal, InstantFPC, Python 3, and Node.js are healthy and ready to roll!

---

Ready to begin? Let's take the first step together!  
👉 **[Open Module 01: The Beginning of the Journey](01-introduction.md)** 🛡️✨🚀
