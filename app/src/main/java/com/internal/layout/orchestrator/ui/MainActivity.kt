package com.internal.layout.orchestrator.ui

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.widget.Button
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast
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
       
        // Show initial instructions if first run
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
        findViewById<Button>(R.id.btnApplyLayout)?.setOnClickListener {
            applyLayout()
        }
       
        findViewById<Button>(R.id.btnConfigureApps)?.setOnClickListener {
            startActivity(Intent(this, ConfigActivity::class.java))
        }
       
        findViewById<Switch>(R.id.switchWatchdog)?.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                LayoutWatchdogService.start(this)
                Toast.makeText(this, "Watchdog service started", Toast.LENGTH_SHORT).show()
            } else {
                LayoutWatchdogService.stop(this)
                Toast.makeText(this, "Watchdog service stopped", Toast.LENGTH_SHORT).show()
            }
        }
       
        findViewById<Button>(R.id.btnOverlayPermission)?.setOnClickListener {
            requestOverlayPermission()
        }
       
        findViewById<Button>(R.id.btnUsageAccess)?.setOnClickListener {
            requestUsageAccess()
        }
       
        findViewById<Button>(R.id.btnGrantShizuku)?.setOnClickListener {
            handleShizukuPermission()
        }
       
        findViewById<Button>(R.id.btnEnableFreeform)?.setOnClickListener {
            enableFreeformFlags()
        }
       
        findViewById<Switch>(R.id.switchBubble)?.setOnCheckedChangeListener { button, isChecked ->
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
        findViewById<TextView>(R.id.tvShizukuStatus)?.apply {
            text = if (ShizukuShell.isBinderAlive()) {
                if (ShizukuShell.hasPermission()) "✓ Connected & Granted" else "⚠ Connected, Not Granted"
            } else {
                "✗ Not Connected"
            }
        }
       
        findViewById<TextView>(R.id.tvFreeformStatus)?.apply {
            text = "Unknown (Tap 'Enable Freeform Flags')"
        }
    }
}
