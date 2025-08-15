import 'package:visprofiler/visprofiler_models.dart';
import 'dart:convert';

/// This example demonstrates how to use the new immutable data models
/// for DeviceInfoPayload, NetworkPayload, and LocationPayload
void demonstrateModels() {
  print('=== VisProfiler Data Models Example ===\n');

  // 1. Device Information with MongoDB-compatible memory representation
  print('1. DeviceInfoPayload Example:');
  final deviceInfo = DeviceInfoPayload(
    deviceId: 'device-abc123',
    brand: 'Apple',
    model: 'iPhone 15 Pro',
    systemName: 'iOS',
    systemVersion: '17.2.1',
    appVersion: '1.2.3',
    platform: 'iOS',
    totalMemory: MongoLong.fromInt(8589934592), // 8GB in bytes
    usedMemory: MongoLong.fromInt(4294967296),  // 4GB in bytes
    isTablet: false,
    isJailbroken: false,
    timezone: 'America/New_York',
    locale: 'en_US',
    batteryLevel: '85',
    isCharging: true,
  );
  
  final deviceJson = jsonEncode(deviceInfo.toJson());
  print(const JsonEncoder.withIndent('  ').convert(jsonDecode(deviceJson)));
  print('');

  // 2. Android Network Information
  print('2. Android NetworkPayload Example:');
  final androidNetworkInfo = AndroidNetworkInfo(
    networkType: 'MOBILE',
    connectionType: 'LTE',
    operatorName: 'Verizon Wireless',
    operatorCode: '311480',
    countryIso: 'us',
    signalStrength: -75,
    isRoaming: false,
    networkGeneration: '4G',
    wifiSSID: null, // Not connected to WiFi
    ipAddress: '192.168.1.105',
    isVpnActive: false,
    mobileNetworkCode: '480',
    mobileCountryCode: '311',
  );

  final androidNetworkPayload = NetworkPayload(
    androidNetworkInfo: androidNetworkInfo,
    publicIpAddress: '203.0.113.42',
    userAgent: 'MyApp/1.0 (iOS; iPhone 15 Pro)',
    isConnected: true,
    timestamp: DateTime.now().toIso8601String(),
  );

  final androidNetworkJson = jsonEncode(androidNetworkPayload.toJson());
  print(const JsonEncoder.withIndent('  ').convert(jsonDecode(androidNetworkJson)));
  print('');

  // 3. iOS Network Information
  print('3. iOS NetworkPayload Example:');
  final iosNetworkInfo = IosNetworkInfo(
    networkType: 'WIFI',
    connectionType: '802.11ac',
    carrierName: 'AT&T',
    carrierCode: '310410',
    countryCode: 'us',
    radioAccessTechnology: 'CTRadioAccessTechnologyLTE',
    isRoaming: false,
    wifiSSID: 'HomeNetwork-5G',
    wifiBSSID: '00:11:22:33:44:55',
    ipAddress: '192.168.1.110',
    isVpnActive: true,
    cellularGeneration: '5G',
    signalStrength: -45,
    networkInterfaceType: 'WiFi',
  );

  final iosNetworkPayload = NetworkPayload(
    iosNetworkInfo: iosNetworkInfo,
    publicIpAddress: '198.51.100.123',
    userAgent: 'MyApp/1.0 (iOS; iPhone 15 Pro)',
    isConnected: true,
    timestamp: DateTime.now().toIso8601String(),
  );

  final iosNetworkJson = jsonEncode(iosNetworkPayload.toJson());
  print(const JsonEncoder.withIndent('  ').convert(jsonDecode(iosNetworkJson)));
  print('');

  // 4. Location Information
  print('4. LocationPayload Example:');
  final locationPayload = LocationPayload(
    latitude: 37.7749,
    longitude: -122.4194,
    accuracy: 5.0,
    altitude: 15.2,
    speed: 2.5,
    bearing: 45.0,
    course: 45.5,
    provider: 'GPS',
    timestamp: DateTime.now().toIso8601String(),
    isMocked: false,
    address: '1 Market Street, San Francisco, CA 94105, USA',
    city: 'San Francisco',
    country: 'United States',
    countryCode: 'US',
    postalCode: '94105',
    administrativeArea: 'California',
    subAdministrativeArea: 'San Francisco County',
    locality: 'San Francisco',
    subLocality: 'Financial District',
  );

  final locationJson = jsonEncode(locationPayload.toJson());
  print(const JsonEncoder.withIndent('  ').convert(jsonDecode(locationJson)));
  print('');

  // 5. Demonstrate null field exclusion
  print('5. Null Field Exclusion Example:');
  final minimalDevice = DeviceInfoPayload(
    deviceId: 'minimal-device',
    platform: 'Unknown',
    // All other fields are null and should be excluded
  );

  final minimalJson = jsonEncode(minimalDevice.toJson());
  print('Minimal device (only non-null fields):');
  print(const JsonEncoder.withIndent('  ').convert(jsonDecode(minimalJson)));
  print('');

  // 6. Demonstrate MongoLong usage
  print('6. MongoLong Examples:');
  final memoryInBytes = MongoLong.fromInt(17179869184); // 16GB
  print('Memory as MongoLong: ${jsonEncode(memoryInBytes.toJson())}');
  print('Converted back to int: ${memoryInBytes.toInt()} bytes');
  print('Converted to GB: ${memoryInBytes.toInt() / (1024 * 1024 * 1024)} GB');
  print('');

  // 7. Test deserialization
  print('7. Deserialization Example:');
  final originalLocation = LocationPayload(
    latitude: 40.7128,
    longitude: -74.0060,
    city: 'New York',
    country: 'United States',
  );

  final serialized = jsonEncode(originalLocation.toJson());
  print('Serialized: $serialized');
  
  final deserialized = LocationPayload.fromJson(jsonDecode(serialized));
  print('Deserialized latitude: ${deserialized.latitude}');
  print('Deserialized city: ${deserialized.city}');
  
  print('\n=== End of Examples ===');
}

