import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_jsbridge/jsbridge.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_jsbridge');
  final calls = List<String>();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      calls.add(methodCall.toString());
      return '"foobar"';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('call', () async {
    final bridge = JSBridge('window.foo = () => 42');
    final result = await bridge.call('foo', [1, 2]);

    expect(calls[0], 'MethodCall(init, {libraryCode: window.foo = () => 42})');
    expect(calls[1], 'MethodCall(call, {id: "foobar", function: foo, arguments: [1,2]})');
    expect(result, 'foobar');
  });
}
