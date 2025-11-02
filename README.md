# Service Engineer Tracker

This Flutter project is an offline-first Android app for service engineers to manage bank machines and visits. It stores data locally with `sqflite` and integrates optional Google Calendar events for `nextVisitDate`.

## Quick setup

1. Install Android Studio (Windows):
   - Download and install Android Studio from https://developer.android.com/studio
   - Install Android SDK, Android SDK Platform for your target API levels (recommend API 31+), and Android SDK Build-Tools.
   - Install Android Emulator images if you want to use an emulator.

2. Install Flutter and set up PATH: https://docs.flutter.dev/get-started/install/windows
   - Run `flutter doctor` and follow any instructions.

3. Open the project in Android Studio or VS Code.

4. Get dependencies:

```powershell
cd 'your project location '
flutter pub get
```

5. Run the app (connect device or emulator):

```powershell
flutter run
```

## Google Sign-In & Calendar setup (Android)

To enable Google Calendar integration you must configure OAuth credentials:

1. Go to Google Cloud Console and create a new project (or use existing).
2. Enable the "Google Calendar API" for the project.
3. Go to "Credentials" -> Create OAuth client ID -> Android.
   - Provide package name (the one in `android/app/src/main/AndroidManifest.xml`) and SHA-1 fingerprint.
   - For debug builds, use the debug keystore SHA-1: `keytool -list -v -keystore %USERPROFILE%\\.android\\debug.keystore -alias androiddebugkey -storepass android -keypass android`
4. Download the configuration or note the client details; for `google_sign_in` normal usage you generally don't need google-services.json unless using Firebase.

Notes:
- The app uses `google_sign_in` and `googleapis` and signs requests by attaching `account.authHeaders`. Ensure the app's package name and SHA-1 are correctly configured in Google Cloud.
- Test sign-in on device where Google Play Services is available.

## Optimizations for low-end devices (Moto G45 5G and similar)

1. Android `minSdkVersion`: keep `minSdkVersion` at a sensible minimum (e.g., 21). Edit `android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.example.service_engineer_tracker"
    minSdkVersion 21
    targetSdkVersion 33
    // ...
}
```

2. Enable app size reductions for release builds (ProGuard / R8):

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

3. Split APKs by ABI if you want smaller downloads:

```gradle
android {
  // ...
  splits {
    abi {
      enable true
      reset()
      include 'armeabi-v7a', 'arm64-v8a'
      universalApk false
    }
  }
}
```

4. Flutter build flags for performance:

```powershell
# Profile build
flutter build apk --release --split-per-abi
```

5. UI performance tips
   - Use const constructors where possible.
   - Keep widget rebuilds minimal; use Riverpod providers as done in this project.
   - Avoid large images; use vector assets where possible.
   - Use ListView.builder for long lists (already used).

## Debugging tips

- Run `flutter analyze` and `flutter doctor` if you encounter issues.
- Use `flutter run --verbose` for verbose logs.
