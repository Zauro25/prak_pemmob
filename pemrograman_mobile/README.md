# Task Manager - Flutter Firebase App

A modern, user-authenticated task management application built with Flutter and Firebase. This app provides a clean, intuitive interface for managing personal tasks with real-time synchronization.

## ✨ Features

### 🔐 Authentication System
- **User Registration**: Create new accounts with email and password
- **User Login**: Secure authentication with Firebase Auth
- **User-Specific Tasks**: Each user has their own private task collection
- **Session Management**: Automatic login state persistence
- **Logout Functionality**: Secure sign-out with confirmation

### 📱 Modern UI/UX Design
- **Material Design 3**: Latest Material Design principles
- **Clean Interface**: Minimalist, distraction-free design
- **Responsive Layout**: Optimized for various screen sizes
- **Smooth Animations**: Fluid transitions and interactions
- **Consistent Theming**: Unified color scheme and typography

### 📋 Task Management
- **Add Tasks**: Create new tasks with detailed descriptions
- **Mark Complete**: Toggle task completion status
- **Delete Tasks**: Remove tasks with confirmation dialog
- **Real-time Updates**: Instant synchronization across devices
- **Task History**: View creation timestamps
- **Empty States**: Helpful guidance when no tasks exist

### 🔄 Real-time Synchronization
- **Firebase Firestore**: Cloud-based data storage
- **Live Updates**: Changes sync instantly across devices
- **Offline Support**: Works offline with automatic sync when online
- **Error Handling**: Robust error management and user feedback

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point and routing
├── models/
│   └── task.dart            # Task data model
├── pages/
│   ├── login_page.dart      # User authentication (login)
│   ├── register_page.dart   # User registration
│   ├── home_page.dart       # Main task list interface
│   └── add_task_page.dart   # Task creation form
└── service/
    ├── firebase_options.dart    # Firebase configuration
    ├── auth_service.dart        # Authentication service
    └── firestore_service.dart   # Firestore data operations
```

### Key Components

#### 🔐 Authentication Service (`auth_service.dart`)
- Email/password authentication
- User session management
- Error handling with user-friendly messages
- Password reset functionality

#### 🔥 Firestore Service (`firestore_service.dart`)
- User-specific task collections
- Real-time data streaming
- CRUD operations (Create, Read, Update, Delete)
- Error handling and logging

#### 📱 Pages
- **LoginPage**: Modern login form with validation
- **RegisterPage**: User registration with password confirmation
- **HomePage**: Task list with user profile and logout
- **AddTaskPage**: Task creation with form validation

## 🎨 Design System

### Color Palette
- **Primary**: Indigo (#6366F1) - Modern, professional
- **Background**: Light grey (#F9FAFB) - Clean, minimal
- **Cards**: White with subtle shadows
- **Text**: Dark grey hierarchy for readability

### Typography
- **Headings**: Bold, clear hierarchy
- **Body**: Readable font sizes
- **Labels**: Consistent styling across forms

### Components
- **Rounded Corners**: 12px radius for modern feel
- **Shadows**: Subtle elevation for depth
- **Spacing**: Consistent 16px grid system
- **Icons**: Material Design icons throughout

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2+)
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pemrograman_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Download configuration files
   - Update `firebase_options.dart` with your credentials

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup

1. **Authentication**
   - Go to Firebase Console → Authentication
   - Enable Email/Password sign-in method
   - Configure authorized domains

2. **Firestore Database**
   - Create Firestore database
   - Set up security rules for user-specific collections
   - Example rule:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /tasks/{userId}/userTasks/{taskId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

## 📱 Usage

### First Time Setup
1. Launch the app
2. Tap "Sign Up" to create an account
3. Enter email and password
4. Start adding tasks!

### Managing Tasks
1. **Add Task**: Tap the floating action button
2. **Complete Task**: Check the checkbox next to any task
3. **Delete Task**: Tap the delete icon and confirm
4. **View Profile**: Tap the menu icon in the app bar

### User Management
- **Logout**: Use the menu in the app bar
- **Switch Accounts**: Logout and login with different credentials

## 🔧 Technical Details

### Dependencies
- `firebase_core: ^3.3.0` - Firebase core functionality
- `firebase_auth: ^5.3.1` - User authentication
- `cloud_firestore: ^5.5.0` - Real-time database
- `flutter` - UI framework

### State Management
- **StreamBuilder**: Real-time UI updates
- **StatefulWidget**: Local state management
- **Firebase Auth Stream**: Authentication state monitoring

### Data Structure
```dart
// Task Model
class Task {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? timestamp;
}
```

### Firestore Structure
```
/tasks/{userId}/userTasks/{taskId}
├── title: string
├── isDone: boolean
└── timestamp: DateTime
```

## 🛡️ Security Features

- **User Authentication**: Firebase Auth integration
- **Data Isolation**: User-specific collections
- **Input Validation**: Form validation and sanitization
- **Error Handling**: Secure error messages
- **Session Management**: Automatic token refresh

## 🎯 Future Enhancements

- [ ] Task categories and tags
- [ ] Due dates and reminders
- [ ] Task sharing and collaboration
- [ ] Dark mode support
- [ ] Offline-first architecture
- [ ] Push notifications
- [ ] Task analytics and insights

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📞 Support

For support and questions, please open an issue in the repository or contact the development team.

---

**Built with ❤️ using Flutter and Firebase**