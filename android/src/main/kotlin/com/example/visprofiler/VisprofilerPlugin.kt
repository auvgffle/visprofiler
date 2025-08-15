package com.example.visprofiler

import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.location.Criteria
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.telephony.CellInfo
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.CellInfoWcdma
import android.telephony.CellSignalStrengthGsm
import android.telephony.CellSignalStrengthLte
import android.telephony.CellSignalStrengthWcdma
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import androidx.core.location.LocationManagerCompat
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.TimeUnit
import kotlin.math.pow
import kotlin.math.sqrt

/** VisprofilerPlugin */
class VisprofilerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "visprofiler")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getAdId" -> {
        getAdId(result)
      }
      "getLocation" -> {
        getLocation(result)
      }
      "getNetworkInfo" -> {
        getComprehensiveNetworkInfo(result)
      }
      "getDeviceInfo" -> {
        getComprehensiveDeviceInfo(result)
      }
      "getPublicIp" -> {
        getPublicIp(result)
      }
      "requestLocationPermission" -> {
        requestLocationPermission(result)
      }
      "checkLocationPermission" -> {
        checkLocationPermission(result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun getAdId(result: Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(context)
        val adId = if (adInfo.isLimitAdTrackingEnabled) null else adInfo.id
        withContext(Dispatchers.Main) {
          result.success(adId)
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          result.success(null)
        }
      }
    }
  }

  private fun getLocation(result: Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        
        // Check if location services are enabled
        if (!LocationManagerCompat.isLocationEnabled(locationManager)) {
          withContext(Dispatchers.Main) {
            result.success(null)
          }
          return@launch
        }
        
        // Check permissions
        val hasCoarsePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val hasFinePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        
        if (!hasCoarsePermission && !hasFinePermission) {
          withContext(Dispatchers.Main) {
            result.success(null)
          }
          return@launch
        }
        
        // Get best available location
        val providers = locationManager.getProviders(true)
        var bestLocation: Location? = null
        var locationAge = Long.MAX_VALUE
        val maxLocationAge = 5 * 60 * 1000 // 5 minutes
        
        // Priority order: GPS, Network, Passive
        val priorityProviders = listOf(
          LocationManager.GPS_PROVIDER,
          LocationManager.NETWORK_PROVIDER,
          LocationManager.PASSIVE_PROVIDER
        ).filter { providers.contains(it) }
        
        for (provider in priorityProviders) {
          try {
            val location = locationManager.getLastKnownLocation(provider)
            if (location != null) {
              val age = System.currentTimeMillis() - location.time
              
              // Prefer fresher and more accurate locations
              if (bestLocation == null || 
                  (age < locationAge && age < maxLocationAge) ||
                  (age < maxLocationAge && location.accuracy < bestLocation.accuracy)) {
                bestLocation = location
                locationAge = age
              }
            }
          } catch (e: SecurityException) {
            // Continue to next provider
            continue
          }
        }
        
        // If no recent location, try to get a fresh one with timeout
        if (bestLocation == null || locationAge > maxLocationAge) {
          try {
            val freshLocation = withTimeoutOrNull(10000) { // 10 second timeout
              getLocationUpdate(locationManager, priorityProviders.firstOrNull() ?: LocationManager.NETWORK_PROVIDER)
            }
            if (freshLocation != null) {
              bestLocation = freshLocation
            }
          } catch (e: Exception) {
            // Use cached location if available
          }
        }
        
        withContext(Dispatchers.Main) {
          if (bestLocation != null) {
            val locationData = mapOf(
              "latitude" to bestLocation.latitude,
              "longitude" to bestLocation.longitude,
              "accuracy" to bestLocation.accuracy.toDouble(),
              "altitude" to bestLocation.altitude,
              "speed" to bestLocation.speed.toDouble(),
              "bearing" to bestLocation.bearing.toDouble(),
              "provider" to (bestLocation.provider ?: "unknown"),
              "timestamp" to bestLocation.time,
              "age_seconds" to ((System.currentTimeMillis() - bestLocation.time) / 1000)
            )
            result.success(locationData)
          } else {
            result.success(null)
          }
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          result.success(null)
        }
      }
    }
  }
  
  private suspend fun getLocationUpdate(locationManager: LocationManager, provider: String): Location? {
    return try {
      suspendCancellableCoroutine { continuation ->
        val listener = object : LocationListener {
          override fun onLocationChanged(location: Location) {
            locationManager.removeUpdates(this)
            continuation.resume(location)
          }
          
          @Deprecated("Deprecated in API level 29")
          override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
          
          override fun onProviderEnabled(provider: String) {}
          
          override fun onProviderDisabled(provider: String) {
            locationManager.removeUpdates(this)
            continuation.resume(null)
          }
        }
        
        // Set up cancellation handler
        continuation.invokeOnCancellation {
          locationManager.removeUpdates(listener)
        }
        
        try {
          locationManager.requestLocationUpdates(
            provider,
            0L,
            0f,
            listener,
            Looper.getMainLooper()
          )
          
          // Timeout handler
          Handler(Looper.getMainLooper()).postDelayed({
            locationManager.removeUpdates(listener)
            if (continuation.isActive) {
              continuation.resume(null)
            }
          }, 8000) // 8 second timeout
          
        } catch (e: SecurityException) {
          continuation.resume(null)
        }
      }
    } catch (e: Exception) {
      null
    }
  }

  private fun getComprehensiveNetworkInfo(result: Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val networkData = mutableMapOf<String, Any?>()
        
        // Basic connectivity info
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        
        val activeNetwork = connectivityManager.activeNetwork
        val networkCapabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
        
        // Network capabilities and bandwidth
        if (networkCapabilities != null) {
          networkData["upstreamBandwidth"] = networkCapabilities.linkUpstreamBandwidthKbps
          networkData["downstreamBandwidth"] = networkCapabilities.linkDownstreamBandwidthKbps
          networkData["isValidated"] = networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
          networkData["hasVpn"] = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
          networkData["hasLowPan"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_LOWPAN)
          } else false
          networkData["hasEthernet"] = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
          networkData["isMetered"] = !networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        }
        
        // Add connection status
        networkData["isConnected"] = activeNetwork != null && networkCapabilities != null
        
        // WiFi specific information
        if (networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true) {
          networkData["hasWifi"] = true
          networkData["isWifiEnabled"] = wifiManager.isWifiEnabled
          
          if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_WIFI_STATE) == PackageManager.PERMISSION_GRANTED) {
            try {
              val wifiInfo = wifiManager.connectionInfo
              networkData["ssid"] = wifiInfo.ssid
              networkData["bssid"] = wifiInfo.bssid ?: "unavailable_android_10+"
              networkData["rssi"] = wifiInfo.rssi
              networkData["linkSpeed"] = wifiInfo.linkSpeed
              networkData["frequency"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                wifiInfo.frequency
              } else 0
              networkData["networkId"] = wifiInfo.networkId
              networkData["signalLevel"] = WifiManager.calculateSignalLevel(wifiInfo.rssi, 5)
              networkData["macAddress"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                "unavailable_android_10+"
              } else {
                wifiInfo.macAddress ?: "unavailable"
              }
              
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                networkData["rxLinkSpeed"] = wifiInfo.rxLinkSpeedMbps
                networkData["txLinkSpeed"] = wifiInfo.txLinkSpeedMbps
              }
              
              // Calculate signal strength percentage
              val level = WifiManager.calculateSignalLevel(wifiInfo.rssi, 100)
              networkData["strength"] = level
            } catch (e: Exception) {
              networkData["wifiError"] = e.message
            }
          }
        } else {
          networkData["hasWifi"] = false
          networkData["isWifiEnabled"] = wifiManager.isWifiEnabled
        }
        
        // Cellular specific information
        if (networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true) {
          networkData["hasCellular"] = true
          
          try {
            networkData["networkOperatorName"] = telephonyManager.networkOperatorName
            networkData["networkOperator"] = telephonyManager.networkOperator
            networkData["simOperatorName"] = telephonyManager.simOperatorName
            networkData["simOperator"] = telephonyManager.simOperator
            networkData["simCountryIso"] = telephonyManager.simCountryIso
            networkData["networkCountryIso"] = telephonyManager.networkCountryIso
            networkData["isNetworkRoaming"] = telephonyManager.isNetworkRoaming
            networkData["simState"] = telephonyManager.simState
            
            // Extract MCC and MNC from operator codes
            val networkOperator = telephonyManager.networkOperator
            val simOperator = telephonyManager.simOperator
            
            if (networkOperator != null && networkOperator.length >= 5) {
              networkData["mobileCountryCode"] = networkOperator.substring(0, 3)
              networkData["mobileNetworkCode"] = networkOperator.substring(3)
            }
            
            if (simOperator != null && simOperator.length >= 5) {
              networkData["simMobileCountryCode"] = simOperator.substring(0, 3)
              networkData["simMobileNetworkCode"] = simOperator.substring(3)
            }
            
            // Get signal strength
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
              try {
                val cellInfoList = telephonyManager.allCellInfo
                var signalStrength = -1
                cellInfoList?.forEach { cellInfo ->
                  when (cellInfo) {
                    is CellInfoLte -> {
                      val strength = cellInfo.cellSignalStrength as CellSignalStrengthLte
                      signalStrength = strength.dbm
                    }
                    is CellInfoGsm -> {
                      val strength = cellInfo.cellSignalStrength as CellSignalStrengthGsm
                      signalStrength = strength.dbm
                    }
                    is CellInfoWcdma -> {
                      val strength = cellInfo.cellSignalStrength as CellSignalStrengthWcdma
                      signalStrength = strength.dbm
                    }
                  }
                }
                if (signalStrength != -1) {
                  networkData["cellularSignalStrength"] = signalStrength
                }
              } catch (e: Exception) {
                networkData["cellularError"] = "Location permission required for cellular info"
              }
            }
            
            // Network type
            try {
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                networkData["dataNetworkType"] = telephonyManager.dataNetworkType
              } else {
                @Suppress("DEPRECATION")
                networkData["networkType"] = telephonyManager.networkType
              }
            } catch (e: Exception) {
              networkData["telephonyError"] = "getDataNetworkTypeForSubscriber"
            }
            
          } catch (e: Exception) {
            networkData["cellularInfoError"] = e.message
          }
        } else {
          networkData["hasCellular"] = false
        }
        
        withContext(Dispatchers.Main) {
          result.success(networkData)
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          result.success(mapOf("error" to e.message))
        }
      }
    }
  }

  private fun getComprehensiveDeviceInfo(result: Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val deviceData = mutableMapOf<String, Any?>()
        
        // Basic device info
        deviceData["brand"] = Build.BRAND
        deviceData["model"] = Build.MODEL
        deviceData["manufacturer"] = Build.MANUFACTURER
        deviceData["device"] = Build.DEVICE
        deviceData["product"] = Build.PRODUCT
        deviceData["hardware"] = Build.HARDWARE
        deviceData["systemName"] = "Android"
        deviceData["systemVersion"] = Build.VERSION.RELEASE
        deviceData["sdkVersion"] = Build.VERSION.SDK_INT
        deviceData["buildNumber"] = Build.DISPLAY
        deviceData["fingerprint"] = Build.FINGERPRINT
        
        // Device identifiers
        try {
          deviceData["androidId"] = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
        } catch (e: Exception) {
          deviceData["androidIdError"] = e.message
        }
        
        // App info
        try {
          val packageManager = context.packageManager
          val packageInfo = packageManager.getPackageInfo(context.packageName, 0)
          deviceData["packageName"] = context.packageName
          deviceData["appVersion"] = packageInfo.versionName
          deviceData["buildNumber"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode.toString()
          } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toString()
          }
        } catch (e: Exception) {
          deviceData["appInfoError"] = e.message
        }
        
        // Memory info
        try {
          val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
          val memoryInfo = ActivityManager.MemoryInfo()
          activityManager.getMemoryInfo(memoryInfo)
          
          deviceData["totalMemory"] = memoryInfo.totalMem
          deviceData["availableMemory"] = memoryInfo.availMem
          deviceData["usedMemory"] = memoryInfo.totalMem - memoryInfo.availMem
          deviceData["lowMemory"] = memoryInfo.lowMemory
          deviceData["memoryThreshold"] = memoryInfo.threshold
        } catch (e: Exception) {
          deviceData["memoryError"] = e.message
        }
        
        // Screen and display info
        try {
          val displayMetrics = context.resources.displayMetrics
          deviceData["screenWidth"] = displayMetrics.widthPixels
          deviceData["screenHeight"] = displayMetrics.heightPixels
          deviceData["screenDensity"] = displayMetrics.density
          deviceData["densityDpi"] = displayMetrics.densityDpi
          
          // Determine if tablet (rough estimation)
          val screenInches = sqrt(
            (displayMetrics.widthPixels / displayMetrics.xdpi.toDouble()).pow(2.0) +
            (displayMetrics.heightPixels / displayMetrics.ydpi.toDouble()).pow(2.0)
          )
          deviceData["isTablet"] = screenInches >= 7.0
          deviceData["screenInches"] = screenInches
        } catch (e: Exception) {
          deviceData["displayError"] = e.message
          deviceData["isTablet"] = false
        }
        
        // Device type and form factor
        deviceData["deviceType"] = if (Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.startsWith("unknown") ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK") ||
            Build.MANUFACTURER.contains("Genymotion") ||
            (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
        ) "Emulator" else "Handset"
        
        // Additional device characteristics
        deviceData["hasNotch"] = false // This would require more complex detection
        deviceData["hasDynamicIsland"] = false // Android doesn't have dynamic island
        deviceData["isCharging"] = false // Placeholder - would need battery manager integration
        deviceData["isJailbroken"] = false // Android doesn't use this concept (rooted is separate)
        deviceData["timezone"] = java.util.TimeZone.getDefault().id
        
        withContext(Dispatchers.Main) {
          result.success(deviceData)
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          result.success(mapOf("error" to e.message))
        }
      }
    }
  }

  private fun getPublicIp(result: Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val publicIp = withTimeoutOrNull(10000) { // 10 second timeout
          val services = listOf(
            "https://api.ipify.org",
            "https://httpbin.org/ip",
            "https://icanhazip.com",
            "https://ifconfig.me/ip"
          )
          
          for (service in services) {
            try {
              val url = URL(service)
              val connection = url.openConnection() as HttpURLConnection
              connection.requestMethod = "GET"
              connection.connectTimeout = 5000
              connection.readTimeout = 5000
              connection.setRequestProperty("User-Agent", "VisProfiler-Android")
              
              if (connection.responseCode == 200) {
                val reader = BufferedReader(InputStreamReader(connection.inputStream))
                val response = reader.readText().trim()
                reader.close()
                connection.disconnect()
                
                // Parse response based on service
                return@withTimeoutOrNull when {
                  service.contains("httpbin") -> {
                    // Parse JSON response from httpbin
                    val start = response.indexOf('"') + 1
                    val end = response.lastIndexOf('"')
                    if (start < end) response.substring(start, end) else response
                  }
                  else -> response
                }
              }
            } catch (e: Exception) {
              continue // Try next service
            }
          }
          null
        }
        
        withContext(Dispatchers.Main) {
          result.success(publicIp)
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          result.success(null)
        }
      }
    }
  }


  private fun checkLocationPermission(result: Result) {
    val hasCoarsePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
    val hasFinePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    val isLocationEnabled = LocationManagerCompat.isLocationEnabled(locationManager)
    
    val status = when {
      hasFinePermission -> "granted_precise"
      hasCoarsePermission -> "granted_approximate"
      else -> "denied"
    }
    
    val permissionInfo = mapOf(
      "status" to status,
      "hasAlwaysPermission" to hasFinePermission, // Android doesn't distinguish always vs when-in-use like iOS
      "hasWhenInUsePermission" to (hasCoarsePermission || hasFinePermission),
      "hasPrecisePermission" to hasFinePermission,
      "hasApproximatePermission" to hasCoarsePermission,
      "locationServicesEnabled" to isLocationEnabled
    )
    
    result.success(permissionInfo)
  }
  
  private fun requestLocationPermission(result: Result) {
    // Android permission requests need to be handled by the Activity, not the plugin
    // This method returns the current status and a message about needing Activity-level permission handling
    val hasCoarsePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
    val hasFinePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    val isLocationEnabled = LocationManagerCompat.isLocationEnabled(locationManager)
    
    val status = when {
      hasFinePermission -> "granted_precise"
      hasCoarsePermission -> "granted_approximate"
      else -> "denied"
    }
    
    val permissionInfo = mapOf(
      "status" to status,
      "hasAlwaysPermission" to hasFinePermission,
      "hasWhenInUsePermission" to (hasCoarsePermission || hasFinePermission),
      "hasPrecisePermission" to hasFinePermission,
      "hasApproximatePermission" to hasCoarsePermission,
      "locationServicesEnabled" to isLocationEnabled,
      "canRequestPermission" to !hasFinePermission,
      "message" to if (hasFinePermission || hasCoarsePermission) {
        "Location permission already granted"
      } else {
        "Location permission needed. Use permission_handler plugin or Activity-level permission requests."
      }
    )
    
    result.success(permissionInfo)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
