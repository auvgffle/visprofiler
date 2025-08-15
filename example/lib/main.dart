import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import 'package:visprofiler/visprofiler.dart';
import 'package:visprofiler/visprofiler_options.dart';
import 'package:visprofiler/visprofiler_method_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _visprofiler = Visprofiler.instance;
  
  // App state
  bool _isInitialized = false;
  bool _isLoading = false;
  String _status = 'Not initialized';
  String _lastResponse = 'No data sent yet';
  Map<String, dynamic> _healthStatus = {};
  Map<String, dynamic> _testResults = {};
  
  // Permission state
  final String _permissionsStatus = 'Permissions will be managed natively';
  
  // Options state - default to all features enabled
  VisProfilerOptions _currentOptions = const VisProfilerOptions();

  @override
  void initState() {
    super.initState();
    // Auto-initialize SDK when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSDKAutomatically();
    });
  }

  Future<void> _initializeSDKAutomatically() async {
    setState(() => _isLoading = true);
    
    try {
      // Auto-initialize with all features enabled
      final options = const VisProfilerOptions(
        enableLocation: true,
        enableNetworkInfo: true,
        enableAdId: true,
        enableDeviceInfo: true,
        enablePublicIp: true,
        enablePeriodicSending: true,
        sendIntervalMs: 30000, // Send every 30 seconds for demo
        enableLogging: true,
        enableCaching: true,
      );
      
      final success = _visprofiler.init(
        'demo_app_12345', // Demo app ID
        {
          'userId': 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'demo@example.com',
          'name': 'Demo User',
          'app_version': '1.0.0',
          'subscription': 'premium',
          'device_type': 'mobile',
        },
        options: options,
      );
      
      setState(() {
        _isInitialized = success;
        _status = success ? 'SDK auto-initialized with all features!' : 'Auto-initialization failed';
        _currentOptions = options;
      });
      
      if (success) {
        _showSnackBar('✅ SDK auto-initialized successfully! Data collection started.', Colors.green);
        // Perform initial health check
        await _performHealthCheck();
        // Send initial data
        await _sendInitialData();
      } else {
        _showSnackBar('❌ SDK auto-initialization failed', Colors.red);
      }
    } catch (e) {
      setState(() => _status = 'Auto-init Error: $e');
      _showSnackBar('❌ SDK auto-initialization error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeSDK() async {
    setState(() => _isLoading = true);
    
    try {
      // Create options based on current settings
      final options = VisProfilerOptions(
        enableLocation: _currentOptions.enableLocation,
        enableNetworkInfo: _currentOptions.enableNetworkInfo,
        enableAdId: _currentOptions.enableAdId,
        enableDeviceInfo: _currentOptions.enableDeviceInfo,
        enablePublicIp: _currentOptions.enablePublicIp,
        enablePeriodicSending: _currentOptions.enablePeriodicSending,
        sendIntervalMs: _currentOptions.sendIntervalMs,
        enableLogging: _currentOptions.enableLogging,
        enableCaching: _currentOptions.enableCaching,
      );
      
      final success = _visprofiler.init(
        'your_app_id_here', // Replace with your actual app ID
        {
          'userId': '12345',
          'email': 'user@example.com',
          'name': 'John Doe',
          'app_version': '1.0.0',
          'subscription': 'premium',
        },
        options: options,
      );
      
      setState(() {
        _isInitialized = success;
        _status = success ? 'SDK initialized with custom options!' : 'Initialization failed';
        _currentOptions = options;
      });
      
      if (success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('SDK initialized successfully!', Colors.green);
        });
        await _performHealthCheck();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('SDK initialization failed', Colors.red);
        });
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
      _showSnackBar('SDK initialization error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendInitialData() async {
    if (!_isInitialized) return;
    
    try {
      final result = await _visprofiler.sendData({
        'event_type': 'app_launch',
        'screen': 'main_screen',
        'user_action': 'auto_initialization',
        'timestamp': DateTime.now().toIso8601String(),
        'session_start': true,
        'auto_init': true,
        'custom_data': {
          'session_id': 'session_${DateTime.now().millisecondsSinceEpoch}',
          'feature_flags': ['auto_init', 'comprehensive_data'],
          'initialization_type': 'automatic',
        },
      });
      
      setState(() {
        _lastResponse = const JsonEncoder.withIndent('  ').convert(result.toJson());
      });
      
      if (result.success) {
        _showSnackBar('📡 Initial data sent automatically!', Colors.blue);
      }
    } catch (e) {
      // Error is already logged by the SDK
      debugPrint('Error sending initial data: $e');
    }
  }

  Future<void> _sendData() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize SDK first', Colors.red);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final result = await _visprofiler.sendData({
        'event_type': 'button_click',
        'screen': 'main_screen',
        'user_action': 'manual_send_data',
        'timestamp': DateTime.now().toIso8601String(),
        'manual_trigger': true,
        'custom_data': {
          'session_id': 'session_${DateTime.now().millisecondsSinceEpoch}',
          'feature_flags': ['manual_send', 'user_interaction'],
          'button_pressed': 'send_data',
        },
      });
      
      setState(() {
        _lastResponse = const JsonEncoder.withIndent('  ').convert(result.toJson());
      });
      
      if (result.success) {
        _showSnackBar('📤 Data sent successfully!', Colors.green);
      } else {
        _showSnackBar('❌ Failed to send data: ${result.error?['message']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('❌ Error sending data: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testModules() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await _visprofiler.testNativeModule();
      setState(() => _testResults = results);
      _showSnackBar('Module tests completed', Colors.blue);
    } catch (e) {
      _showSnackBar('Test failed: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performHealthCheck() async {
    setState(() => _isLoading = true);
    
    try {
      final health = await _visprofiler.healthCheck();
      setState(() => _healthStatus = health);
      _showSnackBar('Health check completed', Colors.blue);
    } catch (e) {
      _showSnackBar('Health check failed: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _stopSending() {
    final success = _visprofiler.stopSendingData();
    _showSnackBar(
      success ? 'Stopped sending data' : 'No active sending to stop',
      success ? Colors.green : Colors.orange,
    );
  }

  void _updateOptions() {
    if (_isInitialized) {
      _visprofiler.updateOptions(_currentOptions);
      _showSnackBar('Options updated successfully', Colors.green);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisProfiler SDK - Options Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _HomeScreen(
        isInitialized: _isInitialized,
        isLoading: _isLoading,
        status: _status,
        permissionsStatus: _permissionsStatus,
        currentOptions: _currentOptions,
        healthStatus: _healthStatus,
        testResults: _testResults,
        lastResponse: _lastResponse,
        onInitialize: _initializeSDK,
        onSendData: _sendData,
        onTestModules: _testModules,
        onPerformHealthCheck: _performHealthCheck,
        onStopSending: _stopSending,
        onUpdateOptions: _updateOptions,
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  final bool isInitialized;
  final bool isLoading;
  final String status;
  final String permissionsStatus;
  final VisProfilerOptions currentOptions;
  final Map<String, dynamic> healthStatus;
  final Map<String, dynamic> testResults;
  final String lastResponse;
  final VoidCallback onInitialize;
  final VoidCallback onSendData;
  final VoidCallback onTestModules;
  final VoidCallback onPerformHealthCheck;
  final VoidCallback onStopSending;
  final VoidCallback onUpdateOptions;

  const _HomeScreen({
    required this.isInitialized,
    required this.isLoading,
    required this.status,
    required this.permissionsStatus,
    required this.currentOptions,
    required this.healthStatus,
    required this.testResults,
    required this.lastResponse,
    required this.onInitialize,
    required this.onSendData,
    required this.onTestModules,
    required this.onPerformHealthCheck,
    required this.onStopSending,
    required this.onUpdateOptions,
  });

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  Map<String, dynamic> _locationPermissionStatus = {};
  Map<String, dynamic> _deviceInfo = {};
  Map<String, dynamic> _networkInfo = {};
  bool _isTestingNative = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _loadIOSSpecificData();
    }
  }

  Future<void> _loadIOSSpecificData() async {
    // Load iOS-specific data for live monitoring
    await _checkLocationPermission();
    await _loadDeviceInfo();
    await _loadNetworkInfo();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final methodChannel = MethodChannelVisprofiler();
      final result = await methodChannel.checkLocationPermission();
      setState(() {
        _locationPermissionStatus = result ?? {};
      });
      print('🍎 iOS Location Permission Status: $result');
    } catch (e) {
      print('❌ Error checking location permission: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final methodChannel = MethodChannelVisprofiler();
      final result = await methodChannel.requestLocationPermission();
      setState(() {
        _locationPermissionStatus = result ?? {};
      });
      print('🍎 iOS Location Permission Request Result: $result');
    } catch (e) {
      print('❌ Error requesting location permission: $e');
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final methodChannel = MethodChannelVisprofiler();
      final result = await methodChannel.getDeviceInfo();
      setState(() {
        _deviceInfo = result ?? {};
      });
      print('🍎 iOS Device Info: ${const JsonEncoder.withIndent('  ').convert(result)}');
    } catch (e) {
      print('❌ Error loading device info: $e');
    }
  }

  Future<void> _loadNetworkInfo() async {
    try {
      final methodChannel = MethodChannelVisprofiler();
      final result = await methodChannel.getNetworkInfo();
      setState(() {
        _networkInfo = result ?? {};
      });
      print('🍎 iOS Network Info: ${const JsonEncoder.withIndent('  ').convert(result)}');
    } catch (e) {
      print('❌ Error loading network info: $e');
    }
  }

  Future<void> _testAllNativeFunctions() async {
    setState(() => _isTestingNative = true);
    
    try {
      final methodChannel = MethodChannelVisprofiler();
      
      // Test platform version
      print('\n🧪 Testing iOS Native Functions:');
      print('================================');
      
      final platformVersion = await methodChannel.getPlatformVersion();
      print('📱 Platform Version: $platformVersion');
      
      // Test Ad ID
      final adId = await methodChannel.getAdId();
      print('📊 Advertising ID: ${adId ?? "Not available (requires permission)"}');
      
      // Test Location
      final location = await methodChannel.getLocation();
      print('📍 Location: ${location != null ? "Available" : "Not available (check permissions)"}');
      if (location != null) {
        print('   Latitude: ${location['latitude']}');
        print('   Longitude: ${location['longitude']}');
        print('   Accuracy: ${location['accuracy']}m');
      }
      
      // Test Public IP
      final publicIp = await methodChannel.getPublicIp();
      print('🌐 Public IP: ${publicIp ?? "Not available"}');
      
      // Reload all data
      await _loadIOSSpecificData();
      
    } catch (e) {
      print('❌ Error testing native functions: $e');
    } finally {
      setState(() => _isTestingNative = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('VisProfiler SDK - Options Demo'),
          backgroundColor: Colors.blue.shade100,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              
              _buildPermissionsCard(),
              const SizedBox(height: 16),
              
              _buildOptionsCard(),
              const SizedBox(height: 16),
              
              _buildActionsCard(),
              const SizedBox(height: 16),
              
              if (Platform.isIOS) _buildIOSSpecificCard(),
              if (Platform.isIOS && _locationPermissionStatus.isNotEmpty) _buildLocationPermissionCard(),
              if (Platform.isIOS && _deviceInfo.isNotEmpty) _buildDeviceInfoCard(),
              if (Platform.isIOS && _networkInfo.isNotEmpty) _buildNetworkInfoCard(),
              
              if (widget.healthStatus.isNotEmpty) _buildHealthCard(),
              if (widget.testResults.isNotEmpty) _buildTestResultsCard(),
              if (widget.lastResponse != 'No data sent yet') _buildResponseCard(),
            ],
          ),
        )
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SDK Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  widget.isInitialized ? Icons.check_circle : Icons.error,
                  color: widget.isInitialized ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.status)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPermissionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Permissions (Host App Managed)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: widget.isLoading ? null : () => debugPrint('Permissions managed by host app'),
                  child: const Text('Native Permissions'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPermissionRow('Location Services', true),
            _buildPermissionRow('Location Permission', true),
            const SizedBox(height: 8),
            Text(
              'Note: Permissions are now managed by your host app. The SDK will only collect data for features you enable when permissions are granted.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.error,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('$label: ${granted ? 'Granted' : 'Denied'}'),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SDK Options (Configurable)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.isInitialized)
                  TextButton(
                    onPressed: widget.onUpdateOptions,
                    child: const Text('Update'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            _buildOptionSwitch(
              'Location Tracking',
              widget.currentOptions.enableLocation,
              (value) => {},
              subtitle: 'Collect GPS coordinates (requires permission)',
            ),
            
            _buildOptionSwitch(
              'Network Info',
              widget.currentOptions.enableNetworkInfo,
              (value) => {},
              subtitle: 'Connection type, carrier info',
            ),
            
            _buildOptionSwitch(
              'Advertising ID',
              widget.currentOptions.enableAdId,
              (value) => {},
              subtitle: 'IDFA/GAID for attribution',
            ),
            
            _buildOptionSwitch(
              'Public IP',
              widget.currentOptions.enablePublicIp,
              (value) => {},
              subtitle: 'External IP address',
            ),
            
            _buildOptionSwitch(
              'Periodic Sending',
              widget.currentOptions.enablePeriodicSending,
              (value) => {},
              subtitle: 'Automatic data transmission',
            ),
            
            _buildOptionSwitch(
              'Caching',
              widget.currentOptions.enableCaching,
              (value) => {},
              subtitle: 'Cache data for performance',
            ),
            
            _buildOptionSwitch(
              'Logging',
              widget.currentOptions.enableLogging,
              (value) => {},
              subtitle: 'Debug console output',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSwitch(
    String title, 
    bool value, 
    Function(bool) onChanged, {
    String? subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onInitialize,
                  child: Text('Initialize SDK'),
                ),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onSendData,
                  child: Text('Send Data'),
                ),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onTestModules,
                  child: Text('Test Native'),
                ),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPerformHealthCheck,
                  child: Text('Health Check'),
                ),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onStopSending,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Stop Sending'),
                ),
              ],
            ),
            if (widget.isLoading)
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHealthCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                JsonEncoder.withIndent('  ').convert(widget.healthStatus),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestResultsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...widget.testResults.entries.map(
              (entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      entry.value['success'] == true
                          ? Icons.check_circle
                          : Icons.error,
                      color: entry.value['success'] == true
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key}: ${entry.value['success'] == true ? 'Success' : entry.value['error']}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResponseCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Response',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.lastResponse,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSSpecificCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🍎 iOS Native Testing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isTestingNative)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ElevatedButton(
                          onPressed: _isTestingNative ? null : _testAllNativeFunctions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Test All'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ElevatedButton(
                          onPressed: _isTestingNative ? null : _checkLocationPermission,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Check Loc'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ElevatedButton(
                          onPressed: _isTestingNative ? null : _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Request Loc'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ElevatedButton(
                          onPressed: _isTestingNative ? null : _loadDeviceInfo,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Device'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ElevatedButton(
                          onPressed: _isTestingNative ? null : _loadNetworkInfo,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Network'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Container(), // Empty space for balance
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These buttons test iOS native functionality directly. Check console for detailed logs.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionCard() {
    final status = _locationPermissionStatus['status'] as String? ?? 'unknown';
    final hasWhenInUse = _locationPermissionStatus['hasWhenInUsePermission'] as bool? ?? false;
    final hasAlways = _locationPermissionStatus['hasAlwaysPermission'] as bool? ?? false;
    final servicesEnabled = _locationPermissionStatus['locationServicesEnabled'] as bool? ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📍 iOS Location Permission Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPermissionStatusRow('Permission Status', status, _getStatusColor(status)),
            _buildPermissionStatusRow('When In Use', hasWhenInUse ? 'Granted' : 'Not Granted', hasWhenInUse ? Colors.green : Colors.red),
            _buildPermissionStatusRow('Always', hasAlways ? 'Granted' : 'Not Granted', hasAlways ? Colors.green : Colors.red),
            _buildPermissionStatusRow('Location Services', servicesEnabled ? 'Enabled' : 'Disabled', servicesEnabled ? Colors.green : Colors.red),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                JsonEncoder.withIndent('  ').convert(_locationPermissionStatus),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 iOS Device Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_deviceInfo.isNotEmpty) ..._buildDeviceInfoRows(),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  JsonEncoder.withIndent('  ').convert(_deviceInfo),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌐 iOS Network Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_networkInfo.isNotEmpty) ..._buildNetworkInfoRows(),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  JsonEncoder.withIndent('  ').convert(_networkInfo),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted_always':
      case 'granted_when_in_use':
        return Colors.green;
      case 'denied':
      case 'restricted':
        return Colors.red;
      case 'not_determined':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildDeviceInfoRows() {
    final List<Widget> rows = [];
    final importantFields = {
      'brand': 'Brand',
      'model': 'Model',
      'systemName': 'System',
      'systemVersion': 'iOS Version',
      'device': 'Device ID',
      'isTablet': 'Is Tablet',
      'screenWidth': 'Screen Width',
      'screenHeight': 'Screen Height',
    };

    for (final entry in importantFields.entries) {
      if (_deviceInfo.containsKey(entry.key)) {
        rows.add(_buildInfoRow(entry.value, _deviceInfo[entry.key].toString()));
      }
    }
    return rows;
  }

  List<Widget> _buildNetworkInfoRows() {
    final List<Widget> rows = [];
    final importantFields = {
      'networkType': 'Network Type',
      'isConnected': 'Connected',
      'hasWifi': 'Has WiFi',
      'hasCellular': 'Has Cellular',
      'ssid': 'WiFi SSID',
      'radioAccessTechnology': 'RAT',
      'networkOperatorName': 'Carrier',
      'isExpensive': 'Expensive',
      'hasVpn': 'VPN Active',
    };

    for (final entry in importantFields.entries) {
      if (_networkInfo.containsKey(entry.key)) {
        rows.add(_buildInfoRow(entry.value, _networkInfo[entry.key].toString()));
      }
    }
    return rows;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
