import java.util.Properties

// Release signing lives in android/key.properties, which is deliberately not in
// version control. Without it a release build falls back to the debug key, so
// the build prints a warning rather than silently producing an unshippable APK.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.littleloaf.little_loaf"
    compileSdk = 36        // Android 16 (required by androidx.core 1.18.0 / browser 1.9.0)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.littleloaf.little_loaf"
        manifestPlaceholders["appLabel"] = "Little Loaf"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35     // Android 15
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Where the DEBUG key comes from, said out loud.
        //
        // By default the Android plugin looks for ~/.android/debug.keystore —
        // except when ANDROID_SDK_HOME is set, when it looks under that
        // instead, and generates a fresh random key if it finds nothing. On a
        // CI runner that is exactly what happened: the workflow wrote the real
        // keystore to $HOME/.android, Gradle looked elsewhere, made its own,
        // and produced an APK signed bd400024… instead of 078c6665… — which
        // Google has never been told about, so sign-in could not work.
        //
        // Pointing at a file in the project removes the guesswork. Absent, the
        // default still applies, so a normal local build is unchanged.
        val projectDebugKey = rootProject.file("debug.keystore")
        if (projectDebugKey.exists()) {
            getByName("debug") {
                storeFile = projectDebugKey
                // Not secrets: these are the values every Android debug
                // keystore in the world uses.
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }

        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            // A separate app, not the same one in a different mood.
            //
            // Without this, debug and release share an applicationId, which
            // means they share the app-private database: installing one
            // replaces the other and inherits its data, so "just try it on the
            // debug build" quietly runs against the bakery's real orders and
            // can migrate them. With it they install side by side and cannot
            // touch each other's storage.
            //
            // The package name is part of what identifies an Android OAuth
            // client, so this needs its own client registered against
            // com.littleloaf.little_loaf.debug and the debug signing SHA-1.
            // See docs/01-platform/sync/lld.md.
            applicationIdSuffix = ".debug"
            manifestPlaceholders["appLabel"] = "Little Loaf debug"
        }

        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING: android/key.properties is missing — signing this " +
                    "release with the DEBUG key. The result is not distributable."
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
