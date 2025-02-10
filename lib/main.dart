import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_invitation/pages.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUid = prefs.getString('anonymous_uid');

    if (savedUid != null) {
      print("Menggunakan UID yang tersimpan: $savedUid");
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
      });
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        _user = userCredential.user;

        await prefs.setString('anonymous_uid', _user!.uid);
        print("Login sukses! UID baru disimpan: ${_user?.uid}");

        setState(() {});
      } catch (e) {
        print("Error login anonim: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _user == null ? LoadingScreen() : HomePage(),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.transparent,),),
    );
  }
}