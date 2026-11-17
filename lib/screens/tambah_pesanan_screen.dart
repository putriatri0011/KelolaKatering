import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/menu_model.dart';
import '../models/pesanan_model.dart';
import '../services/layanan_firestore.dart';
import '../utils/format.dart';
import '../utils/theme.dart';

/// Halaman Form Tambah Pesanan dan Form Edit Pesanan.
///
/// Satu halaman dipakai untuk dua keperluan, seperti rancangan Figma
/// ("Form Edit Pesanan" adalah variasi dari Form Tambah Pesanan):
/// - tanpa [pesananAwal]: mencatat pesanan baru;
/// - dengan [pesananAwal]: mengubah pesanan yang sudah ada. Kolom
///   sudah terisi, judul menjadi "Form Edit Pesanan", dan tombol
///   menjadi "Simpan Perubahan". ID pesanan tidak berubah.
///
/// Halaman ini [StatefulWidget] karena menyimpan isian yang berubah-ubah.
/// Seluruh kolom dibungkus [Form] dengan [GlobalKey<FormState>] agar
/// dapat divalidasi sekaligus.
///
/// Aturan validasi diturunkan dari kriteria penerimaan Modul 2:
/// - Nama pelanggan, menu, jumlah porsi, dan tanggal pengiriman wajib.
/// - Nomor WhatsApp dan total harga opsional, tetapi bila diisi harus
///   berformat benar (10-15 digit diawali 0; harga angka positif).
/// - Jumlah porsi 1 sampai 1000.
/// - Catatan maksimal 200 karakter.
///
/// Modul 10: menu diketik bebas, dengan saran dari collection `menus`
/// (menu yang sudah ada dipakai ulang namanya dan ID-nya), dan pesanan baru
/// disimpan ke collection `orders` lewat [layanan]. Pesanan yang sama
/// (nama pelanggan, menu, dan tanggal kirim sama) ditolak dengan SnackBar
/// tanpa menutup form. Mode edit masih menyimpan ke [MockData]; edit ke
/// Firestore dikerjakan pada Minggu 11.
///
/// Setelah berhasil, halaman ditutup dengan hasil `true` agar pemanggil
/// menggambar ulang tampilannya.
class TambahPesananScreen extends StatefulWidget {
  /// Pesanan yang diedit. Null berarti mode tambah pesanan baru.
  final Pesanan? pesananAwal;

  /// Sumber daftar menu dan tempat menyimpan pesanan baru.
  final LayananKelolaKatering layanan;

  const TambahPesananScreen({
    super.key,
    this.pesananAwal,
    required this.layanan,
  });

  @override
  State<TambahPesananScreen> createState() => _TambahPesananScreenState();
}

class _TambahPesananScreenState extends State<TambahPesananScreen> {
  /// Key untuk memvalidasi seluruh kolom sekaligus.
  final _formKey = GlobalKey<FormState>();

  // ── Controller setiap kolom teks/angka ──────────────────────
  final _namaController = TextEditingController();
  final _nomorHPController = TextEditingController();
  final _porsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _catatanController = TextEditingController();
  final _tanggalController = TextEditingController();

  // ── Nilai pilihan (bukan teks) disimpan di state ─────────────
  DateTime? _tanggalKirim;
  StatusPesanan _statusPesanan = StatusPesanan.baru;
  StatusPembayaran _statusPembayaran = StatusPembayaran.belumBayar;

  // ── Kolom Menu: ketik bebas dengan saran dari `menus` ─────────
  final _menuController = TextEditingController();
  final _menuFocus = FocusNode();
  late final StreamSubscription<List<Menu>> _langgananMenu;
  List<Menu> _daftarMenu = const [];

  /// true selama menunggu Firestore; tombol simpan dinonaktifkan.
  bool _sedangMenyimpan = false;

  // ── Batas nilai yang dipakai validator ──────────────────────
  static const int _maksPorsi = 1000;
  static const int _maksHarga = 100000000;
  static const int _maksCatatan = 200;
  static const int _rentangTanggalHari = 365;

  bool get _modeEdit => widget.pesananAwal != null;

