import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño Haute Beauté para Glam Studio.
/// Conserva los nombres de tokens de color de AppTheme para compatibilidad total
/// con los widgets existentes, pero transforma la identidad visual a una boutique
/// de alta cosmética (Vino Borgoña, Rosa Empolvado, Dorado Champagne y Crema Seda).
class AppTheme {
  // Colores de Identidad Glam Studio
  static const Color primary = Color(0xFF4E1624); // Borgoña Imperial Oscuro
  static const Color primaryContainer = Color(0xFF6B2737); // Vino Borgoña Principal
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFBE9EC);
  static const Color primaryFixed = Color(0xFFF7E2E7); // Rosa Seda Suave
  static const Color onPrimaryFixed = Color(0xFF4E1624);

  // Acentos de Belleza
  static const Color dustyRose = Color(0xFFD88C9A); // Rosa Empolvado
  static const Color softGold = Color(0xFFD4AF37); // Dorado Champagne
  static const Color champagne = Color(0xFFF7EFE6);

  // Colores Secundarios (Validación, en stock, beneficios)
  static const Color secondary = Color(0xFF2E6B56); // Verde Salvia Esmeralda
  static const Color secondaryContainer = Color(0xFFDDF3EA);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1B4B3A);
  static const Color secondaryFixed = Color(0xFFDDF3EA);
  static const Color secondaryFixedDim = Color(0xFF75C9A8);

  // Colores Terciarios (Stock bajo, alertas doradas)
  static const Color tertiary = Color(0xFF8C5E14);
  static const Color tertiaryContainer = Color(0xFFFDF0D5);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF6E470B);
  static const Color tertiaryFixed = Color(0xFFFDF0D5);
  static const Color onTertiaryFixedVariant = Color(0xFF6E470B);

  // Colores de Error (Agotado, validaciones)
  static const Color error = Color(0xFFB42336);
  static const Color errorContainer = Color(0xFFFCE4E7);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF7A1120);

  // Superficies y Fondos (Paleta Seda & Rosé)
  static const Color background = Color(0xFFFCF8F9);
  static const Color surface = Color(0xFFFCF8F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8EFF2);
  static const Color surfaceContainer = Color(0xFFF3E5EA);
  static const Color surfaceContainerHigh = Color(0xFFECD8DF);
  static const Color surfaceContainerHighest = Color(0xFFE4CAD3);

  // Texto y Contornos
  static const Color onSurface = Color(0xFF28151B);
  static const Color onSurfaceVariant = Color(0xFF664A53);
  static const Color outline = Color(0xFF9C7D87);
  static const Color outlineVariant = Color(0xFFE8D6DC);
  static const Color inverseSurface = Color(0xFF2B171E);
  static const Color inverseOnSurface = Color(0xFFFDF5F7);

  // Alias de compatibilidad utilizados por las pantallas de Carrito, Admin y Navegación
  static const Color primaryColor = primaryContainer;
  static const Color secondaryColor = dustyRose;
  static const Color accentGold = softGold;
  static const Color backgroundLight = background;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = outline;
  static const Color borderColor = outlineVariant;
  static const Color successColor = secondary;
  static const Color warningColor = tertiary;
  static const Color dangerColor = error;

  static List<BoxShadow> luxuryShadow = [
    BoxShadow(
      color: const Color(0xFF6B2737).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Construye el tema global Material 3 de Alta Cosmética
  static ThemeData get lightTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryContainer,
        onPrimary: onPrimary,
        primaryContainer: primaryFixed,
        onPrimaryContainer: onPrimaryFixed,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryContainer,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryContainer, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.8),
        ),
        labelStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
        hintStyle: const TextStyle(color: outline, fontSize: 13.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryContainer,
          side: const BorderSide(color: dustyRose, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: StadiumBorder(),
      ),
    );
  }
}
