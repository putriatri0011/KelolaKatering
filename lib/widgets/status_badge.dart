import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/theme.dart';

/// Badge yang menampilkan status pesanan atau status pembayaran.
///
/// Menggunakan enum [StatusPesanan] dan [StatusPembayaran] dari
/// `pesanan_model.dart` beserta extension methods (`.label`,
/// `.color`, `.lightColor`) yang sudah didefinisikan di sana.
///
/// Gunakan factory constructor:
/// - [StatusBadge.pesanan] untuk status pesanan.
/// - [StatusBadge.pembayaran] untuk status pembayaran.
class StatusBadge extends StatelessWidget {
  /// Label teks yang ditampilkan di dalam badge.
  final String _label;

  /// Warna teks di dalam badge.
  final Color _color;

  /// Warna latar muda badge.
  final Color _backgroundColor;

  const StatusBadge._({
    super.key,
    required this._label,
    required this._color,
    required this._backgroundColor,
  });

  /// Membuat badge untuk [StatusPesanan].
  factory StatusBadge.pesanan(
    StatusPesanan status, {
    Key? key,
  }) {
    return StatusBadge._(
      key: key,
      label: status.label,
      color: status.color,
      backgroundColor: status.lightColor,
    );
  }

  /// Membuat badge untuk [StatusPembayaran].
  factory StatusBadge.pembayaran(
    StatusPembayaran status, {
    Key? key,
  }) {
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
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: AppTheme.keterangan,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
