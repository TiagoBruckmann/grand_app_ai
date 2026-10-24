---
applyTo: "**/*.dart"
description: Flutter & Dart conventions for this repository (MVVM, provider, go_router, isolates, flutter_i18n, adaptive Material 3).
---

# Flutter & Dart instructions

These rules are binding for every Dart file. `analysis_options.yaml` enforces part
of them; the rest is enforced in review.

## 1. Language & style

- Code, identifiers, comments and commit messages in **English**.
- `dart format` with page width **80**. Never fight the formatter.
- **Single quotes** for strings; double quotes only to avoid escaping.
- **Package imports only** (`import 'package:<app>/...'`), never relative.
  Order: `dart:` → `package:flutter/` → other packages → this package; one
  blank line between groups (`directives_ordering`).
- `final` by default; `var` only when reassigned; `const` wherever possible
  (constructors, widgets, collections).
- Always declare return types, including `void` and `Future<void>`.
- Never `dynamic`. Use generics, sealed classes or `Object?` + pattern matching.
  `strict-casts`, `strict-inference` and `strict-raw-types` are on.
- No `!` (null assertion) unless the invariant is obvious on the same screen of
  code; prefer early returns and pattern matching.
- Prefer Dart 3 features: `sealed`/`final` classes, records, `switch`
  expressions, patterns, enhanced enums, super parameters.
- Naming: `UpperCamelCase` types, `lowerCamelCase` members, `snake_case` files.
  One public widget/class per file; the file is named after it.
- Private by default (`_`). Expose only what other layers need.
- No doc comments (`///`) required. Write a normal `//` comment only to explain
  **why**, never what.
- TODOs must follow `// TODO(username): description` (`flutter_style_todos`).
- No `print`. Use `debugPrint` only in temporary debugging, never committed.

## 2. Architecture (MVVM — docs.flutter.dev/app-architecture)

```
View (widget) ──listens──▶ ViewModel (ChangeNotifier) ──calls──▶ Service / Repository
     ◀──── commands ─────
```

- **Views** render state and forward user intent to ViewModel methods. No
  business logic, no direct service access, no `async` logic beyond awaiting a
  ViewModel command.
- **ViewModels** extend `ChangeNotifier`, hold UI state as private fields with
  public getters, expose intent methods (`submit()`, `start()`, `pause()`).
  They never import `package:flutter/material.dart` or `cupertino.dart` and
  never receive a `BuildContext`. `foundation.dart` is allowed.
- **Services** wrap platform/low-level APIs (here: isolates). **Repositories**
  are the source of truth for app data (none needed yet — do not invent them).
- Domain models are immutable (`final` fields, `const` constructors, `==`/
  `hashCode` when compared in tests).
- Dependencies are passed through constructors. No singletons, no service
  locators, no static mutable state.
- Feature-first folders: `lib/features/<feature>/{ui,data,domain}`. Shared code
  goes in `lib/core/` only when used by 2+ features.

## 3. State management (provider)

- Root services: `Provider<T>(create: ..., dispose: (_, s) => s.dispose())` in
  `lib/app/dependencies.dart`.
- ViewModels are created per route:
  `ChangeNotifierProvider(create: (context) => XViewModel(service: context.read()))`.
- In widgets: `context.read<T>()` inside callbacks, `context.select` /
  `Selector` for granular rebuilds, `context.watch` only for small widgets.
  Never `read` inside `build` to obtain values that must trigger rebuilds.
- Call `notifyListeners()` only when state actually changed. Guard every
  notification after an `await` with a disposed check.
- A ViewModel that owns subscriptions, timers or services cancels/closes them
  in `dispose()` (`cancel_subscriptions`, `close_sinks`).

## 4. Widgets & UI

- Extract UI into `StatelessWidget`/`StatefulWidget` classes, **never** into
  `Widget _buildX()` methods.
- `StatefulWidget` only for ephemeral UI objects that need disposal
  (`TextEditingController`, `FocusNode`, `AnimationController`). Dispose them.
- Always pass `super.key`; add `Key`s (`ValueKey('echo_text.submit')`) to
  widgets that tests interact with. Keep keys in a `abstract final class
  XKeys` per feature.
- Screen bodies use the shared max-width centered layout from `core/widgets`
  (content ≤ 600 dp, 16 dp gutters) and `SafeArea`.
- **Adaptive design**: Material 3 everywhere, with platform-appropriate
  widgets on iOS. Use `.adaptive` constructors (`Switch.adaptive`,
  `Slider.adaptive`, `CircularProgressIndicator.adaptive`,
  `AlertDialog.adaptive`) and the wrappers in `core/widgets/adaptive/` for
  buttons and text fields. Branch on `Theme.of(context).platform`, never on
  `dart:io Platform`, so tests can override it.
