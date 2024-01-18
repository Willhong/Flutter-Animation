import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honganimation/screens/interactive_hexagon_widget.dart';
import 'package:turf/extensions.dart';
import 'package:turf/turf.dart';

class Point {
  num x;
  num y;

  Point(this.x, this.y);
}

class Hexagon {
  num centerX;
  num centerY;
  num size;

  Hexagon(this.centerX, this.centerY, this.size);

  List<Offset> getVertices() {
    List<Offset> vertices = [];
    for (int i = 0; i < 6; i++) {
      num angle = 2 * math.pi / 6 * i;
      num x = centerX + size * math.cos(angle);
      num y = centerY + size * math.sin(angle);
      vertices.add(Offset(x as double, y as double));
    }
    return vertices;
  }
}

_LoadJSON() async {
  var json = await rootBundle.loadString('assets/mars.json');
  var data = jsonDecode(json);
  print(data);
  return data;
}

class TurfJS extends StatefulWidget {
  const TurfJS({super.key});

  @override
  State<TurfJS> createState() => _TurfJSState();
}

double longitudeDistance(double latitude) {
  return 111.32 * math.cos(latitude * math.pi / 180);
}

List<Hexagon> createHexGridWithinBBox(GeoJSONObject geoJson, num cellSide) {
  BBox bounds = bbox(geoJson); // Calculate the bounding box

  // Convert the BBox coordinates to a more usable form if necessary
  num minX = bounds.lng1; // Western longitude
  num minY = bounds.lat1; // Southern latitude
  num maxX = bounds.lng2; // Eastern longitude
  num maxY = bounds.lat2; // Northern latitude

  return createHexGrid(minX, minY, maxX, maxY, cellSide);
}

List<Hexagon> createHexGrid(
    num minX, num minY, num maxX, num maxY, num cellSide) {
  List<Hexagon> hexagons = [];

  // Approximate conversion of cellSide from kilometers to degrees
  double avgLatitude = (minY + maxY) / 2;
  double kmPerDegreeLong = longitudeDistance(avgLatitude);
  double kmPerDegreeLat = 110.574;

  double cellSideLong =
      cellSide / kmPerDegreeLong; // Cell side in degrees (longitude)
  double cellSideLat =
      cellSide / kmPerDegreeLat; // Cell side in degrees (latitude)

  // Calculate the horizontal and vertical distances between hexagon centers
  num hexHeight = math.sqrt(3) * cellSide;
  num hexWidth = 2 * cellSide;
  num vertDist = hexHeight * 0.75;
  num horizDist = hexWidth * 0.75;

  // Calculate the number of rows and columns
  int numRows = ((maxY - minY) / hexHeight).ceil();
  int numCols = ((maxX - minX) / horizDist).ceil();

  // Generate the hexagons
  for (int col = 0; col < numCols; col++) {
    for (int row = 0; row < numRows; row++) {
      // Offset every odd column downwards
      num yOffset = col % 2 == 0 ? 0 : hexHeight / 2;

      // Calculate the center of the hexagon
      num centerX = minX + col * horizDist;
      num centerY = minY + row * hexHeight + yOffset;

      hexagons.add(Hexagon(centerX, centerY, cellSide));
    }
  }

  return hexagons;
}

class _TurfJSState extends State<TurfJS> {
  var data;
  GeoJSONObject? geojson;
  List<Feature<GeometryObject>>? featureCollection = [];
  List<List<Hexagon>> hexagons = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJson();
  }

  void loadJson() async {
    data = await _LoadJSON();
    geojson = GeoJSONObject.fromJson(data);

    geojson!.featureEach((currentFeature, featureIndex) => {
          print(currentFeature),
          print(featureIndex),
          featureCollection!.add(currentFeature),
          createHex(currentFeature),
        });

    setState(() {});
  }

  bool isPointOnLine(
      double px, double py, double x1, double y1, double x2, double y2) {
    // get distance from the point to the two ends of the line
    var d1 = math.sqrt(math.pow(px - x1, 2) + math.pow(py - y1, 2));
    var d2 = math.sqrt(math.pow(px - x2, 2) + math.pow(py - y2, 2));

    // get the length of the line
    var lineLen = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2));

    // since floats are so minutely accurate, add
    // a little buffer zone that will give collision
    var buffer = 0.1; // higher # = less accurate

    // if the two distances are equal to the line's
    // length, the point is on the line!
    // note we use the buffer here to give a range,
    // rather than one #
    if (d1 + d2 >= lineLen - buffer && d1 + d2 <= lineLen + buffer) {
      return true;
    }
    return false;
  }

  bool isPointInPolygon(double x, double y, List<Position?> polygon) {
    for (var i = 0; i < polygon.length; i++) {
      var j = i + 1;
      if (j == polygon.length) {
        j = 0;
      }
      var xi = polygon[i]!.lng;
      var yi = polygon[i]!.lat;
      var xj = polygon[j]!.lng;
      var yj = polygon[j]!.lat;

      var onLine = isPointOnLine(
          x, y, xi as double, yi as double, xj as double, yj as double);
      if (onLine) {
        print('on line');
        return true;
      }

      var oddNodes = false;
      if ((yi < y && yj >= y) || (yj < y && yi >= y)) {
        if (xi + (y - yi) / (yj - yi) * (xj - xi) < x) {
          oddNodes = !oddNodes;
        }
      }

      if (oddNodes) {
        print('inside');
        return true;
      } else {
        print('outside');
        return false;
      }
    }
    return false;
  }

  void createHex(GeoJSONObject geojson) {
    var hexagons = createHexGridWithinBBox(geojson, 2);
    List<Position?> pos = geojson.coordAll();
    List<Hexagon> newhexagons = [];
    for (var hexagon in hexagons) {
      // if (isPointInPolygon(
      //     hexagon.centerX as double, hexagon.centerY as double, pos)) {
      //   newhexagons.add(hexagon);
      // }
      print('${hexagon.centerX} ${hexagon.centerY}');
    }

    setState(() {
      this.hexagons.add(hexagons);
    });
  }

  Feature<Polygon> poly = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position(0, 0),
        Position(2, 2),
        Position(0, 1),
        Position(0, 0),
      ],
      [
        Position(0, 0),
        Position(1, 1),
        Position(0, 1),
        Position(0, 0),
      ],
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TurfJS'),
      ),
      body: hexagons != null
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hexagons.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text('Hexagon ${index + 1}'),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: InteractiveHexagonWidget(hexagons[index])),
                  ],
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),

      // ListView(
      //   children: featureCollection != null
      //       ? featureCollection!
      //           .map(
      //             (e) => Container(
      //               decoration: BoxDecoration(
      //                 border: Border.all(
      //                   color: Colors.black,
      //                 ),
      //               ),
      //               child: Column(
      //                 children: e.properties!.entries
      //                     .map(
      //                       (e) => Text(
      //                         '${e.key}: ${e.value} ',
      //                       ),
      //                     )
      //                     .toList(),
      //               ),
      //             ),
      //           )
      //           .toList()
      //       : [],
      // ),
    );
  }
}
