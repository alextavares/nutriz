import 'package:flutter/material.dart';

import '../../core/app_export.dart';

/// Temporary restoration of FoodLoggingScreen.
/// The previous file content was corrupted by a single-line comment
/// swallowing the entire file, breaking symbol resolution.
/// This lightweight screen unblocks the build; we can re-sync
/// the full implementation from `nutritracker_clean` if desired.
class FoodLoggingScreen extends StatelessWidget {
  const FoodLoggingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Logging'),
      ),
      backgroundColor: AppTheme.primaryBackgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.restaurant, size: 56),
            SizedBox(height: 12),
            Text(
              'Food Logging screen placeholder',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Restored to fix build. Full UI can be re-synced.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

