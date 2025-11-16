# Docket Uploader

A clean, simple, and efficient image uploader directly from the device camera  with time tracking prototype built with Flutter. Supports task creation, time entry management, and Firebase based image uploads.

## Features

### Core Functionality

* Track time of each upload
* Maintain clean and structured uploads
* View historical entries

### Firebase Integration

* Firebase Cloud Storage for image uploads
* Firebase initialization for analytics and backend expansion

## Tech Stack

**Framework:** Flutter 3.x
**Language:** Dart
**Backend:** Firebase Storage + Firebase Analytics
**Platforms:** Android
**Design:** Material UI

## Installation & Run

### 1. Clone the project

```bash
git clone https://github.com/tylerdurdenhere/docket_uploader
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. Build APK (Release)

```bash
flutter build apk --release
```

## Project Structure

```
task_final/
 ├── lib/               # Flutter source code
 ├── android/           # Android build config
 ├── web/               # Web build config
 ├── windows/           # Windows runner
 ├── run_proof/            # Screenclips demonstrating functionality
 ├── pubspec.yaml       # Dependencies
 └── README.md          # This file
```

## Firebase Setup Notes

To run the Firebase features:

1. Add your `google-services.json` inside:

```
android/app/
```

2. Ensure Firebase Storage rules allow authenticated usage or public upload (dev only)
3. Run flutter clean + rebuild if metadata changes

## Future Improvements

* Add user authentication
* Add dark mode
* Dashboard with charts
* Export task sessions as CSV
* Cloud Firestore data syncing

## Author

**Umair Ahmed** Software Developer -Mobile and Web

## Note

This project was initially built as a prototype and later refined with guidance, debugging, and multi platform testing. It now serves as a solid portfolio piece demonstrating Flutter + Firebase integration.
