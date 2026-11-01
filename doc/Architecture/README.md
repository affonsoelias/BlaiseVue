# 🏛️ BlaiseVue Core Architecture & Internals

Welcome to the internal engineering and architectural specifications of the **BlaiseVue Framework**.

This section is dedicated to framework core engineers, compiler developers, and open-source contributors who wish to understand the low-level mechanics of the platform, the Pas2JS compilation pipeline, and the reactive proxy engine.

---

## 📚 Architectural Guides

| Document | Focus Area | Description |
| :--- | :--- | :--- |
| 🏗️ [**01. Architecture Overview**](01-Architecture-Overview.md) | Platform Layers | High-level architectural tiers from Object Pascal SFCs to Browser Runtime and mORMot 2. |
| 🧠 [**02. Reactivity Engine**](02-Reactivity-Engine.md) | Proxy & DOM Patching | Deep dive into `TBVProxy`, dependency tracking, automatic dirty checking, and $O(1)$ patching. |
| ⚙️ [**03. Compiler Pipeline**](03-Compiler-Pipeline.md) | Transpilation Pipeline | Step-by-step breakdown of how `.bv` Single File Components are stripped, AST-evaluated, and transpiled. |
| 🛡️ [**04. Contributing Guide**](04-Contributing-Guide.md) | Contributor Standard | Coding standards, Git branch workflow (`develop` $\rightarrow$ `main`), test requirements, and Pull Request guidelines. |

---

## 🗺️ Framework Organization

For reference manuals and user guides, visit:
- 📖 [**Technical Documentation (52 Manuals)**](../Documentation/README.md)
- 🎓 [**Practical Course (13 Modules)**](../Course/README.md)
- 🗺️ [**Technical Roadmap (v2.0 – v5.0)**](../Documentation/99-roadmap.md)
