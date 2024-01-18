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

  void createHex(GeoJSONObject geojson) {
    var hexagons = createHexGridWithinBBox(geojson, 1);
    print(hexagons);
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
              itemCount: hexagons.length,
              itemBuilder: (context, index) {
                return InteractiveHexagonWidget(hexagons[index]);
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
