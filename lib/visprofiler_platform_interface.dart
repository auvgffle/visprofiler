import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'visprofiler_method_channel.dart';

abstract class VisprofilerPlatform extends PlatformInterface {
  /// Constructs a VisprofilerPlatform.
  VisprofilerPlatform() : super(token: _token);

  static final Object _token = Object();

  static VisprofilerPlatform _instance = MethodChannelVisprofiler();

  /// The default instance of [VisprofilerPlatform] to use.
  ///
  /// Defaults to [MethodChannelVisprofiler].
  static VisprofilerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VisprofilerPlatform] when
  /// they register themselves.
  static set instance(VisprofilerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
  Future<String?> getAdId() {
    throw UnimplementedError('getAdId() has not been implemented.');
  }
  
  Future<Map<String, dynamic>?> getLocation() {
    throw UnimplementedError('getLocation() has not been implemented.');
  }
  
  Future<Map<String, dynamic>?> getNetworkInfo() {
    throw UnimplementedError('getNetworkInfo() has not been implemented.');
  }
  
  Future<Map<String, dynamic>?> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }
  
  Future<String?> getPublicIp() {
    throw UnimplementedError('getPublicIp() has not been implemented.');
  }
  
  Future<Map<String, dynamic>?> checkLocationPermission() {
    throw UnimplementedError('checkLocationPermission() has not been implemented.');
  }
  
  Future<Map<String, dynamic>?> requestLocationPermission() {
    throw UnimplementedError('requestLocationPermission() has not been implemented.');
  }
}
