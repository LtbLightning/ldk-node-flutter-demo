import 'package:flutter/material.dart';

ThemeData themeData() {
  InputDecorationTheme inputDecorationTheme() {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.blue.withOpacity(.2),
      ),
    );
    return InputDecorationTheme(
        labelStyle: TextStyle(
            color: Colors.black.withOpacity(.4),
            fontSize: 12,
            fontWeight: FontWeight.w500),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.blue.withOpacity(.01),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder);
  }

  var textTheme = const TextTheme(
      displayLarge: TextStyle(
          color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
      bodySmall: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black),
      displaySmall: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black),
      displayMedium: TextStyle(
          fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black));
  return ThemeData(
      secondaryHeaderColor: Colors.indigoAccent,
      visualDensity: VisualDensity.comfortable,
      textTheme: textTheme,
      inputDecorationTheme: inputDecorationTheme());
}
