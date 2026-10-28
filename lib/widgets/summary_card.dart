import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Kartu ringkasan yang menampilkan angka, label, dan ikon.
///
/// Digunakan di Dashboard untuk menampilkan jumlah pesanan
/// per status (misal: Pesanan Baru, Pesanan Diproses).
///
/// Widget ini tidak terhubung ke sumber data apapun.
/// Nilai [value] dan [title] diberikan oleh pemanggil.
class SummaryCard extends StatelessWidget {
  /// Label deskriptif, misalnya "Pesanan Baru".
  final String title;

  /// Nilai angka yang ditampilkan, misalnya jumlah pesanan.
  final int value;

  /// Ikon yang mewakili kategori ringkasan.
  final IconData icon;

  /// Warna aksen untuk ikon dan latar ikon.
  ///
  /// Default: [AppTheme.primary].
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            // ── Ikon dalam container berwarna ────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spacing16),
            // ── Angka dan label ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: AppTheme.judul,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppTheme.isi,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
