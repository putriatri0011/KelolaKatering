import '../models/pesanan_model.dart';

/// Data simulasi pesanan katering untuk Modul 6.
///
/// Lima pesanan fiktif dengan variasi status pesanan dan pembayaran.
/// Tidak menggunakan database atau layanan eksternal.
class MockData {
  MockData._(); // mencegah instansiasi

  /// Mengembalikan salinan list pesanan simulasi.
  ///
  /// Mengembalikan salinan agar perubahan tidak memengaruhi data asli.
  static List<Pesanan> get pesananList {
    return [
      Pesanan(
        id: 'PSN-001',
        namaPelanggan: 'Ibu Siti Rahayu',
        nomorHP: '081234567890',
        menu: 'Nasi Box Ayam Geprek',
        jumlahPorsi: 50,
        tanggalKirim: DateTime(2026, 11, 3),
        totalHarga: 1750000,
        catatan: 'Level pedas sedang, tanpa sayur bayam.',
        statusPesanan: StatusPesanan.baru,
        statusPembayaran: StatusPembayaran.belumBayar,
      ),
      Pesanan(
        id: 'PSN-002',
        namaPelanggan: 'Pak Budi Santoso',
        nomorHP: '082198765432',
        menu: 'Nasi Kuning Komplit',
        jumlahPorsi: 30,
        tanggalKirim: DateTime(2026, 11, 5),
        totalHarga: 1200000,
        catatan: 'Tambahkan kerupuk, air mineral 30 botol.',
        statusPesanan: StatusPesanan.diproses,
        statusPembayaran: StatusPembayaran.dp,
      ),
      Pesanan(
        id: 'PSN-003',
        namaPelanggan: 'Catering Wulandari',
        nomorHP: '085711223344',
        menu: 'Buffet Prasmanan 5 Menu',
        jumlahPorsi: 100,
        tanggalKirim: DateTime(2026, 11, 1),
        totalHarga: 5500000,
        catatan: 'Acara kantor. Delivery pukul 11.00 WIB.',
        statusPesanan: StatusPesanan.siapDikirim,
        statusPembayaran: StatusPembayaran.lunas,
      ),
      Pesanan(
        id: 'PSN-004',
        namaPelanggan: 'Toko Berkah Jaya',
        nomorHP: '081377889900',
        menu: 'Snack Box Mix',
        jumlahPorsi: 75,
        tanggalKirim: DateTime(2026, 10, 30),
        totalHarga: 1125000,
        catatan: 'Isi: risol, pastel, lumpia. Packing terpisah.',
        statusPesanan: StatusPesanan.selesai,
        statusPembayaran: StatusPembayaran.lunas,
      ),
      Pesanan(
        id: 'PSN-005',
        namaPelanggan: 'Ibu Endang Susilowati',
        nomorHP: '089655443322',
        menu: 'Nasi Box Special Rendang',
        jumlahPorsi: 40,
        tanggalKirim: DateTime(2026, 11, 8),
        totalHarga: 1600000,
        catatan: '',
        statusPesanan: StatusPesanan.diproses,
        statusPembayaran: StatusPembayaran.belumBayar,
      ),
    ];
  }

  /// Jumlah pesanan dengan status [StatusPesanan.baru].
  static int get jumlahBaru =>
      pesananList.where((p) => p.statusPesanan == StatusPesanan.baru).length;

  /// Jumlah pesanan dengan status [StatusPesanan.diproses].
  static int get jumlahDiproses =>
      pesananList.where((p) => p.statusPesanan == StatusPesanan.diproses).length;
}