/// Example usage in a real app context
class DataModelUsageExample {
  /// Create a comprehensive device profile
  static Map<String, dynamic> createDeviceProfile() {
    final deviceInfo = DeviceInfoPayload(
      deviceId: 'user-device-456',
      brand: 'Samsung',
      model: 'Galaxy S23',
      systemName: 'Android',
      systemVersion: '14',
      appVersion: '2.1.0',
      platform: 'Android',
      totalMemory: MongoLong.fromInt(12884901888), // 12GB
      isTablet: false,
      isRooted: false,
    );

    final networkInfo = AndroidNetworkInfo(
      networkType: 'MOBILE',
      connectionType: '5G',
      operatorName: 'T-Mobile',
      signalStrength: -65,
      networkGeneration: '5G',
    );

    final networkPayload = NetworkPayload(
      androidNetworkInfo: networkInfo,
      publicIpAddress: '203.0.113.100',
      isConnected: true,
      timestamp: DateTime.now().toIso8601String(),
    );

    final location = LocationPayload(
      latitude: 34.0522,
      longitude: -118.2437,
      accuracy: 10.0,
      provider: 'GPS',
      city: 'Los Angeles',
      country: 'United States',
      countryCode: 'US',
    );

    return {
      'device': deviceInfo.toJson(),
      'network': networkPayload.toJson(),
      'location': location.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Serialize the profile to JSON string
  static String serializeProfile() {
    final profile = createDeviceProfile();
    return jsonEncode(profile);
  }

  /// Pretty print the profile
  static void printProfile() {
    final profile = createDeviceProfile();
    final prettyJson = const JsonEncoder.withIndent('  ').convert(profile);
    print('Complete Device Profile:');
    print(prettyJson);
  }
}
