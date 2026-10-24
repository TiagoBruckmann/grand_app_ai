---
description: Review current changes (staged > unstaged > given paths) before committing
argument-hint: "[path ...]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(flutter analyze:*), Bash(flutter test:*), Bash(dart format:*), Read, Grep, Glob
---

Review the pending changes in this repository.

Scope: $ARGUMENTS (if empty, use `git diff --staged`; if nothing is staged,
use `git diff`).

Changed files:
!`git status --short`

Steps:

1. Use the `code-reviewer` agent on the scope above.
2. If any changed file is under `lib/features/isolate_counter/`, or contains
   `Isolate`, `SendPort`, `ReceivePort`, `StreamController` or `Timer`, also
   use the `concurrency-reviewer` agent, in parallel.
3. If Dart files changed under `lib/` without matching changes under `test/`,
   flag it as 🟡 and suggest which tests the `test-writer` should add.
4. If user-facing strings changed, verify `assets/i18n/en.json` and
   `assets/i18n/pt.json` have the same keys.

Merge the agents' reports into a single review (deduplicate findings) and end
with a suggested Conventional Commit message for the change. Do not edit files
and do not commit.
