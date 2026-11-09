import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/pesanan_model.dart';
import 'screens/cek_status_login.dart';
import 'screens/daftar_pesanan_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_pesanan_screen.dart';
import 'screens/tambah_pesanan_screen.dart';
import 'utils/theme.dart';
import 'widgets/sidebar_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase harus siap sebelum halaman pertama memakai FirebaseAuth.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KelolaKateringApp());
}

/// Root widget aplikasi KelolaKatering.
///
/// Menggunakan [AppTheme.light] sebagai tema Material 3. Halaman awal
/// adalah [CekStatusLogin]: Halaman Masuk bila belum login, [HomeShell]
/// bila sudah. Pengujian dapat memberi [halamanAwal] lain agar tidak
/// perlu menghubungi Firebase.
class KelolaKateringApp extends StatelessWidget {
  final Widget halamanAwal;

  const KelolaKateringApp({
    super.key,
    this.halamanAwal = const CekStatusLogin(),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KelolaKatering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: halamanAwal,
    );
  }
}

/// Pembungkus dua tujuan utama: Dashboard dan Daftar Pesanan.
///
/// Sesuai rancangan navigasi Modul 3 dan wireframe Figma:
/// - ponsel (lebar < 600 px): [NavigationBar] di bawah;
/// - layar lebar (lebar ≥ 600 px): [SidebarMenu] di kiri.
/// Isi dan urutan menu sama di keduanya.
///
/// Index 0 = Dashboard, Index 1 = Daftar Pesanan. [IndexedStack] menjaga
/// state tiap tab (mis. kata pencarian) saat berpindah tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _pilihTab(int index) {
    setState(() => _currentIndex = index);
  }

  /// Keluar dari akun. [CekStatusLogin] lalu menampilkan Halaman Masuk.
  Future<void> _keluar() => FirebaseAuth.instance.signOut();

  /// Membuka Detail Pesanan. Setelah kembali, halaman digambar ulang
  /// karena status bisa saja diubah, pesanan diedit, atau dihapus.
  Future<void> _bukaDetailPesanan(Pesanan pesanan) async {
    final hasil = await Navigator.push<HasilDetail>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananScreen(pesanan: pesanan),
      ),
    );
    if (!mounted) return;
    setState(() {});

    if (hasil == HasilDetail.dihapus) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Pesanan dihapus.')));
    }
  }

  /// Membuka Form Tambah Pesanan, lalu menggambar ulang halaman
  /// ketika pengguna berhasil menyimpan pesanan baru.
  Future<void> _bukaFormTambah() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const TambahPesananScreen()),
    );

    // Halaman bisa saja sudah ditutup saat form masih terbuka.
    if (!mounted || berhasil != true) return;

    setState(() {});

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Pesanan baru berhasil disimpan.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final lebar = AppTheme.layarLebar(context);

    final halaman = IndexedStack(
      index: _currentIndex,
      children: [
        DashboardScreen(
          onLihatSemua: () => _pilihTab(1),
          onPesananTap: _bukaDetailPesanan,
          onTambah: _bukaFormTambah,
          onKeluar: _keluar,
        ),
        DaftarPesananScreen(
          onPesananTap: _bukaDetailPesanan,
          onTambah: _bukaFormTambah,
        ),
      ],
    );

    if (lebar) {
      return Scaffold(
        body: Row(
          children: [
            SidebarMenu(
              indeksAktif: _currentIndex,
              onPilih: _pilihTab,
              onKeluar: _keluar,
            ),
            Expanded(child: halaman),
          ],
        ),
      );
    }

    return Scaffold(
      body: halaman,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _pilihTab,
        destinations: const [
          NavigationDestination(
            key: Key('nav-dashboard'),
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            key: Key('nav-daftar-pesanan'),
            icon: Icon(Icons.list),
            selectedIcon: Icon(Icons.list),
            label: 'Daftar Pesanan',
          ),
        ],
      ),
    );
  }
}
