/// Master data menu katering, disimpan di collection `menus` (Modul 10).
///
/// Document ID memakai kode menu (mis. `menu-ayam-geprek`). Daftar menu
/// dipakai sebagai pilihan pada Form Tambah Pesanan.
class Menu {
  /// Kode menu, sekaligus Document ID.
  final String idMenu;
  final String namaMenu;

  /// Harga satu porsi dalam Rupiah.
  final int hargaPerPorsi;

  const Menu({
    required this.idMenu,
    required this.namaMenu,
    required this.hargaPerPorsi,
  });

  Map<String, dynamic> toMap() => {
        'id_menu': idMenu,
        'nama_menu': namaMenu,
        'harga_per_porsi': hargaPerPorsi,
      };

  factory Menu.fromMap(String id, Map<String, dynamic> data) {
    return Menu(
      idMenu: id,
      namaMenu: data['nama_menu'] as String? ?? '',
      hargaPerPorsi: (data['harga_per_porsi'] as num?)?.toInt() ?? 0,
    );
  }
}
