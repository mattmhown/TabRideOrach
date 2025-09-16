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
