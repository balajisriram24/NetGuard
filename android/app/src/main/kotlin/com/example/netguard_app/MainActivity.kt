package com.example.netguard_app

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "netguard/wifi"
    private var pendingResult: MethodChannel.Result? = null
    private var wifiReceiver: BroadcastReceiver? = null
    private var receiverRegistered = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "scanWifi") {
                    if (pendingResult != null) {
                        result.error("BUSY", "Scan already running", null)
                    } else if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
                        pendingResult = result
                        requestPermissions(
                            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 501
                        )
                    } else {
                        startWifiScan(result)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 501) {
            val result = pendingResult
            pendingResult = null
            if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (result != null) startWifiScan(result)
            } else {
                result?.error("PERMISSION_DENIED",
                    "Location permission is required for Wi-Fi scanning", null)
            }
        }
    }

    private fun startWifiScan(result: MethodChannel.Result) {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

        if (!wifi.isWifiEnabled) {
            result.error("WIFI_OFF", "Please turn on Wi-Fi", null)
            return
        }

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                try {
                    if (receiverRegistered) {
                        unregisterReceiver(this)
                        receiverRegistered = false
                    }

                    val networks = wifi.scanResults.map { item ->
                        mapOf(
                            "ssid" to item.SSID,
                            "bssid" to item.BSSID,
                            "rssi" to item.level,
                            "frequency" to item.frequency,
                            "capabilities" to item.capabilities
                        )
                    }.filter { (it["ssid"] as? String)?.isNotBlank() == true }

                    pendingResult = null
                    result.success(networks)
                } catch (e: Exception) {
                    pendingResult = null
                    result.error("SCAN_ERROR", e.message, null)
                }
                wifiReceiver = null
            }
        }

        try {
            wifiReceiver = receiver
            registerReceiver(
                receiver,
                IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
            )
            receiverRegistered = true
            pendingResult = result

            val started = wifi.startScan()
            if (!started) {
                if (receiverRegistered) {
                    unregisterReceiver(receiver)
                    receiverRegistered = false
                }
                wifiReceiver = null
                pendingResult = null
                result.error("SCAN_THROTTLED",
                    "Android limited this scan. Please try again later.", null)
            }
        } catch (e: Exception) {
            if (receiverRegistered) {
                try { unregisterReceiver(receiver) } catch (_: Exception) {}
                receiverRegistered = false
            }
            wifiReceiver = null
            pendingResult = null
            result.error("SCAN_ERROR", e.message, null)
        }
    }

    override fun onDestroy() {
        if (receiverRegistered && wifiReceiver != null) {
            try { unregisterReceiver(wifiReceiver) } catch (_: Exception) {}
            receiverRegistered = false
        }
        super.onDestroy()
    }
}