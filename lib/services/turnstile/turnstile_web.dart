// Web implementation using JS interop to read token from window helpers.
// Requires web/index.html to define getTurnstileToken() and requestTurnstileRefresh().
import 'package:js/js_util.dart' as jsu;

class TurnstileService {
  static Future<String?> getToken({bool allowRefresh = true}) async {
    try {
      final token = jsu.callMethod<Object?>(jsu.globalThis, 'getTurnstileToken', const []);
      final s = token?.toString();
      if ((s == null || s.isEmpty) && allowRefresh) {
        try { jsu.callMethod(jsu.globalThis, 'requestTurnstileRefresh', const []); } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final token2 = jsu.callMethod<Object?>(jsu.globalThis, 'getTurnstileToken', const []);
        return token2?.toString();
      }
      return s;
    } catch (_) {
      return null;
    }
  }
}
