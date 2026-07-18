import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val requiredSigningProperties = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
)

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val missingSigningProperties = requiredSigningProperties.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val releaseKeystoreFile = keystoreProperties.getProperty("storeFile")?.let {
    rootProject.file(it)
}
val releaseSigningConfigured =
    keystorePropertiesFile.exists() &&
        missingSigningProperties.isEmpty() &&
        releaseKeystoreFile?.isFile == true

gradle.taskGraph.whenReady {
    val releaseTaskScheduled = allTasks.any {
        it.name.contains("release", ignoreCase = true)
    }
    if (releaseTaskScheduled && !releaseSigningConfigured) {
        val reason = when {
            !keystorePropertiesFile.exists() ->
                "android/key.properties does not exist"
            missingSigningProperties.isNotEmpty() ->
                "missing properties: ${missingSigningProperties.joinToString()}"
            else ->
                "keystore file does not exist: ${releaseKeystoreFile?.path}"
        }
        throw GradleException(
            "Release signing is not configured ($reason). " +
                "Copy android/key.properties.example and provide the release keystore.",
        )
    }
}

android {
    namespace = "app.toropass.toropass_wallet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.toropass.toropass_wallet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseKeystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
