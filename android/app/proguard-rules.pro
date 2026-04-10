# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite
-keep class org.sqlite.** { *; }

# Provider
-keep class com.example.** { *; }
-keep class * extends com.example.** { *; }

# Keep main method
-keepclassmembers class ** {
    public static void main(java.lang.String[]);
}

# Keep Flutter plugin registration
-keepattributes *Annotation*
-keepclasseswithmembernames class * {
    native <methods>;
}
