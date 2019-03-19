import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_jsbridge/jsbridge.dart' show JSBridge;
import 'package:tuple/tuple.dart' show Tuple3;

void main() {
  test('Custom Origin', () async {
    final bridge = JSBridge('window.x = () => location.origin', customOrigin: 'https://example.com');
    final result = await bridge.call('x', []) as String;

    expect(result, 'https://example.com');
  });

  test('Incognito', () async {
    const lib = 'window.setItem = localStorage.setItem.bind(localStorage);window.getItem = localStorage.getItem.bind(localStorage)';

    final first = JSBridge(lib, incognito: true);
    await first.call('setItem', ['x', 'x']);
    expect(await first.call('getItem', ['x']) as String, 'x');

    final second = JSBridge(lib, incognito: true);
    expect(await second.call('getItem', ['x']) as String, null);
  });

  // Has to be testWidgets because of: https://github.com/flutter/flutter/issues/27642
  testWidgets('Register functions', (WidgetTester tester) async {
    final bridge = JSBridge('window.callFoobar = (x) => window.foobar(1, 2, x)');

    Tuple3<int, int, String> passedArgs;

    bridge.registerFunction("foobar", (args) {
      passedArgs = Tuple3.fromList(args);
      return "success";
    });

    final returnValue = await bridge.call("callFoobar", ["x"]) as String;

    expect(passedArgs, Tuple3(1, 2, 'x'));
    expect(returnValue, "success");
  });
}
