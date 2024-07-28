import 'dart:async';
import 'dart:convert';
import 'package:driver/Components/customer_switch.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Map/flutter_map.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/Map/google_map_screen.dart';
import 'package:driver/Pages/orderpage/todayorder.dart';
import 'package:driver/Pages/orderpage/tomorroworder.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/driverstatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:driver/Map/sf_Map.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter/material.dart';

import '../Theme/colors.dart';
import '../Theme/colors.dart';
import '../Theme/colors.dart';
import '../Theme/colors.dart';
import '../Theme/colors.dart';
import '../Theme/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  // TODO: Variable

  static const LatLng _center = const LatLng(90.0, 90.0);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var bitmapImage;

  // bool btn_order = false;
  CameraPosition kGooglePlex = CameraPosition(
    target: _center,
    zoom: 25.151926,
  );
  Completer<GoogleMapController> _controller = Completer();
  dynamic lat;
  dynamic lng;
  bool isOffline = true;
  var http = Client();
  int totalOrder = 0;
  double totalincentives = 0.0;
  dynamic apCurency;

  var isRun = false;

  void updateStatus(int status) async {
    setState(() {
      isRun = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('$updateStatusUri  ' +
        'dboy_id : ' +
        '${prefs.getInt('db_id')}' +
        'status : ' +
        '$status');
    http.post(updateStatusUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      'status': '$status'
    }).then((value) {
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        prefs.setInt('online_status', status);
        if (status == 0) {
          setState(() {
            isOffline = true;
            isRun = false;
          });
        } else {
          setState(() {
            isOffline = false;
            isRun = false;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    getDrierStatus();
    _createMarkerImageFromAsset("assets/images/arrow6.png");
  }

  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRun = true;
      apCurency = prefs.getString('app_currency');
    });
    if (prefs.containsKey('online_status')) {
      if (prefs.getInt('online_status') == 1) {
        setState(() {
          isOffline = false;
        });
      } else {
        setState(() {
          isOffline = true;
        });
      }
    } else {
      setState(() {
        isOffline = true;
      });
    }
    print('$driverStatusUri ' + 'dboy_id : ' + '${prefs.getInt('db_id')}');
    http.post(driverStatusUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        DriverStatus dstatus = DriverStatus.fromJson(jsonDecode(value.body));
        if ('${dstatus.status}' == '1') {
          int onoff = int.parse('${dstatus.onlineStatus}');
          prefs.setInt('online_status', onoff);
          if (onoff == 1) {
            setState(() {
              isOffline = false;
            });
          } else {
            setState(() {
              isOffline = true;
            });
          }
          totalOrder = int.parse('${dstatus.totalOrders}');
          totalincentives = double.parse('${dstatus.totalIncentive}');
        }
      }
      setState(() {
        isRun = false;
      });
    }).catchError((e) {
      setState(() {
        isRun = false;
      });
      print(e);
    });
  }


  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      // floatingActionButton: !isOffline
      //     ? FloatingActionButton(
      //         foregroundColor: Colors.white,
      //         child: Icon(
      //           Icons.format_list_bulleted,
      //           size: 28,
      //         ),
      //         onPressed: () {
      //           Navigator.pushNamed(context, PageRoutes.newDeliveryPage);
      //         })
      //     : SizedBox.shrink(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: AppBar(
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.openDrawer();
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Card(
                    color: kWhiteColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal:
                              MediaQuery.of(context).size.width * 0.022),
                      child: Image.asset(
                        "assets/images/awesome_align_right.png",
                        height: 10,
                        width: 10,
                      ),
                    )),
              ),
            ),
            title: Text(
              // isOffline
              //     ? locale.youReOffline.toUpperCase()
              //     : locale.youReOnline.toUpperCase(),
              isOffline ? locale.youReOffline : locale.youReOnline,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    // fontWeight: FontWeight.w600,
                    fontSize: 18, fontFamily: 'Philosopher-Regular',
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: <Widget>[
              isRun
                  ? CupertinoActivityIndicator(
                      radius: 15,
                    )
                  : Container(),
              Container(
                // color: kRedColor,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  bottom: MediaQuery.of(context).size.height * 0.02,
                ),
                child: CustomSwitch(
                  activeColor: theme.primaryColor,
                  value: isOffline,
                  onChanged: (value) {
                    print("VALUE : $value");
                    setState(() {
                      // isOffline = value;
                      if (isOffline) {
                        updateStatus(1);
                      } else {
                        updateStatus(0);
                      }
                    });
                  },
                ),
              ),
              // Padding(
              //     padding: EdgeInsets.all(12.0),
              //     child: InkWell(
              //       onTap: () {
              //         // setState(() {
              //         //   isOffline = !isOffline;
              //         // });
              //         if (isOffline) {
              //           updateStatus(1);
              //         } else {
              //           updateStatus(0);
              //         }
              //       },
              //       child: AnimatedContainer(
              //         duration: Duration(milliseconds: 250),
              //         width: 104,
              //         padding: EdgeInsets.symmetric(vertical: 8),
              //         child: Text(
              //           isOffline
              //               ? locale.goOnline.toUpperCase()
              //               : locale.goOffline.toUpperCase(),
              //           textAlign: TextAlign.center,
              //           style: TextStyle(color: theme.scaffoldBackgroundColor),
              //         ),
              //         decoration: BoxDecoration(
              //           color:
              //               isOffline ? theme.primaryColor : Color(0xffff452c),
              //           borderRadius: BorderRadius.circular(30),
              //         ),
              //       ),
              //     )),
            ],
          ),
        ),
      ),
      drawer: AccountDrawer(context),
      body: Stack(
        children: <Widget>[
          // Container(
          //     decoration: BoxDecoration(
          //         image: DecorationImage(
          //             image: AssetImage("assets/mapdelivery.png"),
          //             fit: BoxFit.cover))),

          // *********************** Google Map *********************** //


          // ********************************************************** //
          MapView(),
          //*********************** Get Live Location With Google Map**********************//
          // Stack(
          //   children: [
          //     GoogleMap(
          //       mapType: MapType.normal,
          //       initialCameraPosition: kGooglePlex,
          //       zoomControlsEnabled: false,
          //       myLocationButtonEnabled: false,
          //       compassEnabled: false,
          //       mapToolbarEnabled: false,
          //       buildingsEnabled: false,
          //       // markers: _createMarker(),
          //       liteModeEnabled: true,
          //       onMapCreated: (GoogleMapController controller) {
          //         _controller.complete(controller);
          //       },
          //     ),
          //     Center(
          //       child: Image.asset(
          //         "assets/images/arrow6.png",
          //         height: 130,
          //         width: 130,
          //       ),
          //     ),
          //   ],
          // ),
          //****************************************************************************//

          isOffline
              ? Container(
                  color: kRoundButtonInButton2,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Flexible(
                        child: Text(locale.youAreOffline,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: kDarkColor)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Flexible(
                        child: Text(locale.goOnlineStartAcceptingJobs,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: kDarkColor)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          Positioned(
              bottom: 1,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.only(top: 10),
                color: kButtonColor,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(50)),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => MapScreen()));
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return TodayOrder();
                                      }));
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    // child: Card(
                                    //   color: Colors.grey[200],
                                    //   elevation: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kRedLightColor,
                                          border:
                                              Border.all(color: kRedLightColor),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            "assets/images/calender_icon.png",
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Flexible(
                                            child: Text(
                                              locale.todayorder,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: kWhiteColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // ),
                                ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => PolylinePage()));

                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return TomorrowOrder();
                                      }));
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    // child: Card(
                                    //   color: Colors.grey[200],
                                    //   elevation: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border:
                                              Border.all(color: kRedLightColor),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              // height: 50,
                                              // padding: EdgeInsets.all(8.0),
                                              // decoration: BoxDecoration(color: kGrey,borderRadius: BorderRadius.all(Radius.circular(20))),
                                              child: Image.asset(
                                            "assets/images/calender_icon.png",
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                          )),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                              locale.nextdayorder,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: kRedLightColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                // )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        color: kWhiteColor,
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.03),
                        // margin: EdgeInsets.symmetric(horizontal: 20.0),
                        // decoration: BoxDecoration(
                        //     color: theme.scaffoldBackgroundColor,
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.grey,
                        //         offset: Offset(0.0, 2.0), //(x,y)
                        //         blurRadius: 6.0,
                        //       ),
                        //     ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            buildRowChild(theme, locale.orders, '$totalOrder'),
                            Container(
                              width: 1,
                              height: MediaQuery.of(context).size.height * 0.07,
                              color: kButtonBorderColor,
                            ),
                            // buildRowChild(theme, '68 km', locale.ride),
                            buildRowChild(theme, locale.earnings,
                                '$apCurency $totalincentives'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Animated
          // )
        ],
      ),
    );
  }

  void _getLocation() async {
    var locale = AppLocalizations.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .then((position) {
          Timer(Duration(seconds: 3), () async {
            double lat = position.latitude;
            double lng = position.longitude;
            setLocation(lat, lng);
          });
        });

        Geolocator.getPositionStream(
                distanceFilter: 10, intervalDuration: Duration(seconds: 10))
            .listen((positionNew) {
          double lat = positionNew.latitude;
          double lng = positionNew.longitude;
          print('$lat - $lng');
          setLocation(lat, lng);
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show(locale.locationPermissionIsRequired, context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show(locale.locationPermissionIsRequired, context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show(locale.locationPermissionIsRequired, context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show(locale.locationPermissionIsRequired, context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String iconPath) async {
    ImageConfiguration configuration = ImageConfiguration(size: Size(32, 32));
    bitmapImage =
        await BitmapDescriptor.fromAssetImage(configuration, iconPath);
    return bitmapImage;
  }

  Set<Marker> _createMarker() {
    return {
      Marker(
        markerId: MarkerId("marker_2"),
        position: LatLng(lat ?? 90.0, lng ?? 90.0),
        icon: bitmapImage,
      ),
    };
  }

  setLocation(lats, lngs) async {
    // print('state - ${scfoldKey.currentState}');
    GoogleMapController controller = await _controller.future;
    setState(() {
      lat = lats;
      lng = lngs;
      kGooglePlex = CameraPosition(
        target: LatLng(lats, lngs),
        zoom: 21.151926,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
    });
  }
}

Column buildRowChild(ThemeData theme, String text1, String text2,
    {CrossAxisAlignment alignment}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: alignment ?? CrossAxisAlignment.center,
    children: <Widget>[
      Flexible(
        child: Text(
          text1,
          textAlign: TextAlign.start,
          style:
              theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 8.0,
      ),
      Flexible(
        child: Text(
          text2,
          textAlign: TextAlign.start,
          style: theme.textTheme.headline6.copyWith(
            color: kRedLightColor, fontWeight: FontWeight.bold,
            // fontSize: 17
          ),
        ),
      ),
    ],
  );
}
