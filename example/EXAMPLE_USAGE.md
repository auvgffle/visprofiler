# VisProfiler SDK Example Usage

This document provides comprehensive examples of how to use the VisProfiler Flutter SDK.

## Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:visprofiler/visprofiler.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisProfiler SDK Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _visprofiler = Visprofiler.instance;
  bool _sdkInitialized = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      setState(() {
        _status = 'Requesting permissions...';
      });

      // Step 1: Request necessary permissions
      final permissionStatus = await _visprofiler.requestPermissions();
      
      if (permissionStatus == PermissionStatus.granted) {
        setState(() {
          _status = 'Initializing SDK...';
        });

        // Step 2: Initialize the SDK
        final success = _visprofiler.init(
          'your_app_id_here', // Replace with your actual app ID
          {
            'userId': 'user_12345',
            'email': 'user@example.com',
            'name': 'John Doe',
            'subscription': 'premium',
            'app_version': '1.0.0',
          },
        );

        setState(() {
          _sdkInitialized = success;
          _status = success ? 'SDK initialized successfully!' : 'Failed to initialize SDK';
        });

        if (success) {
          // Step 3: Perform a health check
          await _performHealthCheck();
        }
      } else {
        setState(() {
          _status = 'Permissions required for full functionality';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Initialization error: $e';
      });
    }
  }

  Future<void> _performHealthCheck() async {
    try {
      final health = await _visprofiler.healthCheck();
      print('SDK Health: ${health['sdk']}');
      print('Cache Status: ${health['cache']}');
    } catch (e) {
      print('Health check failed: $e');
    }
  }

  Future<void> _sendCustomData() async {
    if (!_sdkInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SDK not initialized')),
      );
      return;
    }

    try {
      final result = await _visprofiler.sendData({
        'event_type': 'user_interaction',
        'action': 'button_click',
        'screen': 'home',
        'timestamp': DateTime.now().toIso8601String(),
        'user_properties': {
          'is_premium': true,
          'device_theme': 'dark',
        },
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        print('Server response: ${result.response}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send data: ${result.error?['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  Future<void> _testNativeModules() async {
    try {
      final results = await _visprofiler.testNativeModule();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Native Module Test Results'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: results.entries.map((entry) {
                final success = entry.value['success'] == true;
                return ListTile(
                  leading: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                  ),
                  title: Text(entry.key),
                  subtitle: Text(
                    success 
                        ? 'Success: ${entry.value['result']}'
                        : 'Error: ${entry.value['error']}',
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VisProfiler SDK Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'SDK Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _sdkInitialized ? Icons.check_circle : Icons.error,
                          color: _sdkInitialized ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(_status)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sdkInitialized ? _sendCustomData : null,
              child: Text('Send Custom Data'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testNativeModules,
              child: Text('Test Native Modules'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final permissions = await _visprofiler.checkPermissionStatus();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Permission Status'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: permissions.entries.map((entry) {
                        return ListTile(
                          leading: Icon(
                            entry.value == PermissionStatus.granted
                                ? Icons.check_circle
                                : Icons.error,
                            color: entry.value == PermissionStatus.granted
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(entry.key),
                          subtitle: Text(entry.value.name),
                        );
                      }).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Check Permissions'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final success = _visprofiler.stopSendingData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Stopped sending data' 
                          : 'Failed to stop sending data'
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Stop Data Sending'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Advanced Usage Examples

### 1. Permission Handling with User Education

```dart
class PermissionManager {
  final _visprofiler = Visprofiler.instance;

  Future<bool> requestPermissionsWithEducation(BuildContext context) async {
    // Check current status first
    final permissions = await _visprofiler.checkPermissionStatus();
    final needsLocation = permissions['location'] != PermissionStatus.granted;

    if (needsLocation) {
      // Show educational dialog
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Permission'),
          content: Text(
            'This app uses your location to provide personalized content '
            'and analytics. Your privacy is important to us.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Allow'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldRequest) {
        final status = await _visprofiler.requestPermissions();
        
        if (status == PermissionStatus.permanentlyDenied) {
          // Guide user to settings
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Permission Required'),
              content: Text(
                'Please enable location permission in Settings for '
                'the best experience.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _visprofiler.openAppSettings();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        
        return status == PermissionStatus.granted;
      }
    }
    
    return !needsLocation;
  }
}
```

### 2. Custom Event Tracking

```dart
class AnalyticsService {
  final _visprofiler = Visprofiler.instance;

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    await _visprofiler.sendData({
      'event_name': eventName,
      'event_timestamp': DateTime.now().toIso8601String(),
      'properties': properties ?? {},
    });
  }

  Future<void> trackScreenView(String screenName) async {
    await trackEvent(
      eventName: 'screen_view',
      properties: {
        'screen_name': screenName,
        'view_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackUserAction(String action, [Map<String, dynamic>? context]) async {
    await trackEvent(
      eventName: 'user_action',
      properties: {
        'action': action,
        'context': context ?? {},
      },
    );
  }

  Future<void> trackError(String error, [String? stackTrace]) async {
    await trackEvent(
      eventName: 'error',
      properties: {
        'error_message': error,
        'stack_trace': stackTrace,
        'error_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

### 3. Error Handling and Retry Logic

```dart
class RobustSDKManager {
  final _visprofiler = Visprofiler.instance;
  final _analytics = AnalyticsService();

  Future<void> initializeWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      attempts++;
      
      try {
        final permissionStatus = await _visprofiler.requestPermissions();
        
        if (permissionStatus != PermissionStatus.granted) {
          print('Permissions not granted, continuing with limited functionality');
        }

        final success = _visprofiler.init(
          'your_app_id_here',
          await _getUserContext(),
        );

        if (success) {
          print('SDK initialized successfully on attempt $attempts');
          await _performPostInitializationTasks();
          return;
        } else {
          throw Exception('SDK initialization returned false');
        }
      } catch (e) {
        print('Initialization attempt $attempts failed: $e');
        
        if (attempts >= maxRetries) {
          print('All initialization attempts failed');
          await _analytics.trackError('sdk_initialization_failed', e.toString());
          rethrow;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  Future<Map<String, dynamic>> _getUserContext() async {
    // Get user context from your app's state management
    return {
      'user_id': 'current_user_id',
      'subscription_type': 'premium',
      'app_version': '1.0.0',
      'initialization_timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _performPostInitializationTasks() async {
    try {
      // Perform health check
      final health = await _visprofiler.healthCheck();
      print('Post-init health check: ${health['sdk']['initialized']}');
      
      // Test native modules
      final testResults = await _visprofiler.testNativeModule();
      final failedTests = testResults.entries
          .where((entry) => entry.value['success'] != true)
          .map((entry) => entry.key)
          .toList();
      
      if (failedTests.isNotEmpty) {
        await _analytics.trackEvent(
          eventName: 'native_module_failures',
          properties: {'failed_modules': failedTests},
        );
      }
    } catch (e) {
      print('Post-initialization tasks failed: $e');
      // Don't rethrow as this shouldn't block initialization
    }
  }
}
```

### 4. Integration with State Management (Provider)

```dart
import 'package:provider/provider.dart';

class SDKProvider with ChangeNotifier {
  final _visprofiler = Visprofiler.instance;
  
  bool _isInitialized = false;
  String _status = 'Not initialized';
  Map<String, PermissionStatus> _permissions = {};

  bool get isInitialized => _isInitialized;
  String get status => _status;
  Map<String, PermissionStatus> get permissions => _permissions;

  Future<void> initialize() async {
    _updateStatus('Initializing...');
    
    try {
      await _checkPermissions();
      
      final success = _visprofiler.init(
        'your_app_id_here',
        {
          'user_id': 'current_user',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      _isInitialized = success;
      _updateStatus(success ? 'Initialized' : 'Failed to initialize');
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      _permissions = await _visprofiler.checkPermissionStatus();
      notifyListeners();
    } catch (e) {
      print('Permission check failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    await _visprofiler.requestPermissions();
    await _checkPermissions();
  }

  Future<void> sendEvent(String eventName, [Map<String, dynamic>? data]) async {
    if (!_isInitialized) return;
    
    await _visprofiler.sendData({
      'event': eventName,
      'data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _updateStatus(String newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}

// Usage in main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SDKProvider(),
      child: MyApp(),
    ),
  );
}

// Usage in widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SDKProvider>(
      builder: (context, sdkProvider, child) {
        return Column(
          children: [
            Text('SDK Status: ${sdkProvider.status}'),
            ElevatedButton(
              onPressed: sdkProvider.isInitialized
                  ? () => sdkProvider.sendEvent('button_clicked')
                  : null,
              child: Text('Send Event'),
            ),
          ],
        );
      },
    );
  }
}
```

## Best Practices

1. **Initialize Early**: Call SDK initialization in your app's main entry point
2. **Handle Permissions Gracefully**: Always explain why permissions are needed
3. **Error Handling**: Implement proper error handling and fallbacks
4. **Privacy First**: Only collect data you actually need
5. **Test Thoroughly**: Use the test methods to verify functionality
6. **Monitor Health**: Regularly check SDK health in production

## Production Checklist

- [ ] Replace example app ID with your actual app ID
- [ ] Add proper error handling and logging
- [ ] Test permission flows on both platforms
- [ ] Verify network connectivity handling
- [ ] Test with and without permissions
- [ ] Validate data collection compliance
- [ ] Set up proper analytics dashboard
- [ ] Test SDK health monitoring
