#!/bin/bash
# This script merges the existing TabRideOrach project with new files and zips it.

# --- 1. SETUP ---
echo "Creating the final project directory: TabRideOrach..."
mkdir -p TabRideOrach
cd TabRideOrach

# --- 2. CREATE PROJECT STRUCTURE AND POPULATE WITH EXISTING FILES ---
echo "Creating project structure and populating with your existing files..."

# Root directory files
cat << 'EOF' > settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "TabRideOrach"
include(":app")
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

cat << 'EOF' > build.gradle.kts
plugins {
    id("com.android.application") version "8.1.4" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
}
EOF

# Gradle Wrapper
mkdir -p gradle/wrapper
cat << 'EOF' > gradle/wrapper/gradle-wrapper.properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# App directory structure
mkdir -p app/src/main/java/com/internal/layout/orchestrator/core
mkdir -p app/src/main/java/com/internal/layout/orchestrator/data
mkdir -p app/src/main/java/com/internal/layout/orchestrator/layout
mkdir -p app/src/main/java/com/internal/layout/orchestrator/receivers
mkdir -p app/src/main/java/com/internal/layout/orchestrator/services
mkdir -p app/src/main/java/com/internal/layout/orchestrator/shell
mkdir -p app/src/main/java/com/internal/layout/orchestrator/tiles
mkdir -p app/src/main/java/com/internal/layout/orchestrator/ui
mkdir -p app/src/main/java/com/internal/layout/orchestrator/utils
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/xml

# --- App-level files (from your existing project) ---

# Proguard
cat << 'EOF' > app/proguard-rules.pro
-keep class com.internal.layout.orchestrator.** { *; }
-dontwarn com.google.gson.**
EOF

# Kotlin Source Files
# (Assuming the main package is com.internal.layout.orchestrator)
cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/OrchestratorApplication.kt
package com.internal.layout.orchestrator
import android.app.Application
class OrchestratorApplication : Application()
EOF

cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/data/LayoutConfig.kt
package com.internal.layout.orchestrator.data
import android.content.Context
import com.google.gson.Gson
import java.io.File

