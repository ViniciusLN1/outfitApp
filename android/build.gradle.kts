allprojects {
    repositories {
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

// Eleva o compileSdk de plugins de terceiros (ex: gal usa 33, camera usa valores
// menores) para 36, sem tocar em :app que já define o seu próprio valor.
subprojects {
    afterEvaluate {
        if (project.name != "app") {
            extensions.findByType<com.android.build.gradle.BaseExtension>()
                ?.compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
