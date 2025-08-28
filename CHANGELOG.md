# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-08-16

### Added
- Visual comparison page with reference captures: `assets/comparison.html`.
- ADB automation scripts for screenshots and videos (`scripts/adb_ui.py`, `scripts/flows_*.py`, `scripts/capture_*.py`).
- Design tokens scaffold (`design/tokens.json`, `design/tokens.schema.json`), tabs map and palette extractor.
- Goals Wizard (`/goals-wizard`) with validation and Profile shortcut.
- Diary: per-meal progress bars and empty states with quick add.
- Search: fixed search bar, search history chips, per-100g macro chips, responsive chips.
- Detail: macro chips header and fixed primary CTA to add directly to diary.
- Analytics: week/month view captures + short toggle video.

### Changed
- Theme colors aligned to tokens (primary, success, warning, error; dark backgrounds).
- Bottom navigation aligned to (Diary, Search, Goals/Profile, Analytics).
- Polished spacing/typography on Diary sections; refined dividers and buttons.

### Removed
- Orphan media assets not referenced by `assets/comparison.html` were pruned.

### Notes
- See `assets/comparison.html` for side-by-side visuals (YAZIO vs NutriTracker).
- Minor validations added in Goals Wizard (digits only, basic checks, macro vs calorie estimate warning).

## [1.0.0] - 2025-08-11
- Initial release.

