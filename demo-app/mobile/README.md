# BlaiseVue Mobile (BlaiseVue 3.5 Mobile)

Native mobile application powered by **Capacitor** and **BlaiseVue**.

## Structure
- `android/`: Native Android Studio project.
- `ios/`: Native Xcode project (when added).
- `bin/`: Platform-segregated ready-to-install packages:
  - `bin/android/`: Compiled APKs (`BlaiseVue_Demo-debug.apk`, `BlaiseVue_Demo-release.apk`).
  - `bin/ios/`: Compiled IPAs.
- `capacitor.config.json`: Capacitor bridge configuration.

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

# 5. Run or Open IDE
bv mobile run android              # Install & launch via ADB
bv mobile open android             # Open in Android Studio
bv mobile open ios                 # Open in Xcode
```
