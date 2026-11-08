# 🚀 Module 21: Emulation, Live Debugging & Device Build
**Build, test, debug, and package production-ready APK and AAB bundles for Android.**

Writing mobile components is only half the journey. As a professional developer, you need to test your application on emulated virtual devices, debug on real physical smartphones connected via USB, and package signed bundles ready for the Google Play Store.

The BlaiseVue CLI (`bv mobile`) provides automated commands that orchestrate the Android SDK, Gradle, ADB, and emulators with zero friction.

---

## 🛠️ 1. Environment Checklist (Android SDK)

Before running mobile emulators or building APKs, verify your system has:
1. **Android Studio** installed.
2. **Android SDK Command-line Tools** & **Platform-Tools** (which provides `adb`).
3. An **Android Virtual Device (AVD)** created via the Android Studio *Device Manager*.
4. Environment variable configured:
   - `ANDROID_HOME`: `%LOCALAPPDATA%\Android\Sdk` (Windows) or `~/Android/Sdk` (Linux/macOS).
   - `adb` accessible on your system `PATH`.

---

## 📱 2. Managing Emulators from the CLI

You don't need to keep Android Studio open just to boot a virtual device. BlaiseVue lets you manage emulators directly from your terminal:

```bash
# 1. List all Android Virtual Devices (AVDs) installed on your system
bv mobile emulator list

# 2. Boot a specific emulator in the background
bv mobile emulator start Pixel_7_API_34

# 3. Kill any lingering emulator or hung QEMU processes
bv mobile emulator kill
```

---

## 🏃 3. The All-in-One Run Command (`bv mobile run android`)

The most powerful command during mobile development is `bv mobile run`:

```bash
# Option A: Run on a physical phone connected via USB
bv mobile run android

# Option B: Automatically boot an emulator, install the app, and launch it!
bv mobile run android --emulator

# Option C: Kill any hung emulator, clean-boot a fresh AVD, build & launch:
bv mobile run android --emulator --fresh
```

### 🧠 What Happens Behind the Scenes:
1. Recompiles your latest `.bv` components into `dist/`.
2. Synchronizes web assets with the native Android project (`bv mobile sync android`).
3. Checks if an emulator or physical device is online; if not, boots the AVD automatically.
4. Waits for the Android system to report `sys.boot_completed == 1`.
5. Compiles the native Android project with Gradle.
6. Deploys the APK via `adb install -r`.
7. Launches the main Activity (`com.mycompany.myapp/.MainActivity`) and brings the window to focus!

---

## 🔍 4. Live Debugging with Chrome DevTools

How do you inspect the DOM, view console errors, and step through Pascal code running inside an Android phone or emulator?

1. Connect your phone via USB (or start your emulator).
2. Launch your BlaiseVue mobile app.
3. On your desktop development computer, open Google Chrome and navigate to:  
   **`chrome://inspect/#devices`**
4. Under **Remote Target**, find your device and click **inspect**.

A full Chrome DevTools window opens! You can:
- Inspect elements, modify styles live, and test responsive breakpoints.
- View console logs (`WriteLn` outputs and JavaScript logs).
- Profile network calls made to your mORMot 2 backend!

---

## 📦 5. Building Production Packages (APK vs. AAB)

When your application is tested and ready to ship, compile using the `--release` or `--bundle` flags:

### 1. Release APK (Direct Device Installation)
```bash
bv mobile build android --release
```
- **Output**: `mobile/bin/android/MyApp-release.apk`
- **Use Case**: Side-loading on company devices, sending to beta testers, or enterprise internal distribution.

### 2. Android App Bundle (Google Play Store)
```bash
bv mobile build android --bundle
```
- **Output**: `mobile/bin/android/MyApp-release.aab`
- **Use Case**: Uploading to the Google Play Console. Google Play uses AAB to generate device-optimized split APKs for users.

---

## 🔐 6. Production Code Signing (`keystore.properties`)

For local testing, BlaiseVue automatically uses a fallback debug signature so you can test release builds immediately without signing errors.

When publishing to Google Play:
1. Generate your production keystore with `keytool`:
   ```bash
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
   ```
2. Create a configuration file `mobile/android/keystore.properties`:
   ```properties
   storeFile=../my-release-key.jks
   storePassword=YourKeystorePassword
   keyAlias=my-alias
   keyPassword=YourKeyPassword
   ```
3. Run `bv mobile build android --bundle`. BlaiseVue will automatically detect the keystore and sign the production App Bundle!

*(Both `keystore.properties` and `*.jks` are automatically ignored in `.gitignore` to prevent leaking credentials).*

---

## 🏋️ Practical Exercise

1. Connect an Android phone with USB Debugging enabled (or start an emulator with `bv mobile emulator start`).
2. Run `adb devices` in your terminal to verify connection.
3. Execute `bv mobile run android`.
4. Open `chrome://inspect` in your desktop browser and open the inspector for your app.
5. In your Pascal code, add `WriteLn('Mobile app initialized successfully!');` in the `mounted:` hook and verify that the message appears in the Chrome DevTools console!
6. Generate a standalone release APK with `bv mobile build android --release` and check that the APK file was placed in `mobile/bin/android/`.

---

## 📖 Deeper Technical Reference

- **[Hybrid Mobile Platform & Capacitor Manual](../Documentation/35-mobile-capacitor.md)**: Deep dive into ADB commands, automated Gradle troubleshooting, ProGuard/R8 obfuscation, and multi-device deployment.

---

[⬅️ Module 20: Mobile UI Components & Touch Gestures](20-mobile-ui.md) | [🏠 Course Index](README.md) | [Module 22: Native Lightweight Desktop Applications ➡️](22-desktop-webui.md)
