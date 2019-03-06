import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class JSBridge {
  static const MethodChannel _channel = const MethodChannel('flutter_jsbridge');

  final Future<String> _idFuture;

  JSBridge(String libraryCode): _idFuture = _channel.invokeMethod('init', <String, dynamic>{ 'libraryCode': libraryCode });

  Future<dynamic> call(String function, dynamic arguments) async {
    return jsonDecode(await _channel.invokeMethod('call', <String, dynamic>{
      'id': await _idFuture,
      'function': function,
      'arguments': jsonEncode(arguments),
    }));
  }
}
