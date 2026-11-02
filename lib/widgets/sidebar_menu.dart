import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Sidebar menu untuk layar lebar (versi web).
///
/// Sesuai rancangan web Figma: nama aplikasi di atas, lalu menu
/// Dashboard dan Daftar Pesanan dengan urutan yang sama seperti
/// navigasi bawah di ponsel. Menu aktif berlatar primer.
class SidebarMenu extends StatelessWidget {
  /// Index menu aktif: 0 = Dashboard, 1 = Daftar Pesanan.
  final int indeksAktif;

  /// Dipanggil dengan index menu yang dipilih.
  final ValueChanged<int> onPilih;

  const SidebarMenu({
    super.key,
    required this.indeksAktif,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.lebarSidebar,
      decoration: const BoxDecoration(
        color: AppTheme.permukaan,
        border: Border(right: BorderSide(color: AppTheme.garis)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spacing4,
                  AppTheme.spacing12,
                  AppTheme.spacing4,
                  AppTheme.spacing24,
                ),
                child: Text(
                  'KelolaKatering',
                  style: TextStyle(
                    fontSize: AppTheme.subjudul,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              _ItemMenu(
                key: const Key('nav-dashboard'),
                ikon: Icons.grid_view,
                label: 'Dashboard',
                aktif: indeksAktif == 0,
                onTap: () => onPilih(0),
              ),
              const SizedBox(height: AppTheme.spacing4),
              _ItemMenu(
                key: const Key('nav-daftar-pesanan'),
                ikon: Icons.list,
                label: 'Daftar Pesanan',
                aktif: indeksAktif == 1,
                onTap: () => onPilih(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData ikon;
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _ItemMenu({
    super.key,
    required this.ikon,
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warna = aktif ? AppTheme.onPrimary : AppTheme.textSecondary;
    return Material(
      color: aktif ? AppTheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing12,
            vertical: AppTheme.spacing8 + 2,
          ),
          child: Row(
            children: [
              Icon(ikon, size: 18, color: warna),
              const SizedBox(width: AppTheme.spacing8),
              // Expanded + ellipsis agar label tidak meluber bila ukuran
              // huruf sistem diperbesar.
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTheme.isi,
                    fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                    color: warna,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
