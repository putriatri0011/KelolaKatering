// Pengujian Detail Pesanan dan Daftar Pesanan pada layar ponsel.
//
// Mencakup kebutuhan Must Modul 2 yang ditambahkan setelah Modul 7:
// - K6/K7: mengubah status pesanan dan status pembayaran;
// - K5: mengubah (edit) dan menghapus pesanan;
// - pencarian pesanan berdasarkan nama pelanggan (wireframe Figma).
//
// Layar uji 400 x 900 agar tata letak ponsel (NavigationBar bawah) yang
// diuji. Data MockData dikembalikan ke kondisi awal setelah tiap test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/data/mock_data.dart';
import 'package:kelola_katering/main.dart';
import 'package:kelola_katering/models/pesanan_model.dart';
import 'package:kelola_katering/screens/daftar_pesanan_screen.dart';
import 'package:kelola_katering/screens/dashboard_screen.dart';

void main() {
  late List<Pesanan> dataAwal;

  setUp(() {
    dataAwal = List<Pesanan>.from(MockData.pesananList);
  });

  tearDown(() {
    MockData.pesananList
      ..clear()
      ..addAll(dataAwal);
  });

  // ── Helper ────────────────────────────────────────────────────

  Future<void> bukaAplikasiPonsel(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const KelolaKateringApp(halamanAwal: HomeShell()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tekan(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Membuka Detail Pesanan PSN-001 (Ibu Siti Rahayu) dari Dashboard.
  Future<void> bukaDetailSiti(WidgetTester tester) async {
    await bukaAplikasiPonsel(tester);
    await tekan(
      tester,
      find.descendant(
        of: find.byType(DashboardScreen),
        matching: find.text('Ibu Siti Rahayu'),
      ),
    );
    expect(find.text('Detail Pesanan'), findsOneWidget);
  }

  // ── Kasus uji ─────────────────────────────────────────────────

  testWidgets('7. Status pesanan dapat diubah dari Detail Pesanan', (
    tester,
  ) async {
    await bukaDetailSiti(tester);

    await tekan(tester, find.byKey(const Key('chip-pesanan-diproses')));

    expect(
      MockData.cariById('PSN-001')!.statusPesanan,
      StatusPesanan.diproses,
    );
    expect(
      find.text('Status pesanan diubah menjadi Diproses.'),
      findsOneWidget,
    );
  });

  testWidgets('8. Status pembayaran berubah dan Dashboard ikut diperbarui', (
    tester,
  ) async {
    await bukaDetailSiti(tester);

    await tekan(tester, find.byKey(const Key('chip-bayar-lunas')));
    expect(
      MockData.cariById('PSN-001')!.statusPembayaran,
      StatusPembayaran.lunas,
    );

    // Kembali ke Dashboard: jumlah Lunas di Ringkasan Pembayaran
    // bertambah dari 2 menjadi 3.
    await tester.pageBack();
    await tester.pumpAndSettle();

    final jumlahLunas = tester.widget<Text>(
      find.byKey(const ValueKey('jumlah-bayar-lunas')),
    );
    expect(jumlahLunas.data, '3');
  });

  testWidgets('9. Pesanan dapat diedit tanpa mengubah ID', (tester) async {
    await bukaDetailSiti(tester);

    await tekan(tester, find.text('Edit Pesanan'));
    expect(find.text('Form Edit Pesanan'), findsOneWidget);

    // Kolom sudah terisi data lama.
    final kolomNama = tester.widget<TextFormField>(
      find.byType(TextFormField).at(0),
    );
    expect(kolomNama.controller!.text, 'Ibu Siti Rahayu');

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Ibu Siti Rahayu Putri',
    );
    await tester.enterText(find.byType(TextFormField).at(3), '60');
    await tekan(tester, find.text('Simpan Perubahan'));

    // Kembali ke Detail Pesanan dengan data terbaru.
    expect(find.text('Detail Pesanan'), findsOneWidget);
    expect(find.text('Ibu Siti Rahayu Putri'), findsOneWidget);
    expect(find.text('60 porsi'), findsOneWidget);

    final hasil = MockData.cariById('PSN-001')!;
    expect(hasil.namaPelanggan, 'Ibu Siti Rahayu Putri');
    expect(hasil.jumlahPorsi, 60);
    expect(MockData.pesananList.length, dataAwal.length);
  });

  testWidgets('10. Pesanan dapat dihapus setelah konfirmasi', (tester) async {
    await bukaDetailSiti(tester);

    await tekan(tester, find.text('Hapus Pesanan'));
    expect(find.text('Hapus pesanan ini?'), findsOneWidget);

    await tekan(tester, find.byKey(const Key('konfirmasi-hapus')));

    expect(MockData.cariById('PSN-001'), isNull);
    expect(MockData.pesananList.length, dataAwal.length - 1);
    expect(find.text('Pesanan dihapus.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DashboardScreen),
        matching: find.text('Ibu Siti Rahayu'),
      ),
      findsNothing,
    );
  });

  testWidgets('11. Batal hapus tidak menghapus pesanan', (tester) async {
    await bukaDetailSiti(tester);

    await tekan(tester, find.text('Hapus Pesanan'));
    await tekan(tester, find.text('Batal'));

    expect(MockData.cariById('PSN-001'), isNotNull);
    expect(find.text('Detail Pesanan'), findsOneWidget);
  });

  testWidgets('12. Pencarian menyaring Daftar Pesanan berdasarkan nama', (
    tester,
  ) async {
    await bukaAplikasiPonsel(tester);
    await tekan(tester, find.byKey(const Key('nav-daftar-pesanan')));

    Finder diDaftar(String teks) => find.descendant(
          of: find.byType(DaftarPesananScreen),
          matching: find.text(teks),
        );

    await tester.enterText(find.byKey(const Key('cari-pesanan')), 'budi');
    await tester.pumpAndSettle();

    expect(diDaftar('Pak Budi Santoso'), findsOneWidget);
    expect(diDaftar('Ibu Siti Rahayu'), findsNothing);

    await tester.enterText(find.byKey(const Key('cari-pesanan')), 'zzz');
    await tester.pumpAndSettle();

    expect(diDaftar('Pesanan tidak ditemukan'), findsOneWidget);
  });
}
