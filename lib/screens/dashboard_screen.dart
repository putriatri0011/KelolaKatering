import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/pesanan_model.dart';
import '../utils/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/pesanan_card.dart';
import '../widgets/summary_card.dart';

/// Halaman utama Dashboard KelolaKatering.
///
/// Menampilkan ringkasan jumlah pesanan (Baru & Diproses)
/// serta daftar pesanan terbaru menggunakan data simulasi
/// dari [MockData].
///
/// Pada tahap Modul 6 ini, tombol "Tambah Pesanan" hanya
/// menampilkan SnackBar karena formulir belum dibuat.
///
/// Navigasi:
/// - Tombol "Lihat Semua" beralih ke tab Daftar Pesanan
///   via [onLihatSemua].
/// - Tap pada [PesananCard] membuka Detail Pesanan
///   via [onPesananTap].
class DashboardScreen extends StatelessWidget {
  /// Jumlah pesanan terbaru yang ditampilkan di Dashboard.
  ///
  /// Dibatasi agar Dashboard tetap ringkas.
  static const int _batasPesananTerbaru = 3;

  /// Callback ketika tombol "Lihat Semua" ditekan.
  ///
  /// Dipanggil oleh [HomeShell] untuk beralih ke tab
  /// Daftar Pesanan. Jika null, tombol tidak ditampilkan.
  final VoidCallback? onLihatSemua;

  /// Callback ketika sebuah [PesananCard] ditekan.
  ///
  /// Menerima objek [Pesanan] yang dipilih untuk diteruskan
  /// ke halaman Detail Pesanan.
  final void Function(Pesanan pesanan)? onPesananTap;

  const DashboardScreen({
    super.key,
    this.onLihatSemua,
    this.onPesananTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Mengambil data dari sumber simulasi ─────────────────────
    // Tidak mengubah atau menghapus data sumber.
    final semuaPesanan = MockData.pesananList;
    final jumlahBaru = MockData.jumlahBaru;
    final jumlahDiproses = MockData.jumlahDiproses;

    // Ambil pesanan terbaru (dibatasi) tanpa memodifikasi list asli.
    final pesananTerbaru =
        semuaPesanan.take(_batasPesananTerbaru).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: semuaPesanan.isEmpty
          ? EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Belum Ada Pesanan',
              subtitle:
                  'Tap tombol + untuk mencatat pesanan pertama.',
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section: Ringkasan ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.marginTepi,
                      ),
                      child: Text(
                        'Ringkasan',
                        style: const TextStyle(
                          fontSize: AppTheme.subjudul,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    // Dua SummaryCard berdampingan (lebar layar cukup)
                    // atau tersusun vertikal (layar sempit).
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.marginTepi,
                      ),
                      child: Wrap(
                        spacing: AppTheme.spacing8,
                        runSpacing: AppTheme.spacing8,
                        children: [
                          SummaryCard(
                            title: 'Pesanan Baru',
                            value: jumlahBaru,
                            icon: Icons.fiber_new_outlined,
                            color: AppTheme.statusBaru,
                          ),
                          SummaryCard(
                            title: 'Pesanan Diproses',
                            value: jumlahDiproses,
                            icon: Icons.sync_outlined,
                            color: AppTheme.statusDiproses,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    // ── Section: Pesanan Terbaru ────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.marginTepi,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pesanan Terbaru',
                            style: const TextStyle(
                              fontSize: AppTheme.subjudul,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (semuaPesanan.length >
                                  _batasPesananTerbaru &&
                              onLihatSemua != null)
                            TextButton(
                              onPressed: onLihatSemua,
                              child: const Text('Lihat Semua'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    // ── Daftar PesananCard ──────────────────────────
                    if (pesananTerbaru.isEmpty)
                      const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum Ada Pesanan Terbaru',
                      )
                    else
                      ...pesananTerbaru.map(
                        (pesanan) => PesananCard(
                          pesanan: pesanan,
                          onTap: onPesananTap != null
                              ? () => onPesananTap!(pesanan)
                              : null,
                        ),
                      ),
                    // ── Footer spacing untuk FAB ───────────────────
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      // ── FAB: Tambah Pesanan ────────────────────────────────────
      // Formulir belum dibuat pada Modul 6.
      // Tombol hanya menampilkan SnackBar informatif.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fitur tambah pesanan akan dibuat pada tahap berikutnya.',
              ),
            ),
          );
        },
        tooltip: 'Tambah Pesanan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
