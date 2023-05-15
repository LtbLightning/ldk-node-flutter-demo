import 'package:flutter/material.dart';
import 'package:ldk_node_flutter_quickstart/screens/home.dart';

import 'styles/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LDK NODE FLUTTER TUTORIAL',
      theme: themeData(),
      home: const Home(),
    );
  }
}
