# 🏛️ Framework Architecture: High-Level Overview
**Master the internals of BlaiseVue.**

Welcome to the architectural deep-dive. This section is designed for developers who want to understand the "magic" behind the framework and start contributing to the core repository.

---

## 1. The Multi-Layered Architecture
BlaiseVue is structured into three distinct layers that communicate through a centralized proxy system.

### A. The CLI Layer (The Orchestrator)
- **File**: `bin/bv.pas`
- **Role**: Handles the Single File Components (.bv). It separates the Template, Script, and Style blocks and transforms them into valid Object Pascal units in the `generated/` folder.

### B. The Reactivity Layer (The Brain)
- **File**: `core/BVReactivity.pas`
- **Role**: This is the most critical part. It uses JavaScript Proxies to track which parts of the DOM depend on which variables. It manages the **Observer Pattern** and the **Job Queue** to avoid redundant renders.

### C. The Compiler & Runtime Layer (The Execution)
- **Files**: `core/BVCompiler.pas`, `core/BVDirectives.pas`
- **Role**: Traverses the DOM tree looking for directives (`b-if`, `b-for`, `@click`). It binds "Effects" (reactive functions) to specific DOM nodes and manages the component lifecycle (Created, Mounted, etc.).

---

## 2. The Data Flow (Unidirectional and Reactive)
Data flows from the Pascal state to the DOM via the **Reactivity Engine**.
1. **Mutation**: A method changes a variable in the Proxy (this['counter'] := 1).
2. **Trigger**: The Proxy 'set' trap identifies all 'Effects' that used that variable.
3. **Queue**: Effects are pushed into a microtask queue (The Scheduler).
4. **Flush**: The Scheduler executes all updates once per frame, ensuring maximum performance.

---

## 3. Communication Bridge: Pascal <=> JavaScript
Since BlaiseVue runs in the browser, it uses **Pas2JS** as its foundation.
- The framework uses `asm` blocks for low-level JS manipulations.
- The `JSValue` type is used to handle dynamic objects while maintaining type safety where possible.

---
🛡️ **Next Lesson:** Deep dive into the Reactivity Engine (Observer Pattern).
