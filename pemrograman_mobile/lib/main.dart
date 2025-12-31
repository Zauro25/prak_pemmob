import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './service/firebase_options.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';
import './pages/add_task_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    // Cek apakah Firebase app sudah ada
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } else {
      // Jika sudah ada, gunakan app yang existing
      Firebase.app();
      print('Using existing Firebase app');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue running app even if Firebase fails
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/add': (context) => const AddTaskPage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('=== AUTH WRAPPER DEBUG ===');
        print('Connection State: ${snapshot.connectionState}');
        print('Has Data: ${snapshot.hasData}');
        print('Has Error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
        }
        print('Current User: ${FirebaseAuth.instance.currentUser?.email}');
        print('User UID: ${FirebaseAuth.instance.currentUser?.uid}');
        print('========================');

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // If user is authenticated, go to home
        if (snapshot.hasData && snapshot.data != null) {
          print('User is authenticated, going to HomePage');
          return const HomePage();
        }

        // If no user, go to login
        print('No user found, going to LoginPage');
        return const LoginPage();
      },
    );
  }
}