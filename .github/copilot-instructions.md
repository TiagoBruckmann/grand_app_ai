# Instructions to GitHub Copilot

This document establishes mandatory guidelines, architectural standards, code quality rules, and completion criteria for the development of this Flutter project. AI assistants (such as GitHub Copilot and Claude Code) must strictly adhere to these instructions across all code generation, refactoring, and testing tasks.

## 1. Project Overview & Scope

This application is a Flutter technical assignment demonstrating Clean Architecture, State Management with Provider, Dart Isolates Concurrency with explicit message passing, and Comprehensive Automated Testing (including Golden Tests).
Functional Requirements:

#### UI Task (Text Input & Display Section):
- Features a layout with a text label (Text), a text input field (TextField), and a button (ElevatedButton).
- When the button is pressed, the main label in the section updates to display the text entered into the input field.

#### Multithreading Task (Concurrent Counter):
- Implements two independent Dart Isolates (one for odd numbers, one for even numbers).
- Coordinates counting explicitly via message passing to ensure sequential updates from 1 to 100.
- Manages the lifecycle cleanly: supports start, pause/stop, restart, and re-execution after completion.
- Handles errors gracefully by terminating Isolates, closing ports, and presenting clear error states to the user.

## 2. Language & Code Style Standards

- **Language:** All code, variable names, class names, method signatures, comments, documentation, and user interface (UI) text must be strictly in English.
- **Naming Conventions:** Descriptive naming following standard Dart guidelines: PascalCase for classes and types, camelCase for variables and methods, and snake_case for filenames.

## 3. Architecture & Directory Structure
The project strictly follows Clean Architecture principles, organized by feature (features/), with shared/global UI components placed in the presentation layer.

Directory Structure

lib/
├── app.dart
├── main.dart
├── core/
│   ├── errors/
│   ├── theme/
│   └── widgets/
└── features/
├── text_display/               <-- Feature 1: UI Task
│   ├── data/
│   ├── domain/
│   └── presentation/
└── concurrent_counter/         <-- Feature 2: Multithreading Task
├── data/                   (Isolate services & communication protocols)
├── domain/                 (Entities, Value Objects, Use Cases)
└── presentation/           (ChangeNotifier, View/Widgets)


#### Layer Responsibilities

- **presentation/:** Contains screens, feature-specific widgets, and ChangeNotifier state containers. Shared components belong in presentation/widgets/.
- **domain/:** Pure business logic layer containing entities, repository/service contracts, and use cases (UseCases). No dependency on Flutter UI or external frameworks.
- **data/:** Implementations of repositories, isolate concurrency services, data models, and communication ports handling (SendPort/ReceivePort).

## 4. State Management & Concurrency

State Management (Provider)
Use provider exclusively for state management (the only allowed third-party runtime package).
Use ChangeNotifier to manage UI state within presentation layers, exposing immutable or controlled state properties and notifying listeners (notifyListeners()) efficiently.
Business logic and isolate workers must reside in independent domain/data services injected into the presentation layer.

Concurrency (Dart Isolates)

- **Two Independent Isolates:** One dedicated to odd numbers and another to even numbers.
- **Message Protocol:** Explicit authorization and confirmation protocol using SendPort and ReceivePort.
- **Sequential Guarantee:** The isolates must coordinate handshakes (e.g., Odd Isolate sends 1 -> Even Isolate validates and sends 2 -> repeat) up to the limit of 100.
- **Lifecycle Management:** Safely close communication ports (close()) and terminate isolates (kill()) when disposing resources, pausing, or restarting.

## 5. UI & Styling (Material Design 3)

- **Design System:** Fully utilize Material Design 3 (M3) with modern, native Flutter visuals.
- **Theming:** Support both Light Theme and Dark Theme with automatic system switching (ThemeMode.system).
- **Screen Layout:** A single screen split into two distinct, well-structured sections: Text Display UI Task and Concurrent Counter Task.

## 6. Code Quality, Lints & Static Analysis

Static Analysis: Enforce flutter_lints alongside a strict rule set in analysis_options.yaml.

##### Strict Rules:

- No print statements allowed (use structured logging or omit in production).
- Avoid dynamic types unless strictly unavoidable.
- No dead code or unused variables/imports.
- Zero analyzer warnings or hints allowed in final code.
- **Documentation:** Include doc comments (///) for public APIs, key abstractions, and architectural rationale. Avoid redundant comments that do not add value.

## 7. Automated Testing Strategy

The project requires full automated test coverage across four tiers:

##### Unit Tests (test/):
- Verify domain use cases, isolate counting logic, and message protocol handshakes.

##### Widget Tests (test/ or test_widgets/):
- Validate isolated visual components and ChangeNotifier state updates.

##### Integration Tests (integration_test/):
- Validate end-to-end user flows for both the text input section and the concurrent isolate counter execution.

##### Golden Tests (test/goldens/):
- Visual regression testing for both Light and Dark themes.
- Coverage across counter states: Running, Completed, and Error.

## *. Definition of Done

A task or feature is considered complete only when:

[ ] The code compiles without errors, warnings, or lints (flutter analyze).
[ ] Unit, widget, and integration tests pass successfully (flutter test).
[ ] Golden tests are rendered and verified for both Light and Dark modes.
[ ] Clean Architecture separation and dependency rules are respected.
[ ] Isolates execute smoothly without memory leaks, unclosed ports, or race conditions.