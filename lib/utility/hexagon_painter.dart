import 'package:flutter/material.dart';
import 'package:turf/extensions.dart';
import 'package:turf/turf.dart';

class HexagonPainter extends CustomPainter {
  final List<Feature<GeometryObject>>? hexagons;
  final List<int> tapped;
  HexagonPainter(this.hexagons, this.tapped);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(8, 8);
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1;
    final paint2 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1;
    int i = 0;
    //기준 좌표 첫번쨰 헥사곤의 첫번째 좌표
    var firstPointLat = hexagons![0].geometry!.coordAll()[0]!.lat;
    var firstPointLng = hexagons![0].geometry!.coordAll()[0]!.lng;

    for (var element in hexagons!) {
      var points = element.geometry!.coordAll();
      List<Position> newpoints = [];
      for (var point in points) {
        newpoints.add(
          Position(
            point!.lng - firstPointLng + 10,
            point.lat - firstPointLat + 20,
          ),
        );
      }
      var path = Path()
        ..moveTo((newpoints[0].lng as double), (newpoints[0].lat as double));
      for (var point in newpoints) {
        path.lineTo((point.lng as double), (point.lat as double));
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
