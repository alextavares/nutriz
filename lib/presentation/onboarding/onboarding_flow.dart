import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';
import '../../services/streak_service.dart';
import '../../services/user_preferences.dart';
import '../../services/notifications_service.dart';
import '../../services/gamification_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple, reusable onboarding flow inspired by YAZIO screens.
/// Steps: Welcome/Info -> Commitment (streak) -> Goals (opens wizard) -> Finish
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _kOnboardingCompleted = 'onboarding_completed_v1';

  final PageController _controller = PageController();
  int _index = 0;
  bool _busy = false;

  Future<void> _finish() async {
    setState(() => _busy = true);
    try {
      // Persist completion so splash goes to next appropriate screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingCompleted, true);
      await prefs.setBool('is_first_launch', false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login-screen');
  }

  void _next() {
    if (_index < 3) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index == 0) {
      Navigator.pop(context);
    } else {
      _controller.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)?.onbWelcome ?? 'Welcome'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _index, total: 4),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _InfoStep(
                    title: AppLocalizations.of(context)?.onbInfoTitle ?? "It's okay to be imperfect",
                    body: AppLocalizations.of(context)?.onbInfoBody ?? 'We will build habits gradually. Focus on consistency, not perfection.',
                    icon: Icons.balance,
                  ),
                  const _CommitmentStep(),
                  const _GoalsStep(),
                  const _RemindersStep(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _next,
                  child: Text(_index < 3 ? (AppLocalizations.of(context)?.continueLabel ?? 'Continue') : (AppLocalizations.of(context)?.finishLabel ?? 'Finish')),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    final p = (current + 1) / total;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: p,
          minHeight: 6,
          backgroundColor: AppTheme.dividerGray.withValues(alpha: 0.4),
          color: AppTheme.activeBlue,
        ),
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  const _InfoStep({required this.title, required this.body, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.secondaryBackgroundDark,
              child: Icon(icon, size: 48, color: AppTheme.activeBlue),
            ),
          ),
          SizedBox(height: 3.h),
          Text(title, style: AppTheme.darkTheme.textTheme.headlineSmall),
          SizedBox(height: 1.4.h),
          Text(
            body,
            style: AppTheme.darkTheme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _CommitmentStep extends StatefulWidget {
  const _CommitmentStep();
  @override
  State<_CommitmentStep> createState() => _CommitmentStepState();
}

class _CommitmentStepState extends State<_CommitmentStep> {
  late Future<List<bool>> _week;

  @override
  void initState() {
    super.initState();
    _week = _load();
  }

  Future<List<bool>> _load() async {
    final now = DateTime.now();
    final List<bool> days = [];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      days.add(await StreakService.isCompleted('commitment', d));
    }
    return days;
  }

  Future<void> _commitToday() async {
    await StreakService.markCompleted('commitment', DateTime.now());
    // Fire a gamification event so simple achievements can be created
    // (handled by GamificationEngine)
    // Ignore the returned celebration flag here; onboarding keeps flow simple
    unawaited(GamificationEngine.I.fire(
      GamificationEvent(type: GamificationEventType.goalCompleted, metaKey: 'commitment'),
    ));
    if (!mounted) return;
    setState(() => _week = _load());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.onbCommitToday ?? 'Commitment marked for today'),
          backgroundColor: AppTheme.successGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.h),
          Center(
            child: Column(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 56),
                SizedBox(height: 0.5.h),
                Text(AppLocalizations.of(context)?.dayStreak ?? 'Day Streak',
                    style: AppTheme.darkTheme.textTheme.titleLarge),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                FutureBuilder<List<bool>>(
                  future: _week,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? List<bool>.filled(7, false);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final done = data[i];
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: done
                                  ? AppTheme.successGreen
                                  : AppTheme.dividerGray.withValues(alpha: 0.4),
                              child: Icon(
                                done ? Icons.local_fire_department : Icons.flag_outlined,
                                size: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.6.h),
                            Text(labels[i],
                                style: AppTheme.darkTheme.textTheme.bodySmall),
                          ],
                        );
                      }),
                    );
                  },
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)?.onbCongratsStreak ?? 'Great! You started your streak. Keep it up!',
                  textAlign: TextAlign.center,
                  style: AppTheme.darkTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Center(
            child: OutlinedButton(
              onPressed: _commitToday,
              child: Text(AppLocalizations.of(context)?.onbImCommitted ?? "I'm committed"),
            ),
          )
        ],
      ),
    );
  }
}

