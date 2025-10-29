# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.** { *; }

# Keep MainActivity
-keep class com.nutriz.app.MainActivity { *; }

# Keep all Activities
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Camera
-keep class io.flutter.plugins.camera.** { *; }

# Permissions
-keep class io.flutter.plugins.permission.** { *; }

# Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
