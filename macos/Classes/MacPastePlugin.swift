// File: macos/Classes/PasteWatcherPlugin.swift
import Cocoa
import FlutterMacOS

public class MacPastePlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    private var monitor: Any?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mac_paste_plugin", binaryMessenger: registrar.messenger)
        let instance = MacPastePlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            start(result: result)
        case "stop":
            stop(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func start(result: @escaping FlutterResult) {
        if monitor == nil {
            NSLog("Starting Cmd+V watcher")
            monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                    NSLog("Cmd+V detected")
                    DispatchQueue.main.async {
                        self?.channel.invokeMethod("onPaste", arguments: nil) { result in
                            if let error = result as? FlutterError {
                                NSLog("Error sending Cmd+V event to Flutter: \(error.message ?? "Unknown error")")
                            } else {
                                NSLog("Cmd+V event sent to Flutter successfully")
                            }
                        }
                    }
                }
            }
            result(true)
        } else {
            NSLog("Cmd+V watcher already running")
            result(FlutterError(code: "ALREADY_RUNNING", message: "Cmd+V watcher is already running", details: nil))
        }
    }
    
    private func stop(result: @escaping FlutterResult) {
        if let monitor = monitor {
            NSLog("Stopping Cmd+V watcher")
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
            result(true)
        } else {
            NSLog("Cmd+V watcher not running")
            result(FlutterError(code: "NOT_RUNNING", message: "Cmd+V watcher is not running", details: nil))
        }
    }
}