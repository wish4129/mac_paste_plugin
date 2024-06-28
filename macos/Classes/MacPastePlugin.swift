import FlutterMacOS
import Foundation
import AppKit

public class MacPastePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mac_paste_plugin", binaryMessenger: registrar.messenger)
        let instance = MacPastePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermission":
            result(checkInputMonitoringPermission())
        case "requestPermission":
            requestInputMonitoringPermission { granted in
                result(granted)
            }
        case "start":
            // Implement your start logic here
            result(true)  // Replace with actual implementation
        case "stop":
            // Implement your stop logic here
            result(true)  // Replace with actual implementation
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func checkInputMonitoringPermission() -> Bool {
        return AXIsProcessTrusted()
    }

    private func requestInputMonitoringPermission(completion: @escaping (Bool) -> Void) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
        
        // Since the permission prompt is asynchronous, we need to wait a bit before checking the result
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let granted = AXIsProcessTrusted()
            completion(granted)
        }
    }
}
