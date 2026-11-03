import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/pesanan_model.dart';
import '../utils/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/pesanan_card.dart';
import '../widgets/pesanan_table.dart';
import '../widgets/tombol_tambah_pesanan.dart';

/// Halaman Daftar Pesanan KelolaKatering.
///
/// Menampilkan seluruh pesanan dari [MockData.pesananList] dengan
/// kolom "Cari nama pelanggan" di atasnya, sesuai wireframe Figma.
/// - Ponsel: daftar [PesananCard] dan tombol "Tambah Pesanan" di bawah.
/// - Layar lebar: tabel pesanan dan tombol "Tambah Pesanan" di kanan atas.
///
/// Halaman ini [StatefulWidget] karena menyimpan kata pencarian.
/// Keadaan kosong dibedakan menjadi dua: belum ada pesanan sama sekali,
/// dan pencarian tidak menemukan pesanan.
class DaftarPesananScreen extends StatefulWidget {
  /// Callback ketika sebuah pesanan ditekan.
  final void Function(Pesanan pesanan)? onPesananTap;

  /// Callback ketika tombol "Tambah Pesanan" ditekan.
  final VoidCallback? onTambah;

  const DaftarPesananScreen({
    super.key,
    this.onPesananTap,
    this.onTambah,
  });

  @override
  State<DaftarPesananScreen> createState() => _DaftarPesananScreenState();
}

class _DaftarPesananScreenState extends State<DaftarPesananScreen> {
  final _cariController = TextEditingController();

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lebar = AppTheme.layarLebar(context);
    final adaPesanan = MockData.pesananList.isNotEmpty;
    final hasil = MockData.cariNama(_cariController.text);

    final kolomCari = TextField(
      key: const Key('cari-pesanan'),
      controller: _cariController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari nama pelanggan',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _cariController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(_cariController.clear),
              ),
      ),
    );

    Widget isi;
    if (!adaPesanan) {
      isi = const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada pesanan',
        subtitle: 'Catat pesanan pertama dari WhatsApp pelanggan Anda.',
      );
    } else if (hasil.isEmpty) {
      isi = EmptyState(
        icon: Icons.search_off,
        title: 'Pesanan tidak ditemukan',
        subtitle:
            'Tidak ada pelanggan dengan nama "${_cariController.text.trim()}".',
      );
    } else if (lebar) {
      isi = PesananTable(daftar: hasil, onPesananTap: widget.onPesananTap);
    } else {
      isi = Column(
        children: [
          for (final pesanan in hasil)
            PesananCard(
              pesanan: pesanan,
              margin: const EdgeInsets.symmetric(vertical: 6),
              onTap: widget.onPesananTap == null
                  ? null
                  : () => widget.onPesananTap!(pesanan),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: lebar ? null : AppBar(title: const Text('Daftar Pesanan')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(
            lebar ? AppTheme.spacing24 : AppTheme.marginTepi,
          ),
          children: [
            if (lebar) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Pesanan',
                      style: TextStyle(
                        fontSize: AppTheme.judul,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  TombolTambahPesanan.ringkas(
                    key: const Key('tambah-daftar'),
                    onPressed: widget.onTambah,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: kolomCari,
                ),
              ),
            ] else
              kolomCari,
            const SizedBox(height: AppTheme.spacing12),
            isi,
          ],
        ),
      ),
      bottomNavigationBar: lebar
          ? null
          : TombolTambahPesanan.bawah(
              key: const Key('tambah-daftar'),
              onPressed: widget.onTambah,
            ),
    );
  }
}
