# Flutter and plugin recommended rules
# Keep all from Flutter framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep google sign in auth classes
-keep class com.google.android.gms.** { *; }
-keep class com.google.api.client.** { *; }
-keep class com.google.api.client.googleapis.** { *; }
-keep class com.google.api.client.json.** { *; }

# Keep OkHttp if used
-keep class okhttp3.** { *; }

# You may need to add more rules depending on reflection use in plugins
