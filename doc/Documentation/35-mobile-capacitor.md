# 35. Hybrid Mobile Platform & Capacitor (bv mobile)

BlaiseVue enables native mobile application compilation and execution on **Android** and **iOS**, leveraging the modern **Capacitor** runtime together with the framework's native Pascal compiler.

This architecture enables the exact same Object Pascal business logic and Single File Components (`.bv`) to run on the Web and packaged into native APKs for mobile phones and tablets.

---

## 📱 Mobile Architecture Overview

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Single File Components (.bv)         │
│         100% Object Pascal Logic + Templates           │
└──────────────────────────┬─────────────────────────────┘
                           │ Transpilation (bv run build)
┌──────────────────────────▼─────────────────────────────┐
│                 Optimized Web Bundle                   │
│          dist/ (index.html, main.js, css/)             │
└──────────────────────────┬─────────────────────────────┘
                           │ Synchronization (bv mobile sync)
┌──────────────────────────▼─────────────────────────────┐
│           Capacitor Native Platform (mobile/)          │
│   mobile/android/ (Android Studio) / mobile/ios/ (Xcode)│
└──────────────────────────┬─────────────────────────────┘
                           │ Compilation (bv mobile build [target] [--release])
┌──────────────────────────▼─────────────────────────────┐
│          Native Installable Packages (mobile/bin/)     │
│   mobile/bin/android/<App>-debug.apk                   │
│   mobile/bin/android/<App>-release.apk                 │
│   mobile/bin/ios/<App>.ipa                             │
└────────────────────────────────────────────────────────┘
```

---

## 📦 Directory Structure (`mobile/`)

When running `bv mobile init [AppName] [com.company.app]`, the following segregated multiplatform structure is generated in `mobile/`:

```text
my-project/
├── mobile/
│   ├── capacitor.config.json   # Capacitor configuration with paths to mobile/android and mobile/ios
│   ├── android/                # Native Android Studio project (Gradle Wrapper, app/src, Manifest)
│   ├── ios/                    # Native Xcode project (when added)
│   ├── bin/                    # Platform-segregated ready-to-install packages
│   │   ├── android/            # MyApp-debug.apk and MyApp-release.apk
│   │   └── ios/                # MyApp.ipa
│   └── README.md               # Mobile development instructions and commands
├── desktop/                    # Lazarus / WebUI desktop project
├── src/                        # Shared .bv components and Object Pascal code
└── dist/                       # Compiled production web bundle
```

---

## 📋 Mobile Environment Setup Guide (Android)

To develop and build mobile applications in BlaiseVue, the developer only needs the standard **Android Studio** toolchain.

> [!IMPORTANT]
> **BlaiseVue does NOT use or require Flutter.**  
> The framework has zero dependencies on the Flutter SDK or Dart language. If you have Flutter installed on your system, you can safely uninstall it without affecting BlaiseVue.

### Required Prerequisites:
1. **Node.js (v18+ LTS) & npm**: Used to manage the Capacitor runtime dependencies (`@capacitor/core`, `@capacitor/cli`, `@capacitor/android`).
2. **Android Studio**:
   - **Android SDK Platform**: APIs 33, 34, or 35 installed via *SDK Manager*.
   - **Android SDK Build-Tools & Platform-Tools**: Provides the `adb` utility (Android Debug Bridge).
   - **Android Emulator**: Allows running and testing virtual devices without requiring a physical USB cable.
3. **Java JDK (JDK 17 or 21)**: Typically bundled directly with Android Studio (`jbr` / JetBrains Runtime) or installed via OpenJDK.
4. **Recommended Environment Variables (Windows)**:
   - `ANDROID_HOME`: `%LOCALAPPDATA%\Android\Sdk`
   - Added to `PATH`:
     - `%LOCALAPPDATA%\Android\Sdk\platform-tools` (for `adb`)
     - `%LOCALAPPDATA%\Android\Sdk\emulator` (for `emulator`)

---

## 🛠️ CLI Commands (`bv mobile`)

The `bv.exe` CLI provides native, granular support for the entire mobile lifecycle:

```bash
# 1. Initialize mobile project with Capacitor and mobile/ directory structure
bv mobile init [AppName] [com.yourcompany.app]

# 2. Synchronize build directory (dist/) with Android/iOS native assets
bv mobile sync [android|ios|all]

# 3. DEBUG Build Mode (active symbols and verbose logging):
bv mobile build android             # Builds Debug APK to mobile/bin/android/<App>-debug.apk
bv mobile build ios                 # Prepares and synchronizes native iOS project

# 4. RELEASE Build Mode (R8/ProGuard code shrinking and bytecode optimization):
bv mobile build android --release   # Builds Release APK to mobile/bin/android/<App>-release.apk
bv mobile build all --release       # Compiles all mobile platforms

# 5. Android Virtual Device (AVD) Emulator Management:
bv mobile emulator list             # Lists all emulators installed in Android Studio
bv mobile emulator start [name]      # Boots the specified emulator in the background
bv mobile emulator run [name]        # Boots emulator, waits for system, and launches the app

# 6. Direct execution on connected device or emulator via ADB:
bv mobile run android               # Installs and launches on USB-connected phone
bv mobile run android --emulator    # Automatically boots emulator and launches the app