data class LayoutConfig(
    val topAppPackage: String = "com.android.chrome",
    val bottomLeftAppPackage: String = "com.google.android.apps.messaging",
    val bottomRightAppPackage: String = "com.google.android.youtube",
    val topPaneHeightPercent: Int = 33,
    val autoLaunchOnBoot: Boolean = true
) {
    companion object {
        private const val CONFIG_FILE = "layout_config.json"
        fun save(context: Context, config: LayoutConfig) {
            File(context.filesDir, CONFIG_FILE).writeText(Gson().toJson(config))
        }
        fun load(context: Context): LayoutConfig {
            val file = File(context.filesDir, CONFIG_FILE)
            return if (file.exists()) {
                Gson().fromJson(file.readText(), LayoutConfig::class.java)
            } else {
                LayoutConfig()
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/layout/LayoutCalculator.kt
package com.internal.layout.orchestrator.layout
import android.content.Context
import android.graphics.Rect
import android.view.WindowManager
import android.os.Build
import android.view.WindowMetrics

object LayoutCalculator {
    fun getThreePaneBounds(context: Context, topPaneHeightPercent: Int): Triple<Rect, Rect, Rect> {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val bounds = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            windowManager.currentWindowMetrics.bounds
        } else {
            val displayMetrics = android.util.DisplayMetrics()
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getMetrics(displayMetrics)
            Rect(0, 0, displayMetrics.widthPixels, displayMetrics.heightPixels)
        }
        val topHeight = (bounds.height() * (topPaneHeightPercent / 100.0)).toInt()
        val topPane = Rect(0, 0, bounds.width(), topHeight)
        val bottomLeftPane = Rect(0, topHeight, bounds.width() / 2, bounds.height())
        val bottomRightPane = Rect(bounds.width() / 2, topHeight, bounds.width(), bounds.height())
        return Triple(topPane, bottomLeftPane, bottomRightPane)
    }
}
EOF

# --- 3. ADD NEW FILES AND FEATURES ---
echo "Adding new files (Shizuku, ResetBubble, etc.)..."

cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/shell/ShizukuShell.kt
package com.internal.layout.orchestrator.shell

import android.util.Log
import rikka.shizuku.Shizuku
import rikka.shizuku.ShizukuRemoteProcess

object ShizukuShell {
    private const val TAG = "ShizukuShell"

    val isAvailable: Boolean
        get() = try {
            Shizuku.isRemoteProcess() || (Shizuku.checkSelfPermission() == 0)
        } catch (e: Exception) {
            false
        }

    fun exec(command: String): String {
        if (!isAvailable) {
            Log.e(TAG, "Shizuku not available.")
            return "Shizuku not available."
        }
        return try {
            val process: ShizukuRemoteProcess = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
            val output = process.inputStream.bufferedReader().readText()
            process.waitFor()
            output
        } catch (e: Exception) {
            Log.e(TAG, "Shizuku execution failed for command: $command", e)
            e.message ?: "Execution failed"
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/shell/ShellController.kt
package com.internal.layout.orchestrator.shell

import android.graphics.Rect

object ShellController {
    fun resizeTask(taskId: Int, bounds: Rect) {
        val command = "wm resize-task $taskId ${bounds.left} ${bounds.top} ${bounds.right} ${bounds.bottom}"
        ShizukuShell.exec(command)
    }

    fun forceStopPackage(packageName: String) {
        ShizukuShell.exec("am force-stop $packageName")
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/services/ResetBubbleService.kt
package com.internal.layout.orchestrator.services
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.Button
import com.internal.layout.orchestrator.R
import com.internal.layout.orchestrator.core.LayoutOrchestrator

class ResetBubbleService : Service() {
    private lateinit var windowManager: WindowManager
    private lateinit var bubbleView: android.view.View

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        bubbleView = LayoutInflater.from(this).inflate(R.layout.reset_bubble, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 0
        params.y = 100

        windowManager.addView(bubbleView, params)

        bubbleView.findViewById<Button>(R.id.btnResetLayoutBubble).setOnClickListener {
            LayoutOrchestrator(this).resetLayout()
            stopSelf() // Optional: close the bubble after reset
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        windowManager.removeView(bubbleView)
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/internal/layout/orchestrator/utils/LenovoUtils.kt
package com.internal.layout.orchestrator.utils

import android.os.Build

object LenovoUtils {
    fun isLenovoTablet(): Boolean {
        return Build.MANUFACTURER.equals("lenovo", ignoreCase = true) &&
               (Build.MODEL.contains("tab", ignoreCase = true) || Build.DEVICE.contains("tab", ignoreCase = true))
    }

    fun applyLenovoOptimizations() {
        if (isLenovoTablet()) {
            // Placeholder for Lenovo-specific optimizations, e.g., setting a specific display mode
        }
    }
}
EOF

# --- 4. UPDATE EXISTING FILES TO INTEGRATE NEW FEATURES ---
echo "Updating build scripts and manifests..."

# Modified build.gradle.kts with Shizuku and Gson
cat << 'EOF' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.internal.layout.orchestrator"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.internal.layout.orchestrator"
        minSdk = 28
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")

    // New Dependencies
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("dev.rikka.shizuku:api:13.1.5")
    implementation("dev.rikka.shizuku:provider:13.1.5")
}
EOF

# Modified AndroidManifest.xml
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.REORDER_TASKS" />

    <application
        android:name=".OrchestratorApplication"
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/Theme.3PaneLayoutOrchestrator"
        tools:targetApi="31">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service android:name=".services.ResetBubbleService" />
        <service
            android:name=".tiles.LayoutResetTile"
            android:exported="true"
            android:icon="@drawable/ic_layout_reset"
            android:label="@string/tile_label"
            android:permission="android.permission.BIND_QUICK_SETTINGS_TILE">
            <intent-filter>
                <action android:name="android.service.quicksettings.action.QS_TILE" />
            </intent-filter>
        </service>
        
        <provider
            android:name="rikka.shizuku.ShizukuProvider"
            android:authorities="${applicationId}.shizuku"
            android:enabled="true"
            android:exported="true"
            android:multiprocess="false"
            android:permission="android.permission.MANAGE_DOCUMENTS" />
            
    </application>
</manifest>
EOF

# Add a simple README.md
cat << 'EOF' > README.md
# TabRideOrach (3-Pane Layout Orchestrator)

This Android application orchestrates a 3-pane layout for multitasking on tablets. It uses Shizuku for privileged operations to resize and manage application windows without requiring full root access.

## Features
- **3-Pane Split Screen**: Divides the screen into a top pane and two bottom panes.
- **Customizable Apps**: Select which app to display in each pane.
- **Quick Reset**: Use a Quick Settings tile to instantly close the layout.
- **Shizuku Integration**: Leverages Shizuku for reliable window management.

## Build Instructions
1. Open the project in Android Studio.
2. Let Gradle sync the dependencies.
3. Build the project (`./gradlew assembleDebug`).
4. Install the APK on a device with Shizuku running.
EOF


# --- 5. FINALIZE AND ZIP ---
echo "Finalizing project and creating zip file..."
cd ..
zip -r TabRideOrach-Final.zip TabRideOrach

echo "✅ Done! Project created and zipped as TabRideOrach-Final.zip"