class _GoalsStep extends StatelessWidget {
  const _GoalsStep();

  Future<void> _openWizard(BuildContext context) async {
    final ok = await Navigator.of(context).pushNamed('/goals-wizard');
    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.goalsSet ?? 'Goals set'),
            backgroundColor: AppTheme.successGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.secondaryBackgroundDark,
              child: Icon(Icons.track_changes, size: 48, color: AppTheme.activeBlue),
            ),
          ),
          SizedBox(height: 3.h),
          Text(AppLocalizations.of(context)?.defineGoalsTitle ?? 'Set your goals',
              style: AppTheme.darkTheme.textTheme.headlineSmall),
          SizedBox(height: 1.4.h),
          Text(
            AppLocalizations.of(context)?.defineGoalsBody ?? 'Adjust calories and macros to your target. You can change later.',
            style: AppTheme.darkTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 3.h),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _openWizard(context),
              icon: const Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)?.openGoalsWizard ?? 'Open goals wizard'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemindersStep extends StatefulWidget {
  const _RemindersStep();

  @override
  State<_RemindersStep> createState() => _RemindersStepState();
}

class _RemindersStepState extends State<_RemindersStep> {
  bool _enabled = true;
  final TextEditingController _intervalCtrl = TextEditingController(text: '60');
  bool _requesting = false;

  Future<void> _requestNotifs() async {
    setState(() => _requesting = true);
    try {
      await NotificationsService.initialize();
      await NotificationsService.requestPermissionsIfNeeded();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.notificationsConfigured ?? 'Notifications configured'), backgroundColor: AppTheme.activeBlue),
      );
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _savePrefs() async {
    final interval = int.tryParse(_intervalCtrl.text.trim()) ?? 60;
    await UserPreferences.setHydrationReminder(enabled: _enabled, intervalMinutes: interval.clamp(10, 240));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.remindersSaved ?? 'Reminders saved'), backgroundColor: AppTheme.successGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.secondaryBackgroundDark,
              child: Icon(Icons.notifications_active, size: 48, color: AppTheme.activeBlue),
            ),
          ),
          SizedBox(height: 3.h),
          Text(AppLocalizations.of(context)?.remindersTitle ?? 'Reminders & Notifications', style: AppTheme.darkTheme.textTheme.headlineSmall),
          SizedBox(height: 1.4.h),
          Text(
            AppLocalizations.of(context)?.remindersBody ?? 'Enable hydration reminders to help daily consistency. You can change this later in settings.',
            style: AppTheme.darkTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 2.h),
          SwitchListTile(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            title: Text(AppLocalizations.of(context)?.enableHydrationReminders ?? 'Enable hydration reminders'),
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _intervalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.intervalMinutes ?? 'Interval (min)'
                  ),
                  enabled: _enabled,
                ),
              ),
              SizedBox(width: 3.w),
              ElevatedButton.icon(
                onPressed: _requesting ? null : _requestNotifs,
                icon: const Icon(Icons.app_settings_alt),
                label: Text(_requesting ? (AppLocalizations.of(context)?.requesting ?? 'Requesting…') : (AppLocalizations.of(context)?.allowNotifications ?? 'Allow notifications')),
              ),
              SizedBox(width: 3.w),
              OutlinedButton(onPressed: _savePrefs, child: Text(AppLocalizations.of(context)?.save ?? 'Save')),
            ],
          ),
        ],
      ),
    );
  }
}