# 7. Open project in native IDE:
bv mobile open android              # Opens project in Android Studio
bv mobile open ios                  # Opens project in Xcode (on macOS)
```

### ⚙️ Build Modes & Mobile Platforms

| Mobile Command | Platform | Build Mode | Package / Action | Purpose |
|---|---|---|---|---|
| `bv mobile build android` | Android | Debug | `mobile/bin/android/<App>-debug.apk` | Rapid testing, development, and Logcat diagnostics |
| `bv mobile build android --release` | Android | Release (R8/ProGuard) | `mobile/bin/android/<App>-release.apk` | Compact, optimized production build for stores |
| `bv mobile emulator list` | Android | - | Displays installed AVDs | Inspect configured emulators on host machine |
| `bv mobile emulator start` | Android | - | Boots AVD in background | Prepares emulator environment for development |
| `bv mobile run android` | Android | Debug | ADB Deploy & Launch | Direct installation on USB device |
| `bv mobile run android --emulator` | Android | Debug | Boot AVD + ADB Deploy | 100% automated emulator launch and test |
| `bv mobile open android` | Android | - | Android Studio | Native Java/Kotlin editing, emulators, profilers |
| `bv mobile open ios` | iOS | - | Xcode | Signing and compiling for iPhone/iPad (macOS) |

---

## 🎨 Mobile-Optimized Components & Layouts

To ensure a smooth, ergonomic user experience (UX) on smartphones, the **BlaiseUI** kit includes responsive layout components:

### 1. Responsive Grid System (`<bv-container>`, `<bv-row>`, `<bv-col>`)
Allows layouts to adapt automatically across smartphones, tablets, and desktops:
- Fluid 12-column grid breakpoints (`cols="12" md="6" lg="4"`).
- Adjustable spacing with `gutter="sm|md|lg"`.
- Fully compatible with Bootstrap classes and custom themes.

```html
<bv-container fluid="true">
  <bv-row gutter="md">
    <!-- Full width on mobile (12 cols), half width on tablet/desktop (6 cols) -->
    <bv-col cols="12" md="6">
      <bv-card title="Real-time Metrics">...</bv-card>
    </bv-col>
    <bv-col cols="12" md="6">
      <bv-card title="Quick Actions">...</bv-card>
    </bv-col>
  </bv-row>
</bv-container>
```

### 2. Bottom Navigation Bar (`<bv-bottom-nav>`, `<bv-bottom-nav-item>`)
Pinned to the bottom of the viewport for ergonomic thumb reach on mobile devices:
- Sharp icons and descriptive labels.
- Reactive highlighting of active tab based on current route.
- Automatic responsive visibility via media queries (visible on mobile, hidden on wide desktops).

```html
<bv-bottom-nav class="mobile-bottom-bar">
  <bv-bottom-nav-item href="#/" icon="🏠" label="Home"></bv-bottom-nav-item>
  <bv-bottom-nav-item href="#/pro" icon="⚡" label="Pro"></bv-bottom-nav-item>
  <bv-bottom-nav-item href="#/form" icon="📋" label="Forms"></bv-bottom-nav-item>
  <bv-bottom-nav-item href="#/bootstrap" icon="🎨" label="BlaiseUI"></bv-bottom-nav-item>
</bv-bottom-nav>
```

### 3. Off-Canvas Drawer Menu (`<bv-drawer>`)
Provides a responsive slide-out drawer for secondary navigation:
- Imperative control via template references (`this.$refs.mainDrawer.open()`, `this.$refs.mainDrawer.close()`).
- Closes automatically when clicking the backdrop or selecting internal links.
- Clean rendering outside the standard DOM flow with elevated stacking order (`z-index`).

```html
<bv-drawer b-ref="appDrawer" title="🧭 Application Menu">
  <div class="drawer-nav">
    <a href="#/" class="drawer-link" @click="closeDrawer">🏠 Home</a>
    <a href="#/about" class="drawer-link" @click="closeDrawer">ℹ️ About</a>
    <a href="#/bootstrap" class="drawer-link" @click="closeDrawer">🎨 BlaiseUI Kit</a>
  </div>
</bv-drawer>
```

### 4. Adaptive Modal Dialogs (`<bv-modal>`)
Architected with built-in `<teleport to="body">`:
- Centered layout with safe area margins on compact mobile screens.
- Instant rendering via `b-show="isVisible" style="display: none;"`.
- Strict lifecycle teardown (`bvUnmount`), guaranteeing no orphan backdrops remain in the DOM tree.

---

## 📲 Deploy & Test on Physical Android Device via ADB

Using `adb` (Android Debug Bridge), you can install and validate the application on devices connected via USB or Wi-Fi:

```bash
# 1. Verify connected devices
adb devices

# 2. Install or update APK directly on device
adb install -r mobile/bin/android/BlaiseVue_Demo-debug.apk

# 3. Launch main Activity on smartphone
adb shell am start -n com.blaisevue.demoapp/.MainActivity

# 4. Capture screenshot for layout validation
adb exec-out screencap -p > screen_mobile_test.png
```

---

## 🏆 Advantages of the BlaiseVue Hybrid Mobile Approach

1. **Total Code Reuse**: Over 95% of Object Pascal business logic, state management, and visual components are shared across Web, Android, iOS, and Desktop.
2. **High Performance**: Native Pas2JS transpilation with a lightweight runtime and optional WebAssembly acceleration.
3. **Visual Consistency**: Bootswatch theme palettes and BlaiseUI components behave uniformly across all resolutions. 🚀📱✨
