# VisProfiler SDK for Flutter

A comprehensive, privacy-first device profiling and analytics SDK for Flutter applications that collects device, network, and location data across Android and iOS platforms.

[![pub package](https://img.shields.io/pub/v/visprofiler.svg)](https://pub.dev/packages/visprofiler)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- 🔍 **Comprehensive Device Profiling**: Collect detailed device information including hardware specs, OS version, and device capabilities
- 🌐 **Advanced Network Analytics**: Track network types, connection quality, carrier information, and public IP
- 📍 **Privacy-Aware Location Services**: Optional location tracking with user consent
- 🔒 **Privacy-First Approach**: All data collection is optional and configurable
- ⚡ **Performance Optimized**: Efficient caching and minimal battery impact
- 📱 **Cross-Platform**: Native implementations for both Android and iOS
- 🎯 **Advertising Integration**: Optional IDFA/GAID collection for attribution
- 🔄 **Real-Time & Batch Processing**: Configurable data transmission modes

## Installation

Add `visprofiler` to your `pubspec.yaml`:

```yaml
dependencies:
  visprofiler: ^1.0.0
```

Run the installation command:

```bash
flutter pub get
```

## Platform Setup

### Android Configuration

#### 1. Update your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="your.package.name">
    
    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    
    <!-- Optional Permissions (based on your needs) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- For Advertising ID -->
    <uses-permission android:name="com.google.android.gms.permission.AD_ID" />
    
    <application
        android:label="your_app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your existing application configuration -->
        
    </application>
</manifest>
```

#### 2. Add Google Play Services (for Advertising ID support):

In your `android/app/build.gradle`:

```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-ads-identifier:18.0.1'
    implementation 'com.google.android.gms:play-services-location:21.0.1'
}
```

### iOS Configuration

#### 1. Update your `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing Info.plist content -->
    
    <!-- Location Permissions (if using location features) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to provide location-based analytics.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs location access to provide comprehensive analytics.</string>
    
    <!-- Network Usage Description (if needed) -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- Privacy Manifest (iOS 17+) -->
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategorySystemBootTime</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>35F9.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

#### 2. Add iOS Podfile Configuration:

In your `ios/Podfile`, ensure you have:

```ruby
platform :ios, '11.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

## Basic Usage

### 1. Import the Package

```dart
import 'package:visprofiler/visprofiler.dart';
```

### 2. Initialize the SDK

```dart
void initializeVisProfiler() {
  final options = VisProfilerOptions(
    enableLocation: true,          // Collect location data
    enableNetworkInfo: true,       // Collect network information
    enableAdId: true,              // Collect advertising ID
    enableDeviceInfo: true,        // Collect device information
    enablePublicIp: true,          // Collect public IP
    enablePeriodicSending: true,   // Enable automatic data transmission
    sendIntervalMs: 60000,         // Send data every 60 seconds
    enableLogging: true,           // Enable debug logging
    enableCaching: true,           // Enable data caching for performance
  );

  final success = Visprofiler.instance.init(
    'YOUR_APP_ID_HERE',           // Replace with your app ID
    {
      'userId': 'user_123',
      'email': 'user@example.com',
      'name': 'John Doe',
      'subscription': 'premium',
    },
    options: options,
  );

  if (success) {
    print('VisProfiler SDK initialized successfully');
  } else {
    print('Failed to initialize VisProfiler SDK');
  }
}
```

### 3. Send Data Manually

```dart
Future<void> sendAnalyticsData() async {
  final result = await Visprofiler.instance.sendData({
    'event_type': 'user_action',
    'screen': 'home',
    'action': 'button_click',
    'custom_data': {
      'feature': 'premium_upgrade',
      'timestamp': DateTime.now().toIso8601String(),
    },
  });

  if (result.success) {
    print('Data sent successfully: ${result.response}');
  } else {
    print('Failed to send data: ${result.error}');
  }
}
```

## Advanced Configuration

### Custom Options

```dart
final customOptions = VisProfilerOptions(
  // Data Collection Options
  enableLocation: true,           // GPS coordinates (requires permission)
  enableNetworkInfo: true,        // Network type, carrier, signal strength
  enableAdId: false,              // Advertising ID (IDFA/GAID)
  enableDeviceInfo: true,         // Device specs, OS version
  enablePublicIp: true,           // External IP address
  
  // Performance Options  
  enableCaching: true,            // Cache data to reduce native calls
  
  // Transmission Options
  enablePeriodicSending: true,    // Auto-send data at intervals
  sendIntervalMs: 30000,          // Send every 30 seconds
  
  // Debug Options
  enableLogging: false,           // Disable in production
);
```

### Permission Management

The SDK automatically handles permission requests, but you can also check/request permissions manually:

```dart
// Check current permission status
final permissionStatus = await Visprofiler.instance.checkPermissionStatus();
print('Location permission: ${permissionStatus['location']}');

// Request location permission
final locationPermission = await Visprofiler.instance.requestLocationPermission();
if (locationPermission.isGranted) {
  print('Location permission granted');
}
```

### Health Check and Testing

```dart
// Perform SDK health check
final healthStatus = await Visprofiler.instance.healthCheck();
print('SDK Health: ${healthStatus}');

// Test native module functionality
final testResults = await Visprofiler.instance.testNativeModule();
print('Module Tests: ${testResults}');
```

### Runtime Configuration Updates

```dart
// Update options at runtime
final newOptions = VisProfilerOptions(
  enableLocation: false,          // Disable location tracking
  enablePeriodicSending: false,   // Stop automatic sending
  enableLogging: false,           // Disable logging
);

Visprofiler.instance.updateOptions(newOptions);
```

## Data Types Collected

### Device Information
- Device ID (Android ID / IDFV)
- Brand, model, manufacturer
- Operating system and version
- Screen resolution and density
- Memory usage and storage
- Battery level and charging status
- Jailbreak/root detection
- Device capabilities (notch, dynamic island)

### Network Information
- Connection type (WiFi, Cellular, Ethernet)
- Network generation (2G, 3G, 4G, 5G)
- Carrier information
- Signal strength and quality
- Public IP address
- VPN detection
- Data usage metrics

### Location Information (Optional)
- GPS coordinates (latitude, longitude)
- Location accuracy
- Altitude and speed
- Location provider
- Timestamp

### Advertising Information (Optional)
- Advertising ID (IDFA on iOS, GAID on Android)
- Attribution tracking capabilities

## Privacy and Compliance

### GDPR/CCPA Compliance
- All data collection is **opt-in** and configurable
- Users can control exactly what data is collected
- No data is collected without explicit permission
- Easy to implement data deletion requests

### Data Security
- All data transmission uses HTTPS encryption
- No sensitive personal information is collected by default
- Device identifiers are anonymized where possible
- Local data is securely cached with automatic cleanup

### Best Practices

```dart
// Example: Privacy-conscious initialization
final privacyOptions = VisProfilerOptions(
  enableLocation: false,      // Disable location by default
  enableAdId: false,          // Disable advertising ID
  enablePublicIp: false,      // Disable public IP collection
  enableDeviceInfo: true,     // Only collect basic device info
  enableNetworkInfo: true,    // Network info for performance optimization
  enableLogging: false,       // Disable logging in production
);

// Initialize with minimal data collection
Visprofiler.instance.init('your_app_id', null, options: privacyOptions);

// Later, request user consent for additional data
void requestEnhancedAnalytics() async {
  final userConsent = await showConsentDialog(); // Your consent implementation
  
  if (userConsent) {
    final enhancedOptions = VisProfilerOptions(
      enableLocation: true,
      enableAdId: true,
      enablePublicIp: true,
      // ... other options
    );
    
    Visprofiler.instance.updateOptions(enhancedOptions);
  }
}
```

## Error Handling and Debugging

### Enable Logging
```dart
final debugOptions = VisProfilerOptions(
  enableLogging: true,  // Enable detailed console logs
);
```

### Handle Errors Gracefully
```dart
try {
  final result = await Visprofiler.instance.sendData({'event': 'test'});
  
  if (result.success) {
    print('Success: ${result.response}');
  } else {
    print('Error: ${result.error}');
    
    if (result.retryable) {
      // Retry the operation later
      Timer(Duration(seconds: 30), () {
        // Retry logic
      });
    }
  }
} catch (e) {
  print('Exception occurred: $e');
}
```

### Performance Monitoring
```dart
// Monitor SDK performance
final healthCheck = await Visprofiler.instance.healthCheck();
final cacheStatus = healthCheck['cache'];
final sdkStatus = healthCheck['sdk'];

print('Cache hit rate: Device=${cacheStatus['deviceInfoCached']}, Network=${cacheStatus['networkInfoCached']}');
print('Auto-sending active: ${sdkStatus['hasActiveInterval']}');
```

## Resource Management

### Cleanup and Disposal
```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Stop periodic data transmission
    Visprofiler.instance.stopSendingData();
    
    // Clean up SDK resources
    Visprofiler.instance.dispose();
    
    super.dispose();
  }
}
```

## Troubleshooting

### Common Issues

1. **"SDK not initialized" Error**
   ```dart
   // Ensure init() is called before any other SDK methods
   Visprofiler.instance.init('your_app_id', {});
   ```

2. **Location Data Not Available**
   - Check that location permissions are granted
   - Ensure location services are enabled on the device
   - Verify `enableLocation: true` in options

3. **Network Data Missing**
   - Check internet connectivity
   - Verify network permissions in AndroidManifest.xml
   - Ensure `enableNetworkInfo: true` in options

4. **iOS Build Issues**
   - Run `cd ios && pod install --clean-install`
   - Check iOS deployment target is 11.0+
   - Verify Info.plist permissions are correctly configured

5. **Android Build Issues**
   - Check minimum SDK version is 21+
   - Verify all required permissions in AndroidManifest.xml
   - Ensure Google Play Services dependencies are added

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
final debugOptions = VisProfilerOptions(
  enableLogging: true,
);

Visprofiler.instance.init('your_app_id', {}, options: debugOptions);

// Check debug output in console for detailed information
```

## API Reference

### Core Methods

- `init(appId, contact, options)` - Initialize the SDK
- `sendData(extraPayload)` - Send analytics data
- `stopSendingData()` - Stop periodic data transmission
- `updateOptions(options)` - Update configuration at runtime
- `dispose()` - Clean up SDK resources

### Utility Methods

- `checkPermissionStatus()` - Check current permissions
- `requestLocationPermission()` - Request location access
- `healthCheck()` - Get SDK status information
- `testNativeModule()` - Test native functionality

### Properties

- `isInitialized` - Check if SDK is initialized
- `options` - Get current configuration
- `appId` - Get current app ID

## Support

For technical support, feature requests, or bug reports:

- **GitHub Issues**: [https://github.com/auvgffle/visprofiler/issues](https://github.com/auvgffle/visprofiler/issues)
- **Documentation**: [https://github.com/auvgffle/visprofiler#readme](https://github.com/auvgffle/visprofiler#readme)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read the [contributing guidelines](CONTRIBUTING.md) first.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes and version history.
