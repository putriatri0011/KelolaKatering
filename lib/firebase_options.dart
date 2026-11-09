// Konfigurasi Firebase untuk web (Modul 9, jalur cadangan: salin manual
// dari Project settings > Your apps > KelolaKatering Web).
//
// Isinya pengenal project, bukan password, sehingga boleh di-commit.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8H8Os7XetHrK0vokbxasQ6FIk6vIFHL8',
    appId: '1:284981597810:web:987e1ff0b6de7a106014eb',
    messagingSenderId: '284981597810',
    projectId: 'kelolakatering-2301550011',
    authDomain: 'kelolakatering-2301550011.firebaseapp.com',
    storageBucket: 'kelolakatering-2301550011.firebasestorage.app',
  );
}