- No magic numbers: spacing, radius and durations come from
  `core/theme/tokens.dart`; colors and text styles from `Theme.of(context)`
  (`colorScheme`, `textTheme`). Never hardcode `Color(0x...)` in features.
- Theme: `ColorScheme.fromSeed` for light and dark; `ThemeMode.system`.
- **Accessibility**: every interactive widget has a semantic label or tooltip;
  status changes (new counter value, echoed text) are announced with
  `Semantics(liveRegion: true)`; touch targets ≥ 48 dp; layout must survive
  `textScaler` 2.0 without overflow; never convey meaning by color alone
  (parity uses color **and** text/icon).
- `use_build_context_synchronously`: after an `await`, check
  `context.mounted` before using `context`.

## 5. Internationalization (flutter_i18n)

- Every user-facing string lives in `assets/i18n/en.json` **and**
  `assets/i18n/pt.json`, with identical key sets. Keys are namespaced:
  `echo_text.input_hint`, `isolate_counter.start`.
- Key constants live in `lib/core/i18n/i18n_keys.dart`
  (`abstract final class I18nKeys`) — never inline string keys in widgets.
- Translate only in the UI layer:
  `FlutterI18n.translate(context, I18nKeys.echoTextTitle)` or the
  `I18nText` widget. ViewModels expose enums/values, never translated text.
- Delegate: `FlutterI18nDelegate(translationLoader:
  FileTranslationLoader(basePath: 'assets/i18n', fallbackFile: 'en',
  useCountryCode: false))`, plus the `GlobalMaterialLocalizations`,
  `GlobalWidgetsLocalizations` and `GlobalCupertinoLocalizations` delegates.
  Supported locales: `en`, `pt`. Locale follows the device.

## 6. Async, streams & isolates

- Never leave a `Future` floating: `await` it or wrap in `unawaited(...)` with
  intent (`unawaited_futures`). No `async` functions returning `void`
  (`avoid_void_async`) — return `Future<void>`.
- Every `StreamSubscription` is cancelled, every `StreamController` and
  `ReceivePort` is closed, every `Timer` is cancelled, every spawned `Isolate`
  is killed — in `dispose()`/`stop()`.
- Isolate rules (see `docs/specs/isolate_counter.md` for the full design):
  - Long-lived workers via `Isolate.spawn` with a top-level or static entry
    point; handshake through `SendPort`/`ReceivePort`.
  - Messages between isolates are **sealed, immutable classes**
    (`worker_messages.dart`), handled with exhaustive `switch`. No raw maps
    or `dynamic` messages.
  - Each worker owns its counter state; the main isolate never computes the
    numbers.
  - The coordinator ignores messages from a previous run (run/generation id)
    so stop → start never shows stale values.
  - Set `debugName` on every isolate; use `onError`/`onExit` ports to detect
    worker crashes and surface them as a `Result.error`.
- `Isolate.spawn` is not available on web; this app targets mobile only.

## 7. Error handling

- Use the sealed `Result<T>` from `lib/core/result/result.dart` for operations
  that can fail (`Ok(value)` / `Error(error)`), consumed with `switch`.
- Throw only `Exception`/`Error` subtypes (`only_throw_errors`); define
  specific exception classes when callers must distinguish failures.
- Catch narrowly (`on IsolateSpawnException catch (e)`); use `rethrow`.
  Never swallow errors silently — map them to UI state.

## 8. Tests

- Layout mirrors `lib/`: `test/features/<feature>/...`.
- Test doubles are hand-written fakes in `test/fakes/` implementing the real
  interface (`class FakeCounterCoordinator implements CounterCoordinator`).
  No mocking packages.
- Names describe behavior: `'disables submit button when input is blank'`.
- Structure: arrange / act / assert, one behavior per test.
- Unit tests for every ViewModel (state transitions, notifications, dispose).
- Coordinator tests use **real isolates** with a zero/short interval and
  assert the exact sequence `1, 2, 3, …, N`, alternating parity, pause/resume,
  stop/reset and absence of stale emissions.
- Widget tests pump the screen with fake dependencies, the i18n delegate and
  both `TargetPlatform.android` and `TargetPlatform.iOS`
  (`variant: TargetPlatformVariant.only(...)`).
- Golden tests are tagged `@Tags(['golden'])`, cover light/dark ×
  Android/iOS, and live in `test/goldens/`.
- Integration test in `integration_test/app_test.dart` drives both features
  end to end.
- Never `await tester.pump(Duration(seconds: 5))` to "wait for" isolates in
  widget tests — use the fake. Real isolates only in coordinator/integration
  tests (with `tester.runAsync` where needed).
