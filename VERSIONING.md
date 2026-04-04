# 📋 BlaiseVue Versioning Model

BlaiseVue adopts a versioning model inspired by the **Lazarus IDE and Free Pascal**, which focuses on clearly distinguishing between stable releases and development versions.

## 🏺 The Version Format
Versions follow the standard format: `Major.Minor.Revision` (e.g., `1.0.0`)

### ⚖️ The Even/Odd Rule (Minor Version)
The most important rule in our model is the parity of the **Minor** version number:

- **🟢 EVEN Minor Versions (Stable)**: 
  Versions like `1.0.x`, `1.2.x`, and `2.0.x` are stable, production-ready releases. No new features are added to these branches; they only receive bugfixes through revision updates.
  
- **🔴 ODD Minor Versions (Development)**: 
  Versions like `1.1.x`, `1.3.x`, and `2.1.x` are development branches (trunk). They contain experimental features and represent the path towards the next stable release.

### 🛠️ Revision (Patch)
The third number is incremented for bugfixes and small optimizations.
- Example: `1.0.1` -> `1.0.2` (Strictly bugfixes).

---

## 🚀 Release Cycle Example
1.  **v1.0.0**: **First Stable Release** (Our current launch!).
2.  **v1.1.x**: Development begins for the next generation of features.
3.  **v1.2.0**: The features from the 1.1 branch are stabilized and released as the next stable version.

---
**BlaiseVue: Stability and Predictability.** 🛡️✨🚀
