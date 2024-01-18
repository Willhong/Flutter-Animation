import 'package:flutter/material.dart';
import 'package:honganimation/screens/turf_screen.dart';

class HexagonPainter extends CustomPainter {
  final List<Hexagon> hexagons;
  final List<int> tapped;
  HexagonPainter(this.hexagons, this.tapped);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final paint2 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    int i = 0;
    for (var hexagon in hexagons) {
      var points = hexagon.getVertices();
      var path = Path()
        ..moveTo(points.last.dx * 8 + 50, points.last.dy * 8 + 100);
      for (var point in points) {
        path.lineTo(point.dx * 8 + 50, point.dy * 8 + 100);
      }
      path.close();
      if (tapped.contains(i)) {
        canvas.drawPath(path, paint2);
      } else {
        canvas.drawPath(path, paint);
      }
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
