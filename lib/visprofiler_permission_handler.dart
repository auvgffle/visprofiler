import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'visprofiler_logger.dart';

class VisProfilerPermissionHandler {
  final VisProfilerLogger _logger = VisProfilerLogger();
  
  /// Check and request all necessary permissions
  Future<PermissionStatus> requestAllPermissions() async {
    try {
      _logger.logInfo('Permissions', 'Starting permission request process...');
      
      final permissions = <Permission>[];
      
      // Location permissions
      if (Platform.isAndroid) {
        permissions.addAll([
          Permission.locationWhenInUse,
          Permission.locationAlways,
        ]);
      } else if (Platform.isIOS) {
        permissions.add(Permission.locationWhenInUse);
      }
      
      // Phone permission for carrier info (Android only)
      if (Platform.isAndroid) {
        permissions.add(Permission.phone);
      }
      
      // Request permissions
      final Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      // Log permission results
      for (final entry in statuses.entries) {
        _logger.logInfo('Permissions', '${entry.key.toString()}: ${entry.value.toString()}');
      }
      
      // Check if location permission was granted
      final locationStatus = Platform.isAndroid 
          ? statuses[Permission.locationWhenInUse] ?? PermissionStatus.denied
          : statuses[Permission.locationWhenInUse] ?? PermissionStatus.denied;
          
      if (locationStatus.isGranted) {
        _logger.logSuccess('Permissions', 'Essential permissions granted successfully');
        return PermissionStatus.granted;
      } else if (locationStatus.isPermanentlyDenied) {
        _logger.logWarning('Permissions', 'Location permission permanently denied');
        return PermissionStatus.permanentlyDenied;
      } else {
        _logger.logWarning('Permissions', 'Location permission denied');
        return PermissionStatus.denied;
      }
    } catch (error) {
      _logger.logError('Permissions', 'Permission request failed: ${error.toString()}');
      return PermissionStatus.denied;
    }
  }
  
  /// Check current permission status
  Future<Map<String, PermissionStatus>> checkPermissionStatus() async {
    final result = <String, PermissionStatus>{};
    
    try {
      // Location permissions
      result['location'] = await Permission.locationWhenInUse.status;
      
      // Phone permission (Android only)
      if (Platform.isAndroid) {
        result['phone'] = await Permission.phone.status;
      }
      
      _logger.logInfo('Permissions', 'Permission status checked: $result');
      return result;
    } catch (error) {
      _logger.logError('Permissions', 'Permission status check failed: ${error.toString()}');
      return result;
    }
  }
  
  /// Request location permission specifically
  Future<PermissionStatus> requestLocationPermission() async {
    try {
      _logger.logInfo('Permissions', 'Requesting location permission...');
      
      final status = await Permission.locationWhenInUse.request();
      
      switch (status) {
        case PermissionStatus.granted:
          _logger.logSuccess('Permissions', 'Location permission granted');
          break;
        case PermissionStatus.denied:
          _logger.logWarning('Permissions', 'Location permission denied');
          break;
        case PermissionStatus.permanentlyDenied:
          _logger.logWarning('Permissions', 'Location permission permanently denied');
          break;
        case PermissionStatus.restricted:
          _logger.logWarning('Permissions', 'Location permission restricted');
          break;
        case PermissionStatus.limited:
          _logger.logWarning('Permissions', 'Location permission limited');
          break;
        case PermissionStatus.provisional:
          _logger.logInfo('Permissions', 'Location permission provisional');
          break;
      }
      
      return status;
    } catch (error) {
      _logger.logError('Permissions', 'Location permission request failed: ${error.toString()}');
      return PermissionStatus.denied;
    }
  }
  
  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    try {
      _logger.logInfo('Permissions', 'Opening app settings...');
      final result = await Permission.locationWhenInUse.request().then((_) => 
          Permission.locationWhenInUse.isPermanentlyDenied).then((isDenied) async {
        if (isDenied) {
          return await openAppSettings();
        }
        return true;
      });
      
      _logger.logSuccess('Permissions', 'App settings request processed');
      return result;
    } catch (error) {
      _logger.logError('Permissions', 'Failed to open app settings: ${error.toString()}');
      return false;
    }
  }
  
  /// Check if permission should show rationale
  Future<bool> shouldShowRequestPermissionRationale(Permission permission) async {
    try {
      return await permission.shouldShowRequestRationale;
    } catch (error) {
      _logger.logError('Permissions', 'Failed to check rationale: ${error.toString()}');
      return false;
    }
  }
  
  /// Get user-friendly permission status message
  String getPermissionMessage(PermissionStatus status, String permissionName) {
    switch (status) {
      case PermissionStatus.granted:
        return '$permissionName permission is granted';
      case PermissionStatus.denied:
        return '$permissionName permission is required for full functionality';
      case PermissionStatus.permanentlyDenied:
        return '$permissionName permission is permanently denied. Please enable it in app settings';
      case PermissionStatus.restricted:
        return '$permissionName permission is restricted on this device';
      case PermissionStatus.limited:
        return '$permissionName permission is limited';
      case PermissionStatus.provisional:
        return '$permissionName permission is provisional';
    }
  }
}
