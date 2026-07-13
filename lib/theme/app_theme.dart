import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final textTheme = GoogleFonts.nunitoTextTheme().apply(
      bodyColor: AppColors.darkBrown,
      displayColor: AppColors.darkBrown,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamBrown,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bronzeTan,
        surface: AppColors.creamBrown,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
