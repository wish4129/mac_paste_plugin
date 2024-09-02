// File: macos/Classes/MacPastePlugin.swift
import Cocoa
import FlutterMacOS
import AppKit

public class MacPastePlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    private var pasteboardWatcher: Timer?
    private var keyMonitor: Any?
    private var lastChangeCount: Int = 0

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
        if pasteboardWatcher == nil && keyMonitor == nil {
            lastChangeCount = NSPasteboard.general.changeCount
            pasteboardWatcher = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.checkPasteboard()
            }
            
            keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                    DispatchQueue.main.async {
                        self?.checkPasteboard()
                    }
                }
            }
            
            result(true)
        } else {
            NSLog("Paste watcher already running")
            result(FlutterError(code: "ALREADY_RUNNING", message: "Paste watcher is already running", details: nil))
        }
    }
    
    private func checkPasteboard() {
        let currentChangeCount = NSPasteboard.general.changeCount
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            if let clipboardContent = NSPasteboard.general.string(forType: .string) {
                self.channel.invokeMethod("onPaste", arguments: clipboardContent) { result in
                    if let error = result as? FlutterError {
                        NSLog("Error sending paste event to Flutter: \(error.message ?? "Unknown error")")
                    }
                }
            } else {
                NSLog("No text content in clipboard")
            }
        }
    }
    
    private func stop(result: @escaping FlutterResult) {
        pasteboardWatcher?.invalidate()
        pasteboardWatcher = nil
        
        if let keyMonitor = keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
        
        result(true)
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