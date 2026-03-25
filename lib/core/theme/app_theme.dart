import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const primaryEmerald = Color(0xFF0D4D3A); // Deep, sophisticated green
  static const secondaryAmber = Color(0xFFD4A017); // Golden amber
  static const surfaceLight = Color(0xFFF8FAF9);
  static const surfaceDark = Color(0xFF0A0C0B);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryEmerald,
      primary: primaryEmerald,
      secondary: secondaryAmber,
      surface: surfaceLight,
      background: surfaceLight,
      primaryContainer: const Color(0xFFE0ECE8),
      secondaryContainer: const Color(0xFFF9F1D8),
    ),
    scaffoldBackgroundColor: surfaceLight,
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: primaryEmerald.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: primaryEmerald.withOpacity(0.05)),
      ),
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        color: primaryEmerald,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: primaryEmerald),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: primaryEmerald.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primaryEmerald, width: 2.5),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        shadowColor: primaryEmerald.withOpacity(0.3),
        backgroundColor: primaryEmerald,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.0),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC),
      brightness: Brightness.dark,
      primary: const Color(0xFF4DB6AC),
      secondary: const Color(0xFFFFD54F),
      surface: const Color(0xFF121413),
      background: surfaceDark,
    ),
    scaffoldBackgroundColor: surfaceDark,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      color: const Color(0xFF121413),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        color: const Color(0xFF4DB6AC),
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF4DB6AC)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E201F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2.5),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        shadowColor: Colors.black,
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.0),
      ),
    ),
  );
}