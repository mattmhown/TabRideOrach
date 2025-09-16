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
        // Lenovo devices sometimes need longer delays for UI animations
        return when (getLenovoModelSeries()) {
            "Tab Series" -> 1.4f
            "Yoga Tab Series" -> 1.3f
            else -> 1.2f
        }
    }
   
    fun isKnownIssueModel(): Boolean {
        // Models known to have specific issues
        val knownIssues = arrayOf("TB-X606F", "TB-X606X", "TB-X306X")
        return knownIssues.any { Build.MODEL.equals(it, ignoreCase = true) }
    }
}
