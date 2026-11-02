import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import 'status_badge.dart';

/// Kartu yang menampilkan ringkasan satu pesanan.
///
/// Susunan mengikuti wireframe Figma (Dashboard dan Daftar Pesanan):
/// - baris 1: nama pelanggan di kiri, tanggal pengiriman di kanan;
/// - baris 2: menu · jumlah porsi · total harga;
/// - baris 3: badge status pesanan dan status pembayaran.
///
/// Widget ini tidak mengubah data pesanan dan tidak melakukan
/// navigasi. Aksi ketika kartu ditekan ditangani via [onTap].
class PesananCard extends StatelessWidget {
  /// Pesanan yang ditampilkan di kartu ini.
  final Pesanan pesanan;

  /// Callback ketika kartu ditekan. Jika null, kartu tidak responsif.
  final VoidCallback? onTap;

  /// Tampilkan total harga pada baris kedua.
  ///
  /// Dashboard mobile di Figma hanya menampilkan menu dan porsi,
  /// sedangkan Daftar Pesanan juga menampilkan total harga.
  final bool tampilkanHarga;

  /// Jarak luar kartu. Default memberi margin tepi 16 di kiri-kanan.
  final EdgeInsetsGeometry margin;

  const PesananCard({
    super.key,
    required this.pesanan,
    this.onTap,
    this.tampilkanHarga = true,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppTheme.marginTepi,
      vertical: 6,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final rincian = [
      pesanan.menu,
      '${pesanan.jumlahPorsi} porsi',
      if (tampilkanHarga && pesanan.totalHarga > 0)
        Format.rupiah(pesanan.totalHarga),
    ].join(' · ');

    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      pesanan.namaPelanggan,
                      style: const TextStyle(
                        fontSize: AppTheme.isi,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    Format.tanggal(pesanan.tanggalKirim),
                    style: const TextStyle(
                      fontSize: AppTheme.keterangan,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                rincian,
                style: const TextStyle(
                  fontSize: AppTheme.keterangan,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing4,
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
