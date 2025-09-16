package com.internal.layout.orchestrator.services

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.view.*
import android.widget.ImageView
import android.widget.Toast
import com.internal.layout.orchestrator.core.LayoutOrchestrator
import com.internal.layout.orchestrator.data.TemplatesRepository
import com.internal.layout.orchestrator.shell.ShizukuShell
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class ResetBubbleService : Service() {
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
            // Use system refresh icon instead of custom drawable
            setImageResource(android.R.drawable.ic_popup_sync)
            setPadding(24, 24, 24, 24)
           
            // Lenovo-specific styling for better visibility
            if (isLenovoDevice()) {
                setBackgroundColor(0x80000000.toInt()) // Semi-transparent background
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
                    val dx = kotlin.math.abs(e.rawX - lastX)
                    val dy = kotlin.math.abs(e.rawY - lastY)
                   
                    if (dx > dragThreshold || dy > dragThreshold) {
                        isDragging = true
                       
                        val newX = (e.rawX - lastX).toInt()
                        val newY = (e.rawY - lastY).toInt()
                        params.x -= newX
                        params.y += newY
                       
                        try {
                            wm.updateViewLayout(v, params)
                        } catch (ex: Exception) {
                            // Ignore layout update errors
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
                // Ignore removal errors
            }
        }
        bubbleView = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?) = null
}
