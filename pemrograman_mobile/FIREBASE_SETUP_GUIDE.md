# Firebase Setup Guide - pemrograman_mobile

## ✅ Configuration Completed

Your Firebase project has been successfully configured with the following details:

### Project Information
- **Project ID**: `pem-mob-ee806`
- **Project Name**: pem-mob
- **Storage Bucket**: `pem-mob-ee806.firebasestorage.app`
- **Auth Domain**: `pem-mob-ee806.firebaseapp.com`

### Configured Platforms
- ✅ **Web** - App ID: `1:937169410719:web:4eb03afbd8c728a5f0a0aa`
- ✅ **Android** - App ID: `1:937169410719:android:b6d69c3758f49dbcf0a0aa`
- ✅ **iOS** - App ID: `1:937169410719:ios:606edeff1a76e9c1f0a0aa`
- ✅ **Windows** - App ID: `1:937169410719:web:6a112ffefa266263f0a0aa`
- ✅ **macOS** - Uses iOS configuration

## 🔐 Firebase Authentication

### Enabled Sign-In Methods
To ensure Email/Password authentication works, verify it's enabled in Firebase Console:

1. Go to: https://console.firebase.google.com/project/pem-mob-ee806/authentication/providers
2. Ensure **Email/Password** provider is enabled
3. If not enabled:
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"

### Authentication Rules
Firebase Authentication doesn't use security rules files - it's configured through the Firebase Console. The authentication settings control:
- Which sign-in methods are enabled
- Password policy requirements
- Email verification requirements
- Account management settings

## 📁 Important Files

### Configuration Files Created/Updated
- ✅ `lib/service/firebase_options.dart` - Flutter Firebase configuration
- ✅ `android/app/google-services.json` - Android configuration
- ✅ `ios/Runner/GoogleService-Info.plist` - iOS configuration

### Your Authentication Service
- `lib/service/auth_service.dart` - Handles sign in, sign up, and password reset
- `lib/pages/login_page.dart` - Login UI
- `lib/pages/register_page.dart` - Registration UI

## 🚀 Running Your App

### For Web (recommended for testing)
```bash
flutter run -d chrome
# or
flutter run -d web-server
```

### For Android
```bash
flutter run -d android
```

### For iOS (macOS only)
```bash
flutter run -d ios
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. "No user found with this email address"
**Solution**: 
- You need to register first using the Register page
- Or create a user in Firebase Console: https://console.firebase.google.com/project/pem-mob-ee806/authentication/users

#### 2. "This operation is not allowed"
**Solution**: 
- Email/Password sign-in method is not enabled
- Go to Firebase Console → Authentication → Sign-in method
- Enable "Email/Password"

#### 3. CORS errors (web only)
**Solution**: 
- CORS errors on web are normal during development
- Use `flutter run -d chrome --web-browser-flag "--disable-web-security"`
- Or test on Android/iOS

#### 4. "Network error" or connection timeouts
**Solution**: 
- Check your internet connection
- Verify Firebase project status at: https://status.firebase.google.com/
- Check if API keys are correct in `firebase_options.dart`

#### 5. App stays on loading screen
**Solution**: 
- Check the console logs for initialization errors
- Verify Firebase is initialized properly in `main.dart`
- Run `flutter clean && flutter pub get`

## 🧪 Testing Authentication

### Test User Creation
Create a test user in Firebase Console:
1. Go to: https://console.firebase.google.com/project/pem-mob-ee806/authentication/users
2. Click "Add user"
3. Enter email: `test@example.com`
4. Enter password: `test123456`
5. Click "Add user"

### Test Login Flow
1. Run the app: `flutter run -d chrome`
2. Click "Don't have an account? Register here"
3. Create a new account with:
   - Email: your_email@example.com
   - Password: At least 6 characters
4. After registration, you should be automatically logged in
5. Log out and try logging in with the same credentials

## 📊 Firebase Console Links

- **Project Overview**: https://console.firebase.google.com/project/pem-mob-ee806/overview
- **Authentication**: https://console.firebase.google.com/project/pem-mob-ee806/authentication/users
- **Firestore Database**: https://console.firebase.google.com/project/pem-mob-ee806/firestore
- **Storage**: https://console.firebase.google.com/project/pem-mob-ee806/storage

## 🔄 Updating Firebase Configuration

If you need to reconfigure Firebase in the future:

```bash
# Make sure you're logged in
firebase login

# Reconfigure the project
flutterfire configure
```

## ✨ Next Steps

1. ✅ Firebase is configured
2. ✅ Authentication is set up
3. 🔹 Test the login/register flow
4. 🔹 Create test users
5. 🔹 Build your app features

## 📝 Notes

- Your Firebase configuration is now using the real project credentials
- The placeholder values in `firebase_options.dart` have been replaced
- 2 users already exist in your Firebase Authentication
- All platforms (Web, Android, iOS, Windows, macOS) are configured
