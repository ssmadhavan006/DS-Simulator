# DSA Visualizer - Project Context

## Project Overview

DSA Visualizer is an interactive Flutter application designed for visualizing common data structures and algorithms. This educational tool provides hands-on learning experiences with smooth animations and a clean, modern user interface. The application supports visualizations for stacks, queues, trees, graphs, and sorting algorithms with responsive design that works across mobile, web, and desktop platforms.

## Project Architecture

The application follows a clean, feature-driven architecture with the following structure:

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

## Key Technologies & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (SDK 3.10.8+)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) for theme persistence
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts)
- **Code Quality**: [Flutter Lints](https://pub.dev/packages/flutter_lints)

## Implemented Data Structures

### Stack Visualization
- **Operations**: Push, Pop, Peek
- **Time Complexity**: O(1) for all operations
- **Features**: Visualizes LIFO (Last In First Out) behavior with animations

### Queue Visualization  
- **Operations**: Enqueue, Dequeue, Peek
- **Time Complexity**: O(1) for all operations
- **Features**: Visualizes FIFO (First In First Out) behavior with animations

### Planned Features
- Tree & Graph visualizations (in development)
- Sorting algorithm visualizations

## State Management

The application uses the Provider package for state management with dedicated providers for:
- Theme management (dark/light mode)
- Stack operations and animations
- Queue operations and animations
- Tree and graph operations
- Sorting algorithm visualization

## UI Components

The UI is built with reusable components including:
- Operation buttons with visual feedback
- Control panels for animation speed and options
- Complexity displays showing time/space complexity
- Code preview components
- Zoomable visualization areas

## Building and Running

### Prerequisites
- Flutter SDK (version 3.10.8 or higher)

### Installation Steps
```bash
# Clone the repository
git clone https://github.com/your-username/dsa_sim.git
cd dsa_sim

# Install dependencies
flutter pub get

# Run the application
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

## Development Conventions

- **Architecture**: Clean, feature-driven architecture with separation of concerns
- **State Management**: Provider pattern for predictable state updates
- **UI Design**: Responsive design following Material Design principles
- **Animations**: Smooth animations with configurable speeds
- **Theming**: Support for both light and dark modes
- **Code Quality**: Follows Flutter Lints recommendations

## Key Constants and Configuration

Located in `lib/utils/constants.dart`, the application defines:
- UI dimensions and spacing
- Color schemes for both light and dark modes
- Animation durations and speed controls
- Data structure limits (max stack/queue sizes)
- Time and space complexity mappings

## Testing Strategy

The project includes a `test` directory with unit and widget tests following Flutter testing best practices. Tests cover:
- Data structure model functionality
- State management logic
- UI component behavior
- Animation sequences

## Project Status

The application is actively under development with:
- ✅ Stack visualization (complete)
- ✅ Queue visualization (complete) 
- 🚧 Tree & Graph visualization (in progress)
- 🚧 Sorting algorithms visualization (in progress)

## Contribution Guidelines

The project welcomes contributions. The architecture is designed to be modular, making it easy to add new data structure visualizations or enhance existing ones. New visualizations should follow the same pattern of models, providers, and screens.