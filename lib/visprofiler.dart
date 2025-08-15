import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'visprofiler_platform_interface.dart';
import 'visprofiler_logger.dart';
import 'visprofiler_models.dart';
import 'visprofiler_options.dart';
import 'visprofiler_permission_handler.dart';

// Export public API
export 'visprofiler_platform_interface.dart';
export 'visprofiler_method_channel.dart';
export 'visprofiler_models.dart';
export 'visprofiler_options.dart';
export 'visprofiler_permission_handler.dart';
export 'visprofiler_logger.dart';

// Platform-specific network services are for internal use only

class Visprofiler {
  static const String _internalBaseUrl = "https://sdk.intelvis.org";
  
  String? _appId;
  Map<String, dynamic>? _contact;
  VisProfilerOptions? _options;
  String? _token;
  int _tokenExpiry = 0;
  
  DeviceDataCache? _deviceInfoCache;
  NetworkDataCache? _networkInfoCache;
  int _cacheExpiry = 0;
  
  Timer? _sendDataTimer;
  bool _initialized = false;
  
  late final VisProfilerLogger _logger;
  final VisProfilerPermissionHandler _permissionHandler = VisProfilerPermissionHandler();
  
  // Singleton instance
  static final Visprofiler _instance = Visprofiler._internal();
  Visprofiler._internal() {
    _logger = VisProfilerLogger();
  }
  
  static Visprofiler get instance => _instance;
  
  /// Initialize the SDK with app ID, contact information, and options
  bool init(
    String appId, 
    Map<String, dynamic>? contact, {
    VisProfilerOptions options = const VisProfilerOptions(),
  }) {
    return _safeExecute(() {
      if (!options.enableLogging) {
        // Create a dummy logger if logging is disabled
        _logger = VisProfilerLogger();
      }
      
      _logger.logInfo('Init', 'Starting SDK initialization...');
      
      if (appId.isEmpty) {
        _logger.logError('Init', 'App ID is required for initialization');
        return false;
      }
      
      if (_initialized) {
        _logger.logWarning('Init', 'SDK already initialized, reinitializing...');
        _cleanup();
      }
      
      _appId = appId;
      _contact = (contact != null && contact.isNotEmpty) ? contact : null;
      _options = options;
      _initialized = true;
      
      _logger.logInfo('Init', 'SDK initialized with options: ${options.toMap()}');
      _logger.logInfo('Init', 'Contact info: $_contact');
      
      // Request permissions if location is enabled
      if (_options!.enableLocation) {
        _safeExecuteAsync(() async {
          _logger.logInfo('Init', 'Requesting location permissions...');
          final status = await _permissionHandler.requestLocationPermission();
          if (status.isGranted) {
            _logger.logSuccess('Init', 'Location permissions granted');
          } else {
            _logger.logWarning('Init', 'Location permissions denied - location data will be null');
          }
        }, null, 'PermissionRequest');
      }
      
      // Set up periodic data sending if enabled
      if (_options!.enablePeriodicSending) {
        _startPeriodicDataSending();
      }
      
      // Initial data send with delay to allow permissions to be processed
      _safeExecuteAsync(() async {
        // Small delay to allow permissions to be processed
        await Future.delayed(Duration(milliseconds: 1000));
        final result = await sendData();
        if (result.success) {
          _logger.logSuccess('Init', 'Initial data send completed successfully');
        } else {
          _logger.logWarning('Init', 'Initial data send failed but continuing initialization');
        }
      }, SendDataResult(success: false, error: {'message': 'Initial data send failed'}, attempts: 0), 'InitialDataSend');
      
      _logger.logSuccess('Init', 'SDK initialization completed successfully');
      return true;
    }, false, 'SDKInitialization');
  }
  
