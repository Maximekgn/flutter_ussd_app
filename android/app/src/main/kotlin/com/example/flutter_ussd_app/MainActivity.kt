package com.example.flutter_ussd_app

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_ussd_app/ussd"
    private val CALL_PHONE_PERMISSION_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "directCall" -> {
                    val code = call.argument<String>("code")
                    if (code != null) {
                        val success = makeDirectCall(code)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Code USSD manquant", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkCallPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestCallPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(android.Manifest.permission.CALL_PHONE),
            CALL_PHONE_PERMISSION_CODE
        )
    }

    private fun makeDirectCall(code: String): Boolean {
        return try {
            if (!checkCallPermission()) {
                requestCallPermission()
                return false
            }

            val encodedCode = code.replace("#", "%23")
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$encodedCode")
            }

            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
