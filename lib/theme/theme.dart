import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple.shade300,
    background: Colors.grey[300],
    // primary: Colors.deepPurple[200],
    secondary: Colors.deepPurple,
    error: Colors.red,
    outline: Colors.black
  )
);

ThemeData darkmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade700,
    secondary: Colors.grey.shade900,
    outline: Colors.white
  )

);



