import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/pesanan_model.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import 'tambah_pesanan_screen.dart';

/// Hasil yang dikirim Detail Pesanan ke pemanggil lewat [Navigator.pop].
enum HasilDetail {
  /// Pesanan dihapus; pemanggil menampilkan pesan dan menggambar ulang.
  dihapus,
}

/// Halaman Detail Pesanan KelolaKatering.
///
/// Susunan mengikuti wireframe Figma:
/// - Informasi Pelanggan: nama dan nomor WhatsApp.
/// - Pesanan: menu/paket, jumlah porsi, tanggal pengiriman, total harga,
///   dan catatan.
/// - Perbarui Status Pesanan dan Perbarui Status Pembayaran: pilihan
///   berbentuk chip. Status langsung tersimpan saat chip ditekan
///   (Story 4 dan Story 5, kebutuhan K6 dan K7 Modul 2).
/// - Tombol "Edit Pesanan" membuka Form Edit Pesanan, dan "Hapus Pesanan"
///   menghapus setelah konfirmasi (kebutuhan K5 Modul 2).
///
/// Halaman ini [StatefulWidget] karena status bisa berubah selama halaman
/// terbuka. Data terbaru selalu diambil dari [MockData] berdasarkan ID.
class DetailPesananScreen extends StatefulWidget {
  /// Pesanan yang ditampilkan saat halaman dibuka.
  final Pesanan pesanan;

  const DetailPesananScreen({super.key, required this.pesanan});

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> {
  late Pesanan _pesanan = widget.pesanan;

  /// Menyimpan perubahan status lalu menampilkan pesan konfirmasi.
  void _ubahStatus({
    StatusPesanan? statusPesanan,
    StatusPembayaran? statusPembayaran,
  }) {
    final baru = _pesanan.copyWith(
      statusPesanan: statusPesanan,
      statusPembayaran: statusPembayaran,
    );
    MockData.perbarui(baru);
    setState(() => _pesanan = baru);

    final pesan = statusPesanan != null
        ? 'Status pesanan diubah menjadi ${statusPesanan.label}.'
        : 'Status pembayaran diubah menjadi ${statusPembayaran!.label}.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  /// Membuka Form Edit Pesanan, lalu memuat ulang data bila disimpan.
  Future<void> _bukaEdit() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPesananScreen(pesananAwal: _pesanan),
      ),
    );
    if (!mounted || berhasil != true) return;

    setState(() {
      _pesanan = MockData.cariById(_pesanan.id) ?? _pesanan;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Perubahan pesanan disimpan.')),
      );
  }

  /// Meminta konfirmasi, lalu menghapus pesanan dan kembali ke daftar.
  Future<void> _hapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pesanan ini?'),
        content: const Text('Data pesanan tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const Key('konfirmasi-hapus'),
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || yakin != true) return;

    MockData.hapus(_pesanan.id);
    Navigator.pop(context, HasilDetail.dihapus);
  }

  @override
  Widget build(BuildContext context) {
    final p = _pesanan;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.marginTepi),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTheme.lebarKontenMaks,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _JudulSeksi('INFORMASI PELANGGAN'),
                _Baris(label: 'Nama', nilai: p.namaPelanggan, tebal: true),
                _Baris(
                  label: 'WhatsApp',
                  nilai: p.nomorHP.isEmpty ? '-' : p.nomorHP,
                ),
                const SizedBox(height: AppTheme.spacing12),
                const _JudulSeksi('PESANAN'),
                _Baris(label: 'ID Pesanan', nilai: p.id),
                _Baris(label: 'Menu / Paket', nilai: p.menu),
                _Baris(label: 'Jumlah Porsi', nilai: '${p.jumlahPorsi} porsi'),
                _Baris(
                  label: 'Tgl Pengiriman',
                  nilai: Format.tanggal(p.tanggalKirim),
                ),
                _Baris(
                  label: 'Total Harga',
                  nilai: p.totalHarga > 0 ? Format.rupiah(p.totalHarga) : '-',
                  tebal: true,
                ),
                _Baris(
                  label: 'Catatan',
                  nilai: p.catatan.isEmpty ? '-' : p.catatan,
                ),
                const SizedBox(height: AppTheme.spacing16),
                const _JudulSeksi('PERBARUI STATUS PESANAN'),
                _PilihanStatus<StatusPesanan>(
                  nilai: StatusPesanan.values,
                  terpilih: p.statusPesanan,
                  label: (s) => s.label,
                  kunci: (s) => Key('chip-pesanan-${s.name}'),
                  onPilih: (s) => _ubahStatus(statusPesanan: s),
                ),
                const SizedBox(height: AppTheme.spacing12),
                const _JudulSeksi('PERBARUI STATUS PEMBAYARAN'),
                _PilihanStatus<StatusPembayaran>(
                  nilai: StatusPembayaran.values,
                  terpilih: p.statusPembayaran,
                  label: (s) => s.label,
                  kunci: (s) => Key('chip-bayar-${s.name}'),
                  onPilih: (s) => _ubahStatus(statusPembayaran: s),
                ),
                const SizedBox(height: AppTheme.spacing24),
                OutlinedButton(
                  onPressed: _bukaEdit,
                  child: const Text('Edit Pesanan'),
                ),
                const SizedBox(height: AppTheme.spacing8),
                TextButton(
                  onPressed: _hapus,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
                  ),
                  child: const Text('Hapus Pesanan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Judul seksi kecil berhuruf kapital, mis. "INFORMASI PELANGGAN".
class _JudulSeksi extends StatelessWidget {
  final String teks;

  const _JudulSeksi(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Text(teks, style: AppTheme.gayaLabelSeksi),
    );
  }
}

/// Satu baris label di kiri dan nilai di kanan, dengan garis bawah.
class _Baris extends StatelessWidget {
  final String label;
  final String nilai;
  final bool tebal;

  const _Baris({required this.label, required this.nilai, this.tebal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.garis)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.isi,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppTheme.isi,
                fontWeight: tebal ? FontWeight.w700 : FontWeight.w400,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Deretan chip untuk memilih satu status.
///
/// Chip terpilih berlatar primer dengan teks putih, chip lain bergaris,
/// sesuai wireframe Detail Pesanan.
class _PilihanStatus<T> extends StatelessWidget {
  final List<T> nilai;
  final T terpilih;
  final String Function(T) label;
  final Key Function(T) kunci;
  final ValueChanged<T> onPilih;

  const _PilihanStatus({
    required this.nilai,
    required this.terpilih,
    required this.label,
    required this.kunci,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing8,
      runSpacing: AppTheme.spacing8,
      children: [
        for (final s in nilai)
          ChoiceChip(
            key: kunci(s),
            label: Text(
              label(s),
              style: TextStyle(
                fontSize: AppTheme.keterangan,
                fontWeight: s == terpilih ? FontWeight.w600 : FontWeight.w400,
                color: s == terpilih ? AppTheme.onPrimary : AppTheme.textPrimary,
              ),
            ),
            selected: s == terpilih,
            onSelected: (_) {
              if (s != terpilih) onPilih(s);
            },
          ),
      ],
    );
  }
}
