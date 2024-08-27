import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MacPastePlugin {
  static final MacPastePlugin instance = MacPastePlugin._();

  MacPastePlugin._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  final MethodChannel _channel = const MethodChannel('mac_paste_plugin');
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
      final bool hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Permission not granted. Cannot start Cmd+V watcher.');
        return false;
      }

      final bool? result = await _channel.invokeMethod<bool?>('start');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to start Cmd+V watcher: ${e.message}');
      return false;
    } catch (e, stackTrace) {
      print('Unexpected error starting Cmd+V watcher: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      final bool? result = await _channel.invokeMethod<bool?>('stop');
      print('Cmd+V watcher stopped: $result');
    } on PlatformException catch (e) {
      print('Failed to stop Cmd+V watcher: ${e.message}');
    } catch (e, stackTrace) {
      print('Unexpected error stopping Cmd+V watcher: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final bool? result =
          await _channel.invokeMethod<bool?>('requestPermission');
      print('Permission request result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to request permission: ${e.message}');
      return false;
    } catch (e, stackTrace) {
      print('Unexpected error requesting permission: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
}

final macPastePlugin = MacPastePlugin.instance;
