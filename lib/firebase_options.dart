// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAO7UzDzBvVSVGem4M3nrL7sKjeM30x4WA',
    appId: '1:676660103213:web:7bc6bdf4be507440b0d0a4',
    messagingSenderId: '676660103213',
    projectId: 'sayingwedding',
    authDomain: 'sayingwedding.firebaseapp.com',
    storageBucket: 'sayingwedding.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApww8l2bhaiv0FIBj3u6_MLa71D1dGy9Y',
    appId: '1:676660103213:android:9ff96f92d0d3ead6b0d0a4',
    messagingSenderId: '676660103213',
    projectId: 'sayingwedding',
    storageBucket: 'sayingwedding.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD67ZAuZ2U4NYby5wRiDCd5qDmwJMI-MYA',
    appId: '1:676660103213:ios:813c8cd5fd92d25ab0d0a4',
    messagingSenderId: '676660103213',
    projectId: 'sayingwedding',
    storageBucket: 'sayingwedding.firebasestorage.app',
    iosBundleId: 'com.akhdan.weddingInvitation',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD67ZAuZ2U4NYby5wRiDCd5qDmwJMI-MYA',
    appId: '1:676660103213:ios:813c8cd5fd92d25ab0d0a4',
    messagingSenderId: '676660103213',
    projectId: 'sayingwedding',
    storageBucket: 'sayingwedding.firebasestorage.app',
    iosBundleId: 'com.akhdan.weddingInvitation',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAO7UzDzBvVSVGem4M3nrL7sKjeM30x4WA',
    appId: '1:676660103213:web:e68966c70f9508f1b0d0a4',
    messagingSenderId: '676660103213',
    projectId: 'sayingwedding',
    authDomain: 'sayingwedding.firebaseapp.com',
    storageBucket: 'sayingwedding.firebasestorage.app',
  );
}
