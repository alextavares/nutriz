import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutritracker/services/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setGoals and getGoals persist and return expected values', () async {
    await UserPreferences.setGoals(
      totalCalories: 2100,
      carbs: 260,
      proteins: 130,
      fats: 70,
    );
    await UserPreferences.setWaterGoal(2300);
    final goals = await UserPreferences.getGoals();
    expect(goals.totalCalories, 2100);
    expect(goals.carbs, 260);
    expect(goals.proteins, 130);
    expect(goals.fats, 70);
    expect(goals.waterGoalMl, 2300);
  });

  test('setHydrationReminder and getHydrationReminder work', () async {
    await UserPreferences.setHydrationReminder(
      enabled: true,
      intervalMinutes: 45,
    );
    final hr = await UserPreferences.getHydrationReminder();
    expect(hr.enabled, true);
    expect(hr.intervalMinutes, 45);
  });
}

