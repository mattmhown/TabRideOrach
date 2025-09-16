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
