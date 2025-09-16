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
