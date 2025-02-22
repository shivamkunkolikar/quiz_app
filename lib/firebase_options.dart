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
    apiKey: 'AIzaSyBT9wTAlXUK1_Mrj6N-bI58TOVpIGL1gro',
    appId: '1:94652761783:web:07012bf6cafbc136e0ef32',
    messagingSenderId: '94652761783',
    projectId: 'quizfinal-70789',
    authDomain: 'quizfinal-70789.firebaseapp.com',
    storageBucket: 'quizfinal-70789.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR23x4E3TNFAXh7-eBP16OR4xnI8nd3J8',
    appId: '1:94652761783:android:a6f25b03f5ebba6ee0ef32',
    messagingSenderId: '94652761783',
    projectId: 'quizfinal-70789',
    storageBucket: 'quizfinal-70789.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAw51Y6eF4DH9OqACkVDJ0lH65-KcDQJJ0',
    appId: '1:94652761783:ios:b6db645ac2b06a65e0ef32',
    messagingSenderId: '94652761783',
    projectId: 'quizfinal-70789',
    storageBucket: 'quizfinal-70789.appspot.com',
    iosBundleId: 'com.example.quizApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAw51Y6eF4DH9OqACkVDJ0lH65-KcDQJJ0',
    appId: '1:94652761783:ios:b6db645ac2b06a65e0ef32',
    messagingSenderId: '94652761783',
    projectId: 'quizfinal-70789',
    storageBucket: 'quizfinal-70789.appspot.com',
    iosBundleId: 'com.example.quizApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBT9wTAlXUK1_Mrj6N-bI58TOVpIGL1gro',
    appId: '1:94652761783:web:f3a63ce0b3f3a4a3e0ef32',
    messagingSenderId: '94652761783',
    projectId: 'quizfinal-70789',
    authDomain: 'quizfinal-70789.firebaseapp.com',
    storageBucket: 'quizfinal-70789.appspot.com',
  );

}