import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/pesanan_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/pesanan_card.dart';

/// Halaman Daftar Pesanan KelolaKatering.
///
/// Menampilkan seluruh pesanan dari [MockData.pesananList]
/// menggunakan [PesananCard]. Urutan data dipertahankan
/// sesuai sumber.
///
/// Jika daftar kosong, menampilkan [EmptyState].
///
/// Pada tahap Modul 6 ini, tombol "Tambah Pesanan" hanya
/// menampilkan SnackBar karena formulir belum dibuat.
///
/// Navigasi:
/// - Tap pada [PesananCard] membuka Detail Pesanan
///   via [onPesananTap].
class DaftarPesananScreen extends StatelessWidget {
  /// Callback ketika sebuah [PesananCard] ditekan.
  ///
  /// Menerima objek [Pesanan] yang dipilih untuk diteruskan
  /// ke halaman Detail Pesanan.
  final void Function(Pesanan pesanan)? onPesananTap;

  const DaftarPesananScreen({
    super.key,
    this.onPesananTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Mengambil data dari sumber simulasi ─────────────────────
    // Tidak membuat salinan atau data baru.
    // Urutan data dipertahankan sesuai sumber.
    final daftarPesanan = MockData.pesananList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
      ),
      body: daftarPesanan.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum Ada Pesanan',
              subtitle: 'Tap tombol + untuk mencatat pesanan pertama.',
            )
          : ListView.builder(
              itemCount: daftarPesanan.length,
              // Padding atas agar kartu pertama tidak menempel pada AppBar.
              // Padding bawah agar kartu terakhir tidak tertutup FAB.
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemBuilder: (context, index) {
                final pesanan = daftarPesanan[index];
                return PesananCard(
                  pesanan: pesanan,
                  onTap: onPesananTap != null
                      ? () => onPesananTap!(pesanan)
                      : null,
                );
              },
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
