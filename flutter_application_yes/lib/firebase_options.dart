import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFiWEexR-V3lcwpuYQHnV8I5aqra5IpEg',
    appId: '1:901994591347:web:d3d031278f004da2fee606',
    messagingSenderId: '901994591347',
    projectId: 'my-project-fc1ee',
    authDomain: 'my-project-fc1ee.firebaseapp.com',
    storageBucket: 'my-project-fc1ee.firebasestorage.app',
    measurementId: 'G-N6NXSXPN2Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJJKdcbSClmwJ3-QLd1cRVNpyfH-ntyzw',
    appId: '1:901994591347:android:5a05dd8e394ffad2fee606',
    messagingSenderId: '901994591347',
    projectId: 'my-project-fc1ee',
    storageBucket: 'my-project-fc1ee.firebasestorage.app',
  );
}

