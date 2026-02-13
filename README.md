# DSA Visualizer

An interactive Flutter application for visualizing common data structures and algorithms. This project provides a hands-on learning tool with smooth animations and a clean, modern user interface.

## ✨ Features

- **Interactive Visualizations:** Watch data structures change as you perform operations in real-time.
- **Data Structures:**
  - ✅ **Stack:** Visualize Push, Pop, and Peek operations with LIFO behavior.
  - ✅ **Queue:** Visualize Enqueue and Dequeue operations with FIFO behavior.
  - 🚧 **Tree & Graph:** Coming soon!
  - 🚧 **Sorting Algorithms:** Coming soon!
- **Animation Control:** Adjust the animation speed for a customized learning pace.
- **Theming:** Seamlessly switch between Light and Dark modes.
- **Responsive Design:** The UI adapts to different screen sizes, making it usable on mobile, web, and desktop.
- **Time Complexity Display:** Shows Big O notation for each operation.
- **Customizable Speed:** Control animation speed for better understanding.

## 📹 Demo Video

<div align="center">
  
[![DSA Visualizer Demo](https://img.youtube.com/vi/EEBJdBS_rQ0/maxresdefault.jpg)](https://www.youtube.com/watch?v=EEBJdBS_rQ0)

</div>

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.8 or higher)
- Dart SDK bundled with Flutter

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/dsa_sim.git
    cd dsa_sim
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Run the application:**
    ```sh
    flutter run
    ```

### Additional Commands

```bash
# Run tests
flutter test

# Build for release
flutter build apk
flutter build ios
flutter build web

# Analyze code quality
flutter analyze

# Format code
flutter format .
```

## 📂 Project Structure

The project follows a clean, feature-driven architecture to promote separation of concerns and maintainability.

```
lib/
├── main.dart                 # App entry point with theme management
├── models/                   # Core data structure logic (StackModel, QueueModel, etc.)
├── providers/                # State management using Provider package
├── screens/                  # Top-level UI for each feature
├── utils/                    # Shared constants, themes, and helpers
└── widgets/                  # Reusable UI components
    ├── common/               # General widgets (buttons, panels, dialogs)
    └── visualizers/          # Custom painters for DSA animations
```

## 🛠️ Key Technologies

- **Framework:** [Flutter](https://flutter.dev/) (SDK 3.10.8+)
- **Language:** [Dart](https://dart.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Local Storage:** [Hive](https://pub.dev/packages/hive) (for theme persistence)
- **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts)
- **Code Quality:** [Flutter Lints](https://pub.dev/packages/flutter_lints)

## 🏗️ Architecture

The application follows a feature-driven architecture with clear separation of concerns:

- **`lib/models`**: Contains the core data structure logic (e.g., `StackModel`, `QueueModel`). These are pure Dart classes that implement the data structure's properties and methods.
- **`lib/providers`**: Acts as the state management layer, connecting the UI to the models. These `ChangeNotifier` classes (e.g., `StackProvider`) hold the state of the visualization, handle user actions, and manage animations.
- **`lib/screens`**: Top-level UI for each feature (e.g., `HomeScreen`, `StackVisualizationScreen`). They assemble the different widgets that make up a full view.
- **`lib/widgets`**: Contains reusable UI components.
  - **`lib/widgets/common`**: General-purpose widgets like control panels and buttons.
  - **`lib/widgets/visualizers`**: The core of the UI, these widgets use `CustomPainter` to draw the animated visualizations of the data structures (e.g., `StackVisualizer`).
- **`lib/utils`**: Holds shared constants, theme data (`AppTheme`), and other utilities.

## 🤝 Contributing

Contributions are welcome! If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

### Development Conventions

- **State Management:** The app uses the `provider` package. UI widgets should remain as stateless as possible, listening to changes from a `Provider` to rebuild.
- **Animations:** Visualizations are handled with `CustomPainter` and `AnimationController`. The `Provider` for a given data structure (e.g., `StackProvider`) manages the animation state (`AnimationState`) and triggers updates.
- **Immutability:** The models expose data through unmodifiable lists (e.g., `List.unmodifiable(_items)`) to prevent direct state mutation from the UI layer. All state changes should go through methods on the `Provider`.
- **Styling:** The app uses a centralized `AppTheme` in `lib/utils/app_theme.dart` for both light and dark modes. A `ThemeProvider` manages theme switching.
- **File Structure:** New features should follow the existing structure (create new files in `models`, `providers`, `screens`, `widgets` as needed).
- **Code Quality:** The project adheres to the lints defined in `package:flutter_lints/flutter.yaml`. Run `flutter analyze` to check for issues.

## 📋 Project Status

- ✅ **Stack Visualization** - Complete
- ✅ **Queue Visualization** - Complete  
- 🚧 **Tree Visualization** - In Progress
- 🚧 **Graph Visualization** - In Progress
- 🚧 **Sorting Algorithm Visualization** - In Progress

## 🙏 Acknowledgments

Built by S.S. Madhavan as an educational tool for students and developers to better understand data structures and algorithms through interactive visualizations.
