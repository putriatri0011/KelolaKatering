import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Tombol utama "Tambah Pesanan".
///
/// Wireframe Figma memakai dua bentuk:
/// - ponsel: tombol selebar layar di atas navigasi bawah
///   ([TombolTambahPesanan.bawah]);
/// - layar lebar: tombol ringkas di kanan atas konten
///   ([TombolTambahPesanan.ringkas]).
class TombolTambahPesanan extends StatelessWidget {
  /// Aksi ketika tombol ditekan (membuka Form Tambah Pesanan).
  final VoidCallback? onPressed;

  final bool _selebarLayar;

  /// Tombol selebar layar untuk bagian bawah halaman di ponsel.
  const TombolTambahPesanan.bawah({super.key, this.onPressed})
      : _selebarLayar = true;

  /// Tombol ringkas untuk kepala halaman di layar lebar.
  const TombolTambahPesanan.ringkas({super.key, this.onPressed})
      : _selebarLayar = false;

  @override
  Widget build(BuildContext context) {
    final tombol = FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Tambah Pesanan'),
      style: _selebarLayar
          ? FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
            )
          : FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
              ),
            ),
    );

    if (!_selebarLayar) return tombol;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.marginTepi,
          AppTheme.spacing8,
          AppTheme.marginTepi,
          AppTheme.spacing12,
        ),
        child: tombol,
      ),
    );
  }
}
