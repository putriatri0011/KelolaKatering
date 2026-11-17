import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/menu_awal.dart';
import '../models/menu_model.dart';
import '../models/pengguna_model.dart';

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
}

/// Layanan tiruan di memori, khusus untuk widget test.
class LayananMemori implements LayananKelolaKatering {
  /// Profil yang dianggap sedang login. Null berarti belum ada profil.
  Pengguna? pengguna;

  /// Isi collection `menus` tiruan.
  final List<Menu> menu = [];

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
}
