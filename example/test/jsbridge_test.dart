import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_jsbridge/jsbridge.dart' show JSBridge;

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
}
