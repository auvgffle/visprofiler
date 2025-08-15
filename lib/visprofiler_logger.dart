import 'dart:developer' as developer;

class VisProfilerLogger {
  // Icons (no ANSI colors to avoid truncation)
  static const String _successIcon = '✅';
  static const String _errorIcon = '❌';
  static const String _warningIcon = '⚠️';
  static const String _infoIcon = 'ℹ️';
  static const String _locationIcon = '📍';
  static const String _networkIcon = '🌐';
  static const String _zapIcon = '⚡';
  static const String _databaseIcon = '💾';
  static const String _clockIcon = '⏰';
  static const String _sendIcon = '📤';

  void _safeLog(String level, String context, String icon, String message, [List<dynamic>? args]) {
    try {
      // Use clean formatting without ANSI escape codes to prevent truncation
      final cleanMessage = '$icon [SDK][$context] $message';
      final argsString = args != null && args.isNotEmpty ? ' ${args.join(' ')}' : '';
      final fullMessage = '$cleanMessage$argsString';
      
      // Use developer.log for structured logging
      if (level == 'error') {
        developer.log(
          fullMessage,
          name: 'SDK.$context',
          level: 1000,
          error: message,
        );
      } else {
        developer.log(
          fullMessage,
          name: 'SDK.$context',
          level: level == 'warn' ? 900 : 800,
        );
      }
      
      // Always print to console for immediate visibility
      // Split long messages into chunks to avoid truncation
      _printInChunks(fullMessage);
      
    } catch (e) {
      // Fallback logging without formatting
      _printInChunks('[SDK][$context] $message ${args?.join(' ') ?? ''}');
    }
  }
  
  void _printInChunks(String message, {int chunkSize = 800}) {
    try {
      if (message.length <= chunkSize) {
        // ignore: avoid_print
        print(message);
        return;
      }
      
      // Split into chunks for very long messages
      for (int i = 0; i < message.length; i += chunkSize) {
        final end = (i + chunkSize < message.length) ? i + chunkSize : message.length;
        final chunk = message.substring(i, end);
        final chunkInfo = i == 0 ? '' : ' (part ${(i ~/ chunkSize) + 1})';
        // ignore: avoid_print
        print('$chunk$chunkInfo');
      }
    } catch (e) {
      // Final fallback
      // ignore: avoid_print
      print('[LOG_ERROR] Failed to log message: $e');
    }
  }

  void logSuccess(String context, String message, [List<dynamic>? args]) {
    _safeLog('success', context, _successIcon, message, args);
  }

  void logError(String context, String message, [List<dynamic>? args]) {
    _safeLog('error', context, _errorIcon, message, args);
  }

  void logWarning(String context, String message, [List<dynamic>? args]) {
    _safeLog('warn', context, _warningIcon, message, args);
  }

  void logInfo(String context, String message, [List<dynamic>? args]) {
    _safeLog('info', context, _infoIcon, message, args);
  }

  void logApiCall(String context, String method, String url, [String? extra]) {
    final message = '$method $url${extra != null ? ' - $extra' : ''}';
    _safeLog('info', context, _sendIcon, message);
  }

  void logApiResponse(String context, int status, int duration, [String? extra]) {
    final icon = status >= 200 && status < 300 ? _successIcon : _errorIcon;
    final level = status >= 200 && status < 300 ? 'success' : 'error';
    final message = 'Response $status in ${duration}ms${extra != null ? ' - $extra' : ''}';
    _safeLog(level, context, icon, message);
  }

  void logNetwork(String context, String message, [List<dynamic>? args]) {
    _safeLog('info', context, _networkIcon, message, args);
  }

  void logLocation(String context, String message, [List<dynamic>? args]) {
    _safeLog('info', context, _locationIcon, message, args);
  }

  void logPerformance(String context, String message, [List<dynamic>? args]) {
    _safeLog('info', context, _zapIcon, message, args);
  }

  void logCaching(String context, String message, [List<dynamic>? args]) {
    _safeLog('info', context, _databaseIcon, message, args);
  }

  void logScheduler(String context, String message, [List<dynamic>? args]) {
    _safeLog('info', context, _clockIcon, message, args);
  }
}
