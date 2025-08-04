import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,  // Inverted from shade900
    primary: Colors.grey.shade400,  // Inverted from shade600
    secondary: Colors.grey.shade300,  // Inverted from shade700
    tertiary: Colors.grey.shade200,  // Inverted from shade800
    inversePrimary: Colors.grey.shade700,  // Inverted from shade300
  ),
);