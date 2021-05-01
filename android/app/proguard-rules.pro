#Flutter Wrapper

-optimizationpasses 6
-obfuscationdictionary keywords.txt
-flattenpackagehierarchy

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-dontwarn java8.util.**

-keep class androidx.lifecycle.DefaultLifecycleObserver