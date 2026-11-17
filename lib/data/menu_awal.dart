import '../models/menu_model.dart';

/// Lima menu awal untuk collection `menus` (Modul 10).
///
/// Diambil dari lima pesanan simulasi di [MockData]; harga per porsi
/// adalah total harga dibagi jumlah porsi pesanan tersebut. Daftar ini
/// ditulis sekali ke Firestore bila collection `menus` masih kosong.
const List<Menu> daftarMenuAwal = [
  Menu(
    idMenu: 'menu-ayam-geprek',
    namaMenu: 'Nasi Box Ayam Geprek',
    hargaPerPorsi: 35000,
  ),
  Menu(
    idMenu: 'menu-nasi-kuning',
    namaMenu: 'Nasi Kuning Komplit',
    hargaPerPorsi: 40000,
  ),
  Menu(
    idMenu: 'menu-prasmanan-5',
    namaMenu: 'Buffet Prasmanan 5 Menu',
    hargaPerPorsi: 55000,
  ),
  Menu(
    idMenu: 'menu-snack-box',
    namaMenu: 'Snack Box Mix',
    hargaPerPorsi: 15000,
  ),
  Menu(
    idMenu: 'menu-rendang',
    namaMenu: 'Nasi Box Special Rendang',
    hargaPerPorsi: 40000,
  ),
];
