import 'package:flutter/material.dart';
import 'package:honganimation/screens/turf_screen.dart';
import 'package:honganimation/utility/hexagon_painter.dart';

class InteractiveHexagonWidget extends StatefulWidget {
  final List<Hexagon> hexagons;

  const InteractiveHexagonWidget(this.hexagons, {super.key});

  @override
  _InteractiveHexagonWidgetState createState() =>
      _InteractiveHexagonWidgetState();
}

class _InteractiveHexagonWidgetState extends State<InteractiveHexagonWidget> {
  List<int> tapped = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        // Convert global position to local position
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);

        // Determine which hexagon is tapped
        Hexagon? tappedHexagon = _getTappedHexagon(localPosition);

        if (tappedHexagon != null) {}
        setState(() {});
      },
      child: CustomPaint(
        painter: HexagonPainter(widget.hexagons, tapped),
        child: const SizedBox(
          height: 500,
          width: 500,
        ),
      ),
    );
  }

  Hexagon? _getTappedHexagon(Offset tapPosition) {
    // Logic to determine which hexagon is tapped
    // This involves checking if the tapPosition falls within any hexagon's area
    int i = 0;
    for (var hexagon in widget.hexagons) {
      if (isPointInsideHexagon(tapPosition, hexagon)) {
        print('Tapped hexagon: ${hexagon.size}, $i');
        if (tapped.contains(i)) {
          tapped.remove(i);
        } else {
          tapped.add(i);
        }

        setState(() {
          tapped = tapped;
        });

        return hexagon;
      }
      i++;
    }
    return null;
  }

  bool isPointInsideHexagon(Offset point, Hexagon hexagon) {
    // Logic to determine if a point is inside a hexagon
    // This involves checking if the point falls within the hexagon's area
    // Hint: Use the hexagon's getVertices() method to get the hexagon's vertices
    // Hint: Use the Path class to create a path from the hexagon's vertices
    // Hint: Use the Path class's contains() method to check if the point falls within the path
    double x = point.dx;
    double y = point.dy;
    List<Offset> vertices = hexagon.getVertices();
    Path path = Path()
      ..moveTo(vertices.last.dx * 2 + 50, vertices.last.dy * 2 + 50);
    for (var vertex in vertices) {
      path.lineTo(vertex.dx * 2 + 50, vertex.dy * 2 + 100);
    }
    path.close();
    return path.contains(Offset(x, y));
  }
}
