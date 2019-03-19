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

extension Resolver where T == String {
    func flutter(_ result: Any) {
        if result as? NSObject == FlutterMethodNotImplemented {
            fatalError("Flutter part responded with FlutterMethodNotImplemented, this should never happen")
        } else if let error = result as? FlutterError {
            reject(JSError(name: "FlutterError", message: error.message ?? "Unknown error", stack: "@[flutter code]", line: 0, column: 0, code: error.code))
        } else if let value = result as? T {
            fulfill(value)
        } else {
            fatalError("Flutter part responded with an invalid result type, this should never happen")
        }
    }
}

extension FlutterMethodChannel {
    func invoke(method: String, _ arguments: [String: Any]) -> Promise<String> {
        return Promise<String> { invokeMethod(method, arguments: arguments, result: $0.flutter) }
    }
}

extension Context {
    func register(flutterFunctionNamed name: String, withChannel channel: FlutterMethodChannel) {
        register(functionNamed: name) { channel.invoke(method: "call", ["name": name, "arguments": $0]) }
    }
}

public class SwiftFlutterJsbridgePlugin: NSObject, FlutterPlugin {
    static var contexts = Dictionary<String, Context>()
    static var channels = Dictionary<String, FlutterMethodChannel>()

    private let messenger: FlutterBinaryMessenger

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_jsbridge", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterJsbridgePlugin(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
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
                SwiftFlutterJsbridgePlugin.channels[id] = FlutterMethodChannel(name: "flutter_jsbridge.\(id)", binaryMessenger: self.messenger)
                result(id)
            case "call":
                let id = (call.arguments as! Dictionary<String, AnyObject>)["id"] as! String
                let function = (call.arguments as! Dictionary<String, AnyObject>)["function"] as! String
                let arguments = (call.arguments as! Dictionary<String, AnyObject>)["arguments"] as! String
                SwiftFlutterJsbridgePlugin.contexts[id]!.rawCall(function: function, args: "...\(arguments)").flutter(result)
            case "registerNamespace":
                let id = (call.arguments as! Dictionary<String, AnyObject>)["id"] as! String
                let namespace = (call.arguments as! Dictionary<String, AnyObject>)["namespace"] as! String
                SwiftFlutterJsbridgePlugin.contexts[id]!.register(namespace: namespace)
                result(nil)
            case "registerFunction":
                let id = (call.arguments as! Dictionary<String, AnyObject>)["id"] as! String
                let name = (call.arguments as! Dictionary<String, AnyObject>)["name"] as! String
                let privateChannel = SwiftFlutterJsbridgePlugin.channels[id]!
                SwiftFlutterJsbridgePlugin.contexts[id]!.register(flutterFunctionNamed: name, withChannel: privateChannel)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
