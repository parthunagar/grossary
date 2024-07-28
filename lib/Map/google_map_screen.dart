import 'package:driver/Const/google_map_key.dart';
import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:toast/toast.dart';
import 'dart:async';

//https://blog.codemagic.io/creating-a-route-calculator-using-google-maps/
//https://github.com/sbis04/flutter_maps/blob/master/lib/main.dart

//https://github.com/rajayogan/flutter-googlemaps-routes/blob/master/lib/main.dart

//Map Box
//https://docs.mapbox.com/help/getting-started/directions/    // see doc only

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  //TODO: Variable

  //apply key in Screen
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Initial Camara Position
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  // current location
  Position _currentPosition;
  String _currentAddress = '';

  // start location
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  // end location
  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  // start/end address and find distance
  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  // marker declaration
  Set<Marker> markers = {};

  // Draw route direction on map
  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  //TODO: Method

  // Method for Create TextField  Widget
  Widget _textField({
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
      });
      await _getAddress();
    }).catchError((e) {
      print('_getCurrentLocation => ERROR : $e');
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
      print("P : " + p.toString());
      Placemark place = p[0];
      print("place : " + place.toString());
      setState(() {
        print("place.name : " + place.name.toString());
        print("place.locality : " + place.locality.toString());
        print("place.locality : " + place.locality.toString());
        print("place.country : " + place.country.toString());
        _currentAddress = "${place.name}, ${place.locality}, ${place.locality}, ${place.country}";
        print("_currentAddress : " + _currentAddress.toString());
        startAddressController.text = _currentAddress;
        print("startAddressController.text : " + startAddressController.text.toString());
        _startAddress = _currentAddress;
        print("_startAddress : " + _startAddress.toString());
      });
    } catch (e) {
      print("_getAddress ERROR : " + e.toString());
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      print("startPlacemark : " + startPlacemark.toString());
      List<Location> destinationPlacemark = await locationFromAddress(_destinationAddress);
      print("destinationPlacemark : " + destinationPlacemark.toString());
      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress ? _currentPosition.latitude : startPlacemark[0].latitude;//21.170240;
      print("startLatitude : " + startLatitude.toString());

      double startLongitude = _startAddress == _currentAddress ? _currentPosition.longitude : startPlacemark[0].longitude;// 72.831062;

      print("startLongitude : " + startLongitude.toString());
      double destinationLatitude = destinationPlacemark[0].latitude;// 22.303894;
      print("destinationLatitude : " + destinationLatitude.toString());
      double destinationLongitude = destinationPlacemark[0].longitude;// 70.802162;
      print("destinationLongitude : " + destinationLongitude.toString());

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      print("startCoordinatesString : " + startCoordinatesString.toString());
      String destinationCoordinatesString = '($destinationLatitude, $destinationLongitude)';
      print("destinationCoordinatesString : " + destinationCoordinatesString.toString());

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(title: 'Start $startCoordinatesString', snippet: _startAddress),
        icon: BitmapDescriptor.defaultMarker);

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(title: 'Destination $destinationCoordinatesString', snippet: _destinationAddress),
        icon: BitmapDescriptor.defaultMarker);

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);

      print('START COORDINATES: ($startLatitude, $startLongitude)');
      print('DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)');

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude) ? startLatitude : destinationLatitude;
      print("miny : " + miny.toString());
      double minx = (startLongitude <= destinationLongitude) ? startLongitude : destinationLongitude;
      print("minx : " + minx.toString());
      double maxy = (startLatitude <= destinationLatitude) ? destinationLatitude : startLatitude;
      print("maxy : " + maxy.toString());
      double maxx = (startLongitude <= destinationLongitude) ? destinationLongitude : startLongitude;
      print("maxx : " + maxx.toString());

      double southWestLatitude = miny;
      print("southWestLatitude : " + southWestLatitude.toString());
      double southWestLongitude = minx;
      print("southWestLongitude : " + southWestLongitude.toString());

      double northEastLatitude = maxy;
      print("northEastLatitude : " + northEastLatitude.toString());
      double northEastLongitude = maxx;
      print("northEastLongitude : " + northEastLongitude.toString());

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(LatLngBounds(northeast: LatLng(northEastLatitude, northEastLongitude), southwest: LatLng(southWestLatitude, southWestLongitude)), 100.0),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );
      // print("distanceInMeters : " + distanceInMeters.toString());

      await _createPolylines(startLatitude, startLongitude, destinationLatitude, destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        print("polylineCoordinates : " + polylineCoordinates.toString());
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
        print("totalDistance : " + totalDistance.toString());
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print("_calculateDistance ERROR : " + e.toString());
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    print("startLatitude : " + startLatitude.toString());
    print("startLongitude : " + startLongitude.toString());
    print("destinationLatitude : " + destinationLatitude.toString());
    print("destinationLongitude : " + destinationLongitude.toString());
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
      // wayPoints: [PolylineWayPoint(location: "Surat")]
    );

    if (result.points.isNotEmpty) {
      print("result.points : " + result.points.toString());
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: kRedLightColor,
        points: polylineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        jointType: JointType.round);
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: _textField(
                                  label: 'Start',
                                  hint: 'Choose starting point',
                                  // prefixIcon: Icon(Icons.looks_one),
                                  // suffixIcon: IconButton(
                                  //   icon: Icon(Icons.my_location),
                                  //   onPressed: () {
                                  //     startAddressController.text = _currentAddress;
                                  //     _startAddress = _currentAddress;
                                  //   },
                                  // ),
                                  controller: startAddressController,
                                  focusNode: startAddressFocusNode,
                                  width: width,
                                  locationCallback: (String value) {
                                    setState(() {
                                      _startAddress = value;
                                    });
                                  }),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _textField(
                                  label: 'Destination',
                                  hint: 'Choose destination',
                                  // prefixIcon: Icon(Icons.looks_two),
                                  controller: destinationAddressController,
                                  focusNode: desrinationAddressFocusNode,
                                  width: width,
                                  locationCallback: (String value) {
                                    setState(() {
                                      _destinationAddress = value;
                                    });
                                  }),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: (_startAddress != '' &&
                                  _destinationAddress != '')
                              ? () async {
                                  startAddressFocusNode.unfocus();
                                  desrinationAddressFocusNode.unfocus();
                                  setState(() {
                                    if (markers.isNotEmpty) markers.clear();
                                    if (polylines.isNotEmpty) polylines.clear();
                                    if (polylineCoordinates.isNotEmpty)
                                      polylineCoordinates.clear();
                                    print("_placeDistance : " +
                                        _placeDistance.toString());
                                    _placeDistance = null;
                                  });

                                  _calculateDistance().then((isCalculated) {
                                    print("isCalculated : " +
                                        isCalculated.toString());
                                    if (isCalculated) {
                                      Toast.show(
                                          "Distance Calculated Sucessfully",
                                          context,
                                          gravity: Toast.CENTER,
                                          duration: Toast.LENGTH_SHORT);
                                    } else {
                                      Toast.show(
                                          "Error Calculating Distance", context,
                                          gravity: Toast.CENTER,
                                          duration: Toast.LENGTH_SHORT);
                                    }
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Show Route',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:driver/Components/custom_button.dart';
// import 'package:driver/Locale/locales.dart';
// import 'package:driver/Routes/routes.dart';
// import 'package:driver/Theme/colors.dart';
// import 'package:driver/baseurl/baseurlg.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:grouped_buttons/grouped_buttons.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../language_cubit.dart';
//
// class ChooseLanguage extends StatefulWidget {
//   @override
//   _ChooseLanguageState createState() => _ChooseLanguageState();
// }
//
// class _ChooseLanguageState extends State<ChooseLanguage> {
//   LanguageCubit _languageCubit;
//   bool islogin = false;
//   String selectedLanguage, language;
//
//   var userName;
//   dynamic emailAddress;
//   dynamic mobileNumber;
//   dynamic _image;
//
//   @override
//   void initState() {
//     super.initState();
//     getSharedValue();
//     _languageCubit = BlocProvider.of<LanguageCubit>(context);
//   }
//
//   String getLanguage(BuildContext context) {
//     String language;
//     BlocProvider<LanguageCubit>(
//       create: (context) => LanguageCubit(),
//       child: BlocBuilder<LanguageCubit, Locale>(
//         // ignore: missing_return
//         builder: (_, locale) {
//           print('local  : ' + locale.toString());
//           language = locale.toString();
//         },
//       ),
//     );
//     return language;
//   }
//
//   void getSharedValue() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userName = prefs.getString('user_name');
//       emailAddress = prefs.getString('user_email');
//       mobileNumber = prefs.getString('user_phone');
//       _image = '$imagebaseUrl${prefs.getString('user_image')}';
//       islogin = prefs.getBool('islogin');
//       language = prefs.getString('language');
//       print('lang :' + language);
//     });
//   }
//
//   void getSelectedLanguage(List<String> languages) {
//     print('lang :' + language);
//     if (language == 'en') {
//       selectedLanguage = languages[0];
//     } else if (language == 'fr') {
//       selectedLanguage = languages[3];
//     } else if (language == 'es') {
//       selectedLanguage = languages[1];
//     } else if (language == 'pt') {
//       selectedLanguage = languages[2];
//     } else if (language == 'ar') {
//       selectedLanguage = languages[4];
//     } else if (language == 'id') {
//       selectedLanguage = languages[5];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var locale = AppLocalizations.of(context);
//     List<String> languages = [
//       locale.englishh,
//       locale.spanishh,
//       locale.portuguesee,
//       locale.frenchh,
//       locale.arabicc,
//       locale.indonesiann,
//     ];
//     getSelectedLanguage(languages);
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/language_back.png"),
//             fit: BoxFit.fitHeight,
//           ),
//         ),
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 50),
//               child: Image.asset(
//                 'assets/logo_big.png',
//                 height: 120,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                   top: 20.0, left: 16, right: 16, bottom: 16),
//               child: Text(
//                 locale.selectPreferredLanguage,
//                 style: Theme.of(context).textTheme.subtitle2.copyWith(
//                     fontSize: 14,
//                     fontWeight: FontWeight.normal,
//                     color: kSearchIconColour),
//               ),
//             ),
//             RadioGroup(selectedLanguage),
//             Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CustomButton(
//                   color: kRoundButton,
//                   iconGap: 12,
//                   label: locale.save,
//                   onTap: () async {
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     String selected = prefs.getString("languageSelected");
//                     print(selected);
//                     if (selected == locale.englishh) {
//                       _languageCubit.selectEngLanguage();
//                       prefs.setString("languageSelected", null);
//                     } else if (selected == locale.arabicc) {
//                       _languageCubit.selectArabicLanguage();
//                       prefs.setString("languageSelected", null);
//                     } else if (selected == locale.portuguesee) {
//                       _languageCubit.selectPortugueseLanguage();
//                       prefs.setString("languageSelected", null);
//                     } else if (selected == locale.frenchh) {
//                       _languageCubit.selectFrenchLanguage();
//                       prefs.setString("languageSelected", null);
//                     } else if (selected == locale.spanishh) {
//                       _languageCubit.selectSpanishLanguage();
//                       prefs.setString("languageSelected", null);
//                     } else if (selected == locale.indonesiann) {
//                       _languageCubit.selectIndonesianLanguage();
//                       prefs.setString("languageSelected", null);
//                     }
//                     // Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//             Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class RadioGroup extends StatefulWidget {
//   String selectedLanguage;
//
//   RadioGroup(String selectedLanguage) {
//     this.selectedLanguage = selectedLanguage;
//   }
//
//   @override
//   RadioGroupWidget createState() => RadioGroupWidget(selectedLanguage);
// }
//
// class NumberList {
//   String number;
//   int index;
//
//   NumberList({this.number, this.index});
// }
//
// class RadioGroupWidget extends State {
// // Default Radio Button Selected Item.
//   String radioItemHolder;
//
//   // Group Value for Radio Button.
//   int id;
//
//   RadioGroupWidget(String selectedLanguage) {
//     this.radioItemHolder = selectedLanguage;
//   }
//
//   Widget build(BuildContext context) {
//     var locale = AppLocalizations.of(context);
//     if (radioItemHolder == locale.englishh) {
//       id = 1;
//     } else if (radioItemHolder == locale.spanishh) {
//       id = 2;
//     } else if (radioItemHolder == locale.portuguesee) {
//       id = 3;
//     } else if (radioItemHolder == locale.frenchh) {
//       id = 4;
//     } else if (radioItemHolder == locale.arabicc) {
//       id = 5;
//     } else if (radioItemHolder == locale.indonesiann) {
//       id = 6;
//     }
//
//     List<NumberList> nList = [
//       NumberList(
//         index: 1,
//         number: locale.englishh,
//       ),
//       NumberList(
//         index: 2,
//         number: locale.spanishh,
//       ),
//       NumberList(
//         index: 3,
//         number: locale.portuguesee,
//       ),
//       NumberList(
//         index: 4,
//         number: locale.frenchh,
//       ),
//       NumberList(
//         index: 5,
//         number: locale.arabicc,
//       ),
//       NumberList(
//         index: 6,
//         number: locale.indonesiann,
//       ),
//     ];
//     return Column(
//       children: nList
//           .map((data) => GestureDetector(
//                 onTap: () async {
//                   setState(() {
//                     radioItemHolder = data.number;
//                     id = data.index;
//                   });
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   prefs.setString("languageSelected", data.number);
//                 },
//                 child: RadioListTile(
//                   title: Text(
//                     "${data.number}",
//                     style: Theme.of(context).textTheme.subtitle1.copyWith(
//                         fontSize: 16,
//                         fontWeight: radioItemHolder == data.number
//                             ? FontWeight.bold
//                             : FontWeight.normal),
//                   ),
//                   groupValue: id,
//                   value: data.index,
//                   onChanged: (val) async {
//                     setState(() {
//                       radioItemHolder = data.number;
//                       id = data.index;
//                     });
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.setString("languageSelected", data.number);
//                   },
//                 ),
//               ))
//           .toList(),
//     );
//   }
// }
