// This is a basic Flutter widget test.
//
// To perform an interaction with a widget test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/data/menu_awal.dart';
import 'package:kelola_katering/main.dart';
import 'package:kelola_katering/models/pengguna_model.dart';
import 'package:kelola_katering/services/layanan_firestore.dart';

void main() {
  testWidgets('App menampilkan Dashboard sebagai halaman awal', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      KelolaKateringApp(halamanAwal: HomeShell(layanan: LayananMemori())),
    );

    // Layar uji bawaan 800 x 600 termasuk layar lebar: "Dashboard" tampil
    // sebagai judul halaman dan sebagai menu sidebar.
    expect(find.text('Dashboard'), findsNWidgets(2));

    // Menu kedua memakai nama halaman final "Daftar Pesanan".
    expect(find.byKey(const Key('nav-daftar-pesanan')), findsOneWidget);
  });

  // ── Modul 10: collection users dan menus ──────────────────────

  testWidgets('Dashboard menyapa admin dengan nama dari users', (
    WidgetTester tester,
  ) async {
    final layanan = LayananMemori(
      pengguna: const Pengguna(
        idPengguna: 'uid-uji',
        namaLengkap: 'Putria',
        email: 'putria@kelolakatering.id',
      ),
    );
    await tester.pumpWidget(
      KelolaKateringApp(halamanAwal: HomeShell(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Halo, Putria'), findsOneWidget);
  });

  testWidgets('Tanpa profil di users, sapaan tetap "Halo, Admin"', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      KelolaKateringApp(halamanAwal: HomeShell(layanan: LayananMemori())),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Halo, Admin'), findsOneWidget);
  });

  testWidgets('Membuka aplikasi mengisi menus satu kali saja', (
    WidgetTester tester,
  ) async {
    final layanan = LayananMemori();
    await tester.pumpWidget(
      KelolaKateringApp(halamanAwal: HomeShell(layanan: layanan)),
    );
    await tester.pumpAndSettle();
    expect(layanan.menu.length, daftarMenuAwal.length);

    // Dipanggil lagi: menu tidak boleh terisi dua kali.
    await layanan.isiMenuAwalJikaKosong();
    expect(layanan.menu.length, daftarMenuAwal.length);
  });

  test('simpanPenggunaSaatLogin tidak menimpa profil yang sudah ada', () async {
    final layanan = LayananMemori();
    await layanan.simpanPenggunaSaatLogin(
      uid: 'uid-uji',
      email: 'putria@kelolakatering.id',
      namaLengkap: 'Putria',
    );
    await layanan.simpanPenggunaSaatLogin(
      uid: 'uid-uji',
      email: 'putria@kelolakatering.id',
    );
    expect(layanan.pengguna?.namaLengkap, 'Putria');
  });
}
