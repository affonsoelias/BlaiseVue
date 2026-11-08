# 🎓 BlaiseVue Complete Course: From Zero to Ninja
**Build Modern, Reactive Web Applications with the Power and Clarity of Object Pascal.**

Welcome to the official **BlaiseVue** training course! This curriculum is designed for **anyone who wants to build web applications**, even if you have never programmed before or have only basic knowledge of Pascal or HTML.

You do not need years of JavaScript study, complex build toolchains, or messy configurations. We build your knowledge step-by-step with simple explanations, everyday analogies, and practical, runnable examples! 🛡️✨🚀

---

## 🧭 What is BlaiseVue? (For Complete Beginners)

Imagine you want to build a modern web application — the kind that updates on the fly when you click a button without refreshing the entire page (what the industry calls a **Single Page Application** or **SPA**).

Historically, doing this required mastering dozens of complex JavaScript libraries and build tools. **BlaiseVue changes that**:
1. **You write in Object Pascal**: A globally trusted language known for its clean readability, strong typing, speed, and safety.
2. **BlaiseVue compiles and connects everything for you**: It takes your Pascal code and produces an ultra-fast web application that runs natively in any modern browser (Chrome, Firefox, Edge, Safari) and on mobile devices!
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
| **04** | [Synchronization with b-model](04-synchronization.md) | Two-way form data binding with text inputs, selects, and checkboxes. |
| **05** | [The Brain: Computed Properties](05-computed.md) | Derived data, cached computations, and real-time checkout calculations. |
| **06** | [The Art of Components](06-components.md) | Component modularity, `props:` contracts, bound attributes (`:`), and Vue 3 fragments. |
| **07** | [Events & Communication](07-events.md) | Event listeners (`@click`, `@input`), Pascal `methods:`, and parent notifications (`$emit`). |
| **08** | [Flicker-Free SPA Routing](08-routing.md) | Client-side routing, `<router-view>` outlets, URL parameters, and menu navigation. |

### ⚡ Track 2: Advanced Component Architecture & State (Modules 09 - 13)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **09** | [DOM Access with $refs & Lifecycles](09-refs.md) | Autofocusing inputs, mounted/created lifecycle hooks, and direct element access. |
| **10** | [The CLI Scaffolding Maestro](10-cli.md) | Instant code generation: `bv g c`, `bv g v`, `bv g s`, `bv list`, `bv remove`, `bv rename`. |
| **11** | [Pro Architectural Features](11-pro-features.md) | Flexible slots, scoped slots, FLIP list transitions, and provide/inject dependency injection. |
| **12** | [Declarative Form Validation (b-validate)](12-validation.md) | Rules (`required`, `email`, `min:N`), reactive `$errors`, touch states (`$v`), and `$validate()`. |
| **13** | [BlaiseX 2.0 & Finite State Machines](13-blaisex-fsm.md) | Domain slices (`bv g store`), FSM flows (`bv g fsm`), atomic mutations, and time-travel undo/redo. |

### 🗄️ Track 3: Enterprise Data & Full-Stack Pascal (Modules 14 - 18)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **14** | [In-Browser Database: TBVDataSet & LiveBindings](14-dataset.md) | `TDataSet` in the browser, cursor navigation, transactional buffering, and `b-field`. |
| **15** | [Full-Stack Pascal: Native Backend with mORMot 2](15-mormot-core.md) | Standalone Pascal server: `bv mormot init`, `bv mormot run`, `bv mormot build`, `bv mormot status`, `bv mormot kill`. |
| **16** | [The Full-Stack CRUD Generator](16-mormot-crud.md) | One-command full-stack generation: `bv mormot crud <Model>` (ORM model, REST API, reactive DataGrid). |
| **17** | [Enterprise JWT Authentication & RBAC](17-mormot-auth.md) | Automated auth suite: `bv mormot auth` (JWT tokens, route guards `requiresAuth`, role control). |
| **18** | [Type-Safe Pascal RPC & OpenAPI Swagger](18-mormot-rpc.md) | `bv mormot rpc` client proxies, compile-time API validation, and `bv mormot docs` Swagger UI. |

### 🎨 Track 4: Official Ecosystem Packages & Visual Cockpit (Modules 19 - 22)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **19** | [Official Component Catalog & Themes](19-ui-themes.md) | 30+ `@blaise-ui` components and dynamic theme bundling (`bv theme list/add/use/reset`). |
| **20** | [Reactive Data Visualization (@blaise-charts)](20-charts.md) | Bar, line, pie, doughnut charts bound reactively to datasets. |
| **21** | [Enterprise Document Export (@blaise-reports)](21-reports.md) | Declarative reports with 1-click export to Vector PDF, native Excel, and CSV streaming. |
| **22** | [Developer Cockpit & Telemetry (@blaise-studio)](22-studio.md) | Real-time WebSocket monitoring, reactive state inspection, and performance metrics (`bv studio`). |

### 📱 Track 5: Universal Multiplatform: Mobile & Desktop (Modules 23 - 25)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **23** | [Hybrid Mobile Runtime with Capacitor](23-mobile-init.md) | Scaffolding mobile apps (`bv mobile init`, `bv mobile sync`, `bv mobile upgrade`). |
| **24** | [Compiling Native Android APKs & Emulators](24-mobile-android.md) | Android emulators (`bv mobile emulator`), APK/Bundle compilation (`bv mobile build android`), and `$mobile` hardware APIs. |
| **25** | [Native Desktop Applications with Lazarus & WebUI](25-desktop.md) | Lightweight desktop apps: `bv desktop init`, `bv desktop sync`, `bv desktop build`, `bv desktop run`. |

### 🛡️ Track 6: Banking-Grade Testing, Auditing & Governance (Modules 26 - 28)
| Module | Title | Core Competencies |
| :--- | :--- | :--- |
| **26** | [4-Tier Unit Testing & Headless E2E Suites](26-testing.md) | Pure Pascal unit tests (`bv g t`, `bv test`) and headless browser integration tests (`bv test e2e`). |
| **27** | [AST Type-Checking & Terminal Mastery](27-cli-tools.md) | Template audits (`bv check`), Cockpit shell (`bv enter`, `bv use`), project registry, licenses, and SemVer bumps (`bv meta bump`). |
| **28** | [External Library Packaging & Capstone Universal ERP](28-libraries.md) | Creating libraries (`bv create --lib`), packaging (`bv lib pack`), decentralized repos (`bv repo`), and capstone project. |

---

## 💡 Pro Tips for Your Success

- **Do not just memorize — type and practice**: Coding is learned through your fingers. Open the files, modify values, change colors, and see what happens!
- **Never fear mistakes**: If something does not appear on screen, press `F12` to open your browser developer tools. BlaiseVue gives clear diagnostics to help you.
- **Run the system doctor**: At any time, open your terminal and type `bv doctor`. It verifies that Free Pascal, InstantFPC, Python 3, and Node.js are healthy and ready to roll!

---

Ready to begin? Let's take the first step together!  
👉 **[Open Module 01: The Beginning of the Journey](01-introduction.md)** 🛡️✨🚀
