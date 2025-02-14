import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wedding_invitation/pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<User?> _signInAnonymously() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUid = prefs.getString('anonymous_uid');

    if (savedUid != null) {
      return FirebaseAuth.instance.currentUser;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      await prefs.setString('anonymous_uid', userCredential.user!.uid);
      return userCredential.user;
    } catch (e) {
      debugPrint("Error login anonim: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.transparent,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        future: _signInAnonymously(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          return snapshot.hasData ? const HomePage() : const ErrorScreen();
        },
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Fix your connection dulu, baru kita ngomongin masa depan.",
          style: Desk(textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
