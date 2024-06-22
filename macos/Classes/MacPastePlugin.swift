import FlutterMacOS
import Cocoa

public class MacPastePlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.example/macos_paste_plugin", binaryMessenger: registrar.messenger)
        let instance = MacOsPastePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
            if event.modifierFlags.contains(.command) && event.characters == "v" {
                let pasteboard = NSPasteboard.general
                if let string = pasteboard.string(forType: .string) {
                    channel?.invokeMethod("onPaste", arguments: string)
                }
            }
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPasteboardContents":
            let pasteboard = NSPasteboard.general
            if let string = pasteboard.string(forType: .string) {
                result(string)
            } else {
                result(FlutterError(code: "NO_CONTENT", message: "No string content in pasteboard", details: nil))
            }
        case "simulatePasteEvent":
            if let content = call.arguments as? String {
                MacOsPastePlugin.channel?.invokeMethod("onPaste", arguments: content)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected string argument", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
