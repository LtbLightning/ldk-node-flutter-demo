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

  return ThemeData(
      visualDensity: VisualDensity.comfortable,
      inputDecorationTheme: inputDecorationTheme());
}
