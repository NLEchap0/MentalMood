# MentalMood

A calm, dark mood-tracking app with daily check-ins, journal, streaks and achievements.

## Architecture (back → middle → front)

```
lib/
  data/         BACK   — Drift database, mappers, repositories (storage details)
    database/          — schema + row↔domain mappers
    repositories/      — abstract contracts + Drift implementations
  domain/       MIDDLE — pure logic, zero Flutter imports
    models.dart        — MoodEntry, MoodTag, Badge, AppUser, ChartPoint
    services/          — mood_analytics (chart/streak/avg), badge_service (unlock rules)
  state/        MIDDLE — ChangeNotifier controllers (auth, register, mood)
  services/            — AIService (NVIDIA chat completion, not wired to UI yet)
  app/          FRONT  — everything the user sees
    pages/             — access, home, journal, growth, settings, shell
    widgets/           — glass_card, app_button, empty_state, charts, ...
    theme/             — app_colors, app_tokens, app_typography, app_theme, animations
    navigation/        — shared page transitions (AppNavigator)
  main.dart             — composition root (providers + routes)
```

Rules:
- UI never imports `data/` types — it only sees `domain/models.dart`.
- Controllers never touch Drift companions — repositories own the mapping.
- Domain has no Flutter or Drift dependencies, so it is trivially testable.

## Getting Started

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after schema changes
flutter analyze
flutter test
```

## Environment

Copy `.env` (gitignored) with `NVIDIA_API_KEY`, `NVIDIA_API_URL`, `NVIDIA_MODEL`
for the AI insights service. The key is bundled with the app — use a server-side
proxy before shipping to production.
