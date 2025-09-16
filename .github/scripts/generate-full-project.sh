# gradlew (Unix script) - Fixed version
cat > "$PROJECT_NAME/gradlew" << 'EOT'
#!/bin/sh

# Find the script directory
SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

# Execute Gradle wrapper
if [ -f "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.jar" ]; then
    exec java -jar "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.jar" "$@"
else
    echo "Gradle wrapper not found, creating directory structure..."
    mkdir -p "$SCRIPT_DIR/gradle/wrapper"
    echo "distributionBase=GRADLE_USER_HOME" > "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"
    echo "distributionPath=wrapper/dists" >> "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"
    echo "distributionUrl=https\\://services.gradle.org/distributions/gradle-8.5-bin.zip" >> "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"
    echo "networkTimeout=10000" >> "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"
    echo "zipStoreBase=GRADLE_USER_HOME" >> "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"
    echo "zipStorePath=wrapper/dists" >> "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"
    echo "Run './gradlew assembleRelease' to build APK"
    echo "Note: Gradle wrapper will be downloaded on first execution"
fi
EOT
chmod +x "$PROJECT_NAME/gradlew"
