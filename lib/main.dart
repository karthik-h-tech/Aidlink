import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ Initialize Firebase with proper error handling
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "enter api",
        authDomain: "aidlink-5dcb0.firebaseapp.com",
        projectId: "aidlink-5dcb0",
        storageBucket: "aidlink-5dcb0.appspot.com",
        messagingSenderId: "164072024038",
        appId: "1:164072024038:web:cae8efee0637a8cc595827",
      ),
    );
    print('✅ Firebase Initialized Successfully');
  } catch (e) {
    print('❌ Firebase Initialization Failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AidLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: routes, // ✅ Using the routes defined in routes.dart
    );
  }
}
