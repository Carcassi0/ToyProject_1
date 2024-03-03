import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.grey,
    background: Colors.grey,
    primary: Colors.grey,
    secondary: Colors.deepPurple,
    error: Colors.red
  )
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade900
  )

);



