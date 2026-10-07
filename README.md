# Sailing Course ⛵

A cross-platform (Android & iOS) Flutter app for studying for the Polish
sailing-license exam. The app is built as a hub of thematic **modules** that
share a common quiz engine:

- **MPDM** – the COLREGS rules on vessel **lights and day shapes** (with
  scenes drawn on the fly).
- **Rescue & safety** – text-only knowledge questions (SART, helicopter
  rescue, man overboard, liferaft, lifejackets, distress signals, first aid).

> **MPDM** = *Międzynarodowe Prawo Drogi Morskiej* (International Regulations
> for Preventing Collisions at Sea).

## Features

- **Offline-first** – all quiz content ships with the app as local JSON; no
  backend or network connection required.
- **Three study modes**
  - **Learn** – answer with hints and explanations (cites the relevant COLREGS
    rule).
  - **Review (SRS)** – spaced repetition based on the **SM-2** algorithm; only
    the cards due today are shown.
  - **Exam** – all cards, no hints, pass threshold 75%, best score is recorded.
- **Statistics** – seen/mastered cards, overall accuracy and best exam score,
  with a progress reset option.
- **Custom scene rendering** – lights and shapes are drawn with a `CustomPainter`
  (no image assets needed).
- **Internationalization (PL / EN)** – full UI *and* quiz content are localized,
  with an in-app language switcher (country flags) whose choice is remembered.

## Architecture

The modules follow an **MVI** pattern implemented with
[`flutter_bloc`](https://pub.dev/packages/flutter_bloc):

| MVI concept | Implementation |
|-------------|----------------|
| Intent      | `*Event` classes (e.g. `OptionSelected`, `NextPressed`) |
| Model/State | immutable `*State` classes (`Equatable` + `copyWith`)  |
| Reducer     | the `Bloc` (`QuizBloc`, `HomeBloc`, `StatsBloc`)       |
| View        | `BlocBuilder` / `BlocConsumer` widgets                  |

The reusable quiz engine (cards, repository, progress, quiz/result screens)
lives under `lib/shared/quiz/`; each module in `lib/modules/` is a thin layer
that configures it (its own asset folder and progress namespace).

```
lib/
├── main.dart                 # App root, hub screen, language switcher
├── l10n/                     # ARB files + generated AppLocalizations, LocaleCubit
├── shared/quiz/              # Reusable quiz engine
│   ├── bloc/                 # QuizBloc (Event/State/Bloc)
│   ├── data/                 # CardRepository (loads cards_<lang>.json)
│   ├── models/               # QuizCard, SceneElement
│   ├── painters/             # ScenePainter (CustomPainter)
│   ├── services/             # ProgressService (SM-2 SRS, shared_preferences)
│   ├── screens/              # Quiz / Result views
│   └── widgets/              # SceneView
└── modules/
    ├── mpdm/                 # Lights & shapes: HomeBloc, StatsBloc, screens
    │   └── mpdm_module.dart  # Self-initializing module entry point
    └── rescue/               # Rescue & safety: learn + exam, text-only cards
        └── rescue_module.dart
assets/
├── mpdm/   cards_pl.json / cards_en.json   # 30 cards (lights + shapes)
└── rescue/ cards_pl.json / cards_en.json   # 12 cards (knowledge questions)
```

The MPDM deck contains **30 cards**: 19 night/lights (`n01`–`n19`) and 11
day/shapes (`d01`–`d11`). The rescue deck contains **12 cards** (`r01`–`r12`).

## Getting started

Requirements: Flutter (Dart SDK `^3.13.5`).

```bash
flutter pub get
flutter gen-l10n     # generate the localization classes
flutter run          # run on a connected device or emulator
```

## Tests

The test suite uses the **GIVEN / WHEN / THEN** convention and
[`bloc_test`](https://pub.dev/packages/bloc_test):

```bash
flutter test
```

Coverage includes the blocs (quiz/home/stats), the SRS `ProgressService`, the
`QuizCard` model (JSON parsing & answer shuffling) and the `CardRepository`
(per-language loading with fallback).

## Localization

UI strings live in `lib/l10n/app_<lang>.arb`; quiz content lives in
`assets/<module>/cards_<lang>.json`. To add a language, add the ARB file plus a
card file per module (same keys / card ids) and register the language code in
`CardRepository`.
