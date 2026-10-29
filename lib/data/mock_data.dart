import '../models/pesanan_model.dart';

/// Sumber data pesanan katering untuk Modul 6 dan Modul 7.
///
/// Data disimpan pada satu list di memori yang dipakai bersama oleh
/// Dashboard dan Daftar Pesanan. Tidak menggunakan database atau
/// layanan eksternal, sehingga seluruh data kembali ke kondisi awal
/// ketika aplikasi dijalankan ulang (lihat Modul 7 bagian 5).
class MockData {
  MockData._(); // mencegah instansiasi

  /// Satu list mutable yang dipakai bersama oleh seluruh halaman.
  ///
  /// Sebelumnya list ini dibuat ulang setiap kali diakses (getter),
  /// sehingga pesanan baru tidak pernah bertahan. Sekarang list dibuat
  /// sekali dan dapat ditambah melalui [tambah].
  ///
  /// Berisi lima pesanan simulasi awal dengan variasi status pesanan
  /// dan status pembayaran.
  static final List<Pesanan> pesananList = <Pesanan>[
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

  /// Menambahkan [pesanan] baru ke urutan paling atas list.
  ///
  /// Pesanan terbaru ditampilkan lebih dulu pada Dashboard
  /// ("Pesanan Terbaru") dan Daftar Pesanan.
  static void tambah(Pesanan pesanan) {
    pesananList.insert(0, pesanan);
  }

  /// Membuat ID pesanan berikutnya berdasarkan nomor terbesar yang ada.
  ///
  /// Contoh: bila ID terakhir adalah `PSN-005`, hasilnya `PSN-006`.
  /// Nomor diambil dari bagian setelah tanda hubung pada setiap ID,
  /// lalu ditambah satu dan diberi padding tiga digit.
  static String idBerikutnya() {
    var nomorTerbesar = 0;
    for (final pesanan in pesananList) {
      final bagian = pesanan.id.split('-');
      if (bagian.length < 2) continue;
      final nomor = int.tryParse(bagian.last);
      if (nomor != null && nomor > nomorTerbesar) {
        nomorTerbesar = nomor;
      }
    }
    return 'PSN-${(nomorTerbesar + 1).toString().padLeft(3, '0')}';
  }

  /// Jumlah pesanan dengan status [StatusPesanan.baru].
  static int get jumlahBaru =>
      pesananList.where((p) => p.statusPesanan == StatusPesanan.baru).length;

  /// Jumlah pesanan dengan status [StatusPesanan.diproses].
  static int get jumlahDiproses =>
      pesananList.where((p) => p.statusPesanan == StatusPesanan.diproses).length;
}
