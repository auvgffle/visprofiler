import 'package:json_annotation/json_annotation.dart';

part 'visprofiler_models.g.dart';

/// Helper model for MongoDB long number representation
@JsonSerializable()
class MongoLong {
  @JsonKey(name: '\$numberLong')
  final String value;

  const MongoLong(this.value);

  factory MongoLong.fromInt(int number) => MongoLong(number.toString());

  factory MongoLong.fromJson(Map<String, dynamic> json) => _$MongoLongFromJson(json);
  Map<String, dynamic> toJson() => _$MongoLongToJson(this);

  int toInt() => int.parse(value);
}

/// Pure device metadata payload
@JsonSerializable()
class DeviceInfoPayload {
  @JsonKey(includeIfNull: false)
  final String? deviceId;
  
  @JsonKey(includeIfNull: false)
  final String? brand;
  
  @JsonKey(includeIfNull: false)
  final String? model;
  
  @JsonKey(includeIfNull: false)
  final String? systemName;
  
  @JsonKey(includeIfNull: false)
  final String? systemVersion;
  
  @JsonKey(includeIfNull: false)
  final String? appVersion;
  
  @JsonKey(includeIfNull: false)
  final String? buildNumber;
  
  @JsonKey(includeIfNull: false)
  final String? packageName;
  
  @JsonKey(includeIfNull: false)
  final String? manufacturer;
  
  @JsonKey(includeIfNull: false)
  final String? deviceName;
  
  @JsonKey(includeIfNull: false)
  final String? deviceType;
  
  @JsonKey(includeIfNull: false)
  final MongoLong? totalMemory;
  
  @JsonKey(includeIfNull: false)
  final MongoLong? usedMemory;
  
  @JsonKey(includeToJson: true)
  final bool? isTablet;
  
  @JsonKey(includeIfNull: false)
  final String? adId;
  
  @JsonKey(includeIfNull: false)
  final String? androidId;
  
  @JsonKey(includeIfNull: false)
  final String? idfv;
  
  @JsonKey(includeIfNull: false)
  final String? platform;
  
  @JsonKey(includeIfNull: false)
  final String? osVersion;
  
  @JsonKey(includeIfNull: false)
  final String? screenResolution;
  
  @JsonKey(includeIfNull: false)
  final String? timezone;
  
  @JsonKey(includeIfNull: false)
  final String? locale;
  
  @JsonKey(includeIfNull: false)
  final String? batteryLevel;
  
  @JsonKey(includeIfNull: false)
  final bool? isCharging;
  
  @JsonKey(includeIfNull: false)
  final bool? isJailbroken;
  
  @JsonKey(includeIfNull: false)
  final bool? isRooted;

  const DeviceInfoPayload({
    this.deviceId,
    this.brand,
    this.model,
    this.systemName,
    this.systemVersion,
    this.appVersion,
    this.buildNumber,
    this.packageName,
    this.manufacturer,
    this.deviceName,
    this.deviceType,
    this.totalMemory,
    this.usedMemory,
    this.isTablet,
    this.adId,
    this.androidId,
    this.idfv,
    this.platform,
    this.osVersion,
    this.screenResolution,
    this.timezone,
    this.locale,
    this.batteryLevel,
    this.isCharging,
    this.isJailbroken,
    this.isRooted,
  });

  factory DeviceInfoPayload.fromJson(Map<String, dynamic> json) => 
      _$DeviceInfoPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceInfoPayloadToJson(this);
}

/// Android-specific network information
@JsonSerializable()
class AndroidNetworkInfo {
  @JsonKey(includeIfNull: false)
  final String? networkType;
  
  @JsonKey(includeIfNull: false)
  final String? connectionType;
  
  @JsonKey(includeIfNull: false)
  final String? operatorName;
  
  @JsonKey(includeIfNull: false)
  final String? operatorCode;
  
  @JsonKey(includeIfNull: false)
  final String? countryIso;
  
  @JsonKey(includeIfNull: false)
  final int? signalStrength;
  
  @JsonKey(includeIfNull: false)
  final bool? isRoaming;
  
  @JsonKey(includeIfNull: false)
  final String? networkGeneration;
  
  @JsonKey(includeIfNull: false)
  final String? wifiSSID;
  
