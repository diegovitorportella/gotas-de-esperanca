plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // ADICIONE ESTA LINHA ABAIXO:
    id("com.google.gms.google-services")
}

android {
    namespace = "com.diw.gotas_de_esperanca.gotas_de_esperanca" // Use o seu namespace correto
    compileSdk = flutter.compileSdkVersion
    // --- ADICIONE ESTA LINHA ---
    ndkVersion = "27.0.12077973" // Define a versão do NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.diw.gotas_de_esperanca.gotas_de_esperanca"
        minSdk = 23  // <--- MUDANÇA AQUI (Era: flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Adicione dependências específicas do Android aqui, se necessário
}