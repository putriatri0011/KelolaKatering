import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/pesanan_model.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/pesanan_card.dart';
import '../widgets/pesanan_table.dart';
import '../widgets/ringkasan_pembayaran_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/tombol_tambah_pesanan.dart';

/// Halaman Dashboard KelolaKatering.
///
/// Susunan mengikuti wireframe Figma:
/// - Ponsel: sapaan dan tanggal hari ini, dua kotak ringkasan
///   (Pesanan Baru, Sedang Diproses), kotak Ringkasan Pembayaran,
///   tiga Pesanan Terbaru, dan tombol "Tambah Pesanan" selebar layar.
/// - Layar lebar: judul halaman dengan tombol "Tambah Pesanan" di kanan
///   atas, lima kotak ringkasan sebaris, dan tabel Pesanan Terbaru.
///
/// Navigasi:
/// - "Lihat semua" beralih ke tab Daftar Pesanan via [onLihatSemua].
/// - Kartu atau baris pesanan membuka Detail Pesanan via [onPesananTap].
/// - Tombol "Tambah Pesanan" membuka Form Tambah Pesanan via [onTambah].
class DashboardScreen extends StatelessWidget {
  /// Jumlah pesanan terbaru yang ditampilkan agar Dashboard tetap ringkas.
  static const int _batasPesananTerbaru = 3;

  /// Callback ketika "Lihat semua" ditekan. Jika null, link disembunyikan.
  final VoidCallback? onLihatSemua;

  /// Callback ketika sebuah pesanan ditekan.
  final void Function(Pesanan pesanan)? onPesananTap;

  /// Callback ketika tombol "Tambah Pesanan" ditekan.
  final VoidCallback? onTambah;

  const DashboardScreen({
    super.key,
    this.onLihatSemua,
    this.onPesananTap,
    this.onTambah,
  });

  @override
  Widget build(BuildContext context) {
    final lebar = AppTheme.layarLebar(context);
    final semuaPesanan = MockData.pesananList;
    final pesananTerbaru = semuaPesanan.take(_batasPesananTerbaru).toList();
    final tanggalHariIni = Format.tanggalPanjang(DateTime.now());

    final isi = <Widget>[
      if (lebar)
        _KepalaLebar(tanggal: tanggalHariIni, onTambah: onTambah)
      else
        _SapaanPonsel(tanggal: tanggalHariIni),
      const SizedBox(height: AppTheme.spacing16),
      if (semuaPesanan.isEmpty)
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Belum ada pesanan',
          subtitle: 'Catat pesanan pertama dari WhatsApp pelanggan Anda.',
        )
      else ...[
        // Sengaja tidak const: widget const tidak dibangun ulang saat
        // HomeShell memanggil setState, sehingga angka tidak diperbarui.
        // ignore: prefer_const_constructors
        if (lebar) _RingkasanLebar() else _RingkasanPonsel(),
        const SizedBox(height: AppTheme.spacing24),
        Row(
          children: [
            const Expanded(
              child: Text('Pesanan Terbaru', style: AppTheme.gayaSeksi),
            ),
            if (onLihatSemua != null)
              TextButton(
                key: const Key('lihat-semua'),
                onPressed: onLihatSemua,
                child: const Text('Lihat semua'),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        if (lebar)
          PesananTable(daftar: pesananTerbaru, onPesananTap: onPesananTap)
        else
          for (final pesanan in pesananTerbaru)
            PesananCard(
              pesanan: pesanan,
              tampilkanHarga: false,
              margin: const EdgeInsets.symmetric(vertical: 6),
              onTap: onPesananTap == null
                  ? null
                  : () => onPesananTap!(pesanan),
            ),
      ],
    ];

    return Scaffold(
      appBar: lebar ? null : AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(
            lebar ? AppTheme.spacing24 : AppTheme.marginTepi,
          ),
          children: isi,
        ),
      ),
      bottomNavigationBar: lebar
          ? null
          : TombolTambahPesanan.bawah(
              key: const Key('tambah-dashboard'),
              onPressed: onTambah,
            ),
    );
  }
}

/// Sapaan di bagian atas Dashboard ponsel.
class _SapaanPonsel extends StatelessWidget {
  final String tanggal;

  const _SapaanPonsel({required this.tanggal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Halo, Admin', style: AppTheme.gayaSeksi),
        const SizedBox(height: 2),
        Text(
          tanggal,
          style: const TextStyle(
            fontSize: AppTheme.keterangan,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Kepala halaman Dashboard pada layar lebar.
class _KepalaLebar extends StatelessWidget {
  final String tanggal;
  final VoidCallback? onTambah;

  const _KepalaLebar({required this.tanggal, this.onTambah});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: AppTheme.judul,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Halo, Admin · $tanggal',
                style: const TextStyle(
                  fontSize: AppTheme.keterangan,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacing16),
        TombolTambahPesanan.ringkas(
          key: const Key('tambah-dashboard'),
          onPressed: onTambah,
        ),
      ],
    );
  }
}

/// Ringkasan ponsel: dua kotak status pesanan dan Ringkasan Pembayaran.
class _RingkasanPonsel extends StatelessWidget {
  const _RingkasanPonsel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Pesanan Baru',
                value: MockData.jumlahBaru,
              ),
            ),
            const SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: SummaryCard(
                title: 'Sedang Diproses',
                value: MockData.jumlahDiproses,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        // ignore: prefer_const_constructors
        RingkasanPembayaranCard(jumlahUntuk: MockData.jumlahPembayaran),
      ],
    );
  }
}

/// Ringkasan layar lebar: lima kotak sebaris (dua kolom bila sempit).
class _RingkasanLebar extends StatelessWidget {
  const _RingkasanLebar();

  @override
  Widget build(BuildContext context) {
    final kotak = <SummaryCard>[
      SummaryCard(title: 'Pesanan Baru', value: MockData.jumlahBaru),
      SummaryCard(title: 'Sedang Diproses', value: MockData.jumlahDiproses),
      for (final status in StatusPembayaran.values)
        SummaryCard(
          title: status.label,
          value: MockData.jumlahPembayaran(status),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final kolom = constraints.maxWidth >= 640 ? kotak.length : 2;
        const jarak = AppTheme.spacing12;
        final lebarKotak =
            (constraints.maxWidth - jarak * (kolom - 1)) / kolom;
        return Wrap(
          spacing: jarak,
          runSpacing: jarak,
          children: [
            for (final k in kotak) SizedBox(width: lebarKotak, child: k),
          ],
        );
      },
    );
  }
}
