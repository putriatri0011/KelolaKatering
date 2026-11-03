import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/theme.dart';

/// Badge yang menampilkan status pesanan atau status pembayaran.
///
/// Bentuknya kapsul bergaris dengan latar muda, sesuai bagian
/// "Status Pesanan & Pembayaran" pada style guide Figma. Status
/// selalu disertai teks, jadi tidak disampaikan hanya lewat warna.
///
/// Gunakan factory constructor:
/// - [StatusBadge.pesanan] untuk status pesanan.
/// - [StatusBadge.pembayaran] untuk status pembayaran.
class StatusBadge extends StatelessWidget {
  /// Label teks yang ditampilkan di dalam badge.
  final String label;

  /// Warna teks dan garis badge.
  final Color color;

  /// Warna latar badge.
  final Color backgroundColor;

  const StatusBadge._({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  /// Membuat badge untuk [StatusPesanan].
  factory StatusBadge.pesanan(StatusPesanan status, {Key? key}) {
    return StatusBadge._(
      key: key,
      label: status.label,
      color: status.color,
      backgroundColor: status.lightColor,
    );
  }

  /// Membuat badge untuk [StatusPembayaran].
  factory StatusBadge.pembayaran(StatusPembayaran status, {Key? key}) {
    return StatusBadge._(
      key: key,
      label: status.label,
      color: status.color,
      backgroundColor: status.lightColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTheme.keterangan,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
