import 'package:driver/Theme/colors.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter/material.dart';

//https://help.syncfusion.com/flutter/maps/vector-layers/polyline-layer
class MapScreen extends StatefulWidget {
   MapScreen({Key key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

   List<MapLatLng> polyline;
   List<List<MapLatLng>> polylines;
   MapZoomPanBehavior zoomPanBehavior;


   @override
   void initState() {
     polyline = <MapLatLng>[
       MapLatLng(13.0827, 80.2707),
       MapLatLng(13.1746, 79.6117),
       MapLatLng(13.6373, 79.5037),
       MapLatLng(14.4673, 78.8242),
       MapLatLng(14.9091, 78.0092),
       MapLatLng(16.2160, 77.3566),
       MapLatLng(17.1557, 76.8697),
       MapLatLng(18.0975, 75.4249),
       MapLatLng(18.5204, 73.8567),
       MapLatLng(19.0760, 72.8777),
     ];

     polylines = <List<MapLatLng>>[polyline];
     zoomPanBehavior = MapZoomPanBehavior(
       zoomLevel: 5,
       focalLatLng: MapLatLng(20.3173, 78.7139),
     );
     super.initState();
   }


   @override
  Widget build(BuildContext context) {
     return Scaffold(
       body: SfMaps(
         layers: [
           MapTileLayer(
             urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
             sublayers: [
               MapPolylineLayer(
                 width: 3,
                 polylines: List<MapPolyline>.generate(
                   polylines.length,
                       (int index) {
                     return MapPolyline(
                       points: polylines[index],
                       color: kRedLightColor,
                     );
                   },
                 ).toSet(),
               ),
             ],
             zoomPanBehavior: zoomPanBehavior,
           ),
         ],
       ),
     );
  }
}
