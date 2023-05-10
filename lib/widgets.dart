import 'package:flutter/material.dart';

popUpWidget(
    {required String title,
    required SizedBox widget,
    required BuildContext context}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                height: 4,
                fontWeight: FontWeight.w800),
          ),
          content: widget,
        );
      });
}
