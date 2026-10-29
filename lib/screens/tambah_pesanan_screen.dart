import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/pesanan_model.dart';
import '../utils/theme.dart';

/// Halaman Form Tambah Pesanan (Modul 7).
///
/// Halaman ini adalah [StatefulWidget] karena menyimpan isian yang
/// berubah-ubah. Seluruh kolom dibungkus [Form] dengan
/// [GlobalKey<FormState>] agar dapat divalidasi sekaligus saat tombol
/// "Simpan Pesanan" ditekan.
///
/// Aturan validasi diturunkan dari kriteria penerimaan Modul 2:
/// - Nama pelanggan, menu, jumlah porsi, dan tanggal kirim wajib diisi.
/// - Nomor HP dan total harga opsional, tetapi bila diisi harus berformat
///   benar (10-15 digit diawali 0; harga angka positif).
/// - Jumlah porsi harus lebih dari 0 dan tidak melebihi 1000.
/// - Catatan maksimal 200 karakter.
///
/// Data yang valid disimpan ke [MockData.pesananList] di memori, lalu
/// halaman ditutup dengan hasil `true` agar pemanggil dapat menggambar
/// ulang daftar pesanan.
class TambahPesananScreen extends StatefulWidget {
  const TambahPesananScreen({super.key});

  @override
  State<TambahPesananScreen> createState() => _TambahPesananScreenState();
}

class _TambahPesananScreenState extends State<TambahPesananScreen> {
  /// Key untuk memvalidasi seluruh kolom sekaligus.
  final _formKey = GlobalKey<FormState>();

  // ── Controller setiap kolom teks/angka ──────────────────────
  final _namaController = TextEditingController();
  final _nomorHPController = TextEditingController();
  final _menuController = TextEditingController();
  final _porsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _catatanController = TextEditingController();
  final _tanggalController = TextEditingController();

  // ── Nilai pilihan (bukan teks) disimpan di state ─────────────
  DateTime? _tanggalKirim;
  StatusPesanan _statusPesanan = StatusPesanan.baru;
  StatusPembayaran _statusPembayaran = StatusPembayaran.belumBayar;

  // ── Batas nilai yang dipakai validator ──────────────────────
  static const int _maksPorsi = 1000;
  static const int _maksHarga = 100000000;
  static const int _maksCatatan = 200;
  static const int _rentangTanggalHari = 365;

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHPController.dispose();
    _menuController.dispose();
    _porsiController.dispose();
    _hargaController.dispose();
    _catatanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  Helper format
  // ══════════════════════════════════════════════════════════════

