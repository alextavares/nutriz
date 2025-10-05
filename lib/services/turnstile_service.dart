// Conditional export to avoid importing `dart:js_util` on non-web platforms.
// - On Web: uses JS interop implementation to read token from window.
// - On mobile/desktop: no-op stub that returns null.
export 'turnstile/turnstile_stub.dart'
    if (dart.library.html) 'turnstile/turnstile_web.dart';
