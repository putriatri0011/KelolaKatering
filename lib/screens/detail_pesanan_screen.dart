import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import '../widgets/status_badge.dart';

/// Halaman Detail Pesanan.
///
/// Modul 10: pesanan berasal dari collection `orders` di Cloud Firestore,
/// dan pertemuan ini hanya mencakup Tambah (Create) dan Tampilkan (Read).
/// Karena itu halaman ini hanya menampilkan data. Ubah status, Edit, dan
/// Hapus pesanan disambungkan ke Firestore pada Minggu 11.
class DetailPesananScreen extends StatelessWidget {
  /// Pesanan yang ditampilkan.
  final Pesanan pesanan;

  const DetailPesananScreen({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final p = pesanan;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.marginTepi),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTheme.lebarKontenMaks,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _JudulSeksi('INFORMASI PELANGGAN'),
                _Baris(label: 'Nama', nilai: p.namaPelanggan, tebal: true),
                _Baris(
                  label: 'WhatsApp',
                  nilai: p.nomorHP.isEmpty ? '-' : p.nomorHP,
                ),
                const SizedBox(height: AppTheme.spacing12),
                const _JudulSeksi('PESANAN'),
                _Baris(label: 'ID Pesanan', nilai: p.id),
                _Baris(label: 'Menu / Paket', nilai: p.menu),
                _Baris(label: 'Jumlah Porsi', nilai: '${p.jumlahPorsi} porsi'),
                _Baris(
                  label: 'Tgl Pengiriman',
                  nilai: Format.tanggal(p.tanggalKirim),
                ),
                _Baris(
                  label: 'Total Harga',
                  nilai: p.totalHarga > 0 ? Format.rupiah(p.totalHarga) : '-',
                  tebal: true,
                ),
                _Baris(
                  label: 'Catatan',
                  nilai: p.catatan.isEmpty ? '-' : p.catatan,
                ),
                const SizedBox(height: AppTheme.spacing16),
                const _JudulSeksi('STATUS'),
                Wrap(
                  spacing: AppTheme.spacing8,
                  runSpacing: AppTheme.spacing8,
                  children: [
                    StatusBadge.pesanan(p.statusPesanan),
                    StatusBadge.pembayaran(p.statusPembayaran),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
                const Text(
                  'Ubah status, edit, dan hapus pesanan tersedia di Minggu 11.',
                  key: Key('info-minggu-11'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.keterangan,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Judul seksi kecil berhuruf kapital, mis. "INFORMASI PELANGGAN".
class _JudulSeksi extends StatelessWidget {
  final String teks;

  const _JudulSeksi(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Text(teks, style: AppTheme.gayaLabelSeksi),
    );
  }
}

/// Satu baris label di kiri dan nilai di kanan, dengan garis bawah.
class _Baris extends StatelessWidget {
  final String label;
  final String nilai;
  final bool tebal;

  const _Baris({required this.label, required this.nilai, this.tebal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.garis)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.isi,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppTheme.isi,
                fontWeight: tebal ? FontWeight.w700 : FontWeight.w400,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