  /// Memformat tanggal ke string "dd MMM yyyy" (nama bulan Indonesia).
  ///
  /// Pemformatan manual agar tidak memerlukan package tambahan.
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
    return '$hari $bulanStr ${tanggal.year}';
  }

  // ══════════════════════════════════════════════════════════════
  //  Aksi
  // ══════════════════════════════════════════════════════════════

  /// Membuka [showDatePicker] dan menyimpan tanggal yang dipilih.
  ///
  /// Batas [firstDate] dan [lastDate] sekaligus menjadi validasi:
  /// tanggal yang sudah lewat tidak dapat dipilih.
  Future<void> _pilihTanggal() async {
    FocusScope.of(context).unfocus();

    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggalKirim ?? hariIni,
      firstDate: hariIni,
      lastDate: hariIni.add(const Duration(days: _rentangTanggalHari)),
      helpText: 'Pilih tanggal kirim',
    );

    if (dipilih == null) return;

    setState(() {
      _tanggalKirim = dipilih;
      _tanggalController.text = _formatTanggal(dipilih);
    });
  }

  /// Memvalidasi seluruh kolom, lalu menyimpan pesanan bila valid.
  ///
  /// Bila ada kolom tidak valid, SnackBar memberi tahu bahwa isian
  /// perlu diperiksa dan data tidak disimpan.
  void _kirim() {
    FocusScope.of(context).unfocus();

    // Simpan messenger lebih dulu agar aman dipakai setelah await/pop.
    final messenger = ScaffoldMessenger.of(context);
    // Pesan lama tidak menahan pesan baru (Modul 7 bagian 4).
    messenger.hideCurrentSnackBar();

    if (!_formKey.currentState!.validate()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali isian yang ditandai merah.'),
        ),
      );
      return;
    }

    final teksHarga = _hargaController.text.trim();

    final pesananBaru = Pesanan(
      id: MockData.idBerikutnya(),
      namaPelanggan: _namaController.text.trim(),
      nomorHP: _nomorHPController.text.trim(),
      menu: _menuController.text.trim(),
      jumlahPorsi: int.parse(_porsiController.text.trim()),
      tanggalKirim: _tanggalKirim!,
      totalHarga: teksHarga.isEmpty ? 0 : int.parse(teksHarga),
      catatan: _catatanController.text.trim(),
      statusPesanan: _statusPesanan,
      statusPembayaran: _statusPembayaran,
    );

    // State sederhana: tambahkan ke list yang dipakai bersama.
    MockData.tambah(pesananBaru);

    // Kembali ke halaman pemanggil dengan hasil true.
    // SnackBar berhasil ditampilkan oleh pemanggil setelah halaman ditutup.
    Navigator.pop(context, true);
  }

  // ══════════════════════════════════════════════════════════════
  //  Validator
  // ══════════════════════════════════════════════════════════════

  String? _validasiNama(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return 'Nama pelanggan wajib diisi';
    if (teks.length < 3) return 'Nama pelanggan minimal 3 karakter';
    if (teks.length > 60) return 'Nama pelanggan maksimal 60 karakter';
    return null;
  }

  String? _validasiNomorHP(String? nilai) {
    final teks = nilai?.trim() ?? '';
    // Opsional: boleh dikosongkan.
    if (teks.isEmpty) return null;
    if (!RegExp(r'^0[0-9]{9,14}$').hasMatch(teks)) {
      return 'Nomor HP harus 10-15 digit dan diawali angka 0';
    }
    return null;
  }

  String? _validasiMenu(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return 'Menu wajib diisi';
    if (teks.length < 3) return 'Menu minimal 3 karakter';
    if (teks.length > 80) return 'Menu maksimal 80 karakter';
    return null;
  }

  String? _validasiPorsi(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return 'Jumlah porsi wajib diisi';
    final porsi = int.tryParse(teks);
    if (porsi == null) return 'Jumlah porsi harus berupa angka';
    if (porsi <= 0) return 'Jumlah porsi tidak boleh nol';
    if (porsi > _maksPorsi) return 'Jumlah porsi maksimal $_maksPorsi porsi';
    return null;
  }

  String? _validasiHarga(String? nilai) {
    final teks = nilai?.trim() ?? '';
    // Opsional: bila kosong dianggap 0.
    if (teks.isEmpty) return null;
    final harga = int.tryParse(teks);
    if (harga == null) return 'Total harga harus berupa angka';
    if (harga <= 0) return 'Total harga harus lebih dari nol';
    if (harga > _maksHarga) return 'Total harga maksimal Rp 100.000.000';
    return null;
  }

  String? _validasiCatatan(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.length > _maksCatatan) {
      return 'Catatan maksimal $_maksCatatan karakter';
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════
  //  UI
  // ══════════════════════════════════════════════════════════════

  /// Judul kecil untuk mengelompokkan kolom.
  Widget _judulBagian(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: AppTheme.subjudul,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pesanan'),
      ),
      body: Form(
        key: _formKey,
        // Pesan kesalahan ikut diperbarui saat pengguna memperbaiki isian.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.marginTepi),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bagian 1: Data Pelanggan ─────────────────────────
              _judulBagian('Data Pelanggan'),
              TextFormField(
                controller: _namaController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan *',
                  hintText: 'Contoh: Ibu Siti Rahayu',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _validasiNama,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _nomorHPController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  hintText: '08xxxxxxxxxx',
                  helperText: 'Opsional. 10-15 digit, diawali angka 0.',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: _validasiNomorHP,
              ),
              const SizedBox(height: AppTheme.spacing24),

              // ── Bagian 2: Rincian Pesanan ────────────────────────
              _judulBagian('Rincian Pesanan'),
              TextFormField(
                controller: _menuController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Menu *',
                  hintText: 'Contoh: Nasi Box Ayam Geprek',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                validator: _validasiMenu,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _porsiController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jumlah Porsi *',
                  hintText: 'Contoh: 50',
                  helperText: 'Minimal 1 porsi, maksimal $_maksPorsi porsi.',
                  prefixIcon: Icon(Icons.people_outline),
                  suffixText: 'porsi',
                ),
                validator: _validasiPorsi,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: _pilihTanggal,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kirim *',
                  hintText: 'Pilih tanggal pengiriman',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (_) => _tanggalKirim == null
                    ? 'Tanggal kirim wajib diisi'
                    : null,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Total Harga',
                  hintText: 'Contoh: 1750000',
                  helperText: 'Opsional. Tanpa titik atau koma.',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'Rp ',
                ),
                validator: _validasiHarga,
              ),
              const SizedBox(height: AppTheme.spacing24),

              // ── Bagian 3: Status Awal ────────────────────────────
              _judulBagian('Status Awal'),
              DropdownButtonFormField<StatusPesanan>(
                initialValue: _statusPesanan,
                // isExpanded mencegah teks pilihan panjang meluber.
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status Pesanan',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: [
                  for (final status in StatusPesanan.values)
                    DropdownMenuItem<StatusPesanan>(
                      value: status,
                      child: Text(status.label),
                    ),
                ],
                onChanged: (nilai) {
                  if (nilai == null) return;
                  setState(() => _statusPesanan = nilai);
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              DropdownButtonFormField<StatusPembayaran>(
                initialValue: _statusPembayaran,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status Pembayaran',
                  prefixIcon: Icon(Icons.payment_outlined),
                ),
                items: [
                  for (final status in StatusPembayaran.values)
                    DropdownMenuItem<StatusPembayaran>(
                      value: status,
                      child: Text(status.label),
                    ),
                ],
                onChanged: (nilai) {
                  if (nilai == null) return;
                  setState(() => _statusPembayaran = nilai);
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Contoh: level pedas sedang, tanpa sayur bayam',
                  helperText: 'Opsional. Maksimal $_maksCatatan karakter.',
                  alignLabelWithHint: true,
                ),
                validator: _validasiCatatan,
              ),
              const SizedBox(height: AppTheme.spacing24),

              // ── Tombol aksi ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _kirim,
                      icon: const Icon(Icons.save_outlined, size: 20),
                      label: const Text('Simpan Pesanan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              const Text(
                '* wajib diisi',
                style: TextStyle(
                  fontSize: AppTheme.keterangan,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
