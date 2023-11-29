// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQFM9cYYD4Uno7Fm7SWq0dOgO-trI5vGc',
    appId: '1:251327944354:android:4ebee6e8f78ca93c1169fb',
    messagingSenderId: '251327944354',
    projectId: 'aramanservices-79ed6',
    storageBucket: 'aramanservices-79ed6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3gwnSrg-C1GxHMzTvX3OXchyb0jQjDKs',
    appId: '1:251327944354:ios:6d84ca33daa0cbdd1169fb',
    messagingSenderId: '251327944354',
    projectId: 'aramanservices-79ed6',
    storageBucket: 'aramanservices-79ed6.appspot.com',
    androidClientId: '251327944354-9a652pell05s3sj3799j1v36pnik1epg.apps.googleusercontent.com',
    iosClientId: '251327944354-40249mdnvudj84e5v9r2g8d552gmt9v9.apps.googleusercontent.com',
    iosBundleId: 'com.aramanservices.lite',
  );
}
