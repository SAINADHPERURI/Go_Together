// File generated for GoTogether using exact project credentials
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyAzzzcDRd4LwaThuPqOwtSaIjM1g7H6wNU',
    appId: '1:542140685212:web:d63cd8e1a0ccbe243dc659',
    messagingSenderId: '542140685212',
    projectId: 'gotogether-b18d2',
    authDomain: 'gotogether-b18d2.firebaseapp.com',
    storageBucket: 'gotogether-b18d2.firebasestorage.app',
    measurementId: 'G-2ZVEX3T4EZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzzzcDRd4LwaThuPqOwtSaIjM1g7H6wNU',
    appId: '1:542140685212:android:d63cd8e1a0ccbe243dc659',
    messagingSenderId: '542140685212',
    projectId: 'gotogether-b18d2',
    storageBucket: 'gotogether-b18d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzzzcDRd4LwaThuPqOwtSaIjM1g7H6wNU',
    appId: '1:542140685212:ios:d63cd8e1a0ccbe243dc659',
    messagingSenderId: '542140685212',
    projectId: 'gotogether-b18d2',
    storageBucket: 'gotogether-b18d2.firebasestorage.app',
    iosBundleId: 'com.gotogether.travelapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAzzzcDRd4LwaThuPqOwtSaIjM1g7H6wNU',
    appId: '1:542140685212:ios:d63cd8e1a0ccbe243dc659',
    messagingSenderId: '542140685212',
    projectId: 'gotogether-b18d2',
    storageBucket: 'gotogether-b18d2.firebasestorage.app',
    iosBundleId: 'com.gotogether.travelapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAzzzcDRd4LwaThuPqOwtSaIjM1g7H6wNU',
    appId: '1:542140685212:web:d63cd8e1a0ccbe243dc659',
    messagingSenderId: '542140685212',
    projectId: 'gotogether-b18d2',
    authDomain: 'gotogether-b18d2.firebaseapp.com',
    storageBucket: 'gotogether-b18d2.firebasestorage.app',
  );
}
