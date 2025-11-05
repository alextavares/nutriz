import 'package:flutter/foundation.dart';

class AnalyticsService {
  static void track(String event, [Map<String, Object?> extra = const {}]) {
    // Stub: in produção, integre Firebase/Segment/etc
    if (kDebugMode) {
      debugPrint('[analytics] $event ${extra.isEmpty ? '' : extra}');
    }
  }
}

