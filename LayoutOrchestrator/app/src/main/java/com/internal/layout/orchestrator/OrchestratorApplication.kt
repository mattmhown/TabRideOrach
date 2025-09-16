package com.internal.layout.orchestrator

import android.app.Application
import androidx.appcompat.app.AppCompatDelegate

class OrchestratorApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
    }
}