  @override
  void initState() {
    super.initState();
    // Saran menu hanya pelengkap: bila gagal dimuat, kolom tetap bisa diisi.
    _langgananMenu = widget.layanan.streamDaftarMenu().listen(
      (daftar) => _daftarMenu = daftar,
      onError: (Object _) => _daftarMenu = const [],
    );
    final awal = widget.pesananAwal;
    if (awal == null) return;

    // Mode edit: isi kolom dengan data pesanan yang sudah ada.
    _namaController.text = awal.namaPelanggan;
    _nomorHPController.text = awal.nomorHP;
    _menuController.text = awal.menu;
    _porsiController.text = '${awal.jumlahPorsi}';
    _hargaController.text = awal.totalHarga > 0 ? '${awal.totalHarga}' : '';
    _catatanController.text = awal.catatan;
    _tanggalKirim = awal.tanggalKirim;
    _tanggalController.text = Format.tanggal(awal.tanggalKirim);
    _statusPesanan = awal.statusPesanan;
    _statusPembayaran = awal.statusPembayaran;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHPController.dispose();
    _langgananMenu.cancel();
    _menuController.dispose();
    _menuFocus.dispose();
    _porsiController.dispose();
    _hargaController.dispose();
    _catatanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  Aksi
  // ══════════════════════════════════════════════════════════════

  /// Membuka [showDatePicker] dan menyimpan tanggal yang dipilih.
  ///
  /// Batas [firstDate] dan [lastDate] sekaligus menjadi validasi:
  /// tanggal yang sudah lewat tidak dapat dipilih. Pada mode edit,
  /// tanggal lama yang sudah lewat tetap boleh dipertahankan.
  Future<void> _pilihTanggal() async {
    FocusScope.of(context).unfocus();

    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final tanggalLama = _tanggalKirim;
    final awalRentang = tanggalLama != null && tanggalLama.isBefore(hariIni)
        ? tanggalLama
        : hariIni;

    final dipilih = await showDatePicker(
      context: context,
      initialDate: tanggalLama ?? hariIni,
      firstDate: awalRentang,
      lastDate: hariIni.add(const Duration(days: _rentangTanggalHari)),
      helpText: 'Pilih tanggal pengiriman',
    );

    if (dipilih == null) return;

    setState(() {
      _tanggalKirim = dipilih;
      _tanggalController.text = Format.tanggal(dipilih);
    });
  }

  /// Menu di collection `menus` yang namanya sama dengan [nama]
  /// (tanpa membedakan huruf besar kecil), atau null bila menu baru.
  Menu? _menuCocok(String nama) {
    final kunci = nama.trim().toLowerCase();
    for (final menu in _daftarMenu) {
      if (menu.namaMenu.toLowerCase() == kunci) return menu;
    }
    return null;
  }

  /// Memvalidasi seluruh kolom, lalu menyimpan pesanan bila valid.
  Future<void> _kirim() async {
    FocusScope.of(context).unfocus();

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

    final namaMenu = _menuController.text.trim();
    final menuCocok = _menuCocok(namaMenu);

    final teksHarga = _hargaController.text.trim();

    final pesanan = Pesanan(
      // Pesanan baru mendapat ID dokumen dari Firestore saat disimpan.
      id: widget.pesananAwal?.id ?? '',
      namaPelanggan: _namaController.text.trim(),
      nomorHP: _nomorHPController.text.trim(),
      // Menu dari `menus`: simpan ID dan salin namanya (denormalisasi).
      // Menu yang diketik sendiri: id_menu dibiarkan kosong.
      idMenu: menuCocok?.idMenu ?? '',
      menu: menuCocok?.namaMenu ?? namaMenu,
      jumlahPorsi: int.parse(_porsiController.text.trim()),
      tanggalKirim: _tanggalKirim!,
      totalHarga: teksHarga.isEmpty ? 0 : int.parse(teksHarga),
      catatan: _catatanController.text.trim(),
      statusPesanan: _statusPesanan,
      statusPembayaran: _statusPembayaran,
    );

    if (_modeEdit) {
      MockData.perbarui(pesanan);
      Navigator.pop(context, true);
      return;
    }

    setState(() => _sedangMenyimpan = true);
    try {
      await widget.layanan.tambahPesanan(pesanan);
      if (!mounted) return;
      // SnackBar berhasil ditampilkan oleh pemanggil setelah halaman ditutup.
      Navigator.pop(context, true);
    } on PesananGandaException catch (e) {
      // Form tidak ditutup agar admin dapat memeriksa isiannya.
      messenger.showSnackBar(SnackBar(content: Text(e.pesan)));
    } catch (_) {
      // Isian tetap ada di form sehingga admin cukup menekan Simpan lagi.
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Pesanan gagal disimpan. Periksa koneksi lalu coba lagi.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
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
    if (teks.isEmpty) return null; // opsional
    if (!RegExp(r'^0[0-9]{9,14}$').hasMatch(teks)) {
      return 'Nomor WhatsApp harus 10-15 digit dan diawali angka 0';
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
    if (teks.isEmpty) return null; // opsional, dianggap 0
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

  @override
  Widget build(BuildContext context) {
    final judul = _modeEdit ? 'Form Edit Pesanan' : 'Form Tambah Pesanan';

    final kolomPorsi = TextFormField(
      controller: _porsiController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(hintText: '0', suffixText: 'porsi'),
      validator: _validasiPorsi,
    );

    final kolomTanggal = TextFormField(
      controller: _tanggalController,
      readOnly: true,
      onTap: _pilihTanggal,
      decoration: const InputDecoration(
        hintText: 'Pilih tanggal',
        suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
      ),
      validator: (_) =>
          _tanggalKirim == null ? 'Tanggal pengiriman wajib diisi' : null,
    );

    final kolomMenu = RawAutocomplete<Menu>(
      textEditingController: _menuController,
      focusNode: _menuFocus,
      displayStringForOption: (menu) => menu.namaMenu,
      optionsBuilder: (nilai) {
        final kata = nilai.text.trim().toLowerCase();
        if (kata.isEmpty) return const Iterable<Menu>.empty();
        return _daftarMenu
            .where((menu) => menu.namaMenu.toLowerCase().contains(kata));
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          key: const Key('kolom-menu'),
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Contoh: Nasi Box Ayam Bakar',
            helperText: 'Ketik bebas, atau pilih dari saran menu.',
          ),
          validator: _validasiMenu,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 220,
                maxWidth: AppTheme.lebarKontenMaks,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final menu in options)
                    ListTile(
                      dense: true,
                      title: Text(menu.namaMenu),
                      onTap: () => onSelected(menu),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final pilihStatusPesanan = DropdownButtonFormField<StatusPesanan>(
      key: const Key('dropdown-status-pesanan'),
      initialValue: _statusPesanan,
      isExpanded: true, // mencegah teks pilihan panjang meluber
      items: [
        for (final status in StatusPesanan.values)
          DropdownMenuItem(value: status, child: Text(status.label)),
      ],
      onChanged: (nilai) {
        if (nilai == null) return;
        setState(() => _statusPesanan = nilai);
      },
    );

    final pilihStatusBayar = DropdownButtonFormField<StatusPembayaran>(
      key: const Key('dropdown-status-pembayaran'),
      initialValue: _statusPembayaran,
      isExpanded: true,
      items: [
        for (final status in StatusPembayaran.values)
          DropdownMenuItem(value: status, child: Text(status.label)),
      ],
      onChanged: (nilai) {
        if (nilai == null) return;
        setState(() => _statusPembayaran = nilai);
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: Form(
        key: _formKey,
        // Pesan kesalahan ikut diperbarui saat pengguna memperbaiki isian.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.marginTepi),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTheme.lebarKontenMaks,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_modeEdit) ...[
                    Text(
                      'Mengubah pesanan yang sudah ada · '
                      '#${widget.pesananAwal!.id}',
                      style: const TextStyle(
                        fontSize: AppTheme.keterangan,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                  ],
                  const _Label('Nama Pelanggan *'),
                  TextFormField(
                    controller: _namaController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        const InputDecoration(hintText: 'Nama pelanggan'),
                    validator: _validasiNama,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  const _Label('Nomor WhatsApp'),
                  TextFormField(
                    controller: _nomorHPController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration:
                        const InputDecoration(hintText: '08xxxxxxxxxx'),
                    validator: _validasiNomorHP,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  const _Label('Menu / Paket Katering *'),
                  kolomMenu,
                  const SizedBox(height: AppTheme.spacing12),
                  _DuaKolom(
                    kiri: kolomPorsi,
                    labelKiri: 'Jumlah Porsi *',
                    kanan: kolomTanggal,
                    labelKanan: 'Tanggal Pengiriman *',
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  const _Label('Total Harga'),
                  TextFormField(
                    controller: _hargaController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // "Rp" dipasang sebagai prefixIcon agar selalu terlihat.
                    // prefixText baru muncul setelah kolom diklik, sehingga
                    // kolom kosong tampak bergeser.
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 1750000',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: AppTheme.spacing12,
                          right: AppTheme.spacing4,
                        ),
                        child: Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: AppTheme.isi,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 0),
                      helperText: 'Opsional. Tanpa titik atau koma.',
                    ),
                    validator: _validasiHarga,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  const _Label('Catatan Pesanan'),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: 'Opsional'),
                    validator: _validasiCatatan,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _DuaKolom(
                    kiri: pilihStatusPesanan,
                    labelKiri: 'Status Pesanan',
                    kanan: pilihStatusBayar,
                    labelKanan: 'Status Pembayaran',
                  ),
                  const SizedBox(height: AppTheme.spacing24),
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
                        child: FilledButton(
                          onPressed: _sedangMenyimpan ? null : _kirim,
                          child: Text(
                            _sedangMenyimpan
                                ? 'Menyimpan...'
                                : _modeEdit
                                    ? 'Simpan Perubahan'
                                    : 'Simpan Pesanan',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing12),
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
        ),
      ),
    );
  }
}

/// Label tebal di atas kolom isian, sesuai wireframe Figma.
class _Label extends StatelessWidget {
  final String teks;

  const _Label(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: AppTheme.keterangan,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

/// Dua kolom isian berdampingan, masing-masing dengan labelnya.
class _DuaKolom extends StatelessWidget {
  final Widget kiri;
  final String labelKiri;
  final Widget kanan;
  final String labelKanan;

  const _DuaKolom({
    required this.kiri,
    required this.labelKiri,
    required this.kanan,
    required this.labelKanan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_Label(labelKiri), kiri],
          ),
        ),
        const SizedBox(width: AppTheme.spacing8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_Label(labelKanan), kanan],
          ),
        ),
      ],
    );
  }
}
