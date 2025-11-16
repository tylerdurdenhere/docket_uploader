plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    implementation("com.google.firebase:firebase-analytics")
}

android {
    namespace = "com.example.task_final"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.task_final"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 👇 Remove create("debug"), just use existing one
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packagingOptions {
        resources {
            excludes += setOf(
                "/META-INF/DEPENDENCIES",
                "/META-INF/LICENSE",
                "/META-INF/NOTICE"
            )
        }
    }
}

flutter {
    source = "../.."
}