  @JsonKey(includeIfNull: false)
  final String? wifiBSSID;
  
  @JsonKey(includeIfNull: false)
  final int? wifiSignalLevel;
  
  @JsonKey(includeIfNull: false)
  final String? ipAddress;
  
  @JsonKey(includeIfNull: false)
  final String? macAddress;
  
  @JsonKey(includeIfNull: false)
  final bool? isVpnActive;
  
  @JsonKey(includeIfNull: false)
  final String? mobileNetworkCode;
  
  @JsonKey(includeIfNull: false)
  final String? mobileCountryCode;
  
  // Enhanced fields for comprehensive network information
  @JsonKey(includeIfNull: false)
  final int? rxLinkSpeed;
  
  @JsonKey(includeIfNull: false)
  final int? txLinkSpeed;
  
  @JsonKey(includeIfNull: false)
  final String? publicIp;
  
  @JsonKey(includeIfNull: false)
  final int? upstreamBandwidth;
  
  @JsonKey(includeIfNull: false)
  final int? downstreamBandwidth;
  
  @JsonKey(includeIfNull: false)
  final int? frequency;
  
  @JsonKey(includeIfNull: false)
  final int? linkSpeed;
  
  @JsonKey(includeIfNull: false)
  final int? networkId;
  
  @JsonKey(includeIfNull: false)
  final int? signalLevel;
  
  @JsonKey(includeIfNull: false)
  final int? strength;
  
  @JsonKey(includeIfNull: false)
  final bool? isConnected;
  
  @JsonKey(includeIfNull: false)
  final bool? isValidated;
  
  @JsonKey(includeIfNull: false)
  final bool? isMetered;
  
  @JsonKey(includeIfNull: false)
  final bool? hasEthernet;
  
  @JsonKey(includeIfNull: false)
  final bool? hasLowPan;

  const AndroidNetworkInfo({
    this.networkType,
    this.connectionType,
    this.operatorName,
    this.operatorCode,
    this.countryIso,
    this.signalStrength,
    this.isRoaming,
    this.networkGeneration,
    this.wifiSSID,
    this.wifiBSSID,
    this.wifiSignalLevel,
    this.ipAddress,
    this.macAddress,
    this.isVpnActive,
    this.mobileNetworkCode,
    this.mobileCountryCode,
    this.rxLinkSpeed,
    this.txLinkSpeed,
    this.publicIp,
    this.upstreamBandwidth,
    this.downstreamBandwidth,
    this.frequency,
    this.linkSpeed,
    this.networkId,
    this.signalLevel,
    this.strength,
    this.isConnected,
    this.isValidated,
    this.isMetered,
    this.hasEthernet,
    this.hasLowPan,
  });

  factory AndroidNetworkInfo.fromJson(Map<String, dynamic> json) => 
      _$AndroidNetworkInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AndroidNetworkInfoToJson(this);
}

/// iOS-specific network information
@JsonSerializable()
class IosNetworkInfo {
  @JsonKey(includeIfNull: false)
  final String? networkType;
  
  @JsonKey(includeIfNull: false)
  final String? connectionType;
  
  @JsonKey(includeIfNull: false)
  final String? carrierName;
  
  @JsonKey(includeIfNull: false)
  final String? carrierCode;
  
  @JsonKey(includeIfNull: false)
  final String? countryCode;
  
  @JsonKey(includeIfNull: false)
  final String? radioAccessTechnology;
  
  @JsonKey(includeIfNull: false)
  final bool? isRoaming;
  
  @JsonKey(includeIfNull: false)
  final String? wifiSSID;
  
  @JsonKey(includeIfNull: false)
  final String? wifiBSSID;
  
  @JsonKey(includeIfNull: false)
  final String? ipAddress;
  
  @JsonKey(includeIfNull: false)
  final bool? isVpnActive;
  
  @JsonKey(includeIfNull: false)
  final String? cellularGeneration;
  
  @JsonKey(includeIfNull: false)
  final int? signalStrength;
  
  @JsonKey(includeIfNull: false)
  final String? networkInterfaceType;
  
  // iOS-compatible fields with parity where possible
  @JsonKey(includeIfNull: false)
  final String? publicIp;
  
  @JsonKey(includeIfNull: false)
  final bool? isConnected;
  
