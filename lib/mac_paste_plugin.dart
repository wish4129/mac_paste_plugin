// File: lib/mac_paste_plugin.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MacPastePlugin {
  static final MacPastePlugin instance = MacPastePlugin._();

  MacPastePlugin._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  final MethodChannel _channel = const MethodChannel('mac_paste_plugin');
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onPaste':
          print('MacPastePlugin: Cmd+V event received in Dart');
          _notifyListeners();
          return true;
        default:
          print('MacPastePlugin: Unimplemented method ${call.method}');
          return null;
      }
    } catch (e, stackTrace) {
      print('MacPastePlugin: Error in _methodCallHandler: $e');
      print('MacPastePlugin: Stack trace: $stackTrace');
      return null;
    }
  }

  void _notifyListeners() {
    print('MacPastePlugin: Notifying listeners of Cmd+V event');
    for (final VoidCallback listener in _listeners) {
      try {
        listener();
      } catch (e, stackTrace) {
        print('MacPastePlugin: Error notifying listener: $e');
        print('MacPastePlugin: Stack trace: $stackTrace');
      }
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    print(
        'MacPastePlugin: Listener added. Total listeners: ${_listeners.length}');
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    print(
        'MacPastePlugin: Listener removed. Total listeners: ${_listeners.length}');
  }

  Future<bool> checkPermission() async {
    try {
      final bool? hasPermission =
          await _channel.invokeMethod<bool>('checkPermission');
      return hasPermission ?? false;
    } on PlatformException catch (e) {
      print(
          'MacPastePlugin: PlatformException checking permission: ${e.message}');
      return false;
    } catch (e) {
      print('MacPastePlugin: Error checking permission: $e');
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final bool? granted =
          await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } on PlatformException catch (e) {
      print(
          'MacPastePlugin: PlatformException requesting permission: ${e.message}');
      return false;
    } catch (e) {
      print('MacPastePlugin: Error requesting permission: $e');
      return false;
    }
  }

  Future<void> start() async {
    try {
      bool hasPermission = await checkPermission();

      if (!hasPermission) {
        print('MacPastePlugin: Requesting input monitoring permission...');
        hasPermission = await requestPermission();
      }

      if (hasPermission) {
        final bool? result = await _channel.invokeMethod<bool?>('start');
        print('MacPastePlugin: Cmd+V watcher started: $result');
      } else {
        print('MacPastePlugin: Input monitoring permission denied');
        // You might want to show a dialog to the user here explaining why the permission is needed
        // and how to enable it in System Preferences
      }
    } on PlatformException catch (e) {
      print('MacPastePlugin: PlatformException: ${e.message}');
    } catch (e, stackTrace) {
      print('MacPastePlugin: Unexpected error starting Cmd+V watcher: $e');
      print('MacPastePlugin: Stack trace: $stackTrace');
    }
  }

  Future<void> stop() async {
    try {
      final bool? result = await _channel.invokeMethod<bool?>('stop');
      print('MacPastePlugin: Cmd+V watcher stopped: $result');
    } on PlatformException catch (e) {
      print('MacPastePlugin: Failed to stop Cmd+V watcher: ${e.message}');
    } catch (e, stackTrace) {
      print('MacPastePlugin: Unexpected error stopping Cmd+V watcher: $e');
      print('MacPastePlugin: Stack trace: $stackTrace');
    }
  }
}

final macPastePlugin = MacPastePlugin.instance;
