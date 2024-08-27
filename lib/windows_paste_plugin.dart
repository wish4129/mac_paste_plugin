import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class WindowsPastePlugin {
  static final WindowsPastePlugin instance = WindowsPastePlugin._();

  WindowsPastePlugin._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  final MethodChannel _channel = const MethodChannel('windows_paste_plugin');
  final ObserverList<void Function(String)> _listeners = ObserverList<void Function(String)>();

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onPaste':
          final String clipboardData = call.arguments as String;
          _notifyListeners(clipboardData);
          return true;
        default:
          print('Unimplemented method ${call.method}');
          return null;
      }
    } catch (e, stackTrace) {
      print('Error in _methodCallHandler: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  void _notifyListeners(String clipboardData) {
    for (final listener in _listeners) {
      try {
        listener(clipboardData);
      } catch (e, stackTrace) {
        print('Error notifying listener: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  void addListener(void Function(String) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(String) listener) {
    _listeners.remove(listener);
    print('Listener removed. Total listeners: ${_listeners.length}');
  }

  Future<bool> start() async {
    try {
      final bool? result = await _channel.invokeMethod<bool?>('start');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to start Ctrl+V watcher: ${e.message}');
      return false;
    } catch (e, stackTrace) {
      print('Unexpected error starting Ctrl+V watcher: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      final bool? result = await _channel.invokeMethod<bool?>('stop');
      print('Ctrl+V watcher stopped: $result');
    } on PlatformException catch (e) {
      print('Failed to stop Ctrl+V watcher: ${e.message}');
    } catch (e, stackTrace) {
      print('Unexpected error stopping Ctrl+V watcher: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

final windowsPastePlugin = WindowsPastePlugin.instance;
