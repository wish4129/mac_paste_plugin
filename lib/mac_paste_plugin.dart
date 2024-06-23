// File: lib/paste_watcher.dart
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
          print('Cmd+V event received in Dart');
          _notifyListeners();
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

  void _notifyListeners() {
    print('Notifying listeners of Cmd+V event');
    for (final VoidCallback listener in _listeners) {
      try {
        listener();
      } catch (e, stackTrace) {
        print('Error notifying listener: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    print('Listener added. Total listeners: ${_listeners.length}');
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    print('Listener removed. Total listeners: ${_listeners.length}');
  }

  Future<void> start() async {
    try {
      final bool? result = await _channel.invokeMethod<bool?>('start');
      print('Cmd+V watcher started: $result');
    } on PlatformException catch (e) {
      print('Failed to start Cmd+V watcher: ${e.message}');
    } catch (e, stackTrace) {
      print('Unexpected error starting Cmd+V watcher: $e');
      print('Stack trace: $stackTrace');
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
}

final macPastePlugin = MacPastePlugin.instance;