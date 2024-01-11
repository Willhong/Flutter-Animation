import 'package:flutter/material.dart';

class ImplicitAnimationsScreen extends StatefulWidget {
  const ImplicitAnimationsScreen({super.key});

  @override
  State<ImplicitAnimationsScreen> createState() =>
      _ImplicitAnimationsScreenState();
}

class _ImplicitAnimationsScreenState extends State<ImplicitAnimationsScreen> {
  bool _visible = true;
  void _trigger() {
    setState(() {
      _visible = !_visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Implicit Animations'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AnimatedAlign(
            //   duration: const Duration(seconds: 1),
            //   curve: Curves.easeInOut,
            //   alignment: _visible ? Alignment.topLeft : Alignment.topRight,
            //   child: AnimatedOpacity(
            //     duration: const Duration(seconds: 1),
            //     opacity: _visible ? 1 : 0,
            //     child: Container(
            //       width: size.width * 0.8,
            //       height: size.width * 0.8,
            //       color: Colors.amber,
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // AnimatedContainer(
            //     transform: Matrix4.rotationZ(_visible ? 0 : 0.5),
            //     transformAlignment: Alignment.center,
            //     duration: const Duration(seconds: 1),
            //     curve: Curves.elasticOut,
            //     width: size.width * 0.8,
            //     height: size.width * 0.8,
            //     decoration: BoxDecoration(
            //       color: _visible ? Colors.amber : Colors.blue,
            //       borderRadius: BorderRadius.circular(_visible ? 0 : 100),
            //     )),
            // TweenAnimationBuilder(
            //   tween: ColorTween(
            //     begin: Colors.amber,
            //     end: Colors.blue,
            //   ),
            //   duration: const Duration(seconds: 10),
            //   curve: Curves.elasticOut,
            //   builder: (context, value, child) {
            //     return Image.network(
            //       'https://picsum.photos/200/300',
            //       color: value,
            //       colorBlendMode: BlendMode.colorBurn,
            //     );
            //   },
            //   child: Container(
            //     width: size.width * 0.8,
            //     height: size.width * 0.8,
            //     color: Colors.amber,
            //   ),
            // ),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: _visible ? 1 : 0),
              duration: const Duration(seconds: 10),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Column(
                  children: [
                    Text(
                      'Value: ${value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  ],
                );
              },
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                color: Colors.amber,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: _trigger,
              child: const Text('Animate'),
            ),
          ],
        ),
      ),
    );
  }
}
