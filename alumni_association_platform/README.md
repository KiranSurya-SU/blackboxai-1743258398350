# Alumni Association Platform

A Flutter application for university alumni networking, job postings, and events.

## Features
- User authentication (Email/Password)
- Light/Dark theme support
- Alumni profiles
- Job postings
- Event management

## Setup Instructions

### Firebase Configuration
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Email/Password authentication
3. Set up Firestore database with the provided security rules
4. Register your web app and download the configuration
5. Run `flutterfire configure` to generate `firebase_options.dart`

### Development Setup
1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### Environment Variables
Create a `.env` file in the root directory with:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_bucket.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id