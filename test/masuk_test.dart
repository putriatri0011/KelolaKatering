// Pengujian Halaman Masuk dan Daftar (Modul 9).
//
// Firebase tidak dihubungi: [MasukScreen.prosesAuth] diganti fungsi palsu
// yang mencatat permintaan atau melempar FirebaseAuthException, sehingga
// kasus pada tabel uji login dapat diulang kapan saja.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/screens/masuk_screen.dart';
import 'package:kelola_katering/utils/theme.dart';
import 'package:kelola_katering/utils/validasi_auth.dart';

void main() {
  /// Permintaan yang sampai ke "Firebase" palsu: (email, password, daftar).
  late List<(String, String, bool)> permintaan;

  setUp(() => permintaan = []);

  Future<void> buka(WidgetTester tester, {String? kodeError}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MasukScreen(
          prosesAuth: (email, password, daftar) async {
            permintaan.add((email, password, daftar));
            if (kodeError != null) {
              throw FirebaseAuthException(code: kodeError);
            }
          },
        ),
      ),
    );
  }

  Future<void> isi(WidgetTester tester, Key kolom, String teks) =>
      tester.enterText(find.byKey(kolom), teks);

  Future<void> kirim(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('tombol-kirim')));
    await tester.pumpAndSettle();
  }

  group('Tabel uji login', () {
    testWidgets('1. Login benar diteruskan ke Firebase tanpa pesan', (
      tester,
    ) async {
      await buka(tester);
      await isi(tester, const Key('kolom-email'), 'admin@kelolakatering.id');
      await isi(tester, const Key('kolom-password'), 'rahasia123');
      await kirim(tester);

      expect(permintaan, [('admin@kelolakatering.id', 'rahasia123', false)]);
      expect(find.byKey(const Key('pesan-kesalahan-login')), findsNothing);
    });

    testWidgets('2. Password salah menampilkan pesan yang sama', (
      tester,
    ) async {
      await buka(tester, kodeError: 'invalid-credential');
      await isi(tester, const Key('kolom-email'), 'admin@kelolakatering.id');
      await isi(tester, const Key('kolom-password'), 'salah123');
      await kirim(tester);

      expect(find.text('Email atau password salah'), findsOneWidget);
    });

    testWidgets('3. Email tidak valid ditolak sebelum dikirim', (tester) async {
      await buka(tester);
      await isi(tester, const Key('kolom-email'), 'admin.kelolakatering');
      await isi(tester, const Key('kolom-password'), 'rahasia123');
      await kirim(tester);

      expect(find.text('Format email belum benar'), findsOneWidget);
      expect(permintaan, isEmpty);
    });

    testWidgets('4. Kolom kosong: kedua kolom menampilkan pesan', (
      tester,
    ) async {
      await buka(tester);
      await kirim(tester);

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(permintaan, isEmpty);
    });

    testWidgets('5. Daftar dengan email terpakai', (tester) async {
      await buka(tester, kodeError: 'email-already-in-use');
      await tester.tap(find.byKey(const Key('tombol-ganti-mode')));
      await tester.pumpAndSettle();

      await isi(tester, const Key('kolom-email'), 'admin@kelolakatering.id');
      await isi(tester, const Key('kolom-password'), 'rahasia123');
      await isi(tester, const Key('kolom-ulangi-password'), 'rahasia123');
      await kirim(tester);

      expect(permintaan.single.$3, isTrue); // dikirim sebagai pendaftaran
      expect(
        find.text('Email sudah terdaftar. Silakan masuk.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Mode Daftar menolak password yang tidak sama', (tester) async {
    await buka(tester);
    await tester.tap(find.byKey(const Key('tombol-ganti-mode')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('kolom-ulangi-password')), findsOneWidget);
    await isi(tester, const Key('kolom-email'), 'baru@kelolakatering.id');
    await isi(tester, const Key('kolom-password'), 'rahasia123');
    await isi(tester, const Key('kolom-ulangi-password'), 'rahasia321');
    await kirim(tester);

    expect(find.text('Password tidak sama'), findsOneWidget);
    expect(permintaan, isEmpty);
  });

  testWidgets('Password disembunyikan', (tester) async {
    await buka(tester);
    final kolom = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('kolom-password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(kolom.obscureText, isTrue);
  });

  test('Kode error Firebase diterjemahkan', () {
    expect(pesanKesalahanAuth('user-not-found'), 'Email atau password salah');
    expect(pesanKesalahanAuth('wrong-password'), 'Email atau password salah');
    expect(
      pesanKesalahanAuth('network-request-failed'),
      'Tidak dapat terhubung. Periksa koneksi internet.',
    );
    expect(
      pesanKesalahanAuth('kode-lain'),
      'Terjadi kesalahan. Silakan coba lagi.',
    );
    expect(validasiPassword('12345'), 'Password minimal 6 karakter');
    expect(validasiPassword('123456'), isNull);
  });
}
