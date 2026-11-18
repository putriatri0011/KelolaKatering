import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/pengguna_model.dart';
import 'models/pesanan_model.dart';
import 'screens/cek_status_login.dart';
import 'screens/daftar_pesanan_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_pesanan_screen.dart';
import 'screens/tambah_pesanan_screen.dart';
import 'services/layanan_firestore.dart';
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
///
/// Modul 10: saat dibuka, collection `menus` diisi bila masih kosong, dan
/// Dashboard menyapa admin dengan nama dari collection `users`. Pesanan
/// dibaca sekali dari collection `orders` (milik admin yang login) melalui
/// StreamBuilder, lalu dibagikan ke Dashboard dan Daftar Pesanan.
class HomeShell extends StatefulWidget {
  /// Layanan data. Null berarti memakai [LayananFirestore]; widget test
  /// memberi [LayananMemori] agar tidak menghubungi Firebase.
  final LayananKelolaKatering? layanan;

  const HomeShell({super.key, this.layanan});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final LayananKelolaKatering _layanan;
  late final Stream<Pengguna?> _streamPengguna;
  late final Stream<List<Pesanan>> _streamPesanan;

  @override
  void initState() {
    super.initState();
    _layanan = widget.layanan ?? LayananFirestore();
    _streamPengguna = _layanan.streamPenggunaAktif();
    _streamPesanan = _layanan.streamPesananSaya();
    _siapkanMenu();
  }

  /// Auto-seed collection `menus`. Kegagalan tidak menghentikan aplikasi.
  Future<void> _siapkanMenu() async {
    try {
      await _layanan.isiMenuAwalJikaKosong();
    } catch (e) {
      debugPrint('Gagal mengisi menu awal: $e');
    }
  }

  void _pilihTab(int index) {
    setState(() => _currentIndex = index);
  }

  /// Keluar dari akun. [CekStatusLogin] lalu menampilkan Halaman Masuk.
  Future<void> _keluar() => FirebaseAuth.instance.signOut();

  /// Membuka Detail Pesanan (hanya lihat; ubah dan hapus pada Minggu 11).
  void _bukaDetailPesanan(Pesanan pesanan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananScreen(pesanan: pesanan),
      ),
    );
  }

  /// Membuka Form Tambah Pesanan, lalu menampilkan pesan berhasil.
  /// Daftar pesanan diperbarui sendiri oleh StreamBuilder.
  Future<void> _bukaFormTambah() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPesananScreen(layanan: _layanan),
      ),
    );

    // Halaman bisa saja sudah ditutup saat form masih terbuka.
    if (!mounted || berhasil != true) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Pesanan baru berhasil disimpan.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final lebar = AppTheme.layarLebar(context);

    final halaman = StreamBuilder<List<Pesanan>>(
      stream: _streamPesanan,
      builder: (context, snapPesanan) {
        // Tiga keadaan: memuat, gagal (koneksi/Rules), dan data siap.
        final memuat =
            snapPesanan.connectionState == ConnectionState.waiting &&
                !snapPesanan.hasData;
        final gagal = snapPesanan.hasError;
        final daftar = snapPesanan.data ?? const <Pesanan>[];

        return IndexedStack(
          index: _currentIndex,
          children: [
            StreamBuilder<Pengguna?>(
              stream: _streamPengguna,
              builder: (context, snapshot) => DashboardScreen(
                namaAdmin: snapshot.data?.namaLengkap,
                daftarPesanan: daftar,
                memuat: memuat,
                gagal: gagal,
                onLihatSemua: () => _pilihTab(1),
                onPesananTap: _bukaDetailPesanan,
                onTambah: _bukaFormTambah,
                onKeluar: _keluar,
              ),
            ),
            DaftarPesananScreen(
              daftarPesanan: daftar,
              memuat: memuat,
              gagal: gagal,
              onPesananTap: _bukaDetailPesanan,
              onTambah: _bukaFormTambah,
            ),
          ],
        );
      },
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
