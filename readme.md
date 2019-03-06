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
