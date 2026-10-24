# Spec — Echo text (UI task)

> Create a layout with a text label, a text input field, and a button. When the
> button is pressed, the label should display the text entered in the input
> field.

## Behavior

| # | Given | When | Then |
|---|---|---|---|
| 1 | app opened on this tab | — | label shows a translated placeholder (`echo_text.empty_label`); submit button disabled |
| 2 | input is empty or whitespace only | — | submit button stays disabled |
| 3 | input has `"  Hello  "` | user taps submit | label shows `Hello` (trimmed); input is cleared; button disabled again |
| 4 | input has text | user presses Enter / Done (`onSubmitted`) | same as 3 |
| 5 | input is whitespace only | user presses Enter | nothing changes |
| 6 | label shows a value | user submits a new one | label is replaced, not appended |

## Design

- `EchoTextViewModel extends ChangeNotifier`
  - `String? get echoedText` — null until first submit
  - `bool get canSubmit`
  - `void onInputChanged(String value)`
  - `void submit()` — trims, ignores blank, updates `echoedText`
  - Holds the current input as a `String`, not a controller.
- `EchoTextScreen` (StatefulWidget) owns the `TextEditingController` and
  `FocusNode`, forwards changes to the ViewModel, clears the controller after a
  successful submit, keeps focus on the field.
- Label wrapped in `Semantics(liveRegion: true)` so screen readers announce it.
- Adaptive: Material `TextField` + `FilledButton` on Android;
  `CupertinoTextField` + `CupertinoButton.filled` look on iOS (via
  `core/widgets/adaptive`).
- `textInputAction: TextInputAction.done`; `maxLines: 1`.
- Long text wraps in the label (no overflow, no ellipsis).

## Keys (`EchoTextKeys`)

`input`, `submit`, `label`.

## Tests

- ViewModel: initial state, `canSubmit` for empty/blank/text, trim, blank
  ignored, replacement, notifies only on change.
- Widget (Android + iOS): disabled → enabled button, tap submit, Enter submit,
  input cleared, Portuguese locale shows pt strings.
- Golden: initial and filled states, light/dark × Android/iOS.
