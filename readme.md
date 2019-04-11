# JSBridge for Flutter

Bridge your JavaScript library for usage in Flutter 🚀

## Usage

```dart
import 'package:flutter_jsbridge/jsbridge.dart';

final _libraryCode = """
  window.Foobar = {
    add (a, b) {
      return a + b
    },
    greet (name) {
      return `Hello, \${name}!`
    },
    async fetch (url) {
      const response = await fetch(url)
      const body = await response.text()

      return { status: response.status, body }
    }
  }
""";

class FetchResponse {
  final int status;
  final String body;

  FetchResponse(dynamic data): status = data['status'], body = data['body'];
}

class Foobar {
  static final _bridge = JSBridge(_libraryCode);

  static Future<int> add(int lhs, int rhs) async {
    return await Foobar._bridge.call("Foobar.add", [lhs, rhs]);
  }

  static Future<String> greet(String name) async {
    return await Foobar._bridge.call("Foobar.greet", [name]);
  }

  static Future<FetchResponse> fetch(String url) async {
    return FetchResponse(await Foobar._bridge.call("Foobar.fetch", [url]));
  }
}
```

## iOS

To be able to use JSBridge on iOS, you need to give JSBridge a hook to your view hierarchy. Otherwise the `WKWebView` will get suspended by the OS, and your Promises will never settle.

This is accomplished by using the `setGlobalUIHook` function before instantiating any `JSBridge` instances.

**Flutter:**

If you have a non-modified Flutter application, this should be added to `ios/Runner/AppDelegate.swift`, in the `application(_:didFinishLaunchingWithOptions:)` function.

```diff
--- a/ios/Runner/AppDelegate.swift
+++ b/ios/Runner/AppDelegate.swift
@@ -1,5 +1,6 @@
 import UIKit
 import Flutter
+import flutter_jsbridge

 @UIApplicationMain
 @objc class AppDelegate: FlutterAppDelegate {
   override func application(
     _ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
   ) -> Bool {
+    SwiftFlutterJsbridgePlugin.setGlobalUIHook(window: UIApplication.shared.windows.first!)
     GeneratedPluginRegistrant.register(with: self)
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
   }
```

**App:**

```swift
// Can be called from anywhere, e.g. your AppDelegate
SwiftFlutterJsbridgePlugin.setGlobalUIHook(window: UIApplication.shared.windows.first!)
```

**App Extension:**

```swift
// From within your root view controller
SwiftFlutterJsbridgePlugin.setGlobalUIHook(viewController: self)
```
