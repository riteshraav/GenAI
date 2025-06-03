
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDv4BzBsKEGNmBpyHs5YVk-iNmHS58xnV8',
    appId: '1:835075196472:android:6305c5b4ef1ce7534d48cd',
    messagingSenderId: '835075196472',
    projectId: 'alrex-8602f',
    storageBucket: 'alrex-8602f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'fake_ios_key', // replace if you add iOS support later
    appId: '1:835075196472:ios:f42bfbe3db9a0afc4d48cd',
    messagingSenderId: '835075196472',
    projectId: 'alrex-8602f',
    storageBucket: 'alrex-8602f.appspot.com',
    iosClientId: 'fake_ios_client_id',
    iosBundleId: 'com.example.arlex_getx',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'fake_web_key', // replace if you add web support
    appId: '1:835075196472:web:5ccc528aa75190cc4d48cd',
    messagingSenderId: '835075196472',
    projectId: 'alrex-8602f',
    authDomain: 'alrex-8602f.firebaseapp.com',
    storageBucket: 'alrex-8602f.appspot.com',
  );
}
