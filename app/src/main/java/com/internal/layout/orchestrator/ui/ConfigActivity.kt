package com.internal.layout.orchestrator.ui

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.internal.layout.orchestrator.R
import com.internal.layout.orchestrator.data.LayoutConfig
import com.internal.layout.orchestrator.data.TemplatesRepository

class ConfigActivity : AppCompatActivity() {
    private lateinit var repo: TemplatesRepository
    private lateinit var pkg: PackageManager
    private var config: LayoutConfig = LayoutConfig.getDefault()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_config)

        repo = TemplatesRepository(this)
        pkg = packageManager
        config = repo.getActive()

        setupUI()
        updateUI()
    }

    private fun setupUI() {
        findViewById<Button>(R.id.btnSelectTopApp).setOnClickListener {
            selectApp("Top") { app ->
                config = config.copy(topApp = app)
                updateUI()
            }
        }
       
        findViewById<Button>(R.id.btnSelectBottomLeftApp).setOnClickListener {
            selectApp("Bottom Left") { app ->
                config = config.copy(bottomLeftApp = app)
                updateUI()
            }
        }
       
        findViewById<Button>(R.id.btnSelectBottomRightApp).setOnClickListener {
            selectApp("Bottom Right") { app ->
                config = config.copy(bottomRightApp = app)
                updateUI()
            }
        }

        findViewById<SeekBar>(R.id.seekBarTopHeight).setOnSeekBarChangeListener(
            object: SeekBar.OnSeekBarChangeListener{
                override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                    if (fromUser) {
                        config = config.copy(topHeightPercent = progress / 100f)
                        updateUI()
                    }
                }
                override fun onStartTrackingTouch(seekBar: SeekBar?) {}
                override fun onStopTrackingTouch(seekBar: SeekBar?) {}
            }
        )

        findViewById<Button>(R.id.btnActiveTemplate).setOnClickListener {
            val all = repo.list()
            val names = all.map { it.name }.toTypedArray()
            AlertDialog.Builder(this)
                .setTitle("Select active template")
                .setItems(names) { _, which ->
                    repo.setActive(names[which])
                    config = all[which]
                    updateUI()
                    Toast.makeText(this, "Active template set to: ${names[which]}", Toast.LENGTH_SHORT).show()
                }
                .show()
        }

        findViewById<Button>(R.id.btnSaveConfig).setOnClickListener {
            val name = findViewById<EditText>(R.id.etTemplateName).text.toString().ifBlank { "Template" }
            repo.upsert(config.copy(name = name))
            repo.setActive(name)
            Toast.makeText(this, "Saved template: $name", Toast.LENGTH_SHORT).show()
            setResult(RESULT_OK)
            finish()
        }
       
        findViewById<Button>(R.id.btnDeleteTemplate).setOnClickListener {
            if (config.name != "Default") {
                AlertDialog.Builder(this)
                    .setTitle("Delete Template")
                    .setMessage("Delete template '${config.name}'?")
                    .setPositiveButton("Delete") { _, _ ->
                        repo.delete(config.name)
                        config = LayoutConfig.getDefault()
                        repo.setActive(config.name)
                        updateUI()
                        Toast.makeText(this, "Template deleted", Toast.LENGTH_SHORT).show()
                    }
                    .setNegativeButton("Cancel", null)
                    .show()
            } else {
                Toast.makeText(this, "Cannot delete default template", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun updateUI() {
        findViewById<TextView>(R.id.tvTopApp).text = "Top: ${config.topApp.displayName}"
        findViewById<TextView>(R.id.tvBottomLeftApp).text = "Bottom Left: ${config.bottomLeftApp.displayName}"
        findViewById<TextView>(R.id.tvBottomRightApp).text = "Bottom Right: ${config.bottomRightApp.displayName}"
        findViewById<TextView>(R.id.tvTopHeight).text = "Top Height: ${(config.topHeightPercent * 100).toInt()}%"
        findViewById<SeekBar>(R.id.seekBarTopHeight).progress = (config.topHeightPercent * 100).toInt()
        findViewById<EditText>(R.id.etTemplateName).setText(config.name)
    }

    private fun selectApp(position: String, onSelected: (LayoutConfig.AppConfig) -> Unit) {
        val intent = Intent(Intent.ACTION_MAIN, null).addCategory(Intent.CATEGORY_LAUNCHER)
        val apps = pkg.queryIntentActivities(intent, 0).map { ri ->
            val label = pkg.getApplicationLabel(ri.activityInfo.applicationInfo).toString()
            LayoutConfig.AppConfig(
                packageName = ri.activityInfo.packageName,
                activityName = ri.activityInfo.name,
                displayName = label
            )
        }.sortedBy { it.displayName }
       
        val names = apps.map { it.displayName }.toTypedArray()
        AlertDialog.Builder(this)
            .setTitle("Select $position App")
            .setItems(names) { _, which -> onSelected(apps[which]) }
            .show()
    }
}
