// File: macos/Classes/MacPastePlugin.swift
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
        NSLog("MacPastePlugin: Checking for permissions")
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            NSLog("MacPastePlugin: Input Monitoring permission not granted")
            result(FlutterError(code: "PERMISSION_DENIED", message: "Input Monitoring permission not granted", details: nil))
            return
        }
        
        NSLog("MacPastePlugin: Starting Cmd+V watcher")
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // ... rest of the code ...
        }
        result(true)
    } else {
        NSLog("MacPastePlugin: Cmd+V watcher already running")
        result(FlutterError(code: "ALREADY_RUNNING", message: "Cmd+V watcher is already running", details: nil))
    }
}
    
    private func stop(result: @escaping FlutterResult) {
        if let monitor = monitor {
            NSLog("MacPastePlugin: Stopping Cmd+V watcher")
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
            result(true)
        } else {
            NSLog("MacPastePlugin: Cmd+V watcher not running")
            result(FlutterError(code: "NOT_RUNNING", message: "Cmd+V watcher is not running", details: nil))
        }
    }
}