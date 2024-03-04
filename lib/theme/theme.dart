import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple.shade300,
    background: Colors.grey[300],
    primary: Colors.deepPurple[300],
    secondary: Colors.deepPurple,
    error: Colors.red
  )
);

ThemeData darkmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade700,
    secondary: Colors.grey.shade900
  )

);



