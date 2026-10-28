import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Tampilan yang ditampilkan ketika belum ada data.
///
/// Menampilkan ikon, judul, dan pesan opsional.
/// Dapat digunakan di Daftar Pesanan atau Dashboard
/// ketika list pesanan kosong.
class EmptyState extends StatelessWidget {
  /// Ikon yang mewakili kondisi kosong.
  final IconData icon;

  /// Judul utama, misalnya "Belum Ada Pesanan".
  final String title;

  /// Pesan tambahan yang menjelaskan apa yang bisa dilakukan.
  ///
  /// Boleh kosong (null) jika tidak diperlukan.
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ikon ──────────────────────────────────────────────
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacing16),
            // ── Judul ─────────────────────────────────────────────
            Text(
              title,
              style: const TextStyle(
                fontSize: AppTheme.subjudul,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            // ── Subtitle (opsional) ───────────────────────────────
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacing8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: AppTheme.isi,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
