import 'package:flutter/material.dart';

import '../models/pesanan_model.dart';
import '../utils/theme.dart';
import '../widgets/status_badge.dart';

/// Halaman Detail Pesanan KelolaKatering.
///
/// Menampilkan seluruh informasi penting dari satu objek
/// [Pesanan] yang diterima melalui parameter constructor.
///
/// Status pesanan dan status pembayaran ditampilkan
/// menggunakan [StatusBadge] yang sudah tersedia.
///
/// Halaman ini bersifat read-only: tidak ada tombol edit,
/// hapus, atau simpan. Navigasi kembali melalui tombol
/// standar AppBar.
class DetailPesananScreen extends StatelessWidget {
  /// Pesanan yang akan ditampilkan detailnya.
  ///
  /// Objek ini tidak dimodifikasi di dalam halaman ini.
  final Pesanan pesanan;

  const DetailPesananScreen({
    super.key,
    required this.pesanan,
  });

  /// Memformat tanggal ke string "dd MMM yyyy".
  ///
  /// Menggunakan nama bulan Indonesia tanpa package tambahan.
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

  /// Memformat harga ke string "Rp xxx.xxx".
  ///
  /// Menggunakan pemformatan manual tanpa package tambahan.
  String _formatRupiah(int harga) {
    if (harga == 0) return 'Rp 0';
    final bagian = <String>[];
    int sisa = harga;
    while (sisa > 0) {
      final chunk = sisa % 1000;
      sisa ~/= 1000;
      if (sisa > 0) {
        bagian.add(chunk.toString().padLeft(3, '0'));
      } else {
        bagian.add(chunk.toString());
      }
    }
    final reversed = bagian.reversed.join('.');
    return 'Rp $reversed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.marginTepi),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card 1: Informasi Pesanan ────────────────────────
            _buildInfoCard(),
            const SizedBox(height: AppTheme.spacing16),
            // ── Card 2: Status ────────────────────────────────────
            _buildStatusCard(),
            const SizedBox(height: AppTheme.spacing24),
          ],
        ),
      ),
    );
  }

  /// Membangun kartu informasi pesanan dengan label dan ikon.
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header kartu ──────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  'Informasi Pesanan',
                  style: const TextStyle(
                    fontSize: AppTheme.subjudul,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: AppTheme.spacing24),
            // ── ID Pesanan ────────────────────────────────────────
            _InfoRow(
              icon: Icons.tag,
              label: 'ID Pesanan',
              value: pesanan.id,
            ),
            // ── Nama Pelanggan ────────────────────────────────────
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Nama Pelanggan',
              value: pesanan.namaPelanggan,
            ),
            // ── Nomor HP (hanya jika diisi) ───────────────────────
            if (pesanan.nomorHP.isNotEmpty)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Nomor HP',
                value: pesanan.nomorHP,
              ),
            // ── Menu ──────────────────────────────────────────────
            _InfoRow(
              icon: Icons.restaurant_menu,
              label: 'Menu',
              value: pesanan.menu,
            ),
            // ── Jumlah Porsi ──────────────────────────────────────
            _InfoRow(
              icon: Icons.format_list_numbered,
              label: 'Jumlah Porsi',
              value: '${pesanan.jumlahPorsi} porsi',
            ),
            // ── Tanggal Kirim ─────────────────────────────────────
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal Kirim',
              value: _formatTanggal(pesanan.tanggalKirim),
            ),
            // ── Total Harga ───────────────────────────────────────
            _InfoRow(
              icon: Icons.payments_outlined,
              label: 'Total Harga',
              value: _formatRupiah(pesanan.totalHarga),
            ),
            // ── Catatan (hanya jika diisi) ────────────────────────
            if (pesanan.catatan.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing8),
              _InfoRow(
                icon: Icons.sticky_note_2_outlined,
                label: 'Catatan',
                value: pesanan.catatan,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Membangun kartu status pesanan dan pembayaran.
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header kartu ──────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.task_alt,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  'Status',
                  style: const TextStyle(
                    fontSize: AppTheme.subjudul,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: AppTheme.spacing24),
            // ── Status Pesanan ────────────────────────────────────
            Text(
              'Status Pesanan',
              style: const TextStyle(
                fontSize: AppTheme.isi,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            StatusBadge.pesanan(pesanan.statusPesanan),
            const SizedBox(height: AppTheme.spacing16),
            // ── Status Pembayaran ─────────────────────────────────
            Text(
              'Status Pembayaran',
              style: const TextStyle(
                fontSize: AppTheme.isi,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            StatusBadge.pembayaran(pesanan.statusPembayaran),
          ],
        ),
      ),
    );
  }
}

/// Baris informasi dengan ikon, label, dan nilai.
///
/// Widget helper privat untuk menyusun baris label:nilai
/// di dalam kartu informasi pesanan.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ikon ────────────────────────────────────────────────
          Icon(
            icon,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacing8),
          // ── Label ───────────────────────────────────────────────
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.isi,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          // ── Nilai ───────────────────────────────────────────────
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTheme.isi,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
