# 🛡️ Contributing to BlaiseVue
**How to help build the future of Pascal on the Web.**

We are thrilled to have you here! Contributing to BlaiseVue isn't just about writing code; it's about making Pascal a first-class citizen in the modern web ecosystem.

---

## 1. Coding Standards
To maintain a clean and maintainable codebase, we follow these Pascal standards:
- **Naming**: Use **PascalCase** for classes and types (e.g., `TBVComponent`), and **camelCase** for local variables and parameters.
- **English Only**: All new code, comments, and documentation must be in **English** to be accessible to the global community.
- **Typing**: Avoid using `JSValue` too much. Use specific types whenever possible to take advantage of Pascal's strong typing.

## 2. The Development Workflow
1. **Fork & Clone**: Create your own version of the repository.
2. **Branching**: Create a feature branch (e.g., `feat/new-directive`).
3. **Build CLI**: Compile the CLI (`bin/bv.pas`) using FPC before testing changes.
4. **Unit Testing**: Run `bv test` to ensure your changes don't break existing functionality.

## 3. Testing Your Changes
Never submit a Pull Request without automated tests.
- Create a new test case in `tests/` using `bv new t <FeatureName>`.
- Use the **BVTestUtils** to validate DOM changes and reactivity.
- Run `bv test` and ensure all suites pass (Green).

## 4. Submitting a Pull Request (PR)
- **Clear Title**: Describe the feature or bug fix clearly.
- **Documentation**: If you added a feature, update the relevant file in the `/Documentation` folder.
- **Impact**: Briefly explain how your changes affect the core engine or CLI performance.

---
🛡️ **"In Pascal we trust. Let's build something great together."** ✨🏆🌍
