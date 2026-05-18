import java.io.File
import java.nio.file.Files

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties") // FIXED: rooteProject → rootProject
val keystoreProperties = mutableMapOf<String, String>()
if (keystorePropertiesFile.exists()) {
    Files.readAllLines(keystorePropertiesFile.toPath()).forEach { line ->
        val trimmed = line.trim()
        if (trimmed.isNotEmpty() && !trimmed.startsWith("#")) {
            val separator = trimmed.indexOf("=")
            if (separator > 0) {
                keystoreProperties[trimmed.substring(0, separator).trim()] =
                    trimmed.substring(separator + 1).trim()
            }
        }
    }
}
val requiredSigningKeys = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
val hasReleaseKeystore = keystorePropertiesFile.exists() &&
        requiredSigningKeys.all { keystoreProperties[it] != null }
fun signingProperty(name: String): String =
    keystoreProperties[name] ?: error("Missing signing property: $name")
fun resolveStoreFile(path: String): File {
    val candidate = File(path)
    if (candidate.isAbsolute) return candidate

    return listOf(
        file(path),
        rootProject.file(path),
        rootProject.projectDir.parentFile.resolve(path),
    ).firstOrNull { it.exists() } ?: file(path)
}

android {
    namespace = "com.spicarr.pulsecaller"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.3.13750724" // Tumhare installed NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.spicarr.pulsecaller"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                storeFile = resolveStoreFile(signingProperty("storeFile"))
                storePassword = signingProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release") // Release ke liye custom signing
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
