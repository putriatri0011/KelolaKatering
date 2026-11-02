import 'package:flutter/material.dart';

/// Tema aplikasi KelolaKatering.
///
/// Seluruh nilai warna, ukuran teks, dan jarak mengikuti
/// "KelolaKatering — Mini Style Guide" di file Figma wireframe:
/// - Font Inter dengan 4 tingkat teks: 26 / 18 / 15 / 13.
/// - Primer #1F3A5F, permukaan #F3F4F6, garis #D5DAE1,
///   teks #1B1F24, teks sekunder #5B6470, error #B3261E.
/// - Spasi dasar 4 / 8 / 12 / 16.
class AppTheme {
  AppTheme._(); // mencegah instansiasi

  // ── Palet warna (style guide Figma) ─────────────────────────
  static const Color primary = Color(0xFF1F3A5F);
  static const Color onPrimary = Colors.white;
  static const Color permukaan = Color(0xFFF3F4F6);
  static const Color garis = Color(0xFFD5DAE1);
  static const Color textPrimary = Color(0xFF1B1F24);
  static const Color textSecondary = Color(0xFF5B6470);
  static const Color danger = Color(0xFFB3261E);
  static const Color latar = Colors.white;

  // ── Warna badge status pesanan (teks/garis dan latar) ───────
  static const Color statusBaru = Color(0xFF1F3A5F);
  static const Color statusBaruLatar = Color(0xFFE4EAF3);
  static const Color statusDiproses = Color(0xFF6B4500);
  static const Color statusDiprosesLatar = Color(0xFFFFF1D6);
  static const Color statusSiapKirim = Color(0xFF1B4A5E);
  static const Color statusSiapKirimLatar = Color(0xFFDDF0F7);
  static const Color statusSelesai = Color(0xFF24552A);
  static const Color statusSelesaiLatar = Color(0xFFE2F2E3);

  // ── Warna badge status pembayaran ───────────────────────────
  static const Color bayarBelum = Color(0xFF8C1D18);
  static const Color bayarBelumLatar = Color(0xFFFDECEA);
  static const Color bayarDP = Color(0xFF6B4500);
  static const Color bayarDPLatar = Color(0xFFFFF1D6);
  static const Color bayarLunas = Color(0xFF24552A);
  static const Color bayarLunasLatar = Color(0xFFE2F2E3);

  // ── Ukuran teks (4 tingkat) ─────────────────────────────────
  /// Judul halaman, 26 / Bold.
  static const double judul = 26.0;

  /// Judul bar dan judul seksi, 18 / Bold.
  static const double subjudul = 18.0;

  /// Isi, input, dan tombol, 15 / Regular atau Semi Bold.
  static const double isi = 15.0;

  /// Label, keterangan, dan badge, 13 / Regular atau Semi Bold.
  static const double keterangan = 13.0;

  // ── Spacing (spasi dasar 4/8/12/16, margin tepi 16) ─────────
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double marginTepi = 16.0;

  // ── Dimensi komponen ────────────────────────────────────────
  static const double tinggiTombol = 48.0;
  static const double sudutKartu = 8.0;

  /// Lebar layar minimal yang dianggap layar lebar (browser).
  ///
  /// Sesuai Modul 4: di bawah 600 px ponsel, 600 px ke atas layar lebar.
  static const double batasLayarLebar = 600.0;

  /// Lebar sidebar pada layar lebar (rancangan web Figma).
  static const double lebarSidebar = 240.0;

  /// Lebar maksimum konten form dan detail pada layar lebar.
  static const double lebarKontenMaks = 720.0;

  /// Nama keluarga font yang didaftarkan di pubspec.yaml.
  static const String fontFamily = 'Inter';

  /// Mengembalikan true bila lebar layar termasuk layar lebar.
  static bool layarLebar(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= batasLayarLebar;

  /// Gaya teks judul seksi (18 / Bold).
  static const TextStyle gayaSeksi = TextStyle(
    fontSize: subjudul,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  /// Gaya label kecil berhuruf kapital, mis. "INFORMASI PELANGGAN".
  static const TextStyle gayaLabelSeksi = TextStyle(
    fontSize: keterangan,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.3,
  );

  /// ColorScheme Material 3 yang diturunkan dari warna primer.
  static ColorScheme get colorScheme {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      surface: latar,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: permukaan,
      outline: garis,
      outlineVariant: garis,
      error: danger,
      onError: Colors.white,
    );
  }

  /// ThemeData untuk aplikasi.
  static ThemeData get light {
    final scheme = colorScheme;
    final bentukTombol = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(sudutKartu),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: latar,
      // ── AppBar putih dengan garis bawah (wireframe mobile) ────
      appBarTheme: const AppBarTheme(
        backgroundColor: latar,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: garis)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: subjudul,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      // ── Card bergaris tipis tanpa bayangan ───────────────────
      cardTheme: CardThemeData(
        color: latar,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          side: const BorderSide(color: garis),
        ),
        margin: EdgeInsets.zero,
      ),
      // ── Tombol utama (isi primer) ────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(0, tinggiTombol),
          shape: bentukTombol,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: isi,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size(0, tinggiTombol),
          shape: bentukTombol,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: isi,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ── Tombol sekunder (garis primer) ───────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, tinggiTombol),
          shape: bentukTombol,
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: isi,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: keterangan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ── Input: label di atas kolom, garis abu-abu ────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: latar,
        hintStyle: const TextStyle(color: textSecondary, fontSize: isi),
        errorStyle: const TextStyle(color: danger, fontSize: keterangan),
        helperStyle: const TextStyle(
          color: textSecondary,
          fontSize: keterangan,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: garis),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: Color(0xFFA3ABB6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing12,
          vertical: spacing12,
        ),
      ),
      // ── Chip pilihan status di Detail Pesanan ────────────────
      chipTheme: ChipThemeData(
        backgroundColor: latar,
        selectedColor: primary,
        disabledColor: permukaan,
        side: const BorderSide(color: Color(0xFFA3ABB6)),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: keterangan,
          color: textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: keterangan,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: spacing4),
      ),
      dividerTheme: const DividerThemeData(
        color: garis,
        thickness: 1,
        space: 1,
      ),
      // ── NavigationBar bawah (ponsel) ─────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: permukaan,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: 0.12),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final aktif = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: keterangan,
            fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
            color: aktif ? primary : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final aktif = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 20,
            color: aktif ? primary : textSecondary,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: latar,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: subjudul,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: isi,
          color: textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: isi,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
        ),
      ),
    );
  }
}
