// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visprofiler_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MongoLong _$MongoLongFromJson(Map<String, dynamic> json) =>
    MongoLong(json[r'$numberLong'] as String);

Map<String, dynamic> _$MongoLongToJson(MongoLong instance) => <String, dynamic>{
  r'$numberLong': instance.value,
};

DeviceInfoPayload _$DeviceInfoPayloadFromJson(Map<String, dynamic> json) =>
    DeviceInfoPayload(
      deviceId: json['deviceId'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      systemName: json['systemName'] as String?,
      systemVersion: json['systemVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      buildNumber: json['buildNumber'] as String?,
      packageName: json['packageName'] as String?,
      manufacturer: json['manufacturer'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceType: json['deviceType'] as String?,
      totalMemory: json['totalMemory'] == null
          ? null
          : MongoLong.fromJson(json['totalMemory'] as Map<String, dynamic>),
      usedMemory: json['usedMemory'] == null
          ? null
          : MongoLong.fromJson(json['usedMemory'] as Map<String, dynamic>),
      isTablet: json['isTablet'] as bool?,
      adId: json['adId'] as String?,
      androidId: json['androidId'] as String?,
      idfv: json['idfv'] as String?,
      platform: json['platform'] as String?,
      osVersion: json['osVersion'] as String?,
      screenResolution: json['screenResolution'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
      batteryLevel: json['batteryLevel'] as String?,
      isCharging: json['isCharging'] as bool?,
      isJailbroken: json['isJailbroken'] as bool?,
      isRooted: json['isRooted'] as bool?,
    );

Map<String, dynamic> _$DeviceInfoPayloadToJson(DeviceInfoPayload instance) =>
    <String, dynamic>{
      if (instance.deviceId != null) 'deviceId': instance.deviceId,
      if (instance.brand != null) 'brand': instance.brand,
      if (instance.model != null) 'model': instance.model,
      if (instance.systemName != null) 'systemName': instance.systemName,
      if (instance.systemVersion != null) 'systemVersion': instance.systemVersion,
      if (instance.appVersion != null) 'appVersion': instance.appVersion,
      if (instance.buildNumber != null) 'buildNumber': instance.buildNumber,
      if (instance.packageName != null) 'packageName': instance.packageName,
      if (instance.manufacturer != null) 'manufacturer': instance.manufacturer,
      if (instance.deviceName != null) 'deviceName': instance.deviceName,
      if (instance.deviceType != null) 'deviceType': instance.deviceType,
      if (instance.totalMemory != null) 'totalMemory': instance.totalMemory,
      if (instance.usedMemory != null) 'usedMemory': instance.usedMemory,
      'isTablet': instance.isTablet,
      if (instance.adId != null) 'adId': instance.adId,
      if (instance.androidId != null) 'androidId': instance.androidId,
      if (instance.idfv != null) 'idfv': instance.idfv,
      if (instance.platform != null) 'platform': instance.platform,
      if (instance.osVersion != null) 'osVersion': instance.osVersion,
      if (instance.screenResolution != null) 'screenResolution': instance.screenResolution,
      if (instance.timezone != null) 'timezone': instance.timezone,
      if (instance.locale != null) 'locale': instance.locale,
      if (instance.batteryLevel != null) 'batteryLevel': instance.batteryLevel,
      'isCharging': instance.isCharging,
      'isJailbroken': instance.isJailbroken,
      'isRooted': instance.isRooted,
    };

AndroidNetworkInfo _$AndroidNetworkInfoFromJson(Map<String, dynamic> json) =>
    AndroidNetworkInfo(
      networkType: json['networkType'] as String?,
      connectionType: json['connectionType'] as String?,
      operatorName: json['operatorName'] as String?,
      operatorCode: json['operatorCode'] as String?,
      countryIso: json['countryIso'] as String?,
      signalStrength: (json['signalStrength'] as num?)?.toInt(),
      isRoaming: json['isRoaming'] as bool?,
      networkGeneration: json['networkGeneration'] as String?,
      wifiSSID: json['wifiSSID'] as String?,
      wifiBSSID: json['wifiBSSID'] as String?,
      wifiSignalLevel: (json['wifiSignalLevel'] as num?)?.toInt(),
      ipAddress: json['ipAddress'] as String?,
      macAddress: json['macAddress'] as String?,
      isVpnActive: json['isVpnActive'] as bool?,
      mobileNetworkCode: json['mobileNetworkCode'] as String?,
      mobileCountryCode: json['mobileCountryCode'] as String?,
      rxLinkSpeed: (json['rxLinkSpeed'] as num?)?.toInt(),
      txLinkSpeed: (json['txLinkSpeed'] as num?)?.toInt(),
      publicIp: json['publicIp'] as String?,
      upstreamBandwidth: (json['upstreamBandwidth'] as num?)?.toInt(),
      downstreamBandwidth: (json['downstreamBandwidth'] as num?)?.toInt(),
      frequency: (json['frequency'] as num?)?.toInt(),
      linkSpeed: (json['linkSpeed'] as num?)?.toInt(),
      networkId: (json['networkId'] as num?)?.toInt(),
      signalLevel: (json['signalLevel'] as num?)?.toInt(),
      strength: (json['strength'] as num?)?.toInt(),
      isConnected: json['isConnected'] as bool?,
      isValidated: json['isValidated'] as bool?,
      isMetered: json['isMetered'] as bool?,
      hasEthernet: json['hasEthernet'] as bool?,
      hasLowPan: json['hasLowPan'] as bool?,
    );

Map<String, dynamic> _$AndroidNetworkInfoToJson(AndroidNetworkInfo instance) =>
    <String, dynamic>{
      if (instance.networkType != null) 'networkType': instance.networkType,
      if (instance.connectionType != null) 'connectionType': instance.connectionType,
      if (instance.operatorName != null) 'operatorName': instance.operatorName,
      if (instance.operatorCode != null) 'operatorCode': instance.operatorCode,
      if (instance.countryIso != null) 'countryIso': instance.countryIso,
      if (instance.signalStrength != null) 'signalStrength': instance.signalStrength,
      if (instance.isRoaming != null) 'isRoaming': instance.isRoaming,
      if (instance.networkGeneration != null) 'networkGeneration': instance.networkGeneration,
      if (instance.wifiSSID != null) 'wifiSSID': instance.wifiSSID,
      if (instance.wifiBSSID != null) 'wifiBSSID': instance.wifiBSSID,
      if (instance.wifiSignalLevel != null) 'wifiSignalLevel': instance.wifiSignalLevel,
      if (instance.ipAddress != null) 'ipAddress': instance.ipAddress,
      if (instance.macAddress != null) 'macAddress': instance.macAddress,
      if (instance.isVpnActive != null) 'isVpnActive': instance.isVpnActive,
      if (instance.mobileNetworkCode != null) 'mobileNetworkCode': instance.mobileNetworkCode,
      if (instance.mobileCountryCode != null) 'mobileCountryCode': instance.mobileCountryCode,
      if (instance.rxLinkSpeed != null) 'rxLinkSpeed': instance.rxLinkSpeed,
      if (instance.txLinkSpeed != null) 'txLinkSpeed': instance.txLinkSpeed,
      if (instance.publicIp != null) 'publicIp': instance.publicIp,
      if (instance.upstreamBandwidth != null) 'upstreamBandwidth': instance.upstreamBandwidth,
      if (instance.downstreamBandwidth != null) 'downstreamBandwidth': instance.downstreamBandwidth,
      if (instance.frequency != null) 'frequency': instance.frequency,
      if (instance.linkSpeed != null) 'linkSpeed': instance.linkSpeed,
      if (instance.networkId != null) 'networkId': instance.networkId,
      if (instance.signalLevel != null) 'signalLevel': instance.signalLevel,
      if (instance.strength != null) 'strength': instance.strength,
      if (instance.isConnected != null) 'isConnected': instance.isConnected,
      if (instance.isValidated != null) 'isValidated': instance.isValidated,
      if (instance.isMetered != null) 'isMetered': instance.isMetered,
      if (instance.hasEthernet != null) 'hasEthernet': instance.hasEthernet,
      if (instance.hasLowPan != null) 'hasLowPan': instance.hasLowPan,
    };

IosNetworkInfo _$IosNetworkInfoFromJson(Map<String, dynamic> json) =>
    IosNetworkInfo(
      networkType: json['networkType'] as String?,
      connectionType: json['connectionType'] as String?,
      carrierName: json['carrierName'] as String?,
      carrierCode: json['carrierCode'] as String?,
      countryCode: json['countryCode'] as String?,
      radioAccessTechnology: json['radioAccessTechnology'] as String?,
      isRoaming: json['isRoaming'] as bool?,
      wifiSSID: json['wifiSSID'] as String?,
      wifiBSSID: json['wifiBSSID'] as String?,
      ipAddress: json['ipAddress'] as String?,
      isVpnActive: json['isVpnActive'] as bool?,
      cellularGeneration: json['cellularGeneration'] as String?,
      signalStrength: (json['signalStrength'] as num?)?.toInt(),
      networkInterfaceType: json['networkInterfaceType'] as String?,
      publicIp: json['publicIp'] as String?,
      isConnected: json['isConnected'] as bool?,
      isExpensive: json['isExpensive'] as bool?,
      isConstrained: json['isConstrained'] as bool?,
      hasEthernet: json['hasEthernet'] as bool?,
      mobileCountryCode: json['mobileCountryCode'] as String?,
      mobileNetworkCode: json['mobileNetworkCode'] as String?,
    );

Map<String, dynamic> _$IosNetworkInfoToJson(IosNetworkInfo instance) =>
    <String, dynamic>{
      if (instance.networkType != null) 'networkType': instance.networkType,
      if (instance.connectionType != null) 'connectionType': instance.connectionType,
      if (instance.carrierName != null) 'carrierName': instance.carrierName,
      if (instance.carrierCode != null) 'carrierCode': instance.carrierCode,
      if (instance.countryCode != null) 'countryCode': instance.countryCode,
      if (instance.radioAccessTechnology != null) 'radioAccessTechnology': instance.radioAccessTechnology,
      if (instance.isRoaming != null) 'isRoaming': instance.isRoaming,
      if (instance.wifiSSID != null) 'wifiSSID': instance.wifiSSID,
      if (instance.wifiBSSID != null) 'wifiBSSID': instance.wifiBSSID,
      if (instance.ipAddress != null) 'ipAddress': instance.ipAddress,
      if (instance.isVpnActive != null) 'isVpnActive': instance.isVpnActive,
      if (instance.cellularGeneration != null) 'cellularGeneration': instance.cellularGeneration,
      if (instance.signalStrength != null) 'signalStrength': instance.signalStrength,
      if (instance.networkInterfaceType != null) 'networkInterfaceType': instance.networkInterfaceType,
      if (instance.publicIp != null) 'publicIp': instance.publicIp,
      if (instance.isConnected != null) 'isConnected': instance.isConnected,
      if (instance.isExpensive != null) 'isExpensive': instance.isExpensive,
      if (instance.isConstrained != null) 'isConstrained': instance.isConstrained,
      if (instance.hasEthernet != null) 'hasEthernet': instance.hasEthernet,
      if (instance.mobileCountryCode != null) 'mobileCountryCode': instance.mobileCountryCode,
      if (instance.mobileNetworkCode != null) 'mobileNetworkCode': instance.mobileNetworkCode,
    };

NetworkPayload _$NetworkPayloadFromJson(Map<String, dynamic> json) =>
    NetworkPayload(
      androidNetworkInfo: json['androidNetworkInfo'] == null
          ? null
          : AndroidNetworkInfo.fromJson(
              json['androidNetworkInfo'] as Map<String, dynamic>,
            ),
      iosNetworkInfo: json['iosNetworkInfo'] == null
          ? null
          : IosNetworkInfo.fromJson(
              json['iosNetworkInfo'] as Map<String, dynamic>,
            ),
      publicIpAddress: json['publicIpAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      isConnected: json['isConnected'] as bool?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$NetworkPayloadToJson(NetworkPayload instance) =>
    <String, dynamic>{
      if (instance.androidNetworkInfo != null) 'androidNetworkInfo': instance.androidNetworkInfo,
      if (instance.iosNetworkInfo != null) 'iosNetworkInfo': instance.iosNetworkInfo,
      if (instance.publicIpAddress != null) 'publicIpAddress': instance.publicIpAddress,
      if (instance.userAgent != null) 'userAgent': instance.userAgent,
      if (instance.isConnected != null) 'isConnected': instance.isConnected,
      if (instance.timestamp != null) 'timestamp': instance.timestamp,
    };

VisProfilerPayload _$VisProfilerPayloadFromJson(Map<String, dynamic> json) =>
    VisProfilerPayload(
      deviceId: json['deviceId'] as String?,
      apiKey: json['apiKey'] as String?,
      payload: json['payload'] == null
          ? null
          : PayloadData.fromJson(json['payload'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VisProfilerPayloadToJson(VisProfilerPayload instance) =>
    <String, dynamic>{
      if (instance.deviceId != null) 'deviceId': instance.deviceId,
      if (instance.apiKey != null) 'apiKey': instance.apiKey,
      if (instance.payload != null) 'payload': instance.payload,
    };

PayloadData _$PayloadDataFromJson(Map<String, dynamic> json) => PayloadData(
  deviceId: json['deviceId'] as String?,
  brand: json['brand'] as String?,
  model: json['model'] as String?,
  systemName: json['systemName'] as String?,
  systemVersion: json['systemVersion'] as String?,
  appVersion: json['appVersion'] as String?,
  buildNumber: json['buildNumber'] as String?,
  packageName: json['packageName'] as String?,
  manufacturer: json['manufacturer'] as String?,
  deviceName: json['deviceName'] as String?,
  deviceType: json['deviceType'] as String?,
  totalMemory: json['totalMemory'] == null
      ? null
      : MongoLong.fromJson(json['totalMemory'] as Map<String, dynamic>),
  usedMemory: json['usedMemory'] == null
      ? null
      : MongoLong.fromJson(json['usedMemory'] as Map<String, dynamic>),
  isTablet: json['isTablet'] as bool?,
  adId: json['adId'] as String?,
  androidId: json['androidId'] as String?,
  idfv: json['idfv'] as String?,
  platform: json['platform'] as String?,
  osVersion: json['osVersion'] as String?,
  screenResolution: json['screenResolution'] as String?,
  timezone: json['timezone'] as String?,
  locale: json['locale'] as String?,
  batteryLevel: json['batteryLevel'] as String?,
  isCharging: json['isCharging'] as bool?,
  isJailbroken: json['isJailbroken'] as bool?,
  isRooted: json['isRooted'] as bool?,
  hasNotch: json['hasNotch'] as bool?,
  hasDynamicIsland: json['hasDynamicIsland'] as bool?,
  timestamp: json['timestamp'] as String?,
  network: json['network'] == null
      ? null
      : NetworkPayload.fromJson(json['network'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : LocationPayload.fromJson(json['location'] as Map<String, dynamic>),
  email: json['email'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$PayloadDataToJson(PayloadData instance) =>
    <String, dynamic>{
      if (instance.deviceId != null) 'deviceId': instance.deviceId,
      if (instance.brand != null) 'brand': instance.brand,
      if (instance.model != null) 'model': instance.model,
      if (instance.systemName != null) 'systemName': instance.systemName,
      if (instance.systemVersion != null) 'systemVersion': instance.systemVersion,
      if (instance.appVersion != null) 'appVersion': instance.appVersion,
      if (instance.buildNumber != null) 'buildNumber': instance.buildNumber,
      if (instance.packageName != null) 'packageName': instance.packageName,
      if (instance.manufacturer != null) 'manufacturer': instance.manufacturer,
      if (instance.deviceName != null) 'deviceName': instance.deviceName,
      if (instance.deviceType != null) 'deviceType': instance.deviceType,
      if (instance.totalMemory != null) 'totalMemory': instance.totalMemory,
      if (instance.usedMemory != null) 'usedMemory': instance.usedMemory,
      'isTablet': instance.isTablet,
      if (instance.adId != null) 'adId': instance.adId,
      if (instance.androidId != null) 'androidId': instance.androidId,
      if (instance.idfv != null) 'idfv': instance.idfv,
      if (instance.platform != null) 'platform': instance.platform,
      if (instance.osVersion != null) 'osVersion': instance.osVersion,
      if (instance.screenResolution != null) 'screenResolution': instance.screenResolution,
      if (instance.timezone != null) 'timezone': instance.timezone,
      if (instance.locale != null) 'locale': instance.locale,
      if (instance.batteryLevel != null) 'batteryLevel': instance.batteryLevel,
      'isCharging': instance.isCharging,
      'isJailbroken': instance.isJailbroken,
      'isRooted': instance.isRooted,
      'hasNotch': instance.hasNotch,
      'hasDynamicIsland': instance.hasDynamicIsland,
      if (instance.timestamp != null) 'timestamp': instance.timestamp,
      if (instance.network != null) 'network': instance.network,
      if (instance.location != null) 'location': instance.location,
      if (instance.email != null) 'email': instance.email,
      if (instance.name != null) 'name': instance.name,
      if (instance.phone != null) 'phone': instance.phone,
    };

LocationPayload _$LocationPayloadFromJson(Map<String, dynamic> json) =>
    LocationPayload(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      bearing: (json['bearing'] as num?)?.toDouble(),
      course: (json['course'] as num?)?.toDouble(),
      provider: json['provider'] as String?,
      timestamp: json['timestamp'] as String?,
      isMocked: json['isMocked'] as bool?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      postalCode: json['postalCode'] as String?,
      administrativeArea: json['administrativeArea'] as String?,
      subAdministrativeArea: json['subAdministrativeArea'] as String?,
      locality: json['locality'] as String?,
      subLocality: json['subLocality'] as String?,
    );

Map<String, dynamic> _$LocationPayloadToJson(LocationPayload instance) =>
    <String, dynamic>{
      if (instance.latitude != null) 'latitude': instance.latitude,
      if (instance.longitude != null) 'longitude': instance.longitude,
      if (instance.accuracy != null) 'accuracy': instance.accuracy,
      if (instance.altitude != null) 'altitude': instance.altitude,
      if (instance.speed != null) 'speed': instance.speed,
      if (instance.bearing != null) 'bearing': instance.bearing,
      if (instance.course != null) 'course': instance.course,
      if (instance.provider != null) 'provider': instance.provider,
      if (instance.timestamp != null) 'timestamp': instance.timestamp,
      if (instance.isMocked != null) 'isMocked': instance.isMocked,
      if (instance.address != null) 'address': instance.address,
      if (instance.city != null) 'city': instance.city,
      if (instance.country != null) 'country': instance.country,
      if (instance.countryCode != null) 'countryCode': instance.countryCode,
      if (instance.postalCode != null) 'postalCode': instance.postalCode,
      if (instance.administrativeArea != null) 'administrativeArea': instance.administrativeArea,
      if (instance.subAdministrativeArea != null) 'subAdministrativeArea': instance.subAdministrativeArea,
      if (instance.locality != null) 'locality': instance.locality,
      if (instance.subLocality != null) 'subLocality': instance.subLocality,
    };
