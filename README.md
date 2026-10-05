# Sailing Course ⛵

A cross-platform (Android & iOS) Flutter app for studying for the Polish
sailing-license exam. The app is built as a hub of thematic **modules**; the
first one, **MPDM**, teaches the COLREGS rules on vessel **lights and day
shapes**.

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

The MPDM module follows an **MVI** pattern implemented with
[`flutter_bloc`](https://pub.dev/packages/flutter_bloc):

| MVI concept | Implementation |
|-------------|----------------|
| Intent      | `*Event` classes (e.g. `OptionSelected`, `NextPressed`) |
| Model/State | immutable `*State` classes (`Equatable` + `copyWith`)  |
| Reducer     | the `Bloc` (`QuizBloc`, `HomeBloc`, `StatsBloc`)       |
| View        | `BlocBuilder` / `BlocConsumer` widgets                  |

```
lib/
├── main.dart                 # App root, hub screen, language switcher
├── l10n/                     # ARB files + generated AppLocalizations, LocaleCubit
└── modules/mpdm/
    ├── mpdm_module.dart      # Self-initializing module entry point
    ├── bloc/                 # QuizBloc, HomeBloc, StatsBloc (Event/State/Bloc)
    ├── data/                 # CardRepository (loads cards_<lang>.json)
    ├── models/               # QuizCard, SceneElement
    ├── painters/             # ScenePainter (CustomPainter)
    ├── services/             # ProgressService (SM-2 SRS, shared_preferences)
    ├── screens/              # Home / Quiz / Result / Stats views
    └── widgets/              # SceneView
assets/mpdm/
├── cards_pl.json            # 30 cards – Polish
└── cards_en.json            # 30 cards – English
```

The deck contains **30 cards**: 19 night/lights (`n01`–`n19`) and 11 day/shapes
(`d01`–`d11`).

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
`assets/mpdm/cards_<lang>.json`. To add a language, add both files (same keys /
card ids) and register the language code in `CardRepository`.
