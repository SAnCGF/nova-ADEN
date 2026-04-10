# Reglas para evitar que la app se cierre al abrirse
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantener clases de SQLite
-keep class org.sqlite.** { *; }

# Mantener Provider
-keep class * extends com.example.** { *; }

-keepattributes *Annotation*
