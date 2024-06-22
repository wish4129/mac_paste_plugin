import 'dart:async';
import 'package:flutter/services.dart';

class MacPastePlugin {
  static const MethodChannel _channel =
      MethodChannel('xionapps.com/mac_paste_plugin');
  static Function(String)? onPaste;

  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethod);
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onPaste':
        final String pastedText = call.arguments;
        onPaste?.call(pastedText);
        break;
      default:
        print('Unimplemented method ${call.method}');
    }
  }

  static Future<String?> getPasteboardContents() async {
    try {
      return await _channel.invokeMethod('getPasteboardContents');
    } on PlatformException catch (e) {
      print('Failed to get pasteboard contents: ${e.message}');
      return null;
    }
  }

  static Future<void> simulatePasteEvent(String content) async {
    await _channel.invokeMethod('simulatePasteEvent', content);
  }
}
