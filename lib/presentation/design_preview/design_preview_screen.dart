import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../daily_tracking_dashboard/daily_tracking_dashboard.dart';
import '../food_logging_screen/food_logging_screen.dart';
import '../ai_food_detection_screen/ai_food_detection_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../weekly_progress_screen/weekly_progress_screen.dart';
import '../progress_overview/progress_overview.dart';

class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  final List<String> _refs = const [
    'assets/images/ref_yazio_01.jpg',
    'assets/images/ref_yazio_02.jpg',
  ];
  int _currentRef = 0;

  final Map<String, Widget> _screens = {
    'Dashboard': const DailyTrackingDashboard(),
    'Food Logging': const FoodLoggingScreen(),
    'AI Detection': const AiFoodDetectionScreen(),
    'Weekly Progress': const WeeklyProgressScreen(),
    'Progress Overview': const ProgressOverviewScreen(),
    'Profile': const ProfileScreen(),
  };
  String _currentScreen = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBackgroundDark,
      appBar: AppBar(
        title: const Text('Design Preview'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _currentRef,
              onChanged: (v) => setState(() => _currentRef = v ?? 0),
              items: List.generate(
                _refs.length,
                (i) => DropdownMenuItem(value: i, child: Text('Ref ${i + 1}')),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentScreen,
              onChanged: (v) => setState(() => _currentScreen = v ?? 'Dashboard'),
              items: _screens.keys
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.primaryBackgroundDark,
                  border: Border.all(color: AppTheme.dividerGray),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3,
                    child: Image.asset(
                      _refs[_currentRef],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(color: AppTheme.dividerGray, width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.primaryBackgroundDark,
                  border: Border.all(color: AppTheme.dividerGray),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _screens[_currentScreen]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
