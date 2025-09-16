#!/bin/bash
# Fix the project structure and make it buildable

echo "🔧 Fixing project structure..."

cd LayoutOrchestrator

# Make sure gradlew is executable
chmod +x gradlew

# Create gradle wrapper directory
mkdir -p gradle/wrapper

# Create proper gradle-wrapper.properties
cat > gradle/wrapper/gradle-wrapper.properties << 'EOT'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOT

echo "✅ Project structure fixed!"
