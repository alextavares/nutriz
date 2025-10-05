# NutriTracker UI Redesign — YAZIO‑like

Status and plan to align NutriTracker (emulator 5554) UI to a YAZIO‑like visual system captured from emulator 5560. This document is the single source of truth to resume work across sessions.

## Goals
- Unify visual language (colors, type scale, spacing, radii, elevation).
- Standardize core components (AppBar, BottomNav, Cards, Buttons, Chips, Inputs, Lists).
- Make Fasting, Diary/Home, Recipes, Profile, and PRO pages visually consistent and close to YAZIO.

## Non‑Goals (for now)
- Copying proprietary assets or branding from YAZIO.
- Feature changes beyond layout/visual consistency.

## Approach (High‑Level)
1) Capture YAZIO references via MCP and store under `design/yazio/`.
2) Extract tokens and create a theme preset: `yazio_like`.
3) Wire a theme switch via `--dart-define=THEME_PRESET=yazio`.
4) Unify common components (BottomNav, AppBar, Cards, Buttons, Inputs, Chips, ListTiles).
5) Refatorar telas: Fasting → Diary/Home → Recipes → Profile → PRO.
6) Validate on 5554: contrast, spacing, states, dark mode pass.

## How To Resume Work
- Read current progress file: `docs/redesign_yazio_like.plan.json`.
- Reference images: `design/yazio/*.png`.
- Next steps are tracked in the JSON; update with the helper script:

```
python3 scripts/update_design_progress.py set <step_id> <pending|in_progress|completed> "optional note"
```

- Run app with a preset:

```
flutter run --dart-define=THEME_PRESET=yazio

- If `THEME_PRESET` is omitted, the default NutriTracker theme is used.
```

## Screens To Capture (YAZIO 5560)
- Bottom tabs: Diary, Fasting, Recipes, Profile, PRO.
- Fasting states: can eat, fasting running, about to start.
- Profile subsections: Settings/Preferences if applicable.

Files will live in `design/yazio/` and be referenced by filename in the progress JSON.

## Component Mapping (from YAZIO → NutriTracker)
- Navigation: BottomNavigationBar fixed, labels visible; selected color = primary; unselected = onSurfaceVariant.
- AppBar: surface background, no elevation, bold title, left‑aligned.
- Cards: white/elevated surface, md/lg radius, light shadow, consistent margins.
- Buttons: primary filled (rounded md), outline secondary; text weights medium/semibold.
- Chips/Filters: stadium with outlineVariant border; selected state tinted with primary alpha.
- Inputs: filled/elevated surface, md radius, focus border primary.

## Tokens (Target)
- Spacing: 4, 8, 12, 16, 20, 24, 32.
- Radii: 8, 12, 16, 24.
- Type: Inter/NotoSans style weights with semibold labels.
- Colors: material‑like palette close to YAZIO (primary blue, success green, warning orange, neutrals slate).

## Implementation Steps (Checklist)
Tracked in `docs/redesign_yazio_like.plan.json` for machine‑readable status and notes. Keep this MD as human‑readable context.
