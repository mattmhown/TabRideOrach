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
       
        // Try multiple methods for better reliability on Lenovo devices
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
        // Enhanced regex for better matching on Lenovo devices
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
        // Add more robust positioning for Lenovo devices
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
