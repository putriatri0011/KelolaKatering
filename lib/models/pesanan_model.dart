import 'package:cloud_firestore/cloud_firestore.dart';
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
        return 'Pesanan Baru';
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

  /// Warna latar badge sesuai style guide Figma.
  Color get lightColor {
    switch (this) {
      case StatusPesanan.baru:
        return AppTheme.statusBaruLatar;
      case StatusPesanan.diproses:
        return AppTheme.statusDiprosesLatar;
      case StatusPesanan.siapDikirim:
        return AppTheme.statusSiapKirimLatar;
      case StatusPesanan.selesai:
        return AppTheme.statusSelesaiLatar;
    }
  }

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

  /// Warna latar badge sesuai style guide Figma.
  Color get lightColor {
    switch (this) {
      case StatusPembayaran.belumBayar:
        return AppTheme.bayarBelumLatar;
      case StatusPembayaran.dp:
        return AppTheme.bayarDPLatar;
      case StatusPembayaran.lunas:
        return AppTheme.bayarLunasLatar;
    }
  }

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

  /// uid admin yang mencatat pesanan (field `id_pengguna` di Firestore).
  final String idPengguna;

  /// Nama pelanggan yang memesan.
  final String namaPelanggan;

  /// Nomor HP pelanggan (opsional).
  final String nomorHP;

  /// ID dokumen menu di collection `menus` (field `id_menu`).
  final String idMenu;

  /// Nama menu atau paket katering yang dipesan.
  ///
  /// Disalin dari collection `menus` (denormalisasi) agar Daftar Pesanan
  /// cukup membaca satu dokumen tanpa query tambahan.
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

  /// Waktu pesanan dicatat (diisi server). Null untuk data simulasi.
  final DateTime? dibuatPada;

  Pesanan({
    required this.id,
    this.idPengguna = '',
    required this.namaPelanggan,
    this.nomorHP = '',
    this.idMenu = '',
    required this.menu,
    required this.jumlahPorsi,
    required this.tanggalKirim,
    this.totalHarga = 0,
    this.catatan = '',
    this.statusPesanan = StatusPesanan.baru,
    this.statusPembayaran = StatusPembayaran.belumBayar,
    this.dibuatPada,
  });

  /// Data yang ditulis ke collection `orders` (Modul 10).
  ///
  /// `dibuat_pada` tidak ada di sini karena diisi layanan memakai
  /// FieldValue.serverTimestamp(). Status disimpan sebagai nama enum
  /// (mis. `siapDikirim`) agar mudah dibaca di Firebase Console.
  Map<String, dynamic> toMap() => {
        'id_pesanan': id,
        'id_pengguna': idPengguna,
        'nama_pelanggan': namaPelanggan,
        'nomor_hp': nomorHP,
        'id_menu': idMenu,
        'nama_menu': menu,
        'jumlah_porsi': jumlahPorsi,
        'tanggal_kirim': Timestamp.fromDate(tanggalKirim),
        'total_harga': totalHarga,
        'catatan': catatan,
        'status_pesanan': statusPesanan.name,
        'status_pembayaran': statusPembayaran.name,
      };

  /// Membuat [Pesanan] dari dokumen Firestore dengan Document ID [id].
  factory Pesanan.fromMap(String id, Map<String, dynamic> data) {
    return Pesanan(
      id: id,
      idPengguna: data['id_pengguna'] as String? ?? '',
      namaPelanggan: data['nama_pelanggan'] as String? ?? '',
      nomorHP: data['nomor_hp'] as String? ?? '',
      idMenu: data['id_menu'] as String? ?? '',
      menu: data['nama_menu'] as String? ?? '',
      jumlahPorsi: (data['jumlah_porsi'] as num?)?.toInt() ?? 0,
      tanggalKirim:
          (data['tanggal_kirim'] as Timestamp?)?.toDate() ?? DateTime(2000),
      totalHarga: (data['total_harga'] as num?)?.toInt() ?? 0,
      catatan: data['catatan'] as String? ?? '',
      statusPesanan: StatusPesanan.values.firstWhere(
        (s) => s.name == data['status_pesanan'],
        orElse: () => StatusPesanan.baru,
      ),
      statusPembayaran: StatusPembayaran.values.firstWhere(
        (s) => s.name == data['status_pembayaran'],
        orElse: () => StatusPembayaran.belumBayar,
      ),
      dibuatPada: (data['dibuat_pada'] as Timestamp?)?.toDate(),
    );
  }

  /// Membuat salinan pesanan dengan field yang dapat diubah.
  Pesanan copyWith({
    String? id,
    String? idPengguna,
    String? namaPelanggan,
    String? nomorHP,
    String? idMenu,
    String? menu,
    int? jumlahPorsi,
    DateTime? tanggalKirim,
    int? totalHarga,
    String? catatan,
    StatusPesanan? statusPesanan,
    StatusPembayaran? statusPembayaran,
    DateTime? dibuatPada,
  }) {
    return Pesanan(
      id: id ?? this.id,
      idPengguna: idPengguna ?? this.idPengguna,
      namaPelanggan: namaPelanggan ?? this.namaPelanggan,
      nomorHP: nomorHP ?? this.nomorHP,
      idMenu: idMenu ?? this.idMenu,
      menu: menu ?? this.menu,
      jumlahPorsi: jumlahPorsi ?? this.jumlahPorsi,
      tanggalKirim: tanggalKirim ?? this.tanggalKirim,
      totalHarga: totalHarga ?? this.totalHarga,
      catatan: catatan ?? this.catatan,
      statusPesanan: statusPesanan ?? this.statusPesanan,
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
      dibuatPada: dibuatPada ?? this.dibuatPada,
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
