import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0052CC);
  static const Color secondaryColor = Color(0xFF172B4D);
  static const Color backgroundColor = Color(0xFFF4F5F7);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFED8936);

  // Priority colors
  static const Color criticalColor = Color(0xFFE53E3E);
  static const Color highColor = Color(0xFFED8936);
  static const Color mediumColor = Color(0xFF3182CE);
  static const Color lowColor = Color(0xFF38A169);

  // Status colors
  static const Color todoColor = Color(0xFF718096);
  static const Color inProgressColor = Color(0xFF3182CE);
  static const Color inReviewColor = Color(0xFF805AD5);
  static const Color doneColor = Color(0xFF38A169);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return criticalColor;
      case 'HIGH':
        return highColor;
      case 'MEDIUM':
        return mediumColor;
      case 'LOW':
        return lowColor;
      default:
        return mediumColor;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'TO_DO':
        return todoColor;
      case 'IN_PROGRESS':
        return inProgressColor;
      case 'IN_REVIEW':
        return inReviewColor;
      case 'DONE':
        return doneColor;
      default:
        return todoColor;
    }
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case 'TO_DO':
        return 'To Do';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'IN_REVIEW':
        return 'In Review';
      case 'DONE':
        return 'Done';
      default:
        return status;
    }
  }

  static String getPriorityLabel(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return 'Critical';
      case 'HIGH':
        return 'High';
      case 'MEDIUM':
        return 'Medium';
      case 'LOW':
        return 'Low';
      default:
        return priority;
    }
  }
}
