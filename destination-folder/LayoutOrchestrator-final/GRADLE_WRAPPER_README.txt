This repository includes a checked-in minimal Gradle launcher script (gradlew and gradlew.bat)
which will download Gradle 8.5 from services.gradle.org the first time it is run,
extract it into .gradle-wrapper/, and execute it.

Usage (Unix):
  ./gradlew assembleRelease

Usage (Windows):
  gradlew.bat assembleRelease

Note: The real Gradle wrapper JAR (gradle-wrapper.jar) is not included, but this launcher
provides equivalent behaviour and is safe to check into version control.
