#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="LayoutOrchestrator"
echo "🚀 Creating optimized Lenovo Tab Plus 3-Pane Layout Orchestrator project..."

# Cleanup and initialize
rm -rf "$PROJECT_NAME" && mkdir -p "$PROJECT_NAME"

# Create all required directories
mkdir -p "$PROJECT_NAME"/{.github/workflows,app/src/main/{java/com/internal/layout/orchestrator/{core,data,layout,shell,services,tiles,ui,utils},res/{drawable,layout,mipmap,values},assets}}

name: Generate Project & Build APK
on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Generate Full Android Project
        run: |
          cat > generate_project.sh << 'EOF'
          #!/usr/bin/env bash
          set -euo pipefail

          PROJECT_NAME="LayoutOrchestrator"
          echo "🚀 Creating optimized Lenovo Tab Plus 3-Pane Layout Orchestrator project..."

          # Cleanup and initialize
          rm -rf "$PROJECT_NAME" && mkdir -p "$PROJECT_NAME"

          # Create all required directories
          mkdir -p "$PROJECT_NAME"/{.github/workflows,app/src/main/{java/com/internal/layout/orchestrator/{core,data,layout,shell,services,tiles,ui,utils},res/{drawable,layout,mipmap,values},assets}}

          # -----------------------------
          # GRADLE CONFIGURATION FILES
          # -----------------------------

          # Root build.gradle.kts
          cat > "$PROJECT_NAME/build.gradle.kts" << 'EOT'
          plugins {
              id("com.android.application") version "8.5.2" apply false
              id("org.jetbrains.kotlin.android") version "1.9.24" apply false
          }
          EOT

          # settings.gradle.kts
          cat > "$PROJECT_NAME/settings.gradle.kts" << 'EOT'
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
          rootProject.name = "LayoutOrchestrator"
          include(":app")
          EOT

          # gradle.properties
          cat > "$PROJECT_NAME/gradle.properties" << 'EOT'
          org.gradle.jvmargs=-Xmx3g -Dfile.encoding=UTF-8
          android.useAndroidX=true
          kotlin.code.style=official
          EOT

          # gradlew (Unix script)
          cat > "$PROJECT_NAME/gradlew" << 'EOT'
          #!/bin/sh
          export GRADLE_HOME=`pwd`/gradle
          export PATH=$GRADLE_HOME/bin:$PATH

          if [ ! -d "$GRADLE_HOME" ]; then
            echo "Downloading Gradle wrapper..."
            mkdir -p gradle
          fi

          echo "Run './gradlew assembleRelease' to build APK"
          echo "Note: This script is placeholder for CI builds"
          EOT
          chmod +x "$PROJECT_NAME/gradlew"

          # app/build.gradle.kts
          cat > "$PROJECT_NAME/app/build.gradle.kts" << 'EOT'
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
                  versionCode = 4
                  versionName = "1.3-LenovoOptimized"
              }

              buildFeatures {
                  viewBinding = true
              }

              compileOptions {
                  sourceCompatibility = JavaVersion.VERSION_17
                  targetCompatibility = JavaVersion.VERSION_17
              }
              kotlinOptions {
                  jvmTarget = "17"
              }

              val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
              signingConfigs {
                  if (!keystorePath.isNullOrBlank()) {
                      create("release") {
                          storeFile = file(keystorePath)
                          storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                          keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                          keyPassword = System.getenv("ANDROID_KEY_ALIAS_PASSWORD")
                      }
                  }
              }

              buildTypes {
                  release {
                      isMinifyEnabled = false
                      if (!keystorePath.isNullOrBlank()) {
                          signingConfig = signingConfigs.getByName("release")
                      }
                  }
                  debug {
                      isMinifyEnabled = false
                  }
              }

              packaging {
                  resources.excludes += setOf("META-INF/*")
              }
          }

          dependencies {
              implementation("androidx.core:core-ktx:1.13.1")
              implementation("androidx.appcompat:appcompat:1.7.0")
              implementation("com.google.android.material:material:1.12.0")
              implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.4")
              implementation("androidx.lifecycle:lifecycle-service:2.8.4")
              implementation("androidx.activity:activity-ktx:1.9.2")
              implementation("androidx.fragment:fragment-ktx:1.8.3")
              implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
              implementation("com.google.code.gson:gson:2.11.0")
              implementation("androidx.window:window:1.3.0")

              // Shizuku API for system-level access
              implementation("dev.rikka.shizuku:api:13.1.5")
              implementation("dev.rikka.shizuku:provider:13.1.5")
          }
          EOT

          # -----------------------------
          # ANDROID MANIFEST
          # -----------------------------
          cat > "$PROJECT_NAME/app/src/main/AndroidManifest.xml" << 'EOT'
          <manifest xmlns:android="http://schemas.android.com/apk/res/android"
              xmlns:tools="http://schemas.android.com/tools">

              <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
              <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" 
                  tools:ignore="ProtectedPermissions" />
              <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
              <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
              <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
              <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
              <uses-permission android:name="android.permission.BIND_QUICK_SETTINGS_TILE" />
              <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" 
                  tools:ignore="QueryAllPackagesPermission" />

              <application
                  android:name=".OrchestratorApplication"
                  android:allowBackup="true"
                  android:label="@string/app_name"
                  android:icon="@mipmap/ic_launcher"
                  android:theme="@style/Theme.AppCompat.DayNight">

                  <activity
                      android:name=".ui.MainActivity"
                      android:exported="true"
                      android:launchMode="singleTop">
                      <intent-filter>
                          <action android:name="android.intent.action.MAIN"/>
                          <category android:name="android.intent.category.LAUNCHER"/>
                      </intent-filter>
                  </activity>

                  <activity
                      android:name=".ui.ConfigActivity"
                      android:exported="false"
                      android:label="@string/config_title"/>

                  <service
                      android:name=".services.LayoutWatchdogService"
                      android:exported="false"
                      android:foregroundServiceType="dataSync" />

                  <service
                      android:name=".services.ResetBubbleService"
                      android:exported="false" />

                  <service
                      android:name=".tiles.LayoutResetTile"
                      android:permission="android.permission.BIND_QUICK_SETTINGS_TILE"
                      android:exported="true"
                      android:icon="@drawable/ic_layout_reset"
                      android:label="@string/tile_reset_label">
                      <intent-filter>
                          <action android:name="android.service.quicksettings.action.QS_TILE"/>
                      </intent-filter>
                  </service>
              </application>
          </manifest>
          EOT

          # -----------------------------
          # KOTLIN SOURCE FILES
          # -----------------------------

          # Application class
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/OrchestratorApplication.kt" << 'EOT'
          package com.internal.layout.orchestrator

          import android.app.Application
          import androidx.appcompat.app.AppCompatDelegate

          class OrchestratorApplication : Application() {
              override fun onCreate() {
                  super.onCreate()
                  AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
              }
          }
          EOT

          # Data models
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/data/LayoutConfig.kt" << 'EOT'
          package com.internal.layout.orchestrator.data

          import android.content.Context
          import com.google.gson.Gson
          import com.google.gson.reflect.TypeToken

          data class LayoutConfig(
              val name: String = "Default",
              val topApp: AppConfig,
              val bottomLeftApp: AppConfig,
              val bottomRightApp: AppConfig,
              val topHeightPercent: Float = 0.33f
          ) {
              data class AppConfig(
                  val packageName: String,
                  val activityName: String? = null,
                  val displayName: String = packageName
              )

              companion object {
                  fun getDefault(): LayoutConfig {
                      return LayoutConfig(
                          name = "Default",
                          topApp = AppConfig("com.android.chrome", "com.google.android.apps.chrome.Main", "Chrome"),
                          bottomLeftApp = AppConfig("com.whatsapp", null, "WhatsApp"),
                          bottomRightApp = AppConfig("com.spotify.client", null, "Spotify")
                      )
                  }
              }
          }

          class TemplatesRepository(private val context: Context) {
              private val prefs by lazy { context.getSharedPreferences("orchestrator_config", Context.MODE_PRIVATE) }
              private val gson = Gson()
              private val key = "templates_list"

              fun list(): List<LayoutConfig> {
                  val raw = prefs.getString(key, null) ?: return listOf(LayoutConfig.getDefault())
                  return try {
                      val type = object : TypeToken<List<LayoutConfig>>() {}.type
                      gson.fromJson<List<LayoutConfig>>(raw, type)
                  } catch (_: Throwable) {
                      listOf(LayoutConfig.getDefault())
                  }
              }

              fun getActive(): LayoutConfig = prefs.getString("active_template", null)
                  ?.let { activeName -> list().find { it.name == activeName } } 
                  ?: list().firstOrNull() 
                  ?: LayoutConfig.getDefault()

              fun setActive(name: String) {
                  prefs.edit().putString("active_template", name).apply()
              }

              fun upsert(config: LayoutConfig) {
                  val all = list().toMutableList()
                  val idx = all.indexOfFirst { it.name == config.name }
                  if (idx >= 0) all[idx] = config else all.add(config)
                  saveAll(all)
              }

              fun delete(name: String) {
                  val all = list().filterNot { it.name == name }
                  saveAll(all)
                  if (prefs.getString("active_template", null) == name) {
                      prefs.edit().remove("active_template").apply()
                  }
              }

              private fun saveAll(list: List<LayoutConfig>) {
                  prefs.edit().putString(key, gson.toJson(list)).apply()
              }
          }
          EOT

          # Layout calculator (Lenovo-specific optimizations)
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/layout/LayoutCalculator.kt" << 'EOT'
          package com.internal.layout.orchestrator.layout

          import android.content.Context
          import android.graphics.Rect
          import android.os.Build

          class LayoutCalculator(private val context: Context) {
              data class LayoutBounds(
                  val topApp: Rect,
                  val bottomLeft: Rect,
                  val bottomRight: Rect
              )
              
              fun calculateBounds(topHeightPercent: Float): LayoutBounds {
                  val displayMetrics = context.resources.displayMetrics
                  val screenHeight = displayMetrics.heightPixels
                  val screenWidth = displayMetrics.widthPixels
                  
                  // Lenovo Tab Plus specific adjustments
                  val statusBarHeight = if (isLenovoDevice()) 
                      getLenovoStatusBarHeight() 
                  else 
                      getSystemDimen("status_bar_height")
                      
                  val navigationBarHeight = if (isLenovoDevice()) 
                      getLenovoNavigationBarHeight() 
                  else 
                      getSystemDimen("navigation_bar_height")
                  
                  val usableHeight = screenHeight - statusBarHeight - navigationBarHeight
                  val topHeight = (usableHeight * topHeightPercent).toInt()
                  val bottomStartY = statusBarHeight + topHeight
                  
                  return LayoutBounds(
                      topApp = Rect(0, statusBarHeight, screenWidth, statusBarHeight + topHeight),
                      bottomLeft = Rect(0, bottomStartY, screenWidth / 2, screenHeight - navigationBarHeight),
                      bottomRight = Rect(screenWidth / 2, bottomStartY, screenWidth, screenHeight - navigationBarHeight)
                  )
              }
              
              private fun isLenovoDevice(): Boolean = Build.MANUFACTURER.equals("lenovo", ignoreCase = true)
              
              private fun getLenovoStatusBarHeight(): Int {
                  return when(Build.MODEL) {
                      "TB-X606F", "TB-X606X" -> dpToPx(30)
                      "TB-X306X" -> dpToPx(28)
                      else -> dpToPx(32)
                  }
              }
              
              private fun getLenovoNavigationBarHeight(): Int {
                  return when(Build.MODEL) {
                      "TB-X606F", "TB-X606X" -> dpToPx(48)
                      "TB-X306X" -> dpToPx(42)
                      else -> dpToPx(56)
                  }
              }
              
              private fun getSystemDimen(name: String): Int {
                  val id = context.resources.getIdentifier(name, "dimen", "android")
                  return if (id > 0) context.resources.getDimensionPixelSize(id) else 0
              }
              
              private fun dpToPx(dp: Int): Int {
                  return (dp * context.resources.displayMetrics.density).toInt()
              }
          }
          EOT

          # Shizuku shell controllers
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/shell/ShizukuShell.kt" << 'EOT'
          package com.internal.layout.orchestrator.shell

          import android.content.pm.PackageManager
          import dev.rikka.shizuku.Shizuku
          import kotlinx.coroutines.Dispatchers
          import kotlinx.coroutines.withContext
          import java.io.BufferedReader
          import java.io.InputStreamReader

          object ShizukuShell {

              fun isBinderAlive(): Boolean = try { 
                  Shizuku.pingBinder() 
              } catch (_: Throwable) { 
                  false 
              }

              fun hasPermission(): Boolean = try {
                  Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
              } catch (_: Exception) {
                  false
              }

              fun requestPermission(callback: (granted: Boolean) -> Unit) {
                  val listener = object : Shizuku.OnRequestPermissionResultListener {
                      override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
                          Shizuku.removeRequestPermissionResultListener(this)
                          callback(grantResult == PackageManager.PERMISSION_GRANTED)
                      }
                  }
                  Shizuku.addRequestPermissionResultListener(listener)
                  try {
                      Shizuku.requestPermission(1000)
                  } catch (e: Exception) {
                      callback(false)
                  }
              }

              suspend fun exec(cmd: String): String = withContext(Dispatchers.IO) {
                  if (!isBinderAlive()) throw IllegalStateException("Shizuku not connected")
                  
                  try {
                      val p = Shizuku.newProcess(arrayOf("sh", "-c", cmd), null, null)
                      val out = BufferedReader(InputStreamReader(p.inputStream)).readText().trim()
                      val err = BufferedReader(InputStreamReader(p.errorStream)).readText().trim()
                      p.waitFor()
                      
                      if (err.isNotBlank() && !err.contains("WARNING")) "$out\n$err" else out
                  } catch (e: Exception) {
                      throw RuntimeException("Command failed: $cmd", e)
                  }
              }
          }
          EOT

          # Enhanced shell controller with Lenovo optimizations
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/shell/ShellController.kt" << 'EOT'
          package com.internal.layout.orchestrator.shell

          import android.graphics.Rect
          import android.os.Build
          import kotlinx.coroutines.delay

          class ShellController {

              suspend fun enableFreeformFlags() {
                  val cmds = when {
                      isLenovoDevice() -> getLenovoOptimizedFlags()
                      else -> getDefaultFlags()
                  }
                  for (c in cmds) ShizukuShell.exec(c)
              }

              private fun getDefaultFlags(): List<String> = listOf(
                  "settings put global enable_freeform_support 1",
                  "settings put secure freeform_window_management 1", 
                  "settings put global force_resizable_activities 1",
                  "settings put global force_desktop_mode_on_external_displays 1"
              )

              private fun getLenovoOptimizedFlags(): List<String> = listOf(
                  "settings put global enable_freeform_support 1",
                  "settings put secure freeform_window_management 1",
                  "settings put global force_resizable_activities 1", 
                  "settings put global DEVELOPMENT_FORCE_RESIZABLE_ACTIVITIES 1",
                  "settings put global force_desktop_mode_on_external_displays 1",
                  "settings put global window_animation_scale 0.5",
                  "settings put global transition_animation_scale 0.5",
                  "settings put global animator_duration_scale 0.5"
              )

              suspend fun startAppFreeform(packageName: String, activityName: String?): Boolean {
                  val comp = if (activityName.isNullOrBlank()) packageName else "$packageName/$activityName"
                  
                  val methods = when {
                      isLenovoDevice() -> getLenovoLaunchMethods(comp)
                      else -> getDefaultLaunchMethods(comp)
                  }

                  for (cmd in methods) {
                      try {
                          val result = ShizukuShell.exec(cmd)
                          if (!result.contains("Error", true) && !result.contains("Exception", true)) {
                              delay(600)
                              return true
                          }
                      } catch (e: Exception) {
                          // Continue to next method
                      }
                  }
                  return false
              }

              private fun getDefaultLaunchMethods(component: String): List<String> = listOf(
                  "cmd activity start-activity --user 0 --windowingMode 5 -n $component",
                  "monkey -p ${component.split("/").first()} -c android.intent.category.LAUNCHER 1",
                  "am start --windowingMode 5 --activity.getOrientation $component"
              )

              private fun getLenovoLaunchMethods(component: String): List<String> = listOf(
                  "cmd activity start-activity --user 0 --windowingMode 5 --activity.clearTop --activity.broughtToForeground -n $component",
                  "am start --windowingMode 5 -n $component --activity.clearTop --activity.broughtToForeground",
                  "monkey -p ${component.split("/").first()} -c android.intent.category.LAUNCHER 1"
              )

              suspend fun getTaskBounds(packageName: String): Rect? {
                  val out = ShizukuShell.exec("dumpsys activity activities")
                  val patterns = listOf(
                      Regex("""bounds=\[(\d+),(\d+)\]\[(\d+),(\d+)\].*?$packageName""", RegexOption.DOT_MATCHES_ALL),
                      Regex("""$packageName.*?bounds=\[(\d+),(\d+)\]\[(\d+),(\d+)\]""", RegexOption.DOT_MATCHES_ALL),
                      Regex("""taskId=.*?$packageName.*?bounds=\[(\d+),(\d+)\]\[(\d+),(\d+)\]""", RegexOption.DOT_MATCHES_ALL)
                  )
                  
                  for (pattern in patterns) {
                      val match = pattern.find(out)
                      if (match != null) {
                          val (x1, y1, x2, y2) = match.groupValues.drop(1).map { it.toInt() }
                          return Rect(x1, y1, x2, y2)
                      }
                  }
                  return null
              }

              suspend fun drag(x1: Int, y1: Int, x2: Int, y2: Int, durationMs: Int = 240) {
                  ShizukuShell.exec("input swipe $x1 $y1 $x2 $y2 $durationMs")
                  delay(120)
              }

              suspend fun moveAndResizeTo(packageName: String, target: Rect) {
                  val cur = getTaskBounds(packageName)
                  val headerFrom = if (cur != null) Pair(cur.centerX(), cur.top + 60) else Pair(target.centerX(), target.top + 60)
                  val headerTo = Pair(target.centerX(), target.top + 80)
                  drag(headerFrom.first, headerFrom.second, headerTo.first, headerTo.second, if (isLenovoDevice()) 300 else 260)

                  val resizeFrom = if (cur != null) Pair(cur.right - 15, cur.bottom - 15) else Pair(target.right - 200, target.bottom - 200)
                  val resizeTo = Pair(target.right - 10, target.bottom - 10)
                  drag(resizeFrom.first, resizeFrom.second, resizeTo.first, resizeTo.second, if (isLenovoDevice()) 280 else 240)
              }

              private fun isLenovoDevice(): Boolean = Build.MANUFACTURER.equals("lenovo", ignoreCase = true)
          }
          EOT

          # Core orchestrator with full error handling
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/core/LayoutOrchestrator.kt" << 'EOT'
          package com.internal.layout.orchestrator.core

          import android.content.Context
          import android.util.Log
          import com.internal.layout.orchestrator.data.LayoutConfig
          import com.internal.layout.orchestrator.layout.LayoutCalculator
          import com.internal.layout.orchestrator.shell.ShellController
          import com.internal.layout.orchestrator.shell.ShizukuShell
          import kotlinx.coroutines.delay

          class LayoutOrchestrator(private val context: Context) {

              companion object {
                  private const val TAG = "LayoutOrchestrator"
              }

              private val layoutCalculator = LayoutCalculator(context)
              private val shell = ShellController()

              suspend fun applyLayout(config: LayoutConfig): LayoutResult {
                  if (!ShizukuShell.isBinderAlive() || !ShizukuShell.hasPermission()) {
                      return LayoutResult(false, "Shizuku not available or permission denied")
                  }

                  try {
                      shell.enableFreeformFlags()
                      Log.d(TAG, "Enabled freeform flags")
                      delay(500)

                      val bounds = layoutCalculator.calculateBounds(config.topHeightPercent)
                      Log.d(TAG, "Calculated layout bounds: top=${bounds.topApp}, bottomLeft=${bounds.bottomLeft}, bottomRight=${bounds.bottomRight}")
                      
                      val results = mutableListOf<LaunchResult>()
                      
                      results.add(launchAppWithVerification(config.bottomLeftApp, bounds.bottomLeft, "Bottom Left"))
                      delay(400)
                      
                      results.add(launchAppWithVerification(config.bottomRightApp, bounds.bottomRight, "Bottom Right"))  
                      delay(400)
                      
                      results.add(launchAppWithVerification(config.topApp, bounds.topApp, "Top"))
                      delay(800)

                      Log.d(TAG, "Positioning and resizing apps...")
                      val positioningResults = mutableListOf<Boolean>()
                      positioningResults.add(positionAndResizeApp(config.bottomLeftApp, bounds.bottomLeft))
                      positioningResults.add(positionAndResizeApp(config.bottomRightApp, bounds.bottomRight))
                      positioningResults.add(positionAndResizeApp(config.topApp, bounds.topApp))

                      val successCount = results.count { it.success } + positioningResults.count { it }
                      val totalOperations = results.size + positioningResults.size
                      
                      val message = "Layout applied: $successCount/$totalOperations operations successful"
                      Log.d(TAG, message)
                      
                      return LayoutResult(
                          success = successCount >= (totalOperations * 0.7),
                          message = message,
                          results = results
                      )

                  } catch (e: Exception) {
                      Log.e(TAG, "Error applying layout", e)
                      return LayoutResult(false, "Error: ${e.message}")
                  }
              }

              private suspend fun launchAppWithVerification(
                  app: LayoutConfig.AppConfig, 
                  bounds: android.graphics.Rect, 
                  position: String
              ): LaunchResult {
                  try {
                      Log.d(TAG, "Launching ${app.displayName} ($position)")
                      val success = shell.startAppFreeform(app.packageName, app.activityName)
                      if (success) {
                          delay(300)
                          val isRunning = isAppRunning(app.packageName)
                          val message = if (isRunning) "Launched successfully" else "Launch command succeeded but app not running"
                          Log.d(TAG, "Launch result for ${app.displayName}: $message")
                          return LaunchResult(app, position, isRunning, message)
                      }
                      Log.w(TAG, "Launch command failed for ${app.displayName}")
                      return LaunchResult(app, position, false, "Launch command failed")
                  } catch (e: Exception) {
                      Log.e(TAG, "Launch exception for ${app.displayName}", e)
                      return LaunchResult(app, position, false, "Exception: ${e.message}")
                  }
              }

              private suspend fun positionAndResizeApp(
                  app: LayoutConfig.AppConfig, 
                  targetBounds: android.graphics.Rect
              ): Boolean {
                  return try {
                      Log.d(TAG, "Positioning ${app.displayName} to $targetBounds")
                      shell.moveAndResizeTo(app.packageName, targetBounds)
                      delay(300)
                      true
                  } catch (e: Exception) {
                      Log.w(TAG, "Failed to position ${app.displayName}: ${e.message}")
                      false
                  }
              }

              private suspend fun isAppRunning(packageName: String): Boolean {
                  try {
                      val output = ShizukuShell.exec("dumpsys activity activities | grep 'Running activities'")
                      return output.contains(packageName)
                  } catch (e: Exception) {
                      Log.w(TAG, "Failed to check if $packageName is running", e)
                      return false
                  }
              }

              suspend fun enableFreeformFlags() {
                  shell.enableFreeformFlags()
              }

              data class LayoutResult(
                  val success: Boolean,
                  val message: String,
                  val results: List<LaunchResult> = emptyList()
              )

              data class LaunchResult(
                  val app: LayoutConfig.AppConfig,
                  val position: String,
                  val success: Boolean,
                  val message: String
              )
          }
          EOT

          # Service implementations
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/services/LayoutWatchdogService.kt" << 'EOT'
          package com.internal.layout.orchestrator.services

          import android.app.Notification
          import android.app.NotificationChannel
          import android.app.NotificationManager
          import android.app.PendingIntent
          import android.app.Service
          import android.content.Context
          import android.content.Intent
          import android.os.IBinder
          import androidx.core.app.NotificationCompat
          import com.internal.layout.orchestrator.R
          import com.internal.layout.orchestrator.ui.MainActivity

          class LayoutWatchdogService : Service() {

              override fun onCreate() {
                  super.onCreate()
                  val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                  mgr.createNotificationChannel(
                      NotificationChannel(
                          "layout_watchdog", 
                          "Layout Orchestrator Watchdog", 
                          NotificationManager.IMPORTANCE_LOW
                      ).apply {
                          description = "Monitors and resets layouts when needed"
                      }
                  )
              }

              override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
                  startForeground(1001, createNotification())
                  return START_STICKY
              }

              override fun onBind(intent: Intent?): IBinder? = null

              private fun createNotification(): Notification {
                  val resetIntent = Intent(this, MainActivity::class.java).apply {
                      putExtra("action", "reset_layout")
                  }
                  
                  val pi = PendingIntent.getActivity(
                      this, 0, resetIntent,
                      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                  )
                  
                  return NotificationCompat.Builder(this, "layout_watchdog")
                      .setSmallIcon(android.R.drawable.ic_menu_view)
                      .setContentTitle("Layout Orchestrator Active")
                      .setContentText("Monitoring and quick reset available")
                      .setOngoing(true)
                      .addAction(
                          android.R.drawable.ic_menu_revert, 
                          "Reset", 
                          pi
                      )
                      .build()
              }

              companion object {
                  fun start(ctx: Context) {
                      ctx.startForegroundService(Intent(ctx, LayoutWatchdogService::class.java))
                  }
                  fun stop(ctx: Context) {
                      ctx.stopService(Intent(ctx, LayoutWatchdogService::class.java))
                  }
              }
          }
          EOT

          # Enhanced ResetBubbleService
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/services/ResetBubbleService.kt" << 'EOT'
          package com.internal.layout.orchestrator.services

          import android.content.Context
          import android.content.Intent
          import android.graphics.PixelFormat
          import android.os.Build
          import android.view.*
          import android.widget.ImageView
          import android.widget.Toast
          import com.internal.layout.orchestrator.R
          import com.internal.layout.orchestrator.core.LayoutOrchestrator
          import com.internal.layout.orchestrator.data.TemplatesRepository
          import com.internal.layout.orchestrator.shell.ShizukuShell
          import kotlinx.coroutines.CoroutineScope
          import kotlinx.coroutines.Dispatchers
          import kotlinx.coroutines.SupervisorJob
          import kotlinx.coroutines.launch

          class ResetBubbleService : android.app.Service() {

              private lateinit var wm: WindowManager
              private var bubbleView: View? = null
              private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
              private var isDragging = false

              override fun onCreate() {
                  super.onCreate()
                  wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
                  showBubble()
              }

              private fun showBubble() {
                  if (bubbleView != null) return
                  
                  val params = createLayoutParams()
                  val imageView = createBubbleImageView(params)
                  
                  bubbleView = imageView
                  wm.addView(imageView, params)
              }

              private fun createLayoutParams(): WindowManager.LayoutParams {
                  return WindowManager.LayoutParams(
                      WindowManager.LayoutParams.WRAP_CONTENT, 
                      WindowManager.LayoutParams.WRAP_CONTENT,
                      getWindowType(),
                      getLayoutParamsFlags(),
                      PixelFormat.TRANSLUCENT
                  ).apply {
                      gravity = Gravity.TOP or Gravity.END
                      x = 30
                      y = getOptimalYPosition()
                  }
              }

              private fun getWindowType(): Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                  WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
              } else {
                  @Suppress("DEPRECATION")
                  WindowManager.LayoutParams.TYPE_PHONE
              }

              private fun getLayoutParamsFlags(): Int = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                  WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                  WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                  WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                  WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH

              private fun getOptimalYPosition(): Int {
                  return if (isLenovoDevice()) 300 else 200
              }

              private fun isLenovoDevice(): Boolean {
                  return Build.MANUFACTURER.equals("lenovo", ignoreCase = true)
              }

              private fun createBubbleImageView(params: WindowManager.LayoutParams): ImageView {
                  return ImageView(this).apply {
                      setImageResource(R.drawable.ic_layout_reset)
                      setPadding(24, 24, 24, 24)
                      
                      if (isLenovoDevice()) {
                          setBackgroundColor(0x80000000.toInt())
                          elevation = 12f
                      }

                      setOnClickListener { 
                          if (!isDragging) onResetClicked() 
                      }
                      
                      setOnTouchListener(DragTouchListener(params))
                  }
              }

              private fun onResetClicked() {
                  if (!ShizukuShell.isBinderAlive() || !ShizukuShell.hasPermission()) {
                      showToast("Start Shizuku, then grant permission in the app")
                      return
                  }
                  
                  scope.launch {
                      try {
                          val config = TemplatesRepository(this@ResetBubbleService).getActive()
                          val orchestrator = LayoutOrchestrator(this@ResetBubbleService)
                          val result = orchestrator.applyLayout(config)
                          showToast(if (result.success) "Layout reset complete" else result.message)
                      } catch (e: Exception) {
                          showToast("Error: ${e.message}")
                      }
                  }
              }

              private fun showToast(message: String) {
                  Toast.makeText(this, message, if (message.length > 50) Toast.LENGTH_LONG else Toast.LENGTH_SHORT).show()
              }

              inner class DragTouchListener(private val params: WindowManager.LayoutParams) : View.OnTouchListener {
                  private var lastX = 0f
                  private var lastY = 0f
                  private val dragThreshold = 10

                  override fun onTouch(v: View, e: MotionEvent): Boolean {
                      when (e.actionMasked) {
                          MotionEvent.ACTION_DOWN -> {
                              lastX = e.rawX
                              lastY = e.rawY
                              isDragging = false
                              return true
                          }
                          MotionEvent.ACTION_MOVE -> {
                              val dx = Math.abs(e.rawX - lastX)
                              val dy = Math.abs(e.rawY - lastY)
                              
                              if (dx > dragThreshold || dy > dragThreshold) {
                                  isDragging = true
                                  
                                  val newX = (e.rawX - lastX).toInt()
                                  val newY = (e.rawY - lastY).toInt()
                                  params.x -= newX
                                  params.y += newY
                                  
                                  try {
                                      wm.updateViewLayout(v, params)
                                  } catch (ex: Exception) {
                                  }
                                  
                                  lastX = e.rawX
                                  lastY = e.rawY
                                  return true
                              }
                          }
                          MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                              val wasDragging = isDragging
                              isDragging = false
                              return wasDragging
                          }
                      }
                      return false
                  }
              }

              override fun onDestroy() {
                  bubbleView?.let { 
                      try {
                          wm.removeView(it) 
                      } catch (e: Exception) {
                      }
                  }
                  bubbleView = null
                  super.onDestroy()
              }

              override fun onBind(intent: Intent?) = null
          }
          EOT

          # Quick Settings Tile
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/tiles/LayoutResetTile.kt" << 'EOT'
          package com.internal.layout.orchestrator.tiles

          import android.service.quicksettings.Tile
          import android.service.quicksettings.TileService
          import android.util.Log
          import android.widget.Toast
          import com.internal.layout.orchestrator.core.LayoutOrchestrator
          import com.internal.layout.orchestrator.data.TemplatesRepository
          import com.internal.layout.orchestrator.shell.ShizukuShell
          import kotlinx.coroutines.CoroutineScope
          import kotlinx.coroutines.Dispatchers
          import kotlinx.coroutines.launch

          class LayoutResetTile : TileService() {
              
              companion object {
                  private const val TAG = "LayoutResetTile"
              }
              
              override fun onStartListening() {
                  super.onStartListening()
                  qsTile?.apply {
                      label = "Reset Layout"
                      state = Tile.STATE_ACTIVE
                      updateTile()
                  }
              }

              override fun onClick() {
                  super.onClick()
                  Log.d(TAG, "Quick Settings tile clicked")
                  
                  if (!ShizukuShell.isBinderAlive() || !ShizukuShell.hasPermission()) {
                      Toast.makeText(this, "Start Shizuku and grant permission", Toast.LENGTH_LONG).show()
                      return
                  }
                  
                  val repo = TemplatesRepository(this)
                  val orchestrator = LayoutOrchestrator(this)
                  
                  CoroutineScope(Dispatchers.Main).launch {
                      try {
                          val config = repo.getActive()
                          val result = orchestrator.applyLayout(config)
                          Toast.makeText(
                              this@LayoutResetTile, 
                              if (result.success) "Layout reset successful" else result.message,
                              Toast.LENGTH_SHORT
                          ).show()
                          Log.d(TAG, "Layout reset completed: ${result.message}")
                      } catch (e: Exception) {
                          val errorMsg = "Layout reset failed: ${e.message}"
                          Toast.makeText(this@LayoutResetTile, errorMsg, Toast.LENGTH_LONG).show()
                          Log.e(TAG, errorMsg, e)
                      }
                  }
              }
          }
          EOT

          # UI Activities
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/ui/MainActivity.kt" << 'EOT'
          package com.internal.layout.orchestrator.ui

          import android.content.Intent
          import android.net.Uri
          import android.os.Build
          import android.os.Bundle
          import android.provider.Settings
          import android.widget.*
          import androidx.appcompat.app.AppCompatActivity
          import androidx.lifecycle.lifecycleScope
          import com.internal.layout.orchestrator.R
          import com.internal.layout.orchestrator.core.LayoutOrchestrator
          import com.internal.layout.orchestrator.data.TemplatesRepository
          import com.internal.layout.orchestrator.services.LayoutWatchdogService
          import com.internal.layout.orchestrator.services.ResetBubbleService
          import com.internal.layout.orchestrator.shell.ShizukuShell
          import kotlinx.coroutines.launch

          class MainActivity : AppCompatActivity() {

              private lateinit var orchestrator: LayoutOrchestrator
              private lateinit var repo: TemplatesRepository

              override fun onCreate(savedInstanceState: Bundle?) {
                  super.onCreate(savedInstanceState)
                  setContentView(R.layout.activity_main)
                  orchestrator = LayoutOrchestrator(this)
                  repo = TemplatesRepository(this)

                  setupUI()
                  handleIntent(intent)
                  
                  if (isFirstRun()) {
                      showFirstRunInstructions()
                  }
              }

              override fun onNewIntent(intent: Intent?) {
                  super.onNewIntent(intent)
                  intent?.let { handleIntent(it) }
              }

              private fun isFirstRun(): Boolean {
                  val prefs = getSharedPreferences("app_prefs", MODE_PRIVATE)
                  val firstRun = prefs.getBoolean("first_run", true)
                  if (firstRun) {
                      prefs.edit().putBoolean("first_run", false).apply()
                  }
                  return firstRun
              }

              private fun showFirstRunInstructions() {
                  Toast.makeText(this, "Welcome! Follow setup instructions below", Toast.LENGTH_LONG).show()
              }

              private fun setupUI() {
                  findViewById<Button>(R.id.btnApplyLayout).setOnClickListener { 
                      applyLayout() 
                  }
                  
                  findViewById<Button>(R.id.btnConfigureApps).setOnClickListener {
                      startActivity(Intent(this, ConfigActivity::class.java))
                  }
                  
                  findViewById<Switch>(R.id.switchWatchdog).setOnCheckedChangeListener { _, isChecked ->
                      if (isChecked) {
                          LayoutWatchdogService.start(this)
                          Toast.makeText(this, "Watchdog service started", Toast.LENGTH_SHORT).show()
                      } else {
                          LayoutWatchdogService.stop(this)
                          Toast.makeText(this, "Watchdog service stopped", Toast.LENGTH_SHORT).show()
                      }
                  }
                  
                  findViewById<Button>(R.id.btnOverlayPermission).setOnClickListener {
                      requestOverlayPermission()
                  }
                  
                  findViewById<Button>(R.id.btnUsageAccess).setOnClickListener {
                      requestUsageAccess()
                  }
                  
                  findViewById<Button>(R.id.btnGrantShizuku).setOnClickListener {
                      handleShizukuPermission()
                  }
                  
                  findViewById<Button>(R.id.btnEnableFreeform).setOnClickListener {
                      enableFreeformFlags()
                  }
                  
                  findViewById<Switch>(R.id.switchBubble).setOnCheckedChangeListener { button, isChecked ->
                      if (isChecked && !Settings.canDrawOverlays(this)) {
                          requestOverlayPermission()
                          (button as Switch).isChecked = false
                          return@setOnCheckedChangeListener
                      }
                      
                      if (isChecked) {
                          startService(Intent(this, ResetBubbleService::class.java))
                          Toast.makeText(this, "Floating reset bubble enabled", Toast.LENGTH_SHORT).show()
                      } else {
                          stopService(Intent(this, ResetBubbleService::class.java))
                          Toast.makeText(this, "Floating reset bubble disabled", Toast.LENGTH_SHORT).show()
                      }
                  }
                  
                  updateStatusIndicators()
              }

              private fun applyLayout() {
                  if (!Settings.canDrawOverlays(this)) {
                      requestOverlayPermission()
                      return
                  }
                  
                  lifecycleScope.launch {
                      try {
                          val cfg = repo.getActive()
                          val result = orchestrator.applyLayout(cfg)
                          Toast.makeText(
                              this@MainActivity, 
                              if (result.success) "Applied ${cfg.name}: ${result.message}" else result.message,
                              if (result.success) Toast.LENGTH_SHORT else Toast.LENGTH_LONG
                          ).show()
                      } catch (e: Exception) {
                          Toast.makeText(this@MainActivity, "Error: ${e.message}", Toast.LENGTH_LONG).show()
                      }
                  }
              }

              private fun handleIntent(intent: Intent) {
                  when (intent.getStringExtra("action")) {
                      "reset_layout" -> applyLayout()
                  }
              }

              private fun handleShizukuPermission() {
                  if (!ShizukuShell.isBinderAlive()) {
                      Toast.makeText(
                          this, 
                          "Open Shizuku app and tap Start (Wireless debugging)", 
                          Toast.LENGTH_LONG
                      ).show()
                      return
                  }
                  
                  if (ShizukuShell.hasPermission()) {
                      Toast.makeText(this, "Shizuku permission already granted", Toast.LENGTH_SHORT).show()
                  } else {
                      ShizukuShell.requestPermission { granted ->
                          runOnUiThread {
                              Toast.makeText(
                                  this, 
                                  if (granted) "Shizuku access granted!" else "Permission denied", 
                                  Toast.LENGTH_SHORT
                              ).show()
                              
                              if (granted) {
                                  updateStatusIndicators()
                              }
                          }
                      }
                  }
              }

              private fun enableFreeformFlags() {
                  lifecycleScope.launch {
                      if (!ShizukuShell.isBinderAlive() || !ShizukuShell.hasPermission()) {
                          Toast.makeText(
                              this@MainActivity, 
                              "Start Shizuku and grant permission first", 
                              Toast.LENGTH_LONG
                          ).show()
                          return@launch
                      }
                      
                      try {
                          orchestrator.enableFreeformFlags()
                          Toast.makeText(this@MainActivity, "Freeform flags set successfully!", Toast.LENGTH_SHORT).show()
                      } catch (e: Exception) {
                          Toast.makeText(this@MainActivity, "Failed: ${e.message}", Toast.LENGTH_LONG).show()
                      }
                  }
              }

              private fun requestOverlayPermission() {
                  val intent = Intent(
                      Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                      Uri.parse("package:$packageName")
                  )
                  startActivity(intent)
                  Toast.makeText(this, "Please grant overlay permission", Toast.LENGTH_LONG).show()
              }

              private fun requestUsageAccess() {
                  val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                  startActivity(intent)
                  Toast.makeText(this, "Please grant usage access (optional)", Toast.LENGTH_LONG).show()
              }

              private fun updateStatusIndicators() {
                  val shizukuStatus = findViewById<TextView>(R.id.tvShizukuStatus)
                  val freeformStatus = findViewById<TextView>(R.id.tvFreeformStatus)
                  
                  shizukuStatus.text = if (ShizukuShell.isBinderAlive()) {
                      if (ShizukuShell.hasPermission()) "✓ Connected & Granted" else "⚠ Connected, Not Granted"
                  } else {
                      "✗ Not Connected"
                  }
                  
                  freeformStatus.text = "Unknown (Tap 'Enable Freeform Flags')"
              }
          }
          EOT

          # Configuration Activity
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/ui/ConfigActivity.kt" << 'EOT'
          package com.internal.layout.orchestrator.ui

          import android.content.Intent
          import android.content.pm.PackageManager
          import android.os.Bundle
          import android.widget.*
          import androidx.appcompat.app.AlertDialog
          import androidx.appcompat.app.AppCompatActivity
          import com.internal.layout.orchestrator.R
          import com.internal.layout.orchestrator.data.LayoutConfig
          import com.internal.layout.orchestrator.data.TemplatesRepository

          class ConfigActivity : AppCompatActivity() {

              private lateinit var repo: TemplatesRepository
              private lateinit var pkg: PackageManager
              private var config: LayoutConfig = LayoutConfig.getDefault()

              override fun onCreate(savedInstanceState: Bundle?) {
                  super.onCreate(savedInstanceState)
                  setContentView(R.layout.activity_config)
                  repo = TemplatesRepository(this)
                  pkg = packageManager
                  config = repo.getActive()
                  setupUI()
                  updateUI()
              }

              private fun setupUI() {
                  findViewById<Button>(R.id.btnSelectTopApp).setOnClickListener { 
                      selectApp("Top") { app -> 
                          config = config.copy(topApp = app)
                          updateUI()
                      } 
                  }
                  
                  findViewById<Button>(R.id.btnSelectBottomLeftApp).setOnClickListener { 
                      selectApp("Bottom Left") { app ->
                          config = config.copy(bottomLeftApp = app)
                          updateUI()
                      } 
                  }
                  
                  findViewById<Button>(R.id.btnSelectBottomRightApp).setOnClickListener { 
                      selectApp("Bottom Right") { app ->
                          config = config.copy(bottomRightApp = app)
                          updateUI()
                      } 
                  }

                  findViewById<SeekBar>(R.id.seekBarTopHeight).setOnSeekBarChangeListener(
                      object: SeekBar.OnSeekBarChangeListener{
                          override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                              if (fromUser) {
                                  config = config.copy(topHeightPercent = progress / 100f)
                                  updateUI()
                              }
                          }
                          override fun onStartTrackingTouch(seekBar: SeekBar?) {}
                          override fun onStopTrackingTouch(seekBar: SeekBar?) {}
                      }
                  )

                  findViewById<Button>(R.id.btnActiveTemplate).setOnClickListener {
                      val all = repo.list()
                      val names = all.map { it.name }.toTypedArray()
                      AlertDialog.Builder(this)
                          .setTitle("Select active template")
                          .setItems(names) { _, which ->
                              repo.setActive(names[which])
                              config = all[which]
                              updateUI()
                              Toast.makeText(this, "Active template set to: ${names[which]}", Toast.LENGTH_SHORT).show()
                          }
                          .show()
                  }

                  findViewById<Button>(R.id.btnSaveConfig).setOnClickListener {
                      val name = findViewById<EditText>(R.id.etTemplateName).text.toString().ifBlank { "Template" }
                      repo.upsert(config.copy(name = name))
                      repo.setActive(name)
                      Toast.makeText(this, "Saved template: $name", Toast.LENGTH_SHORT).show()
                      setResult(RESULT_OK)
                      finish()
                  }
                  
                  findViewById<Button>(R.id.btnDeleteTemplate).setOnClickListener {
                      if (config.name != "Default") {
                          AlertDialog.Builder(this)
                              .setTitle("Delete Template")
                              .setMessage("Delete template '${config.name}'?")
                              .setPositiveButton("Delete") { _, _ ->
                                  repo.delete(config.name)
                                  config = LayoutConfig.getDefault()
                                  repo.setActive(config.name)
                                  updateUI()
                                  Toast.makeText(this, "Template deleted", Toast.LENGTH_SHORT).show()
                              }
                              .setNegativeButton("Cancel", null)
                              .show()
                      } else {
                          Toast.makeText(this, "Cannot delete default template", Toast.LENGTH_SHORT).show()
                      }
                  }
              }

              private fun updateUI() {
                  findViewById<TextView>(R.id.tvTopApp).text = "Top: ${config.topApp.displayName}"
                  findViewById<TextView>(R.id.tvBottomLeftApp).text = "Bottom Left: ${config.bottomLeftApp.displayName}"
                  findViewById<TextView>(R.id.tvBottomRightApp).text = "Bottom Right: ${config.bottomRightApp.displayName}"
                  findViewById<TextView>(R.id.tvTopHeight).text = "Top Height: ${(config.topHeightPercent * 100).toInt()}%"
                  findViewById<SeekBar>(R.id.seekBarTopHeight).progress = (config.topHeightPercent * 100).toInt()
                  findViewById<EditText>(R.id.etTemplateName).setText(config.name)
              }

              private fun selectApp(position: String, onSelected: (LayoutConfig.AppConfig) -> Unit) {
                  val intent = Intent(Intent.ACTION_MAIN, null).addCategory(Intent.CATEGORY_LAUNCHER)
                  val apps = pkg.queryIntentActivities(intent, 0).map { ri ->
                      val label = pkg.getApplicationLabel(ri.activityInfo.applicationInfo).toString()
                      LayoutConfig.AppConfig(
                          packageName = ri.activityInfo.packageName,
                          activityName = ri.activityInfo.name,
                          displayName = label
                      )
                  }.sortedBy { it.displayName }
                  
                  val names = apps.map { it.displayName }.toTypedArray()
                  AlertDialog.Builder(this)
                      .setTitle("Select $position App")
                      .setItems(names) { _, which -> onSelected(apps[which]) }
                      .show()
              }
          }
          EOT

          # Utility functions
          cat > "$PROJECT_NAME/app/src/main/java/com/internal/layout/orchestrator/utils/LenovoUtils.kt" << 'EOT'
          package com.internal.layout.orchestrator.utils

          import android.os.Build

          object LenovoUtils {
              fun isLenovoDevice(): Boolean {
                  return Build.MANUFACTURER.equals("lenovo", ignoreCase = true) ||
                         Build.BRAND.equals("lenovo", ignoreCase = true)
              }
              
              fun getLenovoModelSeries(): String {
                  return when {
                      Build.MODEL.contains("TB-", ignoreCase = true) -> "Tab Series"
                      Build.MODEL.contains("LR-", ignoreCase = true) -> "Legion Series"  
                      Build.MODEL.contains("YT-", ignoreCase = true) -> "Yoga Tab Series"
                      else -> "Other Lenovo"
                  }
              }
              
              fun getRecommendedDelayMultiplier(): Float {
                  return when (getLenovoModelSeries()) {
                      "Tab Series" -> 1.4f
                      "Yoga Tab Series" -> 1.3f
                      else -> 1.2f
                  }
              }
              
              fun isKnownIssueModel(): Boolean {
                  val knownIssues = arrayOf("TB-X606F", "TB-X606X", "TB-X306X")
                  return knownIssues.any { Build.MODEL.equals(it, ignoreCase = true) }
              }
          }
          EOT

          # -----------------------------
          # RESOURCE FILES
          # -----------------------------

          # Layouts
          cat > "$PROJECT_NAME/app/src/main/res/layout/activity_main.xml" << 'EOT'
          <?xml version="1.0" encoding="utf-8"?>
          <ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
              android:layout_width="match_parent"
              android:layout_height="match_parent"
              android:padding="16dp">

              <LinearLayout
                  android:layout_width="match_parent"
                  android:layout_height="wrap_content"
                  android:orientation="vertical">

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="3-Pane Layout Orchestrator"
                      android:textStyle="bold"
                      android:textSize="22sp"
                      android:gravity="center"
                      android:layout_marginBottom="16dp"/>

                  <Button
                      android:id="@+id/btnApplyLayout"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Apply 3-Pane Layout"
                      android:layout_marginBottom="12dp"/>

                  <Button
                      android:id="@+id/btnConfigureApps"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Configure Apps"
                      android:layout_marginBottom="16dp"/>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="System Status"
                      android:textStyle="bold"
                      android:layout_marginBottom="8dp"/>
                      
                  <LinearLayout
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:orientation="horizontal"
                      android:layout_marginBottom="4dp">
                      <TextView
                          android:layout_width="0dp"
                          android:layout_weight="1"
                          android:layout_height="wrap_content"
                          android:text="Shizuku:"/>
                      <TextView
                          android:id="@+id/tvShizukuStatus"
                          android:layout_width="0dp"
                          android:layout_weight="1"
                          android:layout_height="wrap_content"
                          android:text="Unknown"/>
                  </LinearLayout>
                  
                  <LinearLayout
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:orientation="horizontal"
                      android:layout_marginBottom="12dp">
                      <TextView
                          android:layout_width="0dp"
                          android:layout_weight="1"
                          android:layout_height="wrap_content"
                          android:text="Freeform:"/>
                      <TextView
                          android:id="@+id/tvFreeformStatus"
                          android:layout_width="0dp"
                          android:layout_weight="1"
                          android:layout_height="wrap_content"
                          android:text="Unknown"/>
                  </LinearLayout>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Services"
                      android:textStyle="bold"
                      android:layout_marginBottom="8dp"/>
                      
                  <LinearLayout
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:orientation="horizontal"
                      android:layout_marginBottom="4dp"
                      android:gravity="center_vertical">
                      <TextView
                          android:layout_width="0dp"
                          android:layout_weight="1"
                          android:layout_height="wrap_content"
                          android:text="Watchdog Service"/>
                      <Switch
                          android:id="@+id/switchWatchdog"
                          android:layout_width="wrap_content"
                          android:layout_height="wrap_content"/>
                  </LinearLayout>

                  <LinearLayout
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:orientation="horizontal"
                      android:layout_marginBottom="16dp"
                      android:gravity="center_vertical">
                      <TextView
                          android:layout_width="0dp"
                          android:layout_weight="1"
                          android:layout_height="wrap_content"
                          android:text="Floating Reset Bubble"/>
                      <Switch
                          android:id="@+id/switchBubble"
                          android:layout_width="wrap_content"
                          android:layout_height="wrap_content"/>
                  </LinearLayout>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Required Permissions"
                      android:textStyle="bold"
                      android:layout_marginBottom="8dp"/>

                  <Button
                      android:id="@+id/btnGrantShizuku"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Grant Shizuku Access"
                      android:layout_marginBottom="8dp"/>

                  <Button
                      android:id="@+id/btnEnableFreeform"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Enable Freeform Flags (Shizuku)"
                      android:layout_marginBottom="8dp"/>

                  <LinearLayout
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:orientation="horizontal"
                      android:layout_marginBottom="8dp">
                      <Button
                          android:id="@+id/btnOverlayPermission"
                          android:layout_width="0dp"
                          android:layout_height="wrap_content"
                          android:layout_weight="1"
                          android:text="Overlay"
                          android:layout_marginEnd="4dp"/>
                      <Button
                          android:id="@+id/btnUsageAccess"
                          android:layout_width="0dp"
                          android:layout_height="wrap_content"
                          android:layout_weight="1"
                          android:text="Usage Access"
                          android:layout_marginStart="4dp"/>
                  </LinearLayout>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Instructions"
                      android:textStyle="bold"
                      android:layout_marginTop="16dp"
                      android:layout_marginBottom="8dp"/>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="1. Install Shizuku from Play Store\n2. Start it via Wireless debugging\n3. Grant permission to this app\n4. Enable freeform flags\n5. Configure apps and templates\n6. Apply layout or use floating bubble/QS tile"
                      android:layout_marginBottom="16dp"/>

              </LinearLayout>
          </ScrollView>
          EOT

          cat > "$PROJECT_NAME/app/src/main/res/layout/activity_config.xml" << 'EOT'
          <?xml version="1.0" encoding="utf-8"?>
          <ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
              android:layout_width="match_parent"
              android:layout_height="match_parent"
              android:padding="16dp">

              <LinearLayout
                  android:orientation="vertical"
                  android:layout_width="match_parent"
                  android:layout_height="wrap_content">

                  <EditText
                      android:id="@+id/etTemplateName"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:hint="Template name"
                      android:singleLine="true"
                      android:layout_marginBottom="16dp"/>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Top App"
                      android:textStyle="bold"/>
                  <TextView
                      android:id="@+id/tvTopApp"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Top: "
                      android:layout_marginTop="4dp"/>
                  <Button
                      android:id="@+id/btnSelectTopApp"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Select Top App"
                      android:layout_marginBottom="12dp"/>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Bottom Left App"
                      android:textStyle="bold"/>
                  <TextView
                      android:id="@+id/tvBottomLeftApp"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Bottom Left: "
                      android:layout_marginTop="4dp"/>
                  <Button
                      android:id="@+id/btnSelectBottomLeftApp"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Select Bottom Left App"
                      android:layout_marginBottom="12dp"/>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Bottom Right App"
                      android:textStyle="bold"/>
                  <TextView
                      android:id="@+id/tvBottomRightApp"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Bottom Right: "
                      android:layout_marginTop="4dp"/>
                  <Button
                      android:id="@+id/btnSelectBottomRightApp"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Select Bottom Right App"
                      android:layout_marginBottom="16dp"/>

                  <TextView
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Top Panel Height"
                      android:textStyle="bold"/>
                  <TextView
                      android:id="@+id/tvTopHeight"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Top Height: 33%"
                      android:layout_marginTop="4dp"/>
                  <SeekBar
                      android:id="@+id/seekBarTopHeight"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:max="80"
                      android:progress="33"
                      android:layout_marginBottom="16dp"/>

                  <Button
                      android:id="@+id/btnActiveTemplate"
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:text="Select Active Template"
                      android:layout_marginBottom="8dp"/>

                  <LinearLayout
                      android:layout_width="match_parent"
                      android:layout_height="wrap_content"
                      android:orientation="horizontal">
                      <Button
                          android:id="@+id/btnSaveConfig"
                          android:layout_width="0dp"
                          android:layout_height="wrap_content"
                          android:layout_weight="1"
                          android:text="Save Template"
                          android:layout_marginEnd="4dp"/>
                      <Button
                          android:id="@+id/btnDeleteTemplate"
                          android:layout_width="0dp"
                          android:layout_height="wrap_content"
                          android:layout_weight="1"
                          android:text="Delete"
                          android:layout_marginStart="4dp"/>
                  </LinearLayout>
              </LinearLayout>
          </ScrollView>
          EOT

          # Strings
          cat > "$PROJECT_NAME/app/src/main/res/values/strings.xml" << 'EOT'
          <resources>
              <string name="app_name">3-Pane Layout Orchestrator</string>
              <string name="config_title">Layout Configuration</string>
              <string name="tile_reset_label">Reset Layout</string>
              <string name="apply_layout">Apply 3-Pane Layout</string>
              <string name="configure_apps">Configure Apps</string>
              <string name="enable_watchdog">Enable Watchdog Service</string>
              <string name="instructions_title">Setup Instructions</string>
              <string name="instructions_body">1. Configure your 3 apps\n2. Install Shizuku, start it via Wireless debugging, and grant permission\n3. Enable freeform flags\n4. Apply layout or use the Reset bubble/QS tile.\nNote: After reboot, just open Shizuku and tap Start. No PC required.</string>
              <string name="notif_title">Layout Orchestrator Active</string>
              <string name="notif_text">Monitoring and quick reset available</string>
              <string name="reset">Reset</string>
          </resources>
          EOT

          # Drawables
          cat > "$PROJECT_NAME/app/src/main/res/drawable/ic_layout_reset.xml" << 'EOT'
          <vector xmlns:android="http://schemas.android.com/apk/res/android"
              android:width="24dp" android:height="24dp"
              android:viewportWidth="24" android:viewportHeight="24">
              <path android:fillColor="#FFFFFF" android:pathData="M12,5v4l3-3 -3-3v4c-3.86,0 -7,3.14 -7,7 0,3.87 3.13,7 7,7 3.86,0 7-3.13 7-7h-2c0,2.76 -2.24,5 -5,5 -2.76,0 -5-2.24 -5-5 0-2.76 2.24-5 5-5z"/>
          </vector>
          EOT

          # Mipmap (using standard Android icons)
          cat > "$PROJECT_NAME/app/src/main/res/mipmap/ic_launcher.xml" << 'EOT'
          <?xml version="1.0" encoding="utf-8"?>
          <layer-list xmlns:android="http://schemas.android.com/apk/res/android">
              <item android:drawable="@android:color/holo_blue_dark" />
          </layer-list>
          EOT

          # -----------------------------
          # GITHUB ACTIONS WORKFLOW
          # -----------------------------
          mkdir -p "$PROJECT_NAME/.github/workflows"

          cat > "$PROJECT_NAME/.github/workflows/android.yml" << 'EOT'
          name: Android CI

          on:
            push:
              branches: [ main, master ]
            pull_request:
              branches: [ main, master ]
            workflow_dispatch:

          jobs:
            build:
              name: Build and Test
              runs-on: ubuntu-latest
              steps:
                - name: Checkout
                  uses: actions/checkout@v4

                - name: Set up JDK 17
                  uses: actions/setup-java@v4
                  with:
                    distribution: 'zulu'
                    java-version: '17'

                - name: Setup Android SDK
                  uses: android-actions/setup-android@v3

                - name: Decode keystore (if provided)
                  if: ${{ secrets.ANDROID_KEYSTORE_BASE64 != '' }}
                  run: |
                    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > keystore.jks
                    echo "ANDROID_KEYSTORE_PATH=$PWD/keystore.jks" >> $GITHUB_ENV
                    echo "ANDROID_KEYSTORE_PASSWORD=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" >> $GITHUB_ENV
                    echo "ANDROID_KEY_ALIAS=${{ secrets.ANDROID_KEY_ALIAS }}" >> $GITHUB_ENV
                    echo "ANDROID_KEY_ALIAS_PASSWORD=${{ secrets.ANDROID_KEY_ALIAS_PASSWORD }}" >> $GITHUB_ENV

                - name: Build Project
                  run: |
                    ./gradlew assembleRelease --stacktrace

                - name: Upload APK
                  uses: actions/upload-artifact@v4
                  with:
                    name: LayoutOrchestrator-APK
                    path: app/build/outputs/apk/release/app-release*.apk
                    if-no-files-found: error

                - name: Upload Build Reports
                  if: failure()
                  uses: actions/upload-artifact@v4
                  with:
                    name: build-reports
                    path: app/build/reports/
          EOT

          # Zip the project
          (cd "$PROJECT_NAME/.." && zip -qr "$PROJECT_NAME.zip" "$PROJECT_NAME")
          echo "✅ Project generated successfully!"
          EOF

          chmod +x generate_project.sh
          bash ./generate_project.sh

      # Commit and push generated files
      - name: Commit and Push Generated Files
        run: |
          git config --global user.email "action@github.com"
          git config --global user.name "GitHub Action"
          git add .
          git commit -m "Auto-generate project structure" || echo "Nothing to commit"
          git push

      # Setup proper Gradle wrapper and build APK
      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Generate Proper Gradle Wrapper
        run: |
          cd LayoutOrchestrator
          mkdir -p gradle/wrapper
          echo "distributionBase=GRADLE_USER_HOME" > gradle/wrapper/gradle-wrapper.properties
          echo "distributionPath=wrapper/dists" >> gradle/wrapper/gradle-wrapper.properties
          echo "distributionUrl=https\\://services.gradle.org/distributions/gradle-8.5-bin.zip" >> gradle/wrapper/gradle-wrapper.properties
          echo "networkTimeout=10000" >> gradle/wrapper/gradle-wrapper.properties
          echo "zipStoreBase=GRADLE_USER_HOME" >> gradle/wrapper/gradle-wrapper.properties
          echo "zipStorePath=wrapper/dists" >> gradle/wrapper/gradle-wrapper.properties
          touch gradlew && chmod +x gradlew

      - name: Assemble Release APK
        run: |
          cd LayoutOrchestrator
          ./gradlew assembleRelease --stacktrace

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: layout-orchestrator-apk
          path: LayoutOrchestrator/app/build/outputs/apk/release/*.apk
