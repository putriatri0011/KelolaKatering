import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil admin yang login, disimpan di collection `users` (Modul 10).
///
/// Document ID memakai uid dari Firebase Authentication, sehingga satu
/// akun login punya tepat satu dokumen profil.
class Pengguna {
  /// uid Firebase Authentication, sekaligus Document ID.
  final String idPengguna;
  final String namaLengkap;
  final String email;
  final String nomorTelepon;

  /// Peran pengguna. KelolaKatering hanya dipakai admin/pemilik katering.
  final String peran;

  /// Waktu dokumen dibuat (diisi server). Bisa null sesaat setelah ditulis.
  final DateTime? dibuatPada;

  const Pengguna({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    this.nomorTelepon = '',
    this.peran = 'admin',
    this.dibuatPada,
  });

  /// Data yang ditulis ke Firestore. `dibuat_pada` diisi lewat
  /// FieldValue.serverTimestamp() di layanan, bukan dari sini.
  Map<String, dynamic> toMap() => {
        'id_pengguna': idPengguna,
        'nama_lengkap': namaLengkap,
        'email': email,
        'nomor_telepon': nomorTelepon,
        'peran': peran,
      };

  factory Pengguna.fromMap(String id, Map<String, dynamic> data) {
    return Pengguna(
      idPengguna: id,
      namaLengkap: data['nama_lengkap'] as String? ?? '',
      email: data['email'] as String? ?? '',
      nomorTelepon: data['nomor_telepon'] as String? ?? '',
      peran: data['peran'] as String? ?? 'admin',
      dibuatPada: (data['dibuat_pada'] as Timestamp?)?.toDate(),
    );
  }
}
