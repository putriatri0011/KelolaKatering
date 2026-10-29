import 'package:flutter/material.dart';

import 'models/pesanan_model.dart';
import 'screens/daftar_pesanan_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_pesanan_screen.dart';
import 'screens/tambah_pesanan_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const KelolaKateringApp());
}

/// Root widget aplikasi KelolaKatering.
///
/// Menggunakan [AppTheme.light] sebagai tema Material 3
/// dan [HomeShell] sebagai halaman awal.
class KelolaKateringApp extends StatelessWidget {
  const KelolaKateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KelolaKatering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeShell(),
    );
  }
}

/// Halaman utama yang membungkus Dashboard dan Daftar Pesanan
/// dengan [NavigationBar] (Material 3) untuk navigasi tab.
///
/// Index 0 = Dashboard, Index 1 = Daftar Pesanan.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  /// Beralih ke tab Daftar Pesanan (index 1).
  void _bukaDaftarPesanan() {
    setState(() {
      _currentIndex = 1;
    });
  }

  /// Navigasi ke halaman Detail Pesanan dengan meneruskan
  /// objek [pesanan] yang dipilih pengguna.
  void _bukaDetailPesanan(Pesanan pesanan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananScreen(pesanan: pesanan),
      ),
    );
  }

  /// Membuka Form Tambah Pesanan, lalu menggambar ulang halaman
  /// ketika pengguna berhasil menyimpan pesanan baru.
  ///
  /// Form mengembalikan `true` melalui [Navigator.pop] bila data valid
  /// dan sudah ditambahkan ke `MockData.pesananList`. Pemanggilan
  /// [setState] membuat Dashboard (ringkasan & pesanan terbaru) dan
  /// Daftar Pesanan menampilkan data terbaru.
  Future<void> _bukaFormTambah() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahPesananScreen(),
      ),
    );

    // Halaman bisa saja sudah ditutup saat form masih terbuka.
    if (!mounted || berhasil != true) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan baru berhasil disimpan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onLihatSemua: _bukaDaftarPesanan,
            onPesananTap: _bukaDetailPesanan,
            onTambah: _bukaFormTambah,
          ),
          DaftarPesananScreen(
            onPesananTap: _bukaDetailPesanan,
            onTambah: _bukaFormTambah,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
        ],
      ),
    );
  }
}
