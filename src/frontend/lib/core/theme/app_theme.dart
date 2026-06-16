import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF111827);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1F5F9);

  static const Color title = Color(0xFF0F172A);
  static const Color text = Color(0xFF1E293B);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const Color moneyGreen = Color(0xFF16A34A);
  static const Color moneyGreenSoft = Color(0xFFDCFCE7);

  static const Color cancelRed = Color(0xFFDC2626);
  static const Color cancelRedSoft = Color(0xFFFEE2E2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: surfaceSoft,
      onPrimaryContainer: primary,
      secondary: muted,
      onSecondary: Colors.white,
      secondaryContainer: surfaceSoft,
      onSecondaryContainer: title,
      tertiary: moneyGreen,
      onTertiary: Colors.white,
      error: cancelRed,
      onError: Colors.white,
      errorContainer: cancelRedSoft,
      onErrorContainer: cancelRed,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: title,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: title,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: title),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: title,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: title,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          color: title,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          color: title,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        titleMedium: TextStyle(
          color: title,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        titleSmall: TextStyle(
          color: title,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(
          color: text,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: text,
          fontSize: 14,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: muted,
          fontSize: 12,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: muted,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: muted,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: cancelRed,
            width: 1.4,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: cancelRed,
            width: 1.8,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: surfaceSoft,
          disabledForegroundColor: muted,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: surfaceSoft,
          disabledForegroundColor: muted,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: surface,
          foregroundColor: title,
          side: const BorderSide(
            color: border,
            width: 1.2,
          ),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cancelRed,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: title,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoft,
        selectedColor: surfaceSoft,
        labelStyle: const TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: title,
          fontWeight: FontWeight.w800,
        ),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        iconColor: title,
        titleTextStyle: TextStyle(
          color: title,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        subtitleTextStyle: TextStyle(
          color: muted,
          fontSize: 13,
          height: 1.35,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: title,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        titleTextStyle: const TextStyle(
          color: title,
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(
          color: text,
          fontSize: 15,
          height: 1.45,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: surfaceSoft,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: title);
          }

          return const IconThemeData(color: muted);
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceSoft,
        circularTrackColor: surfaceSoft,
      ),
    );
  }
}