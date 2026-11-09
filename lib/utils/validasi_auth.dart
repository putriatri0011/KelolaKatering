/// Aturan validasi dan pesan kesalahan untuk Halaman Masuk (Modul 9).
///
/// Validator dipakai oleh [TextFormField] dengan pola yang sama seperti
/// Form Tambah Pesanan (Modul 7). [pesanKesalahanAuth] menerjemahkan kode
/// FirebaseAuthException menjadi pesan yang dipahami admin.
library;

/// Panjang password minimal yang diterima Firebase Authentication.
const int panjangPasswordMinimal = 6;

String? validasiEmail(String? nilai) {
  final email = nilai?.trim() ?? '';
  if (email.isEmpty) return 'Email wajib diisi';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Format email belum benar';
  }
  return null;
}

String? validasiPassword(String? nilai) {
  final password = nilai ?? '';
  if (password.isEmpty) return 'Password wajib diisi';
  if (password.length < panjangPasswordMinimal) {
    return 'Password minimal $panjangPasswordMinimal karakter';
  }
  return null;
}

/// Kolom Ulangi password (hanya pada mode Daftar).
String? validasiUlangiPassword(String? nilai, String password) {
  final ulangi = nilai ?? '';
  if (ulangi.isEmpty) return 'Ulangi password';
  if (ulangi != password) return 'Password tidak sama';
  return null;
}

/// Menerjemahkan kode `FirebaseAuthException.code` menjadi pesan.
///
/// Email tidak terdaftar dan password salah sengaja diberi pesan yang
/// sama, agar orang lain tidak dapat menebak email mana yang terdaftar.
String pesanKesalahanAuth(String kode) {
  switch (kode) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Email atau password salah';
    case 'invalid-email':
      return 'Format email belum benar';
    case 'email-already-in-use':
      return 'Email sudah terdaftar. Silakan masuk.';
    case 'weak-password':
      return 'Password terlalu lemah, minimal $panjangPasswordMinimal karakter';
    case 'user-disabled':
      return 'Akun ini dinonaktifkan. Hubungi pemilik aplikasi.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    case 'network-request-failed':
      return 'Tidak dapat terhubung. Periksa koneksi internet.';
    case 'operation-not-allowed':
      return 'Login email/password belum diaktifkan di Firebase Console';
    default:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
