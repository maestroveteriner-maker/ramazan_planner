import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seed = Color(0xFF6750A4);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF7F7FA),
  );
}

ThemeData buildDarkTheme() {
  const seed = Color(0xFF7C4DFF);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    useMaterial3: true,
  );
}
