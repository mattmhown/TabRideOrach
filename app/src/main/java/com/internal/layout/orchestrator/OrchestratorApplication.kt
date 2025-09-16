package com.internal.layout.orchestrator

import android.app.Application
import dev.rikka.shizuku.ShizukuProvider
import androidx.appcompat.app.AppCompatDelegate

class OrchestratorApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        // Shizuku initialization happens via manifest provider
    }
}
