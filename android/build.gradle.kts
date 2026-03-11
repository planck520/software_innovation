// 添加镜像源配置
buildscript {
    repositories {
        // 1. 阿里云镜像（优先）
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }

        // 2. 腾讯云镜像
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }

        // 3. 华为云镜像
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }

        // 4. Flutter 中国镜像
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }

        // 5. 官方源（作为备份）
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        // 1. 阿里云镜像（优先）
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }

        // 2. 腾讯云镜像
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }

        // 3. 华为云镜像
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }

        // 4. Flutter 中国镜像
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }

        // 5. JitPack
        maven { url = uri("https://jitpack.io") }

        // 6. 官方源（作为备份）
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
