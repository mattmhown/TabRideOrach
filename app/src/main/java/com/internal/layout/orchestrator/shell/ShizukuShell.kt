package com.internal.layout.orchestrator.shell

import android.content.pm.PackageManager
import dev.rikka.shizuku.Shizuku
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.InputStreamReader

object ShizukuShell {
    fun isBinderAlive(): Boolean = try {
        Shizuku.pingBinder()
    } catch (_: Throwable) {
        false
    }

    fun hasPermission(): Boolean = try {
        Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
    } catch (_: Exception) {
        false
    }

    fun requestPermission(callback: (granted: Boolean) -> Unit) {
        val listener = object : Shizuku.OnRequestPermissionResultListener {
            override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
                Shizuku.removeRequestPermissionResultListener(this)
                callback(grantResult == PackageManager.PERMISSION_GRANTED)
            }
        }
        Shizuku.addRequestPermissionResultListener(listener)
        try {
            Shizuku.requestPermission(1000)
        } catch (e: Exception) {
            callback(false)
        }
    }

    suspend fun exec(cmd: String): String = withContext(Dispatchers.IO) {
        if (!isBinderAlive()) throw IllegalStateException("Shizuku not connected")
       
        try {
            val p = Shizuku.newProcess(arrayOf("sh", "-c", cmd), null, null)
            val out = BufferedReader(InputStreamReader(p.inputStream)).readText().trim()
            val err = BufferedReader(InputStreamReader(p.errorStream)).readText().trim()
            p.waitFor()
           
            if (err.isNotBlank() && !err.contains("WARNING")) "$out\n$err" else out
        } catch (e: Exception) {
            throw RuntimeException("Command failed: $cmd", e)
        }
    }
}
