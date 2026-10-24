# CLAUDE.md

Flutter technical challenge for a job application. Quality, clarity and idiomatic
Flutter matter more than feature count. Every change must look like it was written
by a senior Flutter engineer following the official Flutter guidance.

@.github/instructions/flutter_dart.instructions.md
@docs/specs/echo_text.md
@docs/specs/isolate_counter.md

## The challenge

1. **Echo text (UI task)** — a label, a text input and a button. Pressing the
   button shows the entered text in the label. Spec: `docs/specs/echo_text.md`.
2. **Isolate counter (multithreading task)** — two isolates, one counting odd
   numbers and one counting even numbers, taking turns so the label shows
   1, 2, 3, 4… in order. Spec: `docs/specs/isolate_counter.md`.

Both live in a single app, reachable through a bottom navigation shell.

## Tech stack (fixed — do not add packages without asking)

| Concern | Choice |
|---|---|
| Flutter | latest stable |
| Targets | Android, iOS (no web: `Isolate.spawn` is unsupported there) |
| Architecture | MVVM from docs.flutter.dev/app-architecture, feature-first folders |
| State | `ChangeNotifier` ViewModels exposed through `provider` |
| DI | constructor injection, wired with `provider` at the app root |
| Navigation | `go_router` with `StatefulShellRoute.indexedStack` |
| Design | Material 3, adaptive (Material on Android, Cupertino look on iOS) |
| Theme | `ColorScheme.fromSeed`, light + dark following the system |
| i18n | `flutter_i18n` with JSON files in `assets/i18n/` (en, pt) |
| Errors | sealed `Result<T>` (`Ok` / `Error`) |
| Tests | unit, widget, isolate coordinator, golden, integration_test |
| Test doubles | hand-written fakes (no mocking packages) |

Runtime deps: `provider`, `go_router`, `flutter_i18n`, `flutter_localizations` (sdk).
Dev deps: `flutter_lints`, `flutter_test` (sdk), `integration_test` (sdk).
No code generation.

## Commands

```bash
flutter pub get
dart format .                                   # 80 columns
flutter analyze --fatal-infos                   # must be clean
flutter test --exclude-tags golden              # what CI runs
flutter test --tags golden                      # goldens (local, see below)
flutter test --tags golden --update-goldens     # regenerate baselines
flutter test integration_test                   # needs a device/emulator
flutter run
```

Golden baselines are OS-dependent (font rendering). They are generated and
checked locally on the author's machine, so CI excludes the `golden` tag.

## Project layout

```
lib/
├── main.dart                     # bootstrap only
├── app/
│   ├── app.dart                  # MaterialApp.router, theme, i18n delegates
│   ├── router.dart               # go_router config + shell
│   └── dependencies.dart         # root MultiProvider (services, repositories)
├── core/
│   ├── i18n/                     # i18n keys, delegate setup
│   ├── result/result.dart        # sealed Result<T>
│   ├── theme/                    # app_theme.dart, tokens.dart (spacing, radius, durations)
│   └── widgets/                  # adaptive wrappers, shared layout (max-width body)
└── features/
    ├── echo_text/
    │   └── ui/
    │       ├── view_model/echo_text_view_model.dart
    │       └── widgets/echo_text_screen.dart (+ smaller widgets)
    └── isolate_counter/
        ├── domain/models/        # Parity, CounterEmission, CounterStatus
        ├── data/services/        # counter_coordinator.dart, parity_worker.dart, worker_messages.dart
        └── ui/
            ├── view_model/isolate_counter_view_model.dart
            └── widgets/isolate_counter_screen.dart (+ smaller widgets)
assets/i18n/en.json, pt.json
test/                             # mirrors lib/, plus test/fakes/ and test/goldens/
integration_test/app_test.dart
```

A feature only gets `data/` or `domain/` when it needs them. Echo text is pure
UI state, so it has only `ui/`.

## How to work in this repo

1. **New feature or non-trivial change** → ask the `flutter-architect` agent for
   a plan first; follow the plan.
2. Implement in small steps. The post-edit hook formats each file and reports
   analyzer errors/warnings; fix them immediately.
3. Write or update tests in the same change (use the `test-writer` agent when
   useful). No feature is done without tests.
4. Anything touching isolates, ports, timers or streams → run the
   `concurrency-reviewer` agent.
5. Before every commit → `/review`.
6. README / docs changes → `docs-writer` agent.

## Definition of done

- [ ] `dart format --set-exit-if-changed .` passes
- [ ] `flutter analyze --fatal-infos` passes with zero issues
- [ ] `flutter test --exclude-tags golden` passes; goldens updated if UI changed
- [ ] Every user-facing string comes from `assets/i18n/*.json` (en **and** pt)
- [ ] Works in light and dark, Android and iOS look, large text scale
- [ ] No `TODO` left without the `// TODO(username): ...` format
- [ ] Commit follows Conventional Commits

## Commits

Conventional Commits, English, imperative, ≤ 72 chars subject:
`feat(isolate-counter): add pause and resume`, `test(echo-text): cover empty input`,
`chore: configure CI`. One logical change per commit.

## Never

- Add packages, change the architecture or the lint config without asking.
- Use `Future`/`Timer`/`compute`/`Isolate.run` as a substitute for the two
  long-lived isolates in the counter feature.
- Put business logic in widgets or `BuildContext` in ViewModels.
- Hardcode user-facing strings, colors or magic spacing numbers.
- Use `// ignore:` to silence the analyzer without explaining why in the PR.
- `git push`, rewrite history, or delete files outside the task scope.