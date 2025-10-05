
# Golden Refresh Checklist — Theme Tokens Rollout

The latest Material 3 token migration touched the following surfaces and should be re-captured in the next golden run:

- **Daily Tracking Dashboard** (`daily_tracking_dashboard_golden`): header streak chips, meal plan section, logged meals list, CTA button gradient.
- **Intermittent Fasting Tracker** (`fasting_tracker_golden`): control button dialog, countdown timer ring, notification settings card.
- **AI Food Detection + Coach**: locked state, detection results cards, summary dialog.
- **Activity/Streak/Enhanced Dashboard**: activity connect card, streak overview coachmark/week dots, enhanced dashboard summaries.
- **Shared components**: `CelebrationOverlay` confetti colors, `AchievementBadgesWidget` palette tweaks.

Suggested workflow:
1. Run `flutter test --update-goldens test/goldens/daily_dashboard_*` after verifying the dashboard layout is stable.
2. Refresh the fasting tracker scenario (`test/goldens/fasting_*`). Ensure notification settings are enabled to capture the updated card styling.
3. Capture the AI detection/coach screens and activity/streak flows via the existing scripts (e.g. `scripts/capture_nutritracker.py --screens ai,daily,fasting,streaks`).
4. After analyzer is clean, rerun the entire golden suite (`flutter test --update-goldens`) to ensure no regressions.

Prereqs: analyzer must pass once the remaining const-usage errors are resolved; update `analysis_options.yaml` if additional directories need exclusion.
