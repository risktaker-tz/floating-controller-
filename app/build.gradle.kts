plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("org.jetbrains.kotlin.kapt")
}

android {
    namespace = "io.aegis"
    compileSdk = 35
    defaultConfig {
        applicationId = "io.aegis"
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
            // signingConfig is intentionally NOT set here. AGP 8.7.x silently
            // ignores enableV1Signing=true when minSdkVersion >= 24, so we
            // cannot rely on AGP to produce a v1 (JAR) signature. Instead,
            // the CI workflow runs `apksigner sign --v1-signing-enabled true
            // --v2-signing-enabled true --v3-signing-enabled true` directly
            // on the unsigned APK after assembleRelease.
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
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    testImplementation(kotlin("test"))
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
}
