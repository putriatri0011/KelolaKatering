// Pengujian tampilan pesanan dari collection `orders` (Modul 10).
//
// Firebase tidak dihubungi: aplikasi diberi [LayananMemori] yang meniru
// query `where('id_pengguna', isEqualTo: uid)` dan pengurutan terbaru.
// Lima pesanan simulasi dari MockData dipakai sebagai isi `orders`.
//
// Ubah status, edit, dan hapus pesanan dikerjakan pada Minggu 11, sehingga
// pengujiannya ditambahkan kembali saat itu.
//
// Layar uji 400 x 900 agar tata letak ponsel (NavigationBar bawah) yang
// diuji.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/data/mock_data.dart';
import 'package:kelola_katering/main.dart';
import 'package:kelola_katering/models/pesanan_model.dart';
import 'package:kelola_katering/screens/daftar_pesanan_screen.dart';
import 'package:kelola_katering/screens/dashboard_screen.dart';
import 'package:kelola_katering/services/layanan_firestore.dart';

/// Layanan yang selalu gagal membaca `orders`, mis. karena Rules menolak.
class _LayananGagal extends LayananMemori {
  @override
  Stream<List<Pesanan>> streamPesananSaya() =>
      Stream.error(Exception('permission-denied'));
}

void main() {
  /// Lima pesanan simulasi milik akun uji; PSN-001 paling baru dicatat.
  List<Pesanan> pesananSimulasi({String uid = 'uid-uji'}) => [
        for (var i = 0; i < MockData.pesananList.length; i++)
          MockData.pesananList[i].copyWith(
            idPengguna: uid,
            dibuatPada: DateTime(2026, 11, 1).subtract(Duration(minutes: i)),
          ),
      ];

  // ── Helper ────────────────────────────────────────────────────

  Future<void> bukaAplikasiPonsel(
    WidgetTester tester,
    LayananMemori layanan,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      KelolaKateringApp(halamanAwal: HomeShell(layanan: layanan)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tekan(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder diDashboard(String teks) => find.descendant(
        of: find.byType(DashboardScreen),
        matching: find.text(teks),
      );

  Finder diDaftar(String teks) => find.descendant(
        of: find.byType(DaftarPesananScreen),
        matching: find.text(teks),
      );

  // ── Kasus uji ─────────────────────────────────────────────────

  testWidgets('Dashboard menampilkan pesanan dari orders, terbaru di atas', (
    tester,
  ) async {
    await bukaAplikasiPonsel(
      tester,
      LayananMemori(pesananAwal: pesananSimulasi()),
    );

    // Tiga pesanan terbaru: PSN-001, PSN-002, PSN-003. Kartu ketiga berada
    // di bawah layar ponsel, sehingga Dashboard digulir lebih dulu.
    await tester.scrollUntilVisible(
      diDashboard('Catering Wulandari'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(DashboardScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(diDashboard('Ibu Siti Rahayu'), findsOneWidget);
    expect(diDashboard('Pak Budi Santoso'), findsOneWidget);
    expect(diDashboard('Catering Wulandari'), findsOneWidget);
    expect(diDashboard('Toko Berkah Jaya'), findsNothing);

    // Urutan: yang paling baru dicatat berada paling atas.
    final ySiti = tester.getTopLeft(diDashboard('Ibu Siti Rahayu')).dy;
    final yBudi = tester.getTopLeft(diDashboard('Pak Budi Santoso')).dy;
    final yWulan = tester.getTopLeft(diDashboard('Catering Wulandari')).dy;
    expect(ySiti < yBudi && yBudi < yWulan, isTrue);
  });

  testWidgets('Detail Pesanan hanya menampilkan data (Minggu 10)', (
    tester,
  ) async {
    await bukaAplikasiPonsel(
      tester,
      LayananMemori(pesananAwal: pesananSimulasi()),
    );
    await tekan(tester, diDashboard('Ibu Siti Rahayu'));

    expect(find.text('Detail Pesanan'), findsOneWidget);
    expect(find.text('Nasi Box Ayam Geprek'), findsOneWidget);
    expect(find.text('50 porsi'), findsOneWidget);
    expect(find.byKey(const Key('info-minggu-11')), findsOneWidget);
    expect(find.text('Edit Pesanan'), findsNothing);
    expect(find.text('Hapus Pesanan'), findsNothing);
  });

  testWidgets('Pesanan akun lain tidak ikut tampil (isolasi per akun)', (
    tester,
  ) async {
    await bukaAplikasiPonsel(
      tester,
      LayananMemori(pesananAwal: pesananSimulasi(uid: 'uid-akun-lain')),
    );

    expect(diDashboard('Belum ada pesanan'), findsOneWidget);
    expect(diDashboard('Ibu Siti Rahayu'), findsNothing);
  });

  testWidgets('Belum ada pesanan: keadaan kosong tampil', (tester) async {
    await bukaAplikasiPonsel(tester, LayananMemori());
    await tekan(tester, find.byKey(const Key('nav-daftar-pesanan')));

    expect(diDaftar('Belum ada pesanan'), findsOneWidget);
  });

  testWidgets('Firestore gagal: pesan gagal dimuat tampil, bukan error', (
    tester,
  ) async {
    await bukaAplikasiPonsel(tester, _LayananGagal());

    expect(diDashboard('Data pesanan gagal dimuat'), findsOneWidget);
  });

  testWidgets('12. Pencarian menyaring Daftar Pesanan berdasarkan nama', (
    tester,
  ) async {
    await bukaAplikasiPonsel(
      tester,
      LayananMemori(pesananAwal: pesananSimulasi()),
    );
    await tekan(tester, find.byKey(const Key('nav-daftar-pesanan')));

    await tester.enterText(find.byKey(const Key('cari-pesanan')), 'budi');
    await tester.pumpAndSettle();

    expect(diDaftar('Pak Budi Santoso'), findsOneWidget);
    expect(diDaftar('Ibu Siti Rahayu'), findsNothing);

    await tester.enterText(find.byKey(const Key('cari-pesanan')), 'zzz');
    await tester.pumpAndSettle();

    expect(diDaftar('Pesanan tidak ditemukan'), findsOneWidget);
  });
}
