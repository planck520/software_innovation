plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.husterview.software_innovation"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // 修正点 1：Kotlin DSL 下 repositories 的正确写法
    repositories {
        flatDir {
            dirs("libs")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("libs")
        }
    }

    defaultConfig {
        applicationId = "com.example.husterview.software_innovation"
        minSdk = flutter.minSdkVersion
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
    // 关键修正：使用 Kotlin DSL 的标准语法
    // 这一行会同时把你刚放进去的 AIUI.jar 和那个 xrtcsdk...aar 全部加载
    implementation(fileTree("libs") {
        include("*.jar", "*.aar")
    })

    // 如果你之前写了 implementation(name: "...", ext: "aar") 导致报错，
    // 请直接删掉它们，因为上面的 fileTree 已经全包了。
}