import 'package:flutter/material.dart';
import 'package:honganimation/screens/explicit_animations_screen.dart';
import 'package:honganimation/screens/implicit_animations_screen.dart';
import 'package:honganimation/screens/turf_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _goToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Animations'),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _goToPage(
                context,
                const ImplicitAnimationsScreen(),
              );
            },
            child: const Text('Implicit Animations'),
          ),
          ElevatedButton(
            onPressed: () {
              _goToPage(
                context,
                const ExplicitAnimationsScreen(),
              );
            },
            child: const Text('Explicit Animations'),
          ),
          ElevatedButton(
            onPressed: () {
              _goToPage(
                context,
                const TurfJS(),
              );
            },
            child: const Text('TurfJS'),
          ),
        ],
      )),
    );
  }
}
