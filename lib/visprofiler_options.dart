/// Configuration options for VisProfiler SDK data collection
class VisProfilerOptions {
  /// Enable/disable location data collection
  final bool enableLocation;
  
  /// Enable/disable network information collection
  final bool enableNetworkInfo;
  
  /// Enable/disable advertising ID collection
  final bool enableAdId;
  
  /// Enable/disable device information collection (always recommended to keep true)
  final bool enableDeviceInfo;
  
  /// Enable/disable public IP collection
  final bool enablePublicIp;
  
  /// Enable/disable automatic periodic data sending
  final bool enablePeriodicSending;
  
  /// Interval for automatic data sending in milliseconds (default: 3 minutes)
  final int sendIntervalMs;
  
  /// Enable/disable SDK logging
  final bool enableLogging;
  
  /// Enable/disable caching for performance optimization
  final bool enableCaching;

  const VisProfilerOptions({
    this.enableLocation = true,
    this.enableNetworkInfo = true,
    this.enableAdId = true,
    this.enableDeviceInfo = true,
    this.enablePublicIp = true,
    this.enablePeriodicSending = true,
    this.sendIntervalMs = 180000, // 3 minutes
    this.enableLogging = true,
    this.enableCaching = true,
  });

  /// Create options with all features disabled (minimal data collection)
  const VisProfilerOptions.minimal({
    this.enableLocation = false,
    this.enableNetworkInfo = false,
    this.enableAdId = false,
    this.enableDeviceInfo = true, // Always keep device info for basic functionality
    this.enablePublicIp = false,
    this.enablePeriodicSending = false,
    this.sendIntervalMs = 180000,
    this.enableLogging = true,
    this.enableCaching = true,
  });

  /// Create options with only essential features enabled
  const VisProfilerOptions.essential({
    this.enableLocation = false,
    this.enableNetworkInfo = true,
    this.enableAdId = false,
    this.enableDeviceInfo = true,
    this.enablePublicIp = false,
    this.enablePeriodicSending = true,
    this.sendIntervalMs = 180000,
    this.enableLogging = true,
    this.enableCaching = true,
  });

  /// Create options with all features enabled (full tracking)
  const VisProfilerOptions.full({
    this.enableLocation = true,
    this.enableNetworkInfo = true,
    this.enableAdId = true,
    this.enableDeviceInfo = true,
    this.enablePublicIp = true,
    this.enablePeriodicSending = true,
    this.sendIntervalMs = 180000,
    this.enableLogging = true,
    this.enableCaching = true,
  });

  /// Copy options with modifications
  VisProfilerOptions copyWith({
    bool? enableLocation,
    bool? enableNetworkInfo,
    bool? enableAdId,
    bool? enableDeviceInfo,
    bool? enablePublicIp,
    bool? enablePeriodicSending,
    int? sendIntervalMs,
    bool? enableLogging,
    bool? enableCaching,
  }) {
    return VisProfilerOptions(
      enableLocation: enableLocation ?? this.enableLocation,
      enableNetworkInfo: enableNetworkInfo ?? this.enableNetworkInfo,
      enableAdId: enableAdId ?? this.enableAdId,
      enableDeviceInfo: enableDeviceInfo ?? this.enableDeviceInfo,
      enablePublicIp: enablePublicIp ?? this.enablePublicIp,
      enablePeriodicSending: enablePeriodicSending ?? this.enablePeriodicSending,
      sendIntervalMs: sendIntervalMs ?? this.sendIntervalMs,
      enableLogging: enableLogging ?? this.enableLogging,
      enableCaching: enableCaching ?? this.enableCaching,
    );
  }

  /// Convert options to map for debugging/logging
  Map<String, dynamic> toMap() {
    return {
      'enableLocation': enableLocation,
      'enableNetworkInfo': enableNetworkInfo,
      'enableAdId': enableAdId,
      'enableDeviceInfo': enableDeviceInfo,
      'enablePublicIp': enablePublicIp,
      'enablePeriodicSending': enablePeriodicSending,
      'sendIntervalMs': sendIntervalMs,
      'enableLogging': enableLogging,
      'enableCaching': enableCaching,
    };
  }

  @override
  String toString() {
    return 'VisProfilerOptions(${toMap()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VisProfilerOptions &&
      other.enableLocation == enableLocation &&
      other.enableNetworkInfo == enableNetworkInfo &&
      other.enableAdId == enableAdId &&
      other.enableDeviceInfo == enableDeviceInfo &&
      other.enablePublicIp == enablePublicIp &&
      other.enablePeriodicSending == enablePeriodicSending &&
      other.sendIntervalMs == sendIntervalMs &&
      other.enableLogging == enableLogging &&
      other.enableCaching == enableCaching;
  }

  @override
  int get hashCode {
    return Object.hash(
      enableLocation,
      enableNetworkInfo,
      enableAdId,
      enableDeviceInfo,
      enablePublicIp,
      enablePeriodicSending,
      sendIntervalMs,
      enableLogging,
      enableCaching,
    );
  }
}
