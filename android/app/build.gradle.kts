plugins {
    id("com.android.application")
    id("kotlin-android")
    // O Flutter Gradle Plugin TEM de ser aplicado depois dos plugins Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hinario_ieca"

    // ═══════════════════════════════════════════════════════════
    // VERSÕES DE SDK — EXPLÍCITAS
    // ═══════════════════════════════════════════════════════════
    // compileSdk = 36 → obrigatório para os plugins modernos:
    //                    • flutter_local_notifications
    //                    • shared_preferences_android
    //                    • url_launcher_android
    //                   Todos exigem compilação contra SDK 36.
    //
    // minSdk     = 21 → Android 5.0+ (cobre 99,9% dos dispositivos)
    //
    // targetSdk  = 35 → Android 15.
    //                   Mantido em 35 (e NÃO 36) de propósito:
    //                   • Garante instalação em Android 14 (ex.: Galaxy A06)
    //                   • Evita acionar as novas restrições de comportamento
    //                     do Android 16, que podem bloquear dispositivos
    //                     mais antigos.
    //                   compileSdk e targetSdk são independentes: podes
    //                   compilar contra 36 e continuar a ter como alvo 35.
    // ═══════════════════════════════════════════════════════════
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.hinario_ieca"

        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ═══════════════════════════════════════════════════════════
        // ABIs SUPORTADAS
        // ═══════════════════════════════════════════════════════════
        // armeabi-v7a → telemóveis 32 bits (Tecno, Itel, Infinix antigos)
        // arm64-v8a   → telemóveis 64 bits (Galaxy A06, Samsung modernos)
        // x86_64      → emuladores
        // ═══════════════════════════════════════════════════════════
        ndk {
            abiFilters += listOf(
                "armeabi-v7a",
                "arm64-v8a",
                "x86_64"
            )
        }
    }

    // ═══════════════════════════════════════════════════════════
    // ASSINATURA
    // ═══════════════════════════════════════════════════════════
    // Debug e release assinados com a MESMA chave de debug.
    // Isto garante que podes instalar debug por cima de release
    // e vice-versa sem "INSTALL_FAILED_UPDATE_INCOMPATIBLE".
    //
    // ⚠️ ANTES DE PUBLICAR NA PLAY STORE, cria uma keystore real
    //    e substitui a release pela tua chave.
    // ═══════════════════════════════════════════════════════════
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            // Sem minify/shrink → evita falhas de build
            // e APKs malformados que o Android rejeita.
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ═══════════════════════════════════════════════════════════
    // EMPACOTAMENTO
    // ═══════════════════════════════════════════════════════════
    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

dependencies {
    // Desugaring obrigatório para flutter_local_notifications 17+
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}