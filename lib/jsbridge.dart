import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

typedef FutureOr<Object> BridgeFunction(List<dynamic> arguments);

class JSBridge {
  static const MethodChannel _channel = const MethodChannel('flutter_jsbridge');

  final Future<String> _idFuture;
  final _functions = Map<String, BridgeFunction>();

  JSBridge(String libraryCode, { String customOrigin, bool incognito = false }): _idFuture = _channel.invokeMethod('init', <String, dynamic>{ 'libraryCode': libraryCode, 'customOrigin': customOrigin, 'incognito': incognito }) {
    _idFuture.then((id) {
      final privateChannel = MethodChannel('flutter_jsbridge.$id');

      privateChannel.setMethodCallHandler((call) {
        if (call.method == 'call') {
          final fn = (call.arguments['name'] as String);
          final args = (call.arguments['arguments'] as List<dynamic>).map((arg) => jsonDecode(arg)).toList();
          final result = Future.value(_functions[fn](args));

          return result.then((result) => jsonEncode(result));
        }

        throw MissingPluginException('${call.method} method not implemented on the Dart side.');
      });
    });
  }

  Future<dynamic> call(String function, List<dynamic> arguments) async {
    return jsonDecode(await _channel.invokeMethod('call', <String, dynamic>{
      'id': await _idFuture,
      'function': function,
      'arguments': jsonEncode(arguments),
    }));
  }

  Future<void> registerNamespace(String namespace) async {
    await _channel.invokeMethod('registerNamespace', <String, dynamic>{
      'id': await _idFuture,
      'namespace': namespace,
    });
  }

  Future<void> registerFunction(String name, BridgeFunction fn) async {
    _functions[name] = fn;

    await _channel.invokeMethod('registerFunction', <String, dynamic>{
      'id': await _idFuture,
      'name': name,
    });
  }
}
