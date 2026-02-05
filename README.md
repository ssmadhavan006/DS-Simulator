# DSA Visualizer

An interactive Flutter application for visualizing common data structures and algorithms. This project provides a hands-on learning tool with smooth animations and a clean, modern user interface.

## ✨ Features

- **Interactive Visualizations:** Watch data structures change as you perform operations.
- **Data Structures:**
  - ✅ **Stack:** Visualize Push, Pop, and Peek operations.
  - ✅ **Queue:** Visualize Enqueue and Dequeue operations.
  - 🚧 **Tree & Graph:** Coming soon!
- **Animation Control:** Adjust the animation speed for a customized learning pace.
- **Theming:** Seamlessly switch between Light and Dark modes.
- **Responsive Design:** The UI adapts to different screen sizes, making it usable on mobile, web, and desktop.

## 📸 Screenshots

*(TODO: Add screenshots or GIFs of the application in action. For example, show the stack and queue visualizations.)*

| Light Mode | Dark Mode |
| :---: | :---: |
| *(Stack visualization in light mode)* | *(Queue visualization in dark mode)* |

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.8 or higher)

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

## 📂 Project Structure

The project is organized into a clean, feature-driven architecture to promote separation of concerns and maintainability.

```
lib/
├── main.dart             # App entry point
├── models/               # Core data structure logic (e.g., StackModel)
├── providers/            # State management (using Provider package)
├── screens/              # Top-level UI for each feature
├── utils/                # Shared constants, themes, and helpers
└── widgets/              # Reusable UI components
    ├── common/           # General widgets (buttons, panels)
    └── visualizers/      # Custom painters for DSA animations
```

## 🛠️ Key Technologies

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Local Storage:** [Hive](https://pub.dev/packages/hive) (for theme persistence)
- **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts)
- **Code Quality:** [Flutter Lints](https://pub.dev/packages/flutter_lints)

## 🤝 Contributing

Contributions are welcome! If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".