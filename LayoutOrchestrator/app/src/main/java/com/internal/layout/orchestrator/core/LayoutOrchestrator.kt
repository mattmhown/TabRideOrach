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
