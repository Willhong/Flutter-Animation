import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honganimation/define/land_list.dart';
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

_LoadJSON(String LandList) async {
  var json = await rootBundle.loadString('assets/area/$LandList');
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
  Map<String, List<Feature<GeometryObject>>?> featureCollection = {};
  List<List<Hexagon>> hexagons = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJson();
  }

  void loadJson() async {
    Map<String, GeoJSONObject> landGeoJson = {};
    for (var element in LandList) {
      var data = await _LoadJSON(element);
      landGeoJson[element] = (GeoJSONObject.fromJson(data));
    }
    for (var element in landGeoJson.values) {
      List<Feature<GeometryObject>>? newfeatureCollection = [];

      element.featureEach((currentFeature, featureIndex) => {
            print(currentFeature),
            print(featureIndex),
            newfeatureCollection.add(currentFeature),
          });

      featureCollection[landGeoJson.keys
              .elementAt(landGeoJson.values.toList().indexOf(element))] =
          newfeatureCollection;
    }

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

  bool isPointInPolygon(Position point, List<Position?> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i]!.lng > point.lng) != (polygon[j]!.lng > point.lng) &&
          (point.lat <
              (polygon[j]!.lat - polygon[i]!.lat) *
                      (point.lng - polygon[i]!.lng) /
                      (polygon[j]!.lng - polygon[i]!.lng) +
                  polygon[i]!.lat)) {
        inside = !inside;
      }
    }
    return inside;
  }

  void createHex(GeoJSONObject geojson) {
    var hexagons = createHexGridWithinBBox(geojson, 0.3868);
    List<Position?> pol = geojson.coordAll();
    List<Hexagon> newhexagons = [];
    for (var hexagon in hexagons) {
      Position pos = Position(hexagon.centerX, hexagon.centerY);
      if (isPointInPolygon(pos, pol)) {
        newhexagons.add(hexagon);
      }
      print('${hexagon.centerX} ${hexagon.centerY}');
    }

    setState(() {
      this.hexagons.add(newhexagons);
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
              itemCount: featureCollection.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text(
                        'Hexagon ${index + 1}, ${featureCollection.values.elementAt(index)!.length}'),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: InteractiveViewer(
                            maxScale: 100,
                            onInteractionStart: (details) {
                              print(details);
                            },
                            child: InteractiveHexagonWidget(
                              featureCollection[
                                  featureCollection.keys.elementAt(index)],
                            ))),
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
