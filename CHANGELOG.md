# Changelog

All notable changes to the VisProfiler SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-18

### Added
- Initial release of VisProfiler SDK for Flutter
- Device profiling and analytics data collection
- Cross-platform support for Android and iOS
- Real-time data transmission to VisProfiler backend
- Comprehensive device information collection (brand, model, OS version, memory, etc.)
- Network information gathering (WiFi, cellular, connection status, public IP)
- Optional location data collection with permission handling
- Advertising ID collection with proper privacy controls
- Configurable data collection options through `VisProfilerOptions`
- Automatic periodic data sending with customizable intervals
- Robust error handling and retry mechanisms
- Comprehensive logging system with multiple log levels
- Data caching for performance optimization
- Permission management for location services
- JSON serialization for all data models
- Safe fallback mechanisms for data collection failures
- SDK health monitoring and testing utilities
- Support for custom contact information and extra payload data

### Features
- **Device Information**: Collect comprehensive device specs, hardware info, and system details
- **Network Analysis**: Monitor network connectivity, type, and performance metrics
- **Location Services**: Optional GPS/location data with proper permission handling
- **Privacy Controls**: Configurable data collection with advertising ID support
- **Performance**: Efficient data caching and optimized native implementations
- **Reliability**: Robust error handling, retry logic, and fallback mechanisms
- **Logging**: Detailed logging system for debugging and monitoring
- **Customization**: Flexible configuration options and extensible architecture

### Technical Details
- Built with Flutter and Dart
- Native platform implementations for Android and iOS
- JSON-based data serialization with `json_annotation`
- HTTP client for secure data transmission
- Permission handling through `permission_handler` package
- Comprehensive test coverage for all data models
- Modern Dart best practices and null safety
