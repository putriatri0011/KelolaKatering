// Pengujian form Tambah Pesanan (Modul 7).
//
// Setiap pengujian memakai aplikasi utuh agar alur yang diuji sama
// dengan alur nyata: Dashboard -> tombol + -> Form -> Simpan.
//
// Data pada MockData bersifat statis dan dipakai bersama, sehingga
// setiap pengujian menyimpan salinan data awal lalu mengembalikannya
// pada tearDown agar pengujian lain tidak terpengaruh.

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

  /// Menjalankan aplikasi lalu membuka Form Tambah Pesanan
  /// lewat tombol + di Dashboard.
  ///
  /// Ukuran layar uji diperbesar agar seluruh kolom form terlihat
  /// tanpa menggulir, sehingga setiap ketukan benar-benar mengenai
  /// sasaran (ketukan di luar layar hanya menghasilkan peringatan).
  Future<void> bukaForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const KelolaKateringApp());
    await tester.pumpAndSettle();

    // Dua FAB ada di pohon widget (Dashboard & Daftar Pesanan karena
    // IndexedStack); yang pertama adalah milik Dashboard.
    await tester.tap(find.byType(FloatingActionButton).first);
    await tester.pumpAndSettle();
  }

  /// Menggulir sampai [finder] terlihat, lalu menekannya.
  Future<void> tekan(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Memilih tanggal kirim (tanggal hari ini) melalui date picker.
  Future<void> isiTanggal(WidgetTester tester) async {
    await tekan(tester, find.byType(TextFormField).at(4));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  /// Mengisi seluruh kolom wajib dengan nilai valid.
  Future<void> isiFormValid(
    WidgetTester tester, {
    String nama = 'Ibu Rina Kartika',
    String menu = 'Nasi Box Ayam Bakar',
    String porsi = '25',
    String harga = '875000',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), nama);
    await tester.enterText(find.byType(TextFormField).at(1), '081234567890');
    await tester.enterText(find.byType(TextFormField).at(2), menu);
    await tester.enterText(find.byType(TextFormField).at(3), porsi);
    await tester.pump();
    await isiTanggal(tester);
    await tester.enterText(find.byType(TextFormField).at(5), harga);
    await tester.pump();
  }

  // ── Kasus uji ─────────────────────────────────────────────────

  testWidgets('1. Semua kolom kosong ditolak dan data tidak bertambah', (
    tester,
  ) async {
    await bukaForm(tester);
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(find.text('Nama pelanggan wajib diisi'), findsOneWidget);
    expect(find.text('Menu wajib diisi'), findsOneWidget);
    expect(find.text('Jumlah porsi wajib diisi'), findsOneWidget);
    expect(find.text('Tanggal kirim wajib diisi'), findsOneWidget);
    expect(
      find.text('Periksa kembali isian yang ditandai merah.'),
      findsOneWidget,
    );
    expect(MockData.pesananList.length, dataAwal.length);
  });

  testWidgets('2. Jumlah porsi nol ditolak', (tester) async {
    await bukaForm(tester);
    await tester.enterText(find.byType(TextFormField).at(3), '0');
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(find.text('Jumlah porsi tidak boleh nol'), findsOneWidget);
    expect(
      find.text('Periksa kembali isian yang ditandai merah.'),
      findsOneWidget,
    );
    expect(MockData.pesananList.length, dataAwal.length);
  });

  testWidgets('3. Jumlah porsi melebihi batas ditolak', (tester) async {
    await bukaForm(tester);
    await tester.enterText(find.byType(TextFormField).at(3), '5000');
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(find.text('Jumlah porsi maksimal 1000 porsi'), findsOneWidget);
    expect(
      find.text('Periksa kembali isian yang ditandai merah.'),
      findsOneWidget,
    );
    expect(MockData.pesananList.length, dataAwal.length);
  });

  testWidgets('4. Nomor HP berformat salah ditolak', (tester) async {
    await bukaForm(tester);
    await tester.enterText(find.byType(TextFormField).at(1), '0812');
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(
      find.text('Nomor HP harus 10-15 digit dan diawali angka 0'),
      findsOneWidget,
    );
    expect(
      find.text('Periksa kembali isian yang ditandai merah.'),
      findsOneWidget,
    );
    expect(MockData.pesananList.length, dataAwal.length);
  });

  testWidgets('5. Data valid tersimpan ke list memori', (tester) async {
    await bukaForm(tester);
    await isiFormValid(tester);
    await tekan(tester, find.text('Simpan Pesanan'));

    // Kembali ke Dashboard dan pesan berhasil tampil.
    expect(find.text('Pesanan baru berhasil disimpan.'), findsOneWidget);

    expect(MockData.pesananList.length, dataAwal.length + 1);

    final pesananBaru = MockData.pesananList.first;
    expect(pesananBaru.id, 'PSN-006');
    expect(pesananBaru.namaPelanggan, 'Ibu Rina Kartika');
    expect(pesananBaru.menu, 'Nasi Box Ayam Bakar');
    expect(pesananBaru.jumlahPorsi, 25);
    expect(pesananBaru.totalHarga, 875000);
    expect(pesananBaru.statusPesanan, StatusPesanan.baru);
    expect(pesananBaru.statusPembayaran, StatusPembayaran.belumBayar);
  });

  testWidgets('6. Pesanan baru tampil di Dashboard dan Daftar Pesanan', (
    tester,
  ) async {
    await bukaForm(tester);
    await isiFormValid(tester, nama: 'Ibu Rina Kartika');
    await tekan(tester, find.text('Simpan Pesanan'));

    // Dashboard menampilkan pesanan terbaru di urutan pertama.
    // Pencarian dibatasi per halaman karena IndexedStack membangun
    // kedua halaman sekaligus.
    expect(
      find.descendant(
        of: find.byType(DashboardScreen),
        matching: find.text('Ibu Rina Kartika'),
      ),
      findsOneWidget,
    );

    // Pindah ke tab Daftar Pesanan.
    await tester.tap(find.text('Pesanan'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pesanan'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DaftarPesananScreen),
        matching: find.text('Ibu Rina Kartika'),
      ),
      findsOneWidget,
    );
  });
}
