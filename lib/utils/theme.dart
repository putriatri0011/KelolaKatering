import 'package:flutter/material.dart';

/// Tema aplikasi KelolaKatering.
///
/// Menggunakan Material 3 dengan warna primer biru navy #1F4E79
/// sesuai style guide Modul 4.
class AppTheme {
  AppTheme._(); // mencegah instansiasi

  // ── Warna utama ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1F4E79);
  static const Color onPrimary = Colors.white;

  // ── Warna teks ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);

  // ── Warna netral ─────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color cardBackground = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color disabledFill = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFF757575);

  // ── Warna status pesanan ────────────────────────────────────
  static const Color statusBaru = Color(0xFF616161);
  static const Color statusDiproses = Color(0xFFB23C00);
  static const Color statusSiapKirim = Color(0xFF01579B);
  static const Color statusSelesai = Color(0xFF2E7D32);

  // ── Warna status pembayaran ─────────────────────────────────
  static const Color bayarBelum = Color(0xFFC62828);
  static const Color bayarDP = Color(0xFFB23C00);
  static const Color bayarLunas = Color(0xFF2E7D32);

  // ── Warna khusus ─────────────────────────────────────────────
  static const Color danger = Color(0xFFC62828);

  // ── Ukuran teks (style guide Modul 4) ───────────────────────
  static const double judul = 20.0;
  static const double subjudul = 16.0;
  static const double isi = 14.0;
  static const double keterangan = 12.0;

  // ── Spacing (kelipatan 8, margin tepi 16) ───────────────────
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double marginTepi = 16.0;

  // ── Dimensi komponen ────────────────────────────────────────
  static const double tinggiTombol = 48.0;
  static const double sudutKartu = 8.0;

  /// Membangun ColorScheme Material 3 dari warna primer.
  static ColorScheme get colorScheme {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: const Color(0xFFD0E4FF),
      onPrimaryContainer: const Color(0xFF001D36),
      secondary: statusSiapKirim,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD5E3FF),
      onSecondaryContainer: const Color(0xFF001B3D),
      tertiary: statusSelesai,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFB8F5B5),
      onTertiaryContainer: const Color(0xFF002106),
      error: danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: cardBackground,
      onSurface: textPrimary,
      surfaceContainerHighest: const Color(0xFFEDEDED),
      onSurfaceVariant: textSecondary,
      outline: divider,
      outlineVariant: const Color(0xFFD0D0D0),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFF121212),
      onInverseSurface: const Color(0xFFF5F5F5),
      inversePrimary: const Color(0xFF9ECAFF),
    );
  }

  /// ThemeData untuk aplikasi.
  static ThemeData get light {
    final scheme = colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: judul,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
      ),
      // ── Card ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
        ),
        margin: EdgeInsets.zero,
      ),
      // ── ElevatedButton ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: disabledFill,
          disabledForegroundColor: disabledText,
          minimumSize: const Size(0, tinggiTombol),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sudutKartu),
          ),
        ),
      ),
      // ── OutlinedButton ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, tinggiTombol),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sudutKartu),
          ),
          side: BorderSide(color: primary, width: 1.5),
        ),
      ),
      // ── TextButton ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, tinggiTombol),
        ),
      ),
      // ── FloatingActionButton ────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
      ),
      // ── Input decoration ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: isi,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: isi,
        ),
        errorStyle: const TextStyle(
          color: danger,
          fontSize: keterangan,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
          borderSide: const BorderSide(color: divider),
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
          horizontal: spacing16,
          vertical: spacing16,
        ),
      ),
      // ── Divider ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      // ── ListTile ────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: marginTepi,
          vertical: spacing8,
        ),
        titleTextStyle: TextStyle(
          fontSize: subjudul,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: isi,
          color: textSecondary,
        ),
      ),
      // ── BottomNavigationBar ─────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: keterangan),
        unselectedLabelStyle: TextStyle(fontSize: keterangan),
      ),
      // ── Dialog ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sudutKartu),
        ),
        titleTextStyle: const TextStyle(
          fontSize: subjudul,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: isi,
          color: textSecondary,
        ),
      ),
      // ── SnackBar ────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
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
