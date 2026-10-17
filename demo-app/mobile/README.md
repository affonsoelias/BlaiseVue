# BlaiseVue Mobile (BlaiseVue 3.5 Mobile)

Native mobile application powered by **Capacitor** and **BlaiseVue**.

## Structure
- `android/`: Native Android Studio project.
- `ios/`: Native Xcode project (when added).
- `bin/`: Platform-segregated ready-to-install packages:
  - `bin/android/`: Compiled APKs (`BlaiseVue_Demo-debug.apk`, `BlaiseVue_Demo-release.apk`).
  - `bin/ios/`: Compiled IPAs.
- `capacitor.config.json`: Capacitor bridge configuration.

## Prerequisites
- **Node.js**: v18+ LTS and npm
- **Android Studio**: Android SDK (API 33-35), Build-Tools, Platform-Tools (`adb`)
- **Android Emulator**: At least 1 Virtual Device (AVD) created via Android Studio Device Manager
- **Java JDK**: JDK 17 or 21 (bundled with Android Studio or OpenJDK)
- **Note**: **Flutter is NOT required** and does not need to be installed.

## Quick Commands
```bash
# 1. Sync frontend to mobile assets
bv mobile sync

# 2. Build for Android
bv mobile build android            # Debug APK (with logs)
bv mobile build android --release  # Release APK (optimized with R8/ProGuard)

# 3. Build for iOS (macOS only)
bv mobile build ios

# 4. Build for all mobile platforms
bv mobile build all
bv mobile build all --release

# 5. Emulator Management
bv mobile emulator list            # List available AVDs
bv mobile emulator start [avd]     # Start an emulator in the background
bv mobile emulator run [avd]       # Boot emulator and run app

# 6. Run on Device or Emulator via ADB
bv mobile run android              # Install & launch on connected device
bv mobile run android --emulator   # Auto-boot emulator and launch app

# 7. Open Native IDE
bv mobile open android             # Open in Android Studio
bv mobile open ios                 # Open in Xcode (macOS)
```