  @JsonKey(includeIfNull: false)
  final bool? isExpensive;
  
  @JsonKey(includeIfNull: false)
  final bool? isConstrained;
  
  @JsonKey(includeIfNull: false)
  final bool? hasEthernet;
  
  @JsonKey(includeIfNull: false)
  final String? mobileCountryCode;
  
  @JsonKey(includeIfNull: false)
  final String? mobileNetworkCode;
  
  // Note: rxLinkSpeed and txLinkSpeed are Android-only, omitted from iOS model

  const IosNetworkInfo({
    this.networkType,
    this.connectionType,
    this.carrierName,
    this.carrierCode,
    this.countryCode,
    this.radioAccessTechnology,
    this.isRoaming,
    this.wifiSSID,
    this.wifiBSSID,
    this.ipAddress,
    this.isVpnActive,
    this.cellularGeneration,
    this.signalStrength,
    this.networkInterfaceType,
    this.publicIp,
    this.isConnected,
    this.isExpensive,
    this.isConstrained,
    this.hasEthernet,
    this.mobileCountryCode,
    this.mobileNetworkCode,
  });

  factory IosNetworkInfo.fromJson(Map<String, dynamic> json) => 
      _$IosNetworkInfoFromJson(json);
  Map<String, dynamic> toJson() => _$IosNetworkInfoToJson(this);
}

/// Network payload with platform-specific information
@JsonSerializable()
class NetworkPayload {
  @JsonKey(includeIfNull: false)
  final AndroidNetworkInfo? androidNetworkInfo;
  
  @JsonKey(includeIfNull: false)
  final IosNetworkInfo? iosNetworkInfo;
  
  @JsonKey(includeIfNull: false)
  final String? publicIpAddress;
  
  @JsonKey(includeIfNull: false)
  final String? userAgent;
  
  @JsonKey(includeIfNull: false)
  final bool? isConnected;
  
  @JsonKey(includeIfNull: false)
  final String? timestamp;

  const NetworkPayload({
    this.androidNetworkInfo,
    this.iosNetworkInfo,
    this.publicIpAddress,
    this.userAgent,
    this.isConnected,
    this.timestamp,
  });

  factory NetworkPayload.fromJson(Map<String, dynamic> json) => 
      _$NetworkPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkPayloadToJson(this);
}

/// Root payload structure that mirrors the exact outer envelope
@JsonSerializable()
class VisProfilerPayload {
  @JsonKey(includeIfNull: false)
  final String? deviceId;
  
  @JsonKey(includeIfNull: false)
  final String? apiKey;
  
  @JsonKey(includeIfNull: false)
  final PayloadData? payload;
  
  const VisProfilerPayload({
    this.deviceId,
    this.apiKey,
    this.payload,
  });
  
  factory VisProfilerPayload.fromJson(Map<String, dynamic> json) => 
      _$VisProfilerPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$VisProfilerPayloadToJson(this);
}

/// Inner payload data structure
@JsonSerializable()
class PayloadData {
  // Device fields at root level
  @JsonKey(includeIfNull: false)
  final String? deviceId;
  
  @JsonKey(includeIfNull: false)
  final String? brand;
  
  @JsonKey(includeIfNull: false)
  final String? model;
  
  @JsonKey(includeIfNull: false)
  final String? systemName;
  
  @JsonKey(includeIfNull: false)
  final String? systemVersion;
  
  @JsonKey(includeIfNull: false)
  final String? appVersion;
  
  @JsonKey(includeIfNull: false)
  final String? buildNumber;
  
  @JsonKey(includeIfNull: false)
  final String? packageName;
  
  @JsonKey(includeIfNull: false)
  final String? manufacturer;
  
  @JsonKey(includeIfNull: false)
  final String? deviceName;
  
  @JsonKey(includeIfNull: false)
  final String? deviceType;
  
  @JsonKey(includeIfNull: false)
  final MongoLong? totalMemory;
  
  @JsonKey(includeIfNull: false)
  final MongoLong? usedMemory;
  
  @JsonKey(includeToJson: true)
  final bool? isTablet;
  
  @JsonKey(includeIfNull: false)
  final String? adId;
  
  @JsonKey(includeIfNull: false)
  final String? androidId;
  
  @JsonKey(includeIfNull: false)
  final String? idfv;
  
