import 'package:health/health.dart';

class HealthService {
  // Updated for health >= 13.x which exposes `Health` (not `HealthFactory`).
  final Health _health = Health();

  static final List<HealthDataType> _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  static final List<HealthDataAccess> _perms = <HealthDataAccess>[
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<bool> connect() async {
    try {
      // health >= 13 requires configure() to be called before use
      await _health.configure();
      final ok = await _health.requestAuthorization(_types, permissions: _perms);
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<int> stepsForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final total = await _health.getTotalStepsInInterval(start, end);
    return total ?? 0;
  }

  Future<double> activeEnergyForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: [HealthDataType.ACTIVE_ENERGY_BURNED],
    );
    double sum = 0;
    for (final d in data) {
      final v = (d.value is num) ? (d.value as num).toDouble() : 0.0;
      sum += v;
    }
    return sum; // kcal
  }

  Future<double> distanceForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: [HealthDataType.DISTANCE_WALKING_RUNNING],
    );
    double sum = 0;
    for (final d in data) {
      final v = (d.value is num) ? (d.value as num).toDouble() : 0.0;
      sum += v; // metros
    }
    return sum;
  }
}
