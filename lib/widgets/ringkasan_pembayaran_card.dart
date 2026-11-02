import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/theme.dart';
import 'status_badge.dart';

/// Kotak "Ringkasan Pembayaran" di Dashboard mobile.
///
/// Menampilkan badge setiap status pembayaran (Belum Bayar, DP, Lunas)
/// beserta jumlah pesanannya, sesuai wireframe Figma. Jumlah dihitung
/// oleh pemanggil lewat [jumlahUntuk].
class RingkasanPembayaranCard extends StatelessWidget {
  /// Mengembalikan jumlah pesanan untuk satu status pembayaran.
  final int Function(StatusPembayaran status) jumlahUntuk;

  const RingkasanPembayaranCard({super.key, required this.jumlahUntuk});

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
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
              fontSize: AppTheme.keterangan,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Wrap(
            spacing: AppTheme.spacing16,
            runSpacing: AppTheme.spacing8,
            children: [
              for (final status in StatusPembayaran.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge.pembayaran(status),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      '${jumlahUntuk(status)}',
                      key: ValueKey('jumlah-bayar-${status.name}'),
                      style: const TextStyle(
                        fontSize: AppTheme.isi,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