  @JsonKey(includeIfNull: false)
  final String? platform;
  
  @JsonKey(includeIfNull: false)
  final String? osVersion;
  
  @JsonKey(includeIfNull: false)
  final String? screenResolution;
  
  @JsonKey(includeIfNull: false)
  final String? timezone;
  
  @JsonKey(includeIfNull: false)
  final String? locale;
  
  @JsonKey(includeIfNull: false)
  final String? batteryLevel;
  
  @JsonKey(includeToJson: true)
  final bool? isCharging;
  
  @JsonKey(includeToJson: true)
  final bool? isJailbroken;
  
  @JsonKey(includeToJson: true)
  final bool? isRooted;
  
  @JsonKey(includeToJson: true)
  final bool? hasNotch;
  
  @JsonKey(includeToJson: true)
  final bool? hasDynamicIsland;
  
  @JsonKey(includeIfNull: false)
  final String? timestamp;
  
  // Nested structures
  @JsonKey(includeIfNull: false)
  final NetworkPayload? network;
  
  @JsonKey(includeIfNull: false)
  final LocationPayload? location;
  
  // Contact info fields (flattened)
  @JsonKey(includeIfNull: false)
  final String? email;
  
  @JsonKey(includeIfNull: false)
  final String? name;
  
  @JsonKey(includeIfNull: false)
  final String? phone;
  
  const PayloadData({
    this.deviceId,
    this.brand,
    this.model,
    this.systemName,
    this.systemVersion,
    this.appVersion,
    this.buildNumber,
    this.packageName,
    this.manufacturer,
    this.deviceName,
    this.deviceType,
    this.totalMemory,
    this.usedMemory,
    this.isTablet,
    this.adId,
    this.androidId,
    this.idfv,
    this.platform,
    this.osVersion,
    this.screenResolution,
    this.timezone,
    this.locale,
    this.batteryLevel,
    this.isCharging,
    this.isJailbroken,
    this.isRooted,
    this.hasNotch,
    this.hasDynamicIsland,
    this.timestamp,
    this.network,
    this.location,
    this.email,
    this.name,
    this.phone,
  });
  
  factory PayloadData.fromJson(Map<String, dynamic> json) => 
      _$PayloadDataFromJson(json);
  Map<String, dynamic> toJson() => _$PayloadDataToJson(this);
}

/// Location payload
@JsonSerializable()
class LocationPayload {
  @JsonKey(includeIfNull: false)
  final double? latitude;
  
  @JsonKey(includeIfNull: false)
  final double? longitude;
  
  @JsonKey(includeIfNull: false)
  final double? accuracy;
  
  @JsonKey(includeIfNull: false)
  final double? altitude;
  
  @JsonKey(includeIfNull: false)
  final double? speed;
  
  @JsonKey(includeIfNull: false)
  final double? bearing;
  
  @JsonKey(includeIfNull: false)
  final double? course;
  
  @JsonKey(includeIfNull: false)
  final String? provider;
  
  @JsonKey(includeIfNull: false)
  final String? timestamp;
  
  @JsonKey(includeIfNull: false)
  final bool? isMocked;
  
  @JsonKey(includeIfNull: false)
  final String? address;
  
  @JsonKey(includeIfNull: false)
  final String? city;
  
  @JsonKey(includeIfNull: false)
  final String? country;
  
  @JsonKey(includeIfNull: false)
  final String? countryCode;
  
  @JsonKey(includeIfNull: false)
  final String? postalCode;
  
  @JsonKey(includeIfNull: false)
  final String? administrativeArea;
  
  @JsonKey(includeIfNull: false)
  final String? subAdministrativeArea;
  
  @JsonKey(includeIfNull: false)
  final String? locality;
  
  @JsonKey(includeIfNull: false)
  final String? subLocality;

  const LocationPayload({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.bearing,
    this.course,
    this.provider,
    this.timestamp,
    this.isMocked,
    this.address,
    this.city,
    this.country,
    this.countryCode,
    this.postalCode,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.locality,
    this.subLocality,
  });

  factory LocationPayload.fromJson(Map<String, dynamic> json) => 
      _$LocationPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$LocationPayloadToJson(this);
}

