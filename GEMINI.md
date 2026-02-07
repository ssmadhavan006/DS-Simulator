# GEMINI.md: AI Assistant Context

This file provides context for an AI assistant to understand and effectively assist with this project.

## Project Overview

This is a Flutter application named **DSA Visualizer** (`dsa_sim`) designed for interactively visualizing common data structures and algorithms (DSAs). The goal is to provide a clear, animated representation of how these structures work.

The application is built with a focus on clean architecture and a modern, responsive UI.

### Core Technologies

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** `provider`
- **Local Storage:** `hive` (used for theme persistence)
- **Typography:** `google_fonts`
- **Code Quality:** `flutter_lints`

### Architecture

The project follows a feature-driven architecture, separating concerns into distinct layers:

- **`lib/models`**: Contains the core data structure logic (e.g., `StackModel`, `QueueModel`). These are pure Dart classes that implement the data structure's properties and methods.
- **`lib/providers`**: Acts as the state management layer, connecting the UI to the models. These `ChangeNotifier` classes (e.g., `StackProvider`) hold the state of the visualization, handle user actions, and manage animations.
- **`lib/screens`**: Top-level UI for each feature (e.g., `HomeScreen`, `StackVisualizationScreen`). They assemble the different widgets that make up a full view.
- **`lib/widgets`**: Contains reusable UI components.
  - **`lib/widgets/common`**: General-purpose widgets like control panels and buttons.
  - **`lib/widgets/visualizers`**: The core of the UI, these widgets use `CustomPainter` to draw the animated visualizations of the data structures (e.g., `StackVisualizer`).
- **`lib/utils`**: Holds shared constants, theme data (`AppTheme`), and other utilities.

## Building and Running

### 1. Install Dependencies

Ensure you have the Flutter SDK installed. From the project root, run:

```bash
flutter pub get
```

### 2. Run the Application

You can run the app on any supported platform (Android, iOS, Web, Desktop).

```bash
flutter run
```

### 3. Run Tests

To execute the unit and widget tests:

```bash
flutter test
```

## Development Conventions

- **State Management:** The app uses the `provider` package. UI widgets should remain as stateless as possible, listening to changes from a `Provider` to rebuild.
- **Animations:** Visualizations are handled with `CustomPainter` and `AnimationController`. The `Provider` for a given data structure (e.g., `StackProvider`) manages the animation state (`AnimationState`) and triggers updates.
- **Immutability:** The models expose data through unmodifiable lists (e.g., `List.unmodifiable(_items)`) to prevent direct state mutation from the UI layer. All state changes should go through methods on the `Provider`.
- **Styling:** The app uses a centralized `AppTheme` in `lib/utils/app_theme.dart` for both light and dark modes. A `ThemeProvider` manages theme switching.
- **File Structure:** New features should follow the existing structure (create new files in `models`, `providers`, `screens`, `widgets` as needed).
- **Code Quality:** The project adheres to the lints defined in `package:flutter_lints/flutter.yaml`. Run `flutter analyze` to check for issues.
