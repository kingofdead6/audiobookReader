package com.qari.qari

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "qari/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Free bytes on the volume holding [path].
                    "freeBytes" -> {
                        val path = call.argument<String>("path") ?: filesDir.absolutePath
                        try {
                            result.success(StatFs(path).availableBytes)
                        } catch (e: IllegalArgumentException) {
                            result.error("statfs", e.message, null)
                        }
                    }
                    "openTtsSettings" -> {
                        val intent = Intent("com.android.settings.TTS_SETTINGS")
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        try {
                            startActivity(intent)
                        } catch (e: ActivityNotFoundException) {
                            startActivity(Intent(Settings.ACTION_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
