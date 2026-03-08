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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
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
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: primaryEmerald),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: primaryEmerald.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryEmerald, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8,
        shadowColor: primaryEmerald.withOpacity(0.2),
        backgroundColor: primaryEmerald,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
      primaryContainer: const Color(0xFF1A2624),
      secondaryContainer: const Color(0xFF26241A),
    ),
    scaffoldBackgroundColor: surfaceDark,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      color: const Color(0xFF121413),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        color: const Color(0xFF4DB6AC),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF4DB6AC)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF121413),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shadowColor: Colors.black,
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
  );
}