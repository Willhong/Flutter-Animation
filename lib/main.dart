import 'package:flutter/material.dart';
import 'package:honganimation/screens/menu_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animations Demo',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
          )),
      home: const MenuScreen(),
    );
  }
}
