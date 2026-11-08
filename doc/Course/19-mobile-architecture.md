# 📱 Module 19: Mobile Architecture & Capacitor Setup
**Transform your BlaiseVue Pascal applications into native Android and iOS mobile packages.**

One of the greatest superpowers of modern software engineering is code reuse. Why hire separate teams to write Swift for iOS, Kotlin for Android, and TypeScript for the Web when you can write **100% Object Pascal** and deliver across all platforms simultaneously?

BlaiseVue achieves this through a high-performance **Hybrid Mobile Architecture** powered by **Capacitor**. Your reactive `.bv` components and Pascal domain logic transpile to optimized web assets that execute within a native mobile container, granting full access to hardware APIs with near-zero overhead.

---

## 🏛️ 1. Mobile Architecture Overview

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Single File Components (.bv)         │
│         100% Object Pascal Logic + Templates           │
└──────────────────────────┬─────────────────────────────┘
                           │ Transpilation (bv build)
┌──────────────────────────▼─────────────────────────────┐
│                 Optimized Web Bundle                   │
│          dist/ (index.html, main.js, css/)             │
└──────────────────────────┬─────────────────────────────┘
                           │ Synchronization (bv mobile sync)
┌──────────────────────────▼─────────────────────────────┐
│           Capacitor Native Platform (mobile/)          │
│   mobile/android/ (Android Studio) / mobile/ios/ (Xcode)│
└──────────────────────────┬─────────────────────────────┘
                           │ Compilation (bv mobile build android [--release])
┌──────────────────────────▼─────────────────────────────┐
│          Native Installable Packages (mobile/bin/)     │
│   mobile/bin/android/<App>-debug.apk                   │
│   mobile/bin/android/<App>-release.apk                 │
│   mobile/bin/ios/<App>.ipa                             │
└────────────────────────────────────────────────────────┘
```

> [!IMPORTANT]
> **No Flutter, No Dart, Zero Bloat**: BlaiseVue mobile has zero dependencies on Flutter or Dart. You do not need the Flutter SDK. Everything runs on standard web and native mobile toolchains (Android Studio / Xcode).

---

## 🛠️ 2. Initializing Mobile with `bv mobile init`

To turn any existing BlaiseVue project into a multi-platform mobile application, run:

```bash
# Syntax: bv mobile init [AppName] [PackageIdentifier]
bv mobile init MyApp com.mycompany.myapp
```

This single command sets up Capacitor, downloads runtime dependencies, and configures the native Android Studio project structure in `mobile/`.

### 📂 Directory Structure (`mobile/`):

```text
my-project/
├── mobile/
│   ├── capacitor.config.json   # Capacitor configuration (app ID, webDir, plugins)
│   ├── android/                # Native Android Studio project (Gradle Wrapper, app/src, Manifest)
│   ├── ios/                    # Native Xcode project (when added on macOS)
│   ├── bin/                    # Output folder for compiled APK/AAB packages
│   │   ├── android/            # MyApp-debug.apk and MyApp-release.apk
│   │   └── ios/                # MyApp.ipa
│   └── README.md               # Mobile development cheat-sheet
├── src/                        # Your shared .bv components
├── dist/                       # Transpiled web application
└── app.cfg                     # BlaiseVue project config
```

---

## 🔄 3. Synchronizing Web Assets with `bv mobile sync`

Whenever you modify your `.bv` views or Pascal business logic, your web bundle must be copied into the native mobile assets folder:

```bash
# Recompiles frontend and synchronizes native project assets
bv mobile sync android

# Or sync all mobile platforms simultaneously:
bv mobile sync all
```

---

## 📸 4. Accessing Native Hardware APIs

Through Capacitor plugins, your Object Pascal code can access native device hardware such as the Camera, GPS, Haptic engine, and Secure Storage:

### Example: Taking a Photo with the Native Camera

```pascal
uses JS, Web;

procedure TMyView.CapturePhoto;
begin
  // Access the Capacitor native Camera API
  asm
    const { Camera, CameraResultType } = window.Capacitor.Plugins;
    Camera.getPhoto({
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Uri
    }).then(image => {
      this.capturedPhotoUrl = image.webPath;
    }).catch(err => {
      console.error('Camera error:', err);
    });
  end;
end;
```

### Example: Triggering Native Haptic Vibration

```pascal
procedure TMyView.TriggerVibration;
begin
  asm
    const { Haptics, ImpactStyle } = window.Capacitor.Plugins;
    if (Haptics) {
      Haptics.impact({ style: ImpactStyle.Heavy });
    }
  end;
end;
```

---

## 🛡️ 5. Self-Healing Gradle & Java Compatibility

One of the biggest headaches in cross-platform development is Gradle build failures due to incompatible JDK versions (e.g. Java 17 vs Java 21).

BlaiseVue includes an automated **Self-Healing Gradle Engine**:
- When you execute `bv mobile build android` or `bv mobile run android`, BlaiseVue automatically verifies and harmonizes `build.gradle`, `app/build.gradle`, and `capacitor.build.gradle` to **Java 17 LTS**.
- This ensures clean compilation whether your system uses OpenJDK 17, 21, or the bundled JetBrains Runtime (`jbr`) from Android Studio.

---

## 💻 6. Opening the Project in Android Studio

If you want to configure native Android manifests, app icons, splash screens, or custom native Java/Kotlin plugins:

```bash
# Opens the native project directly in Android Studio
bv mobile open android

# On macOS, opens in Xcode:
bv mobile open ios
```

---

## 🏋️ Practical Exercise

1. Inside your BlaiseVue workspace, initialize mobile support:
   ```bash
   bv mobile init MyMobileApp com.example.mymobileapp
   ```
2. Inspect `mobile/capacitor.config.json` and verify the `appId` and `webDir` properties.
3. Add a button in your `src/views/Home.bv` that calls a vibration/haptic alert on click.
4. Run `bv mobile sync android` to ensure the updated view is bundled into the Android project.

---

## 📖 Deeper Technical Reference

- **[Hybrid Mobile Platform & Capacitor Manual](../Documentation/35-mobile-capacitor.md)**: Exhaustive manual detailing Gradle configuration, dual signing modes, and native manifest permissions.

---

[⬅️ Module 18: High-Performance RPC & SOA Client Proxies](18-mormot-rpc.md) | [🏠 Course Index](README.md) | [Module 20: Mobile UI Components & Touch Gestures ➡️](20-mobile-ui.md)
