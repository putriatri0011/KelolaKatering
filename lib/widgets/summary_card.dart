import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Kotak ringkasan berisi satu angka besar dan labelnya.
///
/// Sesuai wireframe Figma: latar abu muda (warna permukaan), angka
/// tebal berwarna primer, label kecil di bawahnya. Dipakai di Dashboard
/// untuk "Pesanan Baru", "Sedang Diproses", dan, pada layar lebar,
/// jumlah per status pembayaran.
///
/// Widget ini tidak terhubung ke sumber data. Nilai diberikan pemanggil.
class SummaryCard extends StatelessWidget {
  /// Label deskriptif, misalnya "Pesanan Baru".
  final String title;

  /// Nilai angka yang ditampilkan.
  final int value;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.permukaan,
        borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: AppTheme.judul,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.keterangan,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
