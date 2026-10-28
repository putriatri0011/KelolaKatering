import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/theme.dart';
import 'status_badge.dart';

/// Kartu yang menampilkan ringkasan satu pesanan.
///
/// Menerima objek [Pesanan] dan menampilkan informasi relevan:
/// nama pelanggan, menu, jumlah porsi, tanggal kirim, serta
/// badge status pesanan dan status pembayaran.
///
/// Widget ini tidak mengubah data pesanan dan tidak melakukan
/// navigasi. Aksi ketika kartu ditekan ditangani via [onTap].
class PesananCard extends StatelessWidget {
  /// Pesanan yang ditampilkan di kartu ini.
  final Pesanan pesanan;

  /// Callback ketika kartu ditekan.
  ///
  /// Boleh null — jika null, kartu tidak responsif terhadap tap.
  final VoidCallback? onTap;

  const PesananCard({
    super.key,
    required this.pesanan,
    this.onTap,
  });

  /// Memformat tanggal kirim ke string "dd MMM yyyy".
  ///
  /// Menggunakan format Indonesia tanpa package tambahan.
  String _formatTanggal(DateTime tanggal) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulanStr = bulan[tanggal.month - 1];
    final tahun = tanggal.year;
    return '$hari $bulanStr $tahun';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.marginTepi,
        vertical: AppTheme.spacing8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Baris 1: Nama pelanggan ──────────────────────────
              Text(
                pesanan.namaPelanggan,
                style: const TextStyle(
                  fontSize: AppTheme.subjudul,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // ── Baris 2: Menu & jumlah porsi ─────────────────────
              Text(
                '${pesanan.menu} — ${pesanan.jumlahPorsi} porsi',
                style: const TextStyle(
                  fontSize: AppTheme.isi,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // ── Baris 3: Tanggal kirim ───────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTanggal(pesanan.tanggalKirim),
                    style: const TextStyle(
                      fontSize: AppTheme.keterangan,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              // ── Baris 4: Badge status pesanan & pembayaran ───────
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: 4,
                children: [
                  StatusBadge.pesanan(pesanan.statusPesanan),
                  StatusBadge.pembayaran(pesanan.statusPembayaran),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
