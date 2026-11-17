import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/menu_awal.dart';
import '../models/menu_model.dart';
import '../models/pengguna_model.dart';
import '../models/pesanan_model.dart';

/// Dilempar bila pesanan yang sama sudah tercatat (aturan bisnis Modul 10).
class PesananGandaException implements Exception {
  final String pesan;

  const PesananGandaException(this.pesan);

  @override
  String toString() => pesan;
}

/// Aturan bisnis KelolaKatering: dua pesanan dianggap sama bila nama
/// pelanggan, nama menu (keduanya tanpa membedakan huruf besar kecil), dan
/// tanggal kirim sama. Mencegah satu pesanan WhatsApp tercatat dua kali.
/// Nama menu yang dibandingkan karena menu boleh diketik bebas.
bool adalahPesananGanda(Pesanan lama, Pesanan baru) {
  String rapikan(String teks) => teks.trim().toLowerCase();
  final a = lama.tanggalKirim;
  final b = baru.tanggalKirim;
  return rapikan(lama.namaPelanggan) == rapikan(baru.namaPelanggan) &&
      rapikan(lama.menu) == rapikan(baru.menu) &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}

PesananGandaException _pesanGanda(Pesanan p) => PesananGandaException(
      'Pesanan ${p.namaPelanggan} untuk ${p.menu} '
      'pada tanggal itu sudah tercatat.',
    );

/// Kontrak layanan data KelolaKatering (Modul 10).
///
/// Halaman cukup memanggil metode di sini dan tidak memakai
/// FirebaseFirestore.instance secara langsung. Aplikasi memakai
/// [LayananFirestore]; widget test memakai [LayananMemori] agar tidak
/// membutuhkan koneksi internet atau Firebase asli.
abstract class LayananKelolaKatering {
  /// Membuat dokumen `users/{uid}` bila belum ada.
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  });

  /// Profil admin yang sedang login, diperbarui secara real-time.
  Stream<Pengguna?> streamPenggunaAktif();

  /// Mengisi collection `menus` dengan [daftarMenuAwal] bila masih kosong.
  Future<void> isiMenuAwalJikaKosong();

  /// Seluruh menu, diurutkan berdasarkan nama, secara real-time.
  Stream<List<Menu>> streamDaftarMenu();

  /// Menyimpan pesanan baru ke collection `orders`.
  ///
  /// Melempar [PesananGandaException] bila pesanan yang sama sudah ada.
  Future<void> tambahPesanan(Pesanan pesanan);
}

/// Layanan yang membaca dan menulis Cloud Firestore asli.
class LayananFirestore implements LayananKelolaKatering {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  LayananFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final snap = await docRef.get();
    if (snap.exists) return;

    final nama = (namaLengkap ?? '').trim();
    final pengguna = Pengguna(
      idPengguna: uid,
      namaLengkap: nama.isNotEmpty ? nama : email.split('@').first,
      email: email,
    );
    await docRef.set({
      ...pengguna.toMap(),
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<Pengguna?> streamPenggunaAktif() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _db.collection('users').doc(user.uid).snapshots().map(
          (snap) => snap.exists ? Pengguna.fromMap(snap.id, snap.data()!) : null,
        );
  }

  @override
  Future<void> isiMenuAwalJikaKosong() async {
    final cek = await _db.collection('menus').limit(1).get();
    if (cek.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final menu in daftarMenuAwal) {
      batch.set(_db.collection('menus').doc(menu.idMenu), menu.toMap());
    }
    await batch.commit();
  }

  @override
  Stream<List<Menu>> streamDaftarMenu() {
    return _db.collection('menus').snapshots().map((snap) {
      final daftar =
          snap.docs.map((d) => Menu.fromMap(d.id, d.data())).toList();
      daftar.sort((a, b) => a.namaMenu.compareTo(b.namaMenu));
      return daftar;
    });
  }

  @override
  Future<void> tambahPesanan(Pesanan pesanan) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Admin belum login.');
    }

    // Cukup satu .where() agar tidak memerlukan composite index; aturan
    // pesanan ganda diperiksa di sisi Dart.
    final milikAdmin = await _db
        .collection('orders')
        .where('id_pengguna', isEqualTo: user.uid)
        .get();
    final ganda = milikAdmin.docs.any(
      (doc) => adalahPesananGanda(Pesanan.fromMap(doc.id, doc.data()), pesanan),
    );
    if (ganda) throw _pesanGanda(pesanan);

    final docRef = _db.collection('orders').doc();
    final data = pesanan.copyWith(id: docRef.id, idPengguna: user.uid).toMap();
    await docRef.set({
      ...data,
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }
}

/// Layanan tiruan di memori, khusus untuk widget test.
class LayananMemori implements LayananKelolaKatering {
  /// Profil yang dianggap sedang login. Null berarti belum ada profil.
  Pengguna? pengguna;

  /// Isi collection `menus` tiruan.
  final List<Menu> menu = [];

  /// Isi collection `orders` tiruan.
  final List<Pesanan> pesanan = [];

  LayananMemori({this.pengguna});

  @override
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  }) async {
    final nama = (namaLengkap ?? '').trim();
    pengguna ??= Pengguna(
      idPengguna: uid,
      namaLengkap: nama.isNotEmpty ? nama : email.split('@').first,
      email: email,
    );
  }

  @override
  Stream<Pengguna?> streamPenggunaAktif() => Stream.value(pengguna);

  @override
  Future<void> isiMenuAwalJikaKosong() async {
    if (menu.isEmpty) menu.addAll(daftarMenuAwal);
  }

  @override
  Stream<List<Menu>> streamDaftarMenu() {
    final daftar = List<Menu>.of(menu)
      ..sort((a, b) => a.namaMenu.compareTo(b.namaMenu));
    return Stream.value(daftar);
  }

  @override
  Future<void> tambahPesanan(Pesanan baru) async {
    if (pesanan.any((lama) => adalahPesananGanda(lama, baru))) {
      throw _pesanGanda(baru);
    }
    pesanan.add(
      baru.copyWith(
        id: 'uji-${pesanan.length + 1}',
        idPengguna: pengguna?.idPengguna ?? 'uid-uji',
        dibuatPada: DateTime.now(),
      ),
    );
  }
}
