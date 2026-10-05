plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
}

/** Lê um valor de propriedade Gradle (-Pnome) ou variável de ambiente; nunca falha se ausente. */
fun configuracao(nome: String): String? =
    (project.findProperty(nome) as String?)?.takeIf { it.isNotBlank() }
        ?: System.getenv(nome)?.takeIf { it.isNotBlank() }

fun String.comoLiteralJava(): String = "\"" + replace("\\", "\\\\").replace("\"", "\\\"") + "\""

val versaoNome: String = configuracao("VERSION_NAME") ?: "0.1.0"
val versaoCodigo: Int = configuracao("VERSION_CODE")?.toIntOrNull() ?: 1

// Keystore de assinatura: só existe no job de release (decodificado dos GitHub Secrets).
val keystoreArquivo: String? = configuracao("KEYSTORE_FILE")

android {
    namespace = "br.com.oficinadopaulo"
    compileSdk = 37

    defaultConfig {
        applicationId = "br.com.oficinadopaulo"
        minSdk = 26
        targetSdk = 37
        versionCode = versaoCodigo
        versionName = versaoNome

        // Supabase: vem de variáveis de ambiente / GitHub Secrets. Sem eles, placeholders vazios
        // (o app mostra "Servidor não configurado"); o build nunca falha por isso.
        buildConfigField("String", "SUPABASE_URL", (configuracao("SUPABASE_URL") ?: "").comoLiteralJava())
        buildConfigField("String", "SUPABASE_ANON_KEY", (configuracao("SUPABASE_ANON_KEY") ?: "").comoLiteralJava())

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        if (keystoreArquivo != null) {
            create("release") {
                storeFile = file(keystoreArquivo)
                storeType = "pkcs12"
                storePassword = configuracao("KEYSTORE_PASSWORD")
                keyAlias = configuracao("KEY_ALIAS")
                keyPassword = configuracao("KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            if (keystoreArquivo != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all { teste ->
                teste.maxHeapSize = "2g"
                teste.testLogging {
                    events("failed")
                    exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
                }
            }
        }
    }

    lint {
        abortOnError = true
        checkReleaseBuilds = false
        // Atualização de dependências é decidida por fase (consultando a documentação), não pelo lint.
        disable += setOf("GradleDependency", "NewerVersionAvailable", "AndroidGradlePluginVersion")
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.core.splashscreen)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.navigation.compose)

    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons.extended)
    debugImplementation(libs.androidx.compose.ui.tooling)
    debugImplementation(libs.androidx.compose.ui.test.manifest)

    testImplementation(libs.junit)
    testImplementation(libs.androidx.test.ext.junit)
    testImplementation(libs.robolectric)
    testImplementation(platform(libs.androidx.compose.bom))
    testImplementation(libs.androidx.compose.ui.test.junit4)
}
