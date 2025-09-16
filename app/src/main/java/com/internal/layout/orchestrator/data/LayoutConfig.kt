package com.internal.layout.orchestrator.data

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

data class LayoutConfig(
    val name: String = "Default",
    val topApp: AppConfig,
    val bottomLeftApp: AppConfig,
    val bottomRightApp: AppConfig,
    val topHeightPercent: Float = 0.33f
) {
    data class AppConfig(
        val packageName: String,
        val activityName: String? = null,
        val displayName: String = packageName
    )

    companion object {
        fun getDefault(): LayoutConfig {
            return LayoutConfig(
                name = "Default",
                topApp = AppConfig("com.android.chrome", "com.google.android.apps.chrome.Main", "Chrome"),
                bottomLeftApp = AppConfig("com.whatsapp", null, "WhatsApp"),
                bottomRightApp = AppConfig("com.spotify.client", null, "Spotify")
            )
        }
    }
}

class TemplatesRepository(private val context: Context) {
    private val prefs by lazy { context.getSharedPreferences("orchestrator_config", Context.MODE_PRIVATE) }
    private val gson = Gson()
    private val key = "templates_list"

    fun list(): List<LayoutConfig> {
        val raw = prefs.getString(key, null) ?: return listOf(LayoutConfig.getDefault())
        return try {
            val type = object : TypeToken<List<LayoutConfig>>() {}.type
            gson.fromJson<List<LayoutConfig>>(raw, type)
        } catch (_: Throwable) {
            listOf(LayoutConfig.getDefault())
        }
    }

    fun getActive(): LayoutConfig = prefs.getString("active_template", null)
        ?.let { activeName -> list().find { it.name == activeName } }
        ?: list().firstOrNull()
        ?: LayoutConfig.getDefault()

    fun setActive(name: String) {
        prefs.edit().putString("active_template", name).apply()
    }

    fun upsert(config: LayoutConfig) {
        val all = list().toMutableList()
        val idx = all.indexOfFirst { it.name == config.name }
        if (idx >= 0) all[idx] = config else all.add(config)
        saveAll(all)
    }

    fun delete(name: String) {
        val all = list().filterNot { it.name == name }
        saveAll(all)
        if (prefs.getString("active_template", null) == name) {
            prefs.edit().remove("active_template").apply()
        }
    }

    private fun saveAll(list: List<LayoutConfig>) {
        prefs.edit().putString(key, gson.toJson(list)).apply()
    }
}
