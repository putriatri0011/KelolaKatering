import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Status pesanan katering.
///
/// Mewakili 4 tahap alur pesanan sesuai Modul 2-4.
enum StatusPesanan {
  baru,
  diproses,
  siapDikirim,
  selesai,
}

/// Status pembayaran pesanan.
///
/// Mewakili 3 tahap pembayaran sesuai Modul 2-4.
enum StatusPembayaran {
  belumBayar,
  dp,
  lunas,
}

/// Ekstensi untuk menampilkan label dan warna [StatusPesanan] di UI.
extension StatusPesananUI on StatusPesanan {
  /// Label teks yang ditampilkan ke pengguna.
  String get label {
    switch (this) {
      case StatusPesanan.baru:
        return 'Baru';
      case StatusPesanan.diproses:
        return 'Diproses';
      case StatusPesanan.siapDikirim:
        return 'Siap Dikirim';
      case StatusPesanan.selesai:
        return 'Selesai';
    }
  }

  /// Warna penuh untuk teks atau ikon status.
  Color get color {
    switch (this) {
      case StatusPesanan.baru:
        return AppTheme.statusBaru;
      case StatusPesanan.diproses:
        return AppTheme.statusDiproses;
      case StatusPesanan.siapDikirim:
        return AppTheme.statusSiapKirim;
      case StatusPesanan.selesai:
        return AppTheme.statusSelesai;
    }
  }

  /// Warna latar muda untuk badge (opacity 0.15).
  Color get lightColor => color.withValues(alpha: 0.15);

  /// Ikon Material yang mewakili status.
  IconData get icon {
    switch (this) {
      case StatusPesanan.baru:
        return Icons.fiber_new_outlined;
      case StatusPesanan.diproses:
        return Icons.sync_outlined;
      case StatusPesanan.siapDikirim:
        return Icons.local_shipping_outlined;
      case StatusPesanan.selesai:
        return Icons.check_circle_outlined;
    }
  }
}

/// Ekstensi untuk menampilkan label dan warna [StatusPembayaran] di UI.
extension StatusPembayaranUI on StatusPembayaran {
  /// Label teks yang ditampilkan ke pengguna.
  String get label {
    switch (this) {
      case StatusPembayaran.belumBayar:
        return 'Belum Bayar';
      case StatusPembayaran.dp:
        return 'DP';
      case StatusPembayaran.lunas:
        return 'Lunas';
    }
  }

  /// Warna penuh untuk teks atau ikon status.
  Color get color {
    switch (this) {
      case StatusPembayaran.belumBayar:
        return AppTheme.bayarBelum;
      case StatusPembayaran.dp:
        return AppTheme.bayarDP;
      case StatusPembayaran.lunas:
        return AppTheme.bayarLunas;
    }
  }

  /// Warna latar muda untuk badge (opacity 0.15).
  Color get lightColor => color.withValues(alpha: 0.15);

  /// Ikon Material yang mewakili status pembayaran.
  IconData get icon {
    switch (this) {
      case StatusPembayaran.belumBayar:
        return Icons.schedule_outlined;
      case StatusPembayaran.dp:
        return Icons.percent_outlined;
      case StatusPembayaran.lunas:
        return Icons.paid_outlined;
    }
  }
}

/// Model data pesanan katering.
///
/// Setiap field sesuai kebutuhan Modul 1-4:
/// - [namaPelanggan], [menu], [jumlahPorsi], [tanggalKirim]: wajib
/// - [nomorHP], [totalHarga], [catatan]: opsional
/// - [statusPesanan], [statusPembayaran]: default saat dibuat
class Pesanan {
  /// ID unik pesanan (untuk navigasi dan identifikasi).
  final String id;

  /// Nama pelanggan yang memesan.
  final String namaPelanggan;

  /// Nomor HP pelanggan (opsional).
  final String nomorHP;

  /// Menu atau paket katering yang dipesan.
  final String menu;

  /// Jumlah porsi yang dipesan.
  final int jumlahPorsi;

  /// Tanggal pengiriman pesanan.
  final DateTime tanggalKirim;

  /// Total harga pesanan dalam Rupiah (opsional, default 0).
  final int totalHarga;

  /// Catatan tambahan dari pelanggan (opsional).
  final String catatan;

  /// Status pemrosesan pesanan.
  StatusPesanan statusPesanan;

  /// Status pembayaran pesanan.
  StatusPembayaran statusPembayaran;

  Pesanan({
    required this.id,
    required this.namaPelanggan,
    this.nomorHP = '',
    required this.menu,
    required this.jumlahPorsi,
    required this.tanggalKirim,
    this.totalHarga = 0,
    this.catatan = '',
    this.statusPesanan = StatusPesanan.baru,
    this.statusPembayaran = StatusPembayaran.belumBayar,
  });

  /// Membuat salinan pesanan dengan field yang dapat diubah.
  Pesanan copyWith({
    String? id,
    String? namaPelanggan,
    String? nomorHP,
    String? menu,
    int? jumlahPorsi,
    DateTime? tanggalKirim,
    int? totalHarga,
    String? catatan,
    StatusPesanan? statusPesanan,
    StatusPembayaran? statusPembayaran,
  }) {
    return Pesanan(
      id: id ?? this.id,
      namaPelanggan: namaPelanggan ?? this.namaPelanggan,
      nomorHP: nomorHP ?? this.nomorHP,
      menu: menu ?? this.menu,
      jumlahPorsi: jumlahPorsi ?? this.jumlahPorsi,
      tanggalKirim: tanggalKirim ?? this.tanggalKirim,
      totalHarga: totalHarga ?? this.totalHarga,
      catatan: catatan ?? this.catatan,
      statusPesanan: statusPesanan ?? this.statusPesanan,
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
    );
  }

  @override
  String toString() {
    return 'Pesanan(id: $id, nama: $namaPelanggan, menu: $menu, '
        'porsi: $jumlahPorsi, status: ${statusPesanan.label}, '
        'bayar: ${statusPembayaran.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pesanan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