// Legacy classes for backward compatibility - these will be deprecated
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? bearing;
  final String? provider;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.bearing,
    this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      if (provider != null) 'provider': provider,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      speed: json['speed']?.toDouble(),
      bearing: json['bearing']?.toDouble(),
      provider: json['provider'],
    );
  }
}

class DeviceData {
  final String deviceId;
  final String? brand;
  final String? model;
  final String? systemName;
  final String? systemVersion;
  final String? appVersion;
  final String? buildNumber;
  final String? packageName;
  final String? manufacturer;
  final String? deviceName;
  final String? deviceType;
  final int? totalMemory;
  final int? usedMemory;
  final bool? isTablet;
  final String? adId;
  final String? androidId;
  final Map<String, dynamic>? network;
  final LocationData? location;
  final String? timestamp;
  final String? timezone;
  final String platform;
  final String? error;

  DeviceData({
    required this.deviceId,
    this.brand,
    this.model,
    this.systemName,
    this.systemVersion,
    this.appVersion,
    this.buildNumber,
    this.packageName,
    this.manufacturer,
    this.deviceName,
    this.deviceType,
    this.totalMemory,
    this.usedMemory,
    this.isTablet,
    this.adId,
    this.androidId,
    this.network,
    this.location,
    this.timestamp,
    this.timezone,
    required this.platform,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (systemName != null) 'systemName': systemName,
      if (systemVersion != null) 'systemVersion': systemVersion,
      if (appVersion != null) 'appVersion': appVersion,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (packageName != null) 'packageName': packageName,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (deviceName != null) 'deviceName': deviceName,
      if (deviceType != null) 'deviceType': deviceType,
      if (totalMemory != null) 'totalMemory': totalMemory,
      if (usedMemory != null) 'usedMemory': usedMemory,
      if (isTablet != null) 'isTablet': isTablet,
      if (adId != null) 'adId': adId,
      if (androidId != null) 'androidId': androidId,
      if (network != null) 'network': network,
      if (location != null) 'location': location?.toJson(),
      if (timestamp != null) 'timestamp': timestamp,
      if (timezone != null) 'timezone': timezone,
      'platform': platform,
      if (error != null) 'error': error,
    };
  }

  DeviceData copyWith({
    String? deviceId,
    String? brand,
    String? model,
    String? systemName,
    String? systemVersion,
    String? appVersion,
    String? buildNumber,
    String? packageName,
    String? manufacturer,
    String? deviceName,
    String? deviceType,
    int? totalMemory,
    int? usedMemory,
    bool? isTablet,
    String? adId,
    String? androidId,
    Map<String, dynamic>? network,
    LocationData? location,
    String? timestamp,
    String? timezone,
    String? platform,
    String? error,
  }) {
    return DeviceData(
      deviceId: deviceId ?? this.deviceId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      systemName: systemName ?? this.systemName,
      systemVersion: systemVersion ?? this.systemVersion,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      packageName: packageName ?? this.packageName,
      manufacturer: manufacturer ?? this.manufacturer,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      totalMemory: totalMemory ?? this.totalMemory,
      usedMemory: usedMemory ?? this.usedMemory,
      isTablet: isTablet ?? this.isTablet,
      adId: adId ?? this.adId,
      androidId: androidId ?? this.androidId,
      network: network ?? this.network,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      timezone: timezone ?? this.timezone,
      platform: platform ?? this.platform,
      error: error ?? this.error,
    );
  }
}

class SendDataResult {
  final bool success;
  final Map<String, dynamic>? error;
  final DeviceData? data;
  final Map<String, dynamic>? response;
  final int? duration;
  final int attempts;
  final bool retryable;

  SendDataResult({
    required this.success,
    this.error,
    this.data,
    this.response,
    this.duration,
    required this.attempts,
    this.retryable = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (error != null) 'error': error,
      if (data != null) 'data': data?.toJson(),
      if (response != null) 'response': response,
      if (duration != null) 'duration': duration,
      'attempts': attempts,
      'retryable': retryable,
    };
  }
}

class DeviceDataCache {
  final DeviceData data;
  final int expiry;

  DeviceDataCache({
    required this.data,
    required this.expiry,
  });
}

class NetworkDataCache {
  final Map<String, dynamic> data;

  NetworkDataCache({
    required this.data,
  });
}
