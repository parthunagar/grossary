import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';


class OSPMapScreen extends StatefulWidget {
  const OSPMapScreen({Key key}) : super(key: key);

  @override
  _OSPMapScreenState createState() => _OSPMapScreenState();
}

class _OSPMapScreenState extends State<OSPMapScreen> {
  @override
  Widget build(BuildContext context) {
   return  Scaffold(
     // child: OSMFlutter(
     //    controler:mapController,
     //    currentLocation: false,
     //    road: Road(
     //      startIcon: MarkerIcon(
     //        icon: Icon(
     //          Icons.person,
     //          size: 64,
     //          color: Colors.brown,
     //        ),
     //      ),
     //      roadColor: Colors.yellowAccent,
     //    ),
     //    markerIcon: MarkerIcon(
     //      icon: Icon(
     //        Icons.person_pin_circle,
     //        color: Colors.blue,
     //        size: 56,
     //      ),
     //    ),
     //    initPosition: GeoPoint(latitude: 47.35387, longitude: 8.43609),
     //  ),
   );
  }
}
