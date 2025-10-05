// Non-web stub: no Turnstile available. Always returns null.
class TurnstileService {
  static Future<String?> getToken({bool allowRefresh = true}) async => null;
}
