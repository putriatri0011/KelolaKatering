import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/theme.dart';
import '../utils/validasi_auth.dart';

/// Fungsi yang mengirim email dan password ke Firebase.
///
/// [daftar] true berarti membuat akun baru, false berarti masuk.
typedef ProsesAuth = Future<void> Function(
  String email,
  String password,
  bool daftar,
);

/// Halaman Masuk (H1 di sitemap), dengan mode tambahan Daftar (Modul 9).
///
/// Susunan mengikuti wireframe Figma: nama aplikasi, keterangan,
/// pesan kesalahan berlatar merah muda, kolom Email dan Password,
/// tombol utama, lalu catatan "Khusus admin / pemilik katering".
///
/// Setelah berhasil, halaman tidak memanggil Navigator. [CekStatusLogin]
/// mendengar perubahan status login dan mengganti halaman sendiri.
class MasukScreen extends StatefulWidget {
  /// Dapat diganti saat pengujian agar tidak menghubungi Firebase.
  final ProsesAuth? prosesAuth;

  const MasukScreen({super.key, this.prosesAuth});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ulangiController = TextEditingController();

  /// true: mode Daftar (ada kolom Ulangi password). false: mode Masuk.
  bool _modeDaftar = false;

  /// true selama menunggu jawaban Firebase; tombol dinonaktifkan.
  bool _sedangProses = false;

  /// Pesan dari Firebase, ditampilkan di atas kolom Email.
  String? _pesanKesalahan;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ulangiController.dispose();
    super.dispose();
  }

  static Future<void> _prosesFirebase(
    String email,
    String password,
    bool daftar,
  ) async {
    final auth = FirebaseAuth.instance;
    if (daftar) {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    }
  }

  void _gantiMode() {
    setState(() {
      _modeDaftar = !_modeDaftar;
      _pesanKesalahan = null;
      _ulangiController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _kirim() async {
    setState(() => _pesanKesalahan = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sedangProses = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final proses = widget.prosesAuth ?? _prosesFirebase;

    try {
      await proses(email, password, _modeDaftar);
      // Berhasil: CekStatusLogin mengganti halaman secara otomatis.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _pesanKesalahan = pesanKesalahanAuth(e.code));
    } finally {
      if (mounted) setState(() => _sedangProses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final judulTombol = _modeDaftar ? 'Daftar' : 'Masuk';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.marginTepi),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'KelolaKatering',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTheme.judul,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      _modeDaftar
                          ? 'Daftar akun admin baru'
                          : 'Aplikasi Pencatatan Pesanan Katering',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppTheme.keterangan,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    if (_pesanKesalahan != null) ...[
                      _KotakKesalahan(_pesanKesalahan!),
                      const SizedBox(height: AppTheme.spacing16),
                    ],
                    const _Label('Email *'),
                    TextFormField(
                      key: const Key('kolom-email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        hintText: 'admin@kelolakatering.id',
                      ),
                      validator: validasiEmail,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    const _Label('Password *'),
                    TextFormField(
                      key: const Key('kolom-password'),
                      controller: _passwordController,
                      obscureText: true, // karakter disembunyikan
                      textInputAction: _modeDaftar
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted: _modeDaftar ? null : (_) => _kirim(),
                      decoration: const InputDecoration(
                        hintText: 'Minimal 6 karakter',
                      ),
                      validator: validasiPassword,
                    ),
                    if (_modeDaftar) ...[
                      const SizedBox(height: AppTheme.spacing16),
                      const _Label('Ulangi Password *'),
                      TextFormField(
                        key: const Key('kolom-ulangi-password'),
                        controller: _ulangiController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _kirim(),
                        decoration: const InputDecoration(
                          hintText: 'Ketik ulang password',
                        ),
                        validator: (nilai) => validasiUlangiPassword(
                          nilai,
                          _passwordController.text,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacing24),
                    FilledButton(
                      key: const Key('tombol-kirim'),
                      onPressed: _sedangProses ? null : _kirim,
                      child: _sedangProses
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.onPrimary,
                              ),
                            )
                          : Text(judulTombol),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    TextButton(
                      key: const Key('tombol-ganti-mode'),
                      onPressed: _sedangProses ? null : _gantiMode,
                      child: Text(
                        _modeDaftar
                            ? 'Sudah punya akun? Masuk'
                            : 'Belum punya akun? Daftar',
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    const Text(
                      'Khusus admin / pemilik katering',
                      textAlign: TextAlign.center,
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
      ),
    );
  }
}

/// Pesan kesalahan dari Firebase, sesuai keadaan "login gagal" di Figma.
class _KotakKesalahan extends StatelessWidget {
  final String pesan;

  const _KotakKesalahan(this.pesan);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('pesan-kesalahan-login'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8 + 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bayarBelumLatar,
        border: Border.all(color: AppTheme.danger),
        borderRadius: BorderRadius.circular(AppTheme.sudutKartu),
      ),
      child: Text(
        pesan,
        style: const TextStyle(
          fontSize: AppTheme.keterangan,
          fontWeight: FontWeight.w600,
          color: AppTheme.bayarBelum,
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
