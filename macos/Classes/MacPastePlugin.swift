// File: macos/Classes/MacPastePlugin.swift
import Cocoa
import FlutterMacOS
import AppKit

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
        case "requestPermission":
            requestPermission(result: result)
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
                        if let clipboardContent = NSPasteboard.general.string(forType: .string) {
                            self?.channel.invokeMethod("onPaste", arguments: clipboardContent) { result in
                                if let error = result as? FlutterError {
                                    NSLog("Error sending Cmd+V event to Flutter: \(error.message ?? "Unknown error")")
                                }
                            }
                        } else {
                            NSLog("No text content in clipboard")
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
    
    private func requestPermission(result: @escaping FlutterResult) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if accessEnabled {
            result(true)
        } else {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Permission Required"
                alert.informativeText = "This app needs permission to monitor key events. Please grant access in System Preferences > Security & Privacy > Privacy > Accessibility."
                alert.addButton(withTitle: "Open System Preferences")
                alert.addButton(withTitle: "Cancel")
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
                
                result(false)
            }
        }
    }
}