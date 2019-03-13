import WebKit
import Flutter
import UIKit
import PromiseKit

extension Promise {
    func flutter(_ result: @escaping FlutterResult) {
        self.done {
            result($0)
        }.catch {
            if let err = $0 as? JSError {
                result(FlutterError(code: err.code ?? "EUNKNOWN", message: err.message, details: nil))
            } else {
                result(FlutterError(code: "EUNKNOWN", message: $0.localizedDescription, details: nil))
            }
        }
    }
}

public class SwiftFlutterJsbridgePlugin: NSObject, FlutterPlugin {
    static var contexts = Dictionary<String, Context>()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_jsbridge", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterJsbridgePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "init":
                let id = UUID().uuidString
                let libraryCode = (call.arguments as! Dictionary<String, AnyObject>)["libraryCode"] as! String
                let customOrigin = ((call.arguments as! Dictionary<String, AnyObject>)["customOrigin"] as? String).map { URL(string: $0)! }
                let incognito = (call.arguments as! Dictionary<String, AnyObject>)["incognito"] as! Bool
                let context = Context(libraryCode: libraryCode, customOrigin: customOrigin, incognito: incognito)
                UIApplication.shared.windows.first?.addSubview(context.webView)
                SwiftFlutterJsbridgePlugin.contexts[id] = context
                result(id)
            case "call":
                let id = (call.arguments as! Dictionary<String, AnyObject>)["id"] as! String
                let function = (call.arguments as! Dictionary<String, AnyObject>)["function"] as! String
                let arguments = (call.arguments as! Dictionary<String, AnyObject>)["arguments"] as! String
                SwiftFlutterJsbridgePlugin.contexts[id]!.rawCall(function: function, args: "...\(arguments)").flutter(result)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
