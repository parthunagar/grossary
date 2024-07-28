import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class PolylinePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var points = <LatLng>[
      LatLng(21.170240, 72.831062),
      LatLng(22.308155, 70.800705),
      LatLng(22.308155, 70.800705),
      LatLng(48.8566, 2.3522),
    ];

    var pointsGradient = <LatLng>[
      LatLng(55.5, -0.09),
      LatLng(54.3498, -6.2603),
      LatLng(52.8566, 2.3522),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Polylines')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 8.0, bottom: 8.0), child: Text('Polylines')),
            Flexible(
              child: FlutterMap(
                options: MapOptions(center: LatLng(51.5, -0.09), zoom: 5.0),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c']),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(points: points, strokeWidth: 4.0, color: Colors.purple),
                    ],
                  ),
                  // PolylineLayerOptions(
                  //   polylines: [
                  //     Polyline(
                  //       points: pointsGradient,
                  //       strokeWidth: 4.0,
                  //       gradientColors: [
                  //         Color(0xffE40203),
                  //         Color(0xffFEED00),
                  //         Color(0xff007E2D),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}