import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

abstract class MacPasteDelegate {
  void onPaste(String clipboardData);
}

class MacPastePlugin {
  static final MacPastePlugin instance = MacPastePlugin._();

  MacPastePlugin._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  final MethodChannel _channel = const MethodChannel('mac_paste_plugin');
  MacPasteDelegate? _delegate;

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onPaste':
          final String clipboardData = call.arguments as String;
          _delegate?.onPaste(clipboardData);
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

  void setDelegate(MacPasteDelegate delegate) {
    _delegate = delegate;
    print('Delegate set');
  }

  void removeDelegate() {
    _delegate = null;
    print('Delegate removed');
  }

  Future<bool> start() async {
    try {
      final bool hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Permission not granted. Cannot start Cmd+V watcher.');
        return false;
      }

      final bool? result = await _channel.invokeMethod<bool?>('start');
      print('Cmd+V watcher started: $result');
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
