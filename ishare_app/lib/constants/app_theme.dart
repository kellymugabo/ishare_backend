import 'package:flutter/material.dart';

// 💎 UNIFIED DESIGN SYSTEM
class AppTheme {
  // Brand Palette
  static const primaryBlue = Color(0xFF0077B6); // Deep Blue
  static const primaryDark = Color(0xFF023E8A); // Darker shade
  
  // ✅ ADDED: This fixes the "undefined getter 'deepBlue'" error
  static const deepBlue = primaryDark; 
  
  static const accentTeal = Color(0xFF00B4D8);  // Cyan
  static const accentPurple = Color(0xFF90E0EF); // Light Blue
  static const softBlue = Color(0xFFCAF0F8); // Lightest Blue
  static const successGreen = Color(0xFF10B981);

  // Backgrounds
  static const surfaceGrey = Color(0xFFF1F5F9); 
  static const pureWhite = Colors.white;

  // Typography
  static const textDark = Color(0xFF1E293B); 
  static const textGrey = Color(0xFF64748B); 
  
  // Shadows
  static final softShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 15),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF1E293B).withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 5),
      spreadRadius: 0,
    ),
  ];

  static final cardDecoration = BoxDecoration(
    color: pureWhite,
    borderRadius: BorderRadius.circular(28), 
    boxShadow: softShadow,
    border: Border.all(color: Colors.white, width: 2), 
  );

  static final inputDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16), 
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ],
    border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
  );
}