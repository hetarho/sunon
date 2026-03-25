# Quickstart: 003-workspace-project

## Prerequisites

- Flutter SDK (stable, Dart ^3.11.1)
- Desktop platform toolchain (macOS Xcode / Windows Visual Studio / Linux build-essential)

## Setup

```bash
cd app
flutter pub add file_picker shared_preferences window_manager desktop_multi_window
flutter pub get
```

## Run

```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## Key Files

```
app/lib/
├── main.dart                    # App entry point, multi-window setup
├── models/
│   ├── workspace.dart           # Workspace model
│   └── project.dart             # Project model
├── services/
│   ├── workspace_service.dart   # Directory scanning, project listing
│   └── persistence_service.dart # shared_preferences wrapper
├── providers/
│   └── workspace_provider.dart  # State management (ChangeNotifier)
└── screens/
    ├── workspace_selection_screen.dart  # "Select workspace" UI
    └── workspace_home_screen.dart       # Project list UI
```

## Test

```bash
cd app
flutter test
```
