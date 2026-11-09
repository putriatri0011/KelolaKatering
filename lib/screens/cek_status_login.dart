import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'masuk_screen.dart';

/// Memilih halaman berdasarkan status login (Modul 9).
///
/// [FirebaseAuth.authStateChanges] memberi kabar setiap kali admin masuk
/// atau keluar. Halaman yang tampil selalu mengikuti status terakhir,
/// sehingga Halaman Masuk dan tombol Keluar tidak perlu memanggil
/// Navigator. Sesi disimpan Firebase, jadi tetap masuk setelah refresh.
class CekStatusLogin extends StatelessWidget {
  const CekStatusLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return const HomeShell();
        return const MasukScreen();
      },
    );
  }
}