  /// Start periodic data sending
  void _startPeriodicDataSending() {
    _sendDataTimer?.cancel();
    
    _sendDataTimer = Timer.periodic(
      Duration(milliseconds: _options!.sendIntervalMs),
      (timer) async {
        final result = await _safeExecuteAsync(() async {
          return await sendData();
        }, SendDataResult(success: false, error: {'message': 'Scheduled send failed'}, attempts: 0), 'ScheduledDataSend');
        
        if (result.success) {
          _logger.logScheduler('Schedule', 'Scheduled sendData executed successfully');
        } else {
          _logger.logError('Schedule', 'Scheduled sendData failed: ${result.error?['message'] ?? 'Unknown error'}');
        }
      },
    );
    
    _logger.logScheduler('Init', 'Scheduled sendData to run every ${_options!.sendIntervalMs}ms');
  }
  
  /// Send data to the server
  Future<SendDataResult> sendData([Map<String, dynamic> extraPayload = const {}]) async {
    return _safeExecuteAsync(() async {
      _logger.logInfo('SendData', 'Starting data transmission...');
      final startTime = DateTime.now();
      
      if (!_initialized || _appId == null) {
        throw Exception("SDK not initialized. Call init(appId, contact, options) first");
      }
      
      // Build the payload based on options
      final payload = await _buildPayload(extraPayload);
      final collectionTime = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logPerformance('SendData', 'Data collected in ${collectionTime}ms');
      
      // Get authentication token
      final deviceId = payload['deviceId'] as String;
      final authToken = await _getToken(deviceId);
      if (authToken == null) {
        _logger.logWarning('SendData', 'Failed to get authentication token, data will not be sent');
        return SendDataResult(
          success: false,
          error: {'message': "Failed to get authentication token", 'timestamp': DateTime.now().toIso8601String()},
          retryable: true,
          attempts: 0,
        );
      }
      
      // Add API key to payload
      payload['apiKey'] = authToken;
      
      // Convert payload for transmission
      final Map<String, dynamic> fullPayload = _deepConvertToJson(payload);
      
      // Log payload summary for debugging (if logging enabled)
      if (_options!.enableLogging) {
        _logger.logInfo('SendData', 'Payload Summary:');
        _logger.logInfo('SendData', '- Device ID: ${fullPayload['deviceId']}');
        _logger.logInfo('SendData', '- Platform: ${fullPayload['payload']?['platform']}');
        _logger.logInfo('SendData', '- Brand/Model: ${fullPayload['payload']?['brand']}/${fullPayload['payload']?['model']}');
        _logger.logInfo('SendData', '- Network Available: ${fullPayload['payload']?['network'] != null}');
        _logger.logInfo('SendData', '- Location Available: ${fullPayload['payload']?['location'] != null}');
      }
      
      // Send data with retries
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final url = '$_internalBaseUrl/events';
          
          _logger.logInfo('SendData', 'Sending payload to server (attempt $attempt)...');
          _logger.logApiCall('SendData', 'POST', url, 'Device: $deviceId, Platform: ${Platform.isAndroid ? 'android' : 'ios'}, Attempt: $attempt');
          
          // Use fullPayload for encoding to ensure all objects are properly serialized
          String jsonBody;
          try {
            jsonBody = jsonEncode(fullPayload);
          } catch (e) {
            _logger.logError('SendData', 'JSON encoding failed, attempting fallback: $e');
            // Create a simplified payload if encoding fails
            final fallbackPayload = {
              'deviceId': deviceId,
              'apiKey': authToken,
              'timestamp': DateTime.now().toIso8601String(),
              'platform': Platform.isAndroid ? 'android' : 'ios',
              'error': 'Payload serialization failed',
              'errorDetails': e.toString(),
            };
            jsonBody = jsonEncode(fallbackPayload);
          }
          
          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: jsonBody,
          ).timeout(Duration(seconds: 30));
          
          final totalTime = DateTime.now().difference(startTime).inMilliseconds;
          _logger.logApiResponse('SendData', response.statusCode, totalTime);
          
          if (response.statusCode < 200 || response.statusCode >= 300) {
            if (response.statusCode == 500 && attempt < 3) {
              _logger.logWarning('SendData', 'Server error (500) on attempt $attempt/3, retrying...');
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
            throw Exception('Failed to send data: ${response.statusCode}');
          }
          
          final responseData = jsonDecode(response.body);
          _logger.logSuccess('SendData', 'Data sent successfully in ${totalTime}ms');
          _logger.logInfo('SendData', 'Response received: $responseData');
          
          return SendDataResult(
            success: true,
            response: responseData,
            duration: totalTime,
            attempts: attempt,
          );
        } catch (error) {
          final totalTime = DateTime.now().difference(startTime).inMilliseconds;
          _logger.logError('SendData', 'Data transmission failed on attempt $attempt: ${error.toString()} (${totalTime}ms)');
          
          if (attempt == 3) {
            return SendDataResult(
              success: false,
              error: {
                'message': error.toString(),
                'timestamp': DateTime.now().toIso8601String(),
              },
              retryable: !error.toString().contains("not initialized"),
              attempts: attempt,
            );
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      // This should never be reached
      throw Exception('Unexpected error in sendData');
    }, SendDataResult(
      success: false,
      error: {
        'message': 'Unknown error',
        'timestamp': DateTime.now().toIso8601String(),
      },
      retryable: false,
      attempts: 1,
    ), 'DataTransmission');
  }
  
  /// Build payload based on options
  Future<Map<String, dynamic>> _buildPayload(Map<String, dynamic> extraPayload) async {
    final deviceInfo = await _getDeviceInfo();
    final deviceId = deviceInfo['deviceId'] as String;
    
    // Build network payload with platform detection
    NetworkPayload? networkPayload;
    if (_options!.enableNetworkInfo) {
      final networkInfo = await _getOptimizedNetworkInfo();
      if (networkInfo != null) {
        // Use platform detection to choose the proper network key
        if (Platform.isAndroid) {
          final androidNetworkData = networkInfo['android_network_info'] as Map<String, dynamic>? ?? {};
          networkPayload = NetworkPayload(
            androidNetworkInfo: AndroidNetworkInfo.fromJson(androidNetworkData),
            publicIpAddress: androidNetworkData['publicIp'],
            isConnected: true,
            timestamp: DateTime.now().toIso8601String(),
          );
        } else {
          final iosNetworkData = networkInfo['ios_network_info'] as Map<String, dynamic>? ?? {};
          networkPayload = NetworkPayload(
            iosNetworkInfo: IosNetworkInfo.fromJson(iosNetworkData),
            publicIpAddress: iosNetworkData['publicIp'],
            isConnected: true,
            timestamp: DateTime.now().toIso8601String(),
          );
        }
      }
    }
    
    // Build location payload
    LocationPayload? locationPayload;
    if (_options!.enableLocation) {
      final location = await _getLocationFast();
      if (location != null) {
        locationPayload = LocationPayload(
          latitude: location.latitude,
          longitude: location.longitude,
          accuracy: location.accuracy,
          altitude: location.altitude,
          speed: location.speed,
          bearing: location.bearing,
          provider: location.provider,
          timestamp: DateTime.now().toIso8601String(),
        );
      } else {
        // Create location payload with null values
        locationPayload = LocationPayload(
          latitude: null,
          longitude: null,
          accuracy: null,
          altitude: null,
          speed: null,
          bearing: null,
          provider: null,
          timestamp: DateTime.now().toIso8601String(),
        );
      }
    }
    
    // Get advertising ID
    String? adId;
    if (_options!.enableAdId) {
      adId = await _getAdIdFast();
    }
    
    // Build inner payload data with flat device fields at root
    final payloadData = PayloadData(
      // Device fields at root level
      deviceId: deviceId,
      brand: deviceInfo['brand'],
      model: deviceInfo['model'],
      systemName: deviceInfo['systemName'],
      systemVersion: deviceInfo['systemVersion'],
      appVersion: deviceInfo['appVersion'],
      buildNumber: deviceInfo['buildNumber'],
      packageName: deviceInfo['packageName'],
      manufacturer: deviceInfo['manufacturer'],
      deviceName: deviceInfo['deviceName'],
      deviceType: deviceInfo['deviceType'],
      totalMemory: deviceInfo['totalMemory'] != null 
          ? MongoLong.fromInt(deviceInfo['totalMemory'] as int) 
          : null,
      usedMemory: deviceInfo['usedMemory'] != null 
          ? MongoLong.fromInt(deviceInfo['usedMemory'] as int) 
          : null,
      isTablet: deviceInfo['isTablet'] ?? false,
      adId: adId,
      androidId: deviceInfo['androidId'],
      idfv: deviceInfo['identifierForVendor'],
      platform: Platform.isAndroid ? 'android' : 'ios',
      osVersion: deviceInfo['systemVersion'],
      screenResolution: deviceInfo['screenResolution'],
      timezone: DateTime.now().timeZoneName,
      locale: deviceInfo['locale'],
      batteryLevel: deviceInfo['batteryLevel'],
      isCharging: deviceInfo['isCharging'] ?? false,
      isJailbroken: deviceInfo['isJailbroken'] ?? false,
      isRooted: deviceInfo['isRooted'] ?? false,
      hasNotch: deviceInfo['hasNotch'] ?? false,
      hasDynamicIsland: deviceInfo['hasDynamicIsland'] ?? false,
      timestamp: DateTime.now().toIso8601String(),
      
      // Nested structures
      network: networkPayload,
      location: locationPayload,
      
      // Contact info fields (flattened)
      email: _contact?['email'],
      name: _contact?['name'],
      phone: _contact?['phone'],
    );
    
    // Create root payload with wrapper layers
    final rootPayload = VisProfilerPayload(
      deviceId: deviceId,
      // apiKey will be added later in sendData method
      payload: payloadData,
    );
    
    // Convert to JSON and add extra payload to the inner payload data
    final payloadJson = rootPayload.toJson();
    if (extraPayload.isNotEmpty && payloadJson['payload'] is Map<String, dynamic>) {
      final innerPayload = payloadJson['payload'] as Map<String, dynamic>;
      innerPayload.addAll(extraPayload);
    }
    
    return payloadJson;
  }
  
  /// Get comprehensive device information using native implementations
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    if (!_options!.enableDeviceInfo) {
      return {
        'deviceId': 'minimal_${Platform.isAndroid ? 'android' : 'ios'}_${DateTime.now().millisecondsSinceEpoch}',
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'sdk_platform': 'flutter',
      };
    }
    
    return _safeExecuteAsync(() async {
      _logger.logInfo('Device', 'Collecting comprehensive device information...');
      
      // Check cache first
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_options!.enableCaching && _deviceInfoCache != null && now < _deviceInfoCache!.expiry) {
        _logger.logCaching('Device', 'Using cached device info');
        final cachedData = _deviceInfoCache!.data.toJson();
        cachedData['sdk_platform'] = 'flutter';
        return cachedData;
      }
      
      // Get comprehensive device info from native implementations
      Map<String, dynamic> nativeDeviceInfo = {};
      try {
        nativeDeviceInfo = await VisprofilerPlatform.instance.getDeviceInfo() ?? {};
      } catch (error) {
        _logger.logWarning('Device', 'Native device info failed, using fallback: $error');
      }
      
      // Fallback device ID generation - prioritize androidId on Android
      String deviceId;
      if (Platform.isAndroid) {
        deviceId = nativeDeviceInfo['androidId'] ??
            nativeDeviceInfo['deviceId'] ??
            'fallback_android_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
      } else {
        deviceId = nativeDeviceInfo['identifierForVendor'] ??
            nativeDeviceInfo['deviceId'] ??
            'fallback_ios_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
      }
      
      // Build comprehensive device info
      final info = <String, dynamic>{
        'deviceId': deviceId,
        'sdk_platform': 'flutter',
        ...nativeDeviceInfo,
      };
      
      // Ensure androidId is properly included for Android devices
      if (Platform.isAndroid && nativeDeviceInfo.containsKey('androidId')) {
        info['androidId'] = nativeDeviceInfo['androidId'];
      }
      
      // Ensure required fields are present with fallbacks
      info['platform'] = Platform.isAndroid ? 'android' : 'ios';
      info['systemName'] ??= Platform.isAndroid ? 'Android' : 'iOS';
      info['brand'] ??= Platform.isAndroid ? 'Unknown Android' : 'Apple';
      info['manufacturer'] ??= Platform.isAndroid ? 'Unknown' : 'Apple';
      info['deviceType'] ??= 'Handset';
      info['isTablet'] ??= false;
      info['hasNotch'] ??= false;
      info['hasDynamicIsland'] ??= false;
      info['timezone'] ??= DateTime.now().timeZoneName;
      
      // Add collection errors array
      final collectionErrors = <String>[];
      if (info.containsKey('error')) {
        collectionErrors.add('device_info: ${info['error']}');
      }
      info['collectionErrors'] = collectionErrors;
      
      // Cache the result if caching is enabled
      if (_options!.enableCaching) {
        final deviceData = DeviceData(
          deviceId: deviceId,
          brand: info['brand'],
          model: info['model'],
          systemName: info['systemName'],
          systemVersion: info['systemVersion'],
          manufacturer: info['manufacturer'],
          deviceName: info['deviceName'],
          deviceType: info['deviceType'],
          isTablet: info['isTablet'],
          appVersion: info['appVersion'],
          buildNumber: info['buildNumber'],
          packageName: info['packageName'],
          platform: info['platform'],
          timestamp: DateTime.now().toIso8601String(),
        );
        
        _deviceInfoCache = DeviceDataCache(
          data: deviceData,
          expiry: now + 300000, // 5 minutes
        );
        _logger.logCaching('Device', 'Comprehensive device info cached for 5 minutes');
      }
      
      _logger.logSuccess('Device', 'Comprehensive device info collected successfully');
      return info;
    }, {
      'deviceId': 'error_${Platform.isAndroid ? 'android' : 'ios'}_${DateTime.now().millisecondsSinceEpoch}',
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'sdk_platform': 'flutter',
      'error': 'Failed to collect device info',
      'collectionErrors': ['device_info: Native collection failed'],
    }, 'DeviceInfo');
  }
  
  /// Get advertising ID if enabled using native implementation
  Future<String?> _getAdIdFast() async {
    if (!_options!.enableAdId) {
      return null;
    }
    
    return _safeExecuteAsync(() async {
      _logger.logInfo('AdId', 'Starting native AdId retrieval...');
      try {
        final adId = await VisprofilerPlatform.instance.getAdId();
        if (adId != null && adId.isNotEmpty) {
          _logger.logSuccess('AdId', 'Native AdId retrieved successfully');
          return adId;
        } else {
          _logger.logWarning('AdId', 'Native AdId retrieval returned null');
          return null;
        }
      } catch (error) {
        _logger.logWarning('AdId', 'Native AdId service not available: $error');
        return null;
      }
    }, null, 'NativeAdIdRetrieval');
  }
  
  /// Get location using native implementation
  Future<LocationData?> _getLocationFast() async {
    if (!_options!.enableLocation) {
      return null;
    }
    
    return _safeExecuteAsync(() async {
      _logger.logLocation('GetLocation', 'Starting native location retrieval...');
      
      try {
        final locationMap = await VisprofilerPlatform.instance.getLocation();
        if (locationMap != null) {
          final location = LocationData(
            latitude: locationMap['latitude']?.toDouble() ?? 0.0,
            longitude: locationMap['longitude']?.toDouble() ?? 0.0,
            accuracy: locationMap['accuracy']?.toDouble(),
            altitude: locationMap['altitude']?.toDouble(),
            speed: locationMap['speed']?.toDouble(),
            bearing: locationMap['bearing']?.toDouble(),
            provider: locationMap['provider'],
          );
          
          _logger.logSuccess('GetLocation', 'Native location retrieved successfully');
          return location;
        } else {
          _logger.logWarning('GetLocation', 'Native location returned null (permissions/services disabled)');
          return null;
        }
      } catch (error) {
        _logger.logWarning('GetLocation', 'Native location retrieval failed: $error');
        return null;
      }
    }, null, 'NativeLocationRetrieval');
  }
  
  /// Get comprehensive network information using native implementation
  Future<Map<String, dynamic>?> _getOptimizedNetworkInfo() async {
    if (!_options!.enableNetworkInfo) {
      return null;
    }
    
    return _safeExecuteAsync(() async {
      _logger.logNetwork('Network', 'Fetching comprehensive native network info...');
      
      // Check cache
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_options!.enableCaching && _networkInfoCache != null && now < _cacheExpiry) {
        _logger.logCaching('Network', 'Using cached comprehensive network info');
        return _networkInfoCache!.data;
      }
      
      // Get comprehensive network data from native and combine with public IP
      final futures = await Future.wait([
        VisprofilerPlatform.instance.getNetworkInfo(),
        if (_options!.enablePublicIp) VisprofilerPlatform.instance.getPublicIp() else Future.value(null),
      ]);
      
      final nativeNetworkInfo = futures[0] as Map<String, dynamic>?;
      final publicIp = futures[1] as String?;
      
      // Build comprehensive network data
      final networkData = nativeNetworkInfo ?? <String, dynamic>{};
      
      // Add public IP to network data
      if (_options!.enablePublicIp && publicIp != null) {
        networkData['publicIp'] = publicIp;
      }
      
      final result = {
        Platform.isAndroid ? 'android_network_info' : 'ios_network_info': networkData
      };
      
      // Cache the result
      if (_options!.enableCaching) {
        _networkInfoCache = NetworkDataCache(data: result);
        _cacheExpiry = now + 30000; // 30 seconds
        _logger.logCaching('Network', 'Comprehensive network info cached for 30 seconds');
      }
      
      _logger.logSuccess('Network', 'Comprehensive native network info retrieved successfully');
      return result;
    }, <String, dynamic>{}, 'ComprehensiveNetworkInfo');
  }
  
  /// Request location permission for better location accuracy
  Future<PermissionStatus> requestLocationPermission() async {
    return await _permissionHandler.requestLocationPermission();
  }
  
  /// Check current location permission status
  Future<Map<String, PermissionStatus>> checkPermissionStatus() async {
    return await _permissionHandler.checkPermissionStatus();
  }
  
  
  /// Get authentication token
  Future<String?> _getToken(String deviceId) async {
    return _safeExecuteAsync(() async {
      _logger.logInfo('Token', 'Starting token retrieval...');
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      if (_token != null && now < _tokenExpiry - 30) {
        _logger.logInfo('Token', 'Using cached token');
        return _token;
      }
      
      _logger.logInfo('Token', 'Fetching fresh token...');
      
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final url = '$_internalBaseUrl/get-token';
          final payload = {'appId': _appId, 'deviceId': deviceId};
          
          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          ).timeout(Duration(seconds: 30));
          
          if (response.statusCode != 200) {
            if (response.statusCode == 500 && attempt < 3) {
              _logger.logWarning('Token', 'Server error (500) on attempt $attempt/3, retrying...');
              await Future.delayed(Duration(seconds: 3));
              continue;
            }
            throw Exception('Failed to get token: ${response.statusCode}');
          }
          
          final data = jsonDecode(response.body);
          _token = data['token'];
          _tokenExpiry = data['expiry'] ?? (now + 3600);
          _logger.logSuccess('Token', 'Token retrieved successfully');
          return _token;
        } catch (error) {
          _logger.logError('Token', 'Token retrieval failed on attempt $attempt: $error');
          if (attempt == 3) {
            return null;
          }
          await Future.delayed(Duration(seconds: 3));
        }
      }
      
      return null;
    }, null, 'TokenRetrieval');
  }
  
  /// Stop sending data
  bool stopSendingData() {
    return _safeExecute(() {
      _logger.logInfo('Stop', 'Stopping data transmission...');
      if (_sendDataTimer != null) {
        _sendDataTimer!.cancel();
        _sendDataTimer = null;
        _logger.logSuccess('Stop', 'Scheduled data sending stopped successfully');
        return true;
      } else {
        _logger.logInfo('Stop', 'No active data sending to stop');
        return false;
      }
    }, false, 'StopDataSending');
  }
  
  /// Update options at runtime
  void updateOptions(VisProfilerOptions newOptions) {
    _safeExecute(() {
      _logger.logInfo('Options', 'Updating SDK options...');
      final oldOptions = _options;
      _options = newOptions;
      
      // Restart periodic sending if interval changed or enabled/disabled
      if (oldOptions?.enablePeriodicSending != newOptions.enablePeriodicSending ||
          oldOptions?.sendIntervalMs != newOptions.sendIntervalMs) {
        _sendDataTimer?.cancel();
        if (newOptions.enablePeriodicSending) {
          _startPeriodicDataSending();
        }
      }
      
      // Clear caches if caching was disabled
      if (!newOptions.enableCaching) {
        _deviceInfoCache = null;
        _networkInfoCache = null;
        _logger.logInfo('Options', 'Caches cleared due to caching being disabled');
      }
      
      _logger.logSuccess('Options', 'SDK options updated successfully');
    }, null, 'UpdateOptions');
  }
  
  /// Get current options
  VisProfilerOptions? get options => _options;
  
  /// Check if SDK is initialized
  bool get isInitialized => _initialized;
  
  /// Get current app ID
  String? get appId => _appId;
  
  /// Test native module functionality
  Future<Map<String, dynamic>> testNativeModule() async {
    return _safeExecuteAsync(() async {
      _logger.logInfo('Test', '=== Starting Module Test ===');
      final results = <String, dynamic>{};
      
      // Test device info
      try {
        final deviceInfo = await _getDeviceInfo();
        results['DeviceInfo'] = {'success': true, 'result': deviceInfo};
      } catch (error) {
        results['DeviceInfo'] = {'success': false, 'error': error.toString()};
      }
      
      // Test AdId if enabled
      if (_options?.enableAdId == true) {
        try {
          final adId = await _getAdIdFast();
          results['AdId'] = {'success': true, 'result': adId};
        } catch (error) {
          results['AdId'] = {'success': false, 'error': error.toString()};
        }
      }
      
      // Test Location if enabled
      if (_options?.enableLocation == true) {
        try {
          final location = await _getLocationFast();
          results['Location'] = {'success': true, 'result': location?.toJson()};
        } catch (error) {
          results['Location'] = {'success': false, 'error': error.toString()};
        }
      }
      
      // Test Network if enabled
      if (_options?.enableNetworkInfo == true) {
        try {
          final network = await _getOptimizedNetworkInfo();
          results['NetworkInfo'] = {'success': true, 'result': network};
        } catch (error) {
          results['NetworkInfo'] = {'success': false, 'error': error.toString()};
        }
      }
      
      _logger.logInfo('Test', '=== Module Test Complete ===');
      return results;
    }, <String, dynamic>{}, 'ModuleTest');
  }
  
  /// SDK health check
  Future<Map<String, dynamic>> healthCheck() async {
    return _safeExecuteAsync(() async {
      _logger.logInfo('Health', 'Starting SDK health check...');
      final health = {
        'timestamp': DateTime.now().toIso8601String(),
        'sdk': {
          'initialized': _initialized,
          'appId': _appId,
          'contact': _contact,
          'options': _options?.toMap(),
          'hasActiveInterval': _sendDataTimer?.isActive ?? false,
        },
        'cache': {
          'deviceInfoCached': _deviceInfoCache != null,
          'networkInfoCached': _networkInfoCache != null,
          'tokenCached': _token != null,
          'tokenExpiry': _tokenExpiry > 0 ? DateTime.fromMillisecondsSinceEpoch(_tokenExpiry * 1000).toIso8601String() : null,
        },
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };
      _logger.logInfo('Health', 'Health check completed');
      return health;
    }, {
      'error': "Health check failed",
      'timestamp': DateTime.now().toIso8601String()
    }, 'HealthCheck');
  }
  
  /// Cleanup resources
  void _cleanup() {
    _sendDataTimer?.cancel();
    _sendDataTimer = null;
    _deviceInfoCache = null;
    _networkInfoCache = null;
    _token = null;
    _tokenExpiry = 0;
  }
  
  /// Dispose the SDK
  void dispose() {
    _safeExecute(() {
      _logger.logInfo('Dispose', 'Disposing SDK...');
      _cleanup();
      _initialized = false;
      _logger.logSuccess('Dispose', 'SDK disposed successfully');
    }, null, 'Dispose');
  }
  
  // Utility methods
  T _safeExecute<T>(T Function() operation, T fallback, String context) {
    try {
      return operation();
    } catch (error) {
      if (_options?.enableLogging != false) {
        _logger.logError(context, 'Operation failed: $error');
      }
      return fallback;
    }
  }
  
  Future<T> _safeExecuteAsync<T>(Future<T> Function() operation, T fallback, String context) async {
    try {
      return await operation();
    } catch (error) {
      if (_options?.enableLogging != false) {
        _logger.logError(context, 'Async operation failed: $error');
      }
      return fallback;
    }
  }
  
  /// Deep convert all nested objects to JSON-serializable format
  dynamic _deepConvertToJson(dynamic obj) {
    try {
      if (obj == null) {
        return null;
      } else if (obj is String || obj is num || obj is bool) {
        // Return primitive types as-is
        return obj;
      } else if (obj is Map) {
        final result = <String, dynamic>{};
        obj.forEach((key, value) {
          try {
            result[key.toString()] = _deepConvertToJson(value);
          } catch (e) {
            // If conversion fails, convert to string representation
            result[key.toString()] = value?.toString();
          }
        });
        return result;
      } else if (obj is List) {
        return obj.map((item) {
          try {
            return _deepConvertToJson(item);
          } catch (e) {
            // If conversion fails, convert to string representation
            return item?.toString();
          }
        }).toList();
      } else if (obj is PayloadData) {
        return _safeToJson(() => obj.toJson());
      } else if (obj is NetworkPayload) {
        return _safeToJson(() => obj.toJson());
      } else if (obj is LocationPayload) {
        return _safeToJson(() => obj.toJson());
      } else if (obj is AndroidNetworkInfo) {
        return _safeToJson(() => obj.toJson());
      } else if (obj is IosNetworkInfo) {
        return _safeToJson(() => obj.toJson());
      } else if (obj is MongoLong) {
        return _safeToJson(() => obj.toJson());
      } else {
        // For any other object type, try to convert to string
        return obj.toString();
      }
    } catch (e) {
      _logger.logWarning('DeepConvert', 'Failed to convert object to JSON: $e');
      return obj?.toString() ?? 'null';
    }
  }
  
  /// Safely convert an object to JSON, with fallback for errors
  Map<String, dynamic> _safeToJson(Map<String, dynamic> Function() toJsonFunc) {
    try {
      final result = toJsonFunc();
      return _deepConvertToJson(result) as Map<String, dynamic>;
    } catch (e) {
      _logger.logWarning('SafeToJson', 'Failed to convert to JSON: $e');
      return {
        'error': 'JSON conversion failed',
        'message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  
  // Legacy method for compatibility
  Future<String?> getPlatformVersion() {
    return VisprofilerPlatform.instance.getPlatformVersion();
  }
}
