// Pengujian form Tambah Pesanan (Modul 7, diperbarui Modul 10).
//
// Modul 10: menu diketik bebas dengan saran dari collection `menus`, dan
// pesanan baru disimpan ke collection `orders`. Firebase tidak dihubungi; aplikasi diberi
// [LayananMemori] sehingga isi `orders` dapat diperiksa langsung.
//
// Setiap pengujian memakai aplikasi utuh agar alur yang diuji sama
// dengan alur nyata: Dashboard -> Tambah Pesanan -> Form -> Simpan.
// Layar uji 800 px termasuk layar lebar, sehingga navigasinya sidebar.
//
// Data pada MockData bersifat statis dan dipakai bersama, sehingga
// setiap pengujian menyimpan salinan data awal lalu mengembalikannya
// pada tearDown agar pengujian lain tidak terpengaruh.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/data/mock_data.dart';
import 'package:kelola_katering/main.dart';
import 'package:kelola_katering/models/pesanan_model.dart';
import 'package:kelola_katering/services/layanan_firestore.dart';

void main() {
  late List<Pesanan> dataAwal;
  late LayananMemori layanan;

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

    layanan = LayananMemori();
    await tester.pumpWidget(
      KelolaKateringApp(halamanAwal: HomeShell(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    // Tombol "Tambah Pesanan" milik Dashboard diberi key tersendiri
    // karena Daftar Pesanan juga punya tombol yang sama.
    await tester.tap(find.byKey(const Key('tambah-dashboard')));
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
    String menu = 'Nasi Box Ayam Geprek',
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
    expect(find.text('Tanggal pengiriman wajib diisi'), findsOneWidget);
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
      find.text('Nomor WhatsApp harus 10-15 digit dan diawali angka 0'),
      findsOneWidget,
    );
    expect(
      find.text('Periksa kembali isian yang ditandai merah.'),
      findsOneWidget,
    );
    expect(MockData.pesananList.length, dataAwal.length);
  });

  testWidgets('5. Data valid tersimpan ke collection orders', (tester) async {
    await bukaForm(tester);
    await isiFormValid(tester);
    await tekan(tester, find.text('Simpan Pesanan'));

    // Kembali ke Dashboard dan pesan berhasil tampil.
    expect(find.text('Pesanan baru berhasil disimpan.'), findsOneWidget);

    expect(layanan.pesanan.length, 1);
    final pesananBaru = layanan.pesanan.single;
    expect(pesananBaru.namaPelanggan, 'Ibu Rina Kartika');
    // Nama sama dengan menu di `menus`: ID ikut tersimpan.
    expect(pesananBaru.idMenu, 'menu-ayam-geprek');
    expect(pesananBaru.menu, 'Nasi Box Ayam Geprek'); // denormalisasi
    expect(pesananBaru.jumlahPorsi, 25);
    expect(pesananBaru.totalHarga, 875000);
    expect(pesananBaru.idPengguna, isNotEmpty);
    expect(pesananBaru.statusPesanan, StatusPesanan.baru);
    expect(pesananBaru.statusPembayaran, StatusPembayaran.belumBayar);
  });

  testWidgets('6. Pesanan ganda ditolak dan form tetap terbuka', (
    tester,
  ) async {
    await bukaForm(tester);
    await isiFormValid(tester);
    await tekan(tester, find.text('Simpan Pesanan'));
    expect(layanan.pesanan.length, 1);

    // Catat ulang pesanan yang sama: pelanggan, menu, dan tanggal sama.
    // Huruf besar kecil nama pelanggan tidak dibedakan.
    await tester.tap(find.byKey(const Key('tambah-dashboard')));
    await tester.pumpAndSettle();
    await isiFormValid(tester, nama: 'ibu rina kartika');
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(find.textContaining('sudah tercatat'), findsOneWidget);
    expect(find.text('Form Tambah Pesanan'), findsOneWidget);
    expect(layanan.pesanan.length, 1);
  });

  testWidgets('7. Menu lain untuk pelanggan yang sama tetap boleh', (
    tester,
  ) async {
    await bukaForm(tester);
    await isiFormValid(tester);
    await tekan(tester, find.text('Simpan Pesanan'));

    await tester.tap(find.byKey(const Key('tambah-dashboard')));
    await tester.pumpAndSettle();
    await isiFormValid(tester, menu: 'Snack Box Mix');
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(find.text('Pesanan baru berhasil disimpan.'), findsOneWidget);
    expect(layanan.pesanan.length, 2);
  });

  testWidgets('8. Menu yang diketik sendiri tetap tersimpan', (tester) async {
    await bukaForm(tester);
    await isiFormValid(tester, menu: 'Nasi Liwet Komplit');
    await tekan(tester, find.text('Simpan Pesanan'));

    expect(find.text('Pesanan baru berhasil disimpan.'), findsOneWidget);
    final pesananBaru = layanan.pesanan.single;
    expect(pesananBaru.menu, 'Nasi Liwet Komplit');
    expect(pesananBaru.idMenu, isEmpty); // tidak ada di collection menus
  });

  testWidgets('9. Saran menu muncul saat mengetik dan dapat dipilih', (
    tester,
  ) async {
    await bukaForm(tester);
    final kolomMenu = find.byKey(const Key('kolom-menu'));
    await tester.enterText(kolomMenu, 'snack');
    await tester.pumpAndSettle();

    final saran = find.widgetWithText(ListTile, 'Snack Box Mix');
    expect(saran, findsOneWidget);
    await tester.tap(saran);
    await tester.pumpAndSettle();

    final kolom = tester.widget<TextFormField>(kolomMenu);
    expect(kolom.controller!.text, 'Snack Box Mix');
  });
}
