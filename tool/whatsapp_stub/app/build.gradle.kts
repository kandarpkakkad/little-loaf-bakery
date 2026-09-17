plugins {
    id("com.android.application")
}

android {
    namespace = "com.littleloaf.whatsappstub"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.littleloaf.whatsappstub"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
