# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Ignore missing Play Core classes (not needed without deferred components)
-dontwarn com.google.android.play.core.**

# SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** { *; }

# Gson - preserve generic type information
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# timezone
-keep class org.threeten.** { *; }

# flutter_timezone
-keep class net.wolverinebeach.flutter_timezone.** { *; }

# printing / pdf
-keep class com.example.printing.** { *; }

# Keep all model classes
-keep class com.example.hyper_journal.** { *; }

-keepattributes Exceptions
