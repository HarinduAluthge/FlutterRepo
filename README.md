FlutterRepo

A Flutter application by Harindu Aluthge.

Table of Contents

Project Description

Features

Getting Started

Prerequisites

Installation

Running

Project Structure

Contributing

License

Project Description

This is a Flutter project (repo: FlutterRepo) built by Harindu Aluthge.
The project contains a sample (“flutter_application_yes”) Flutter app. 
GitHub

Features

Basic Flutter app scaffold

Cross-platform (iOS, Android) setup

(You can list any specific screens / widgets / functionality here if added)

Getting Started
Prerequisites

Before you begin, ensure you have:

Flutter SDK installed (stable channel recommended)

Dart SDK (usually comes with Flutter)

An IDE or editor (e.g. Android Studio, VS Code)

A device / emulator to run the app

Installation

Clone the repository:

git clone https://github.com/HarinduAluthge/FlutterRepo.git


Navigate into the project directory:

cd FlutterRepo/flutter_application_yes


Get dependencies:

flutter pub get

Running

To run the app:

flutter run


You can also target specific device or platform. For example:

flutter run -d <device_id>

Project Structure

Here’s a rough outline of how the project’s organized:

FlutterRepo/
├── flutter_application_yes/      # Main Flutter application folder
│   ├── lib/                       # Dart source files
│   ├── ios/                       # iOS platform-specific code
│   ├── android/                   # Android platform-specific code
│   ├── test/                      # Test files (if any)
│   ├── pubspec.yaml               # Package dependencies, metadata
│   └── ...                        # Other standard Flutter directories
└── (other files / folders…)       # Additional files at root


You can expand on this with descriptions of major Dart files, widgets, state management, etc.

Contributing

Contributions are welcome! Here’s how you can help:

Fork the repository

Create a new branch: git checkout -b feature/YourFeatureName

Make your changes

Commit: git commit -m "Add some feature"

Push: git push origin feature/YourFeatureName

Open a Pull Request

Please ensure that your code follows Flutter / Dart style guidelines. Running tests (if any) before submitting is appreciated.
