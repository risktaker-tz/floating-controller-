plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "io.aegis.mock"
    compileSdk = 35
    defaultConfig {
        applicationId = "io.aegis.mock"
        minSdk = 26
        targetSdk = 35
        versionCode = 2
        versionName = "1.0.1"
    }
    buildFeatures { compose = true }

    buildTypes {
        getByName("release") {
            isDebuggable = false
            isMinifyEnabled = false
            // signingConfig intentionally NOT set — CI uses apksigner directly
            // to enable v1+v2+v3 signing (AGP 8.7.x ignores enableV1Signing=true
            // for minSdkVersion >= 24).
        }
    }
}

kotlin { jvmToolchain(17) }

dependencies {
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.activity:activity-compose:1.10.0")
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
}
