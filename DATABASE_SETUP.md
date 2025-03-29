# Firebase Database Setup Guide

## Prerequisites
- Flutter SDK installed
- Firebase account (create at https://firebase.google.com/)
- FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "AlumniAssociationPlatform")
4. Enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Configure Firebase for Your App
1. In Firebase Console, click "Add app"
2. Select platforms (Android, iOS, Web) as needed
3. For each platform:
   - Android: Provide package name (e.g., `com.example.alumni`)
   - iOS: Provide bundle ID
   - Web: Provide nickname
4. Download configuration files when prompted

## Step 3: Set Up Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select "Start in production mode" (you can change rules later)
4. Choose location closest to your users
5. Click "Enable"

## Step 4: Configure Flutter App
1. Run in terminal:
```bash
cd alumni_association_platform
flutterfire configure
```
2. Select your Firebase project
3. Choose platforms to configure (same as step 2)
4. The command will generate `firebase_options.dart`

## Step 5: Initialize Firebase
1. In your main app initialization:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```
2. Verify connection in `firebase_service.dart`

## Step 6: Security Rules (Optional)
Configure Firestore security rules in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 7: Test Connection
1. Run the app
2. Check debug console for initialization messages
3. Verify you can perform basic CRUD operations

## Troubleshooting
- **Initialization errors**: Verify `firebase_options.dart` is properly generated
- **Permission denied**: Check Firestore security rules
- **Network issues**: Enable offline persistence in `FirebaseService`

## Additional Configuration
- To enable offline persistence:
```dart
await FirebaseFirestore.instance.enablePersistence();
```
- For better error handling, use the provided `DatabaseService` class

## Maintenance
- Regularly backup your Firestore data
- Monitor usage in Firebase Console
- Adjust security rules as needed