import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'visprofiler_platform_interface.dart';

/// An implementation of [VisprofilerPlatform] that uses method channels.
class MethodChannelVisprofiler extends VisprofilerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('visprofiler');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  
  @override
  Future<String?> getAdId() async {
    final adId = await methodChannel.invokeMethod<String>('getAdId');
    return adId;
  }
  
  @override
  Future<Map<String, dynamic>?> getLocation() async {
    final result = await methodChannel.invokeMethod('getLocation');
    if (result == null) return null;
    return Map<String, dynamic>.from(result as Map);
  }
  
  @override
  Future<Map<String, dynamic>?> getNetworkInfo() async {
    final result = await methodChannel.invokeMethod('getNetworkInfo');
    if (result == null) return null;
    return Map<String, dynamic>.from(result as Map);
  }
  
  @override
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    final result = await methodChannel.invokeMethod('getDeviceInfo');
    if (result == null) return null;
    return Map<String, dynamic>.from(result as Map);
  }
  
  @override
  Future<String?> getPublicIp() async {
    final publicIp = await methodChannel.invokeMethod<String>('getPublicIp');
    return publicIp;
  }
  
  /// Check current location permission status
  @override
  Future<Map<String, dynamic>?> checkLocationPermission() async {
    final result = await methodChannel.invokeMethod('checkLocationPermission');
    if (result == null) return null;
    return Map<String, dynamic>.from(result as Map);
  }
  
  /// Request location permission (iOS will show system dialog)
  @override
  Future<Map<String, dynamic>?> requestLocationPermission() async {
    final result = await methodChannel.invokeMethod('requestLocationPermission');
    if (result == null) return null;
    return Map<String, dynamic>.from(result as Map);
  }
}
