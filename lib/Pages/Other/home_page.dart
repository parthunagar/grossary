import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/locpage/locationpage.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/beanmodel/appnotice/appnotice.dart';
import 'package:groshop/beanmodel/banner/bannerdeatil.dart';
import 'package:groshop/beanmodel/category/topcategory.dart';
import 'package:groshop/beanmodel/deal/dealproduct.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:groshop/nav_bloc/navigation_bloc.dart';
import 'package:http/http.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'dart:developer' as logger;

class HomePage extends StatefulWidget with NavigationStates {
  @override
  _HomePageState createState() => _HomePageState();
}
BuildContext contextmain;

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _current = 0;
  bool islogin = false;
  dynamic _scanBarcode;
  String store_id = '';
  String storeName = '';
  String shownMessage = '';
  StoreFinderData storeFinderData;
  List<BannerDataModel> bannerList = [];
  List<WhatsNewDataModel> whatsNewList = [];
  List<WhatsNewDataModel> recentSaleList = [];
  List<WhatsNewDataModel> topSaleList = [];
  List<DealProductDataModel> dealProductList = [];
  List<TopCategoryDataModel> topCategoryList = [];
  List<WishListDataModel> wishModel = [];

  dynamic userName;
  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;

  bool bannerLoading = true;
  bool topCatLoading = true;
  bool topSellingLoading = true;
  bool whatsnewLoading = true;
  bool recentSaleLoading = true;
  bool dealProductLoading = true;

  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(40.866813, 34.566688),
    zoom: 19.151926,
  );
  String currentAddress = "";
  Completer<GoogleMapController> _controller = Completer();

  String apCurrency;

  String appnoticetext = '';
  bool appnoticeStatus = false;
  List<Color> colors1 = [kCategoryColor1, kCategoryColor2, kCategoryColor3, kCategoryColor4];
  List<Color> colors2 = [kCategoryColor11, kCategoryColor22, kCategoryColor33, kCategoryColor44];

  Future<void> _goToTheLake(lat, lng) async {
    // final CameraPosition _kLake = CameraPosition(
    //     bearing: 192.8334901395799,
    //     target: LatLng(lat, lng),
    //     tilt: 59.440717697143555,
    //     zoom: 19.151926040649414);
    setState(() {
      this.lat = lat;
      this.lng = lng;
    });
    kGooglePlex = CameraPosition(target: LatLng(lat, lng), zoom: 19.151926,);
    getStoreId();
    // final GoogleMapController controller = await _controller.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // GlobalKey<ScaffoldState> scafKey = new GlobalKey<ScaffoldState>();

  void scanProductCode(BuildContext context) async {
    await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.DEFAULT).then((value) {
      setState(() { _scanBarcode = value; });
      print('scancode - $_scanBarcode');
      Navigator.pushNamed(context, PageRoutes.search, arguments: {
        'ean_code': _scanBarcode,
        'storedetails': storeFinderData,
      });
    }).catchError((e) {
      print('scanProductCode => ERROR : ${e.toString()}');
    });
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      emailAddress = prefs.getString('user_email');
      mobileNumber = prefs.getString('user_phone');
      _image = '$imagebaseUrl${prefs.getString('user_image')}';
      apCurrency = prefs.getString('app_currency');
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getSharedValue();
      hitAppInfo();
      hitAppNotice();
      _getLocation();
    });


    // hitAsyncList();
  }

  void hitAsyncList() async {
    getWislist();
    getBannerList();
    getWhatsNewList();
    getDealProductsList();
    getTopCategoryList();
    getRecentSaleList();
    getTopSellingList();
  }

  void getWislist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    print('getWislist => showWishlistUri : $showWishlistUri || user_id : ${userId.toString()} || store_id : ${store_id.toString()}');
    http.post(url, body: {'user_id': '$userId', 'store_id': '$store_id'}).then((value) {
      print('getWislist => value.body : ${value.body}');
      if (value.statusCode == 200) {
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
            print('wishModel : ${wishModel.toString()}');
            print('wishModel.length : ${wishModel.length.toString()}');
            print('wishModel.wish_id: ${wishModel[0].wish_id.toString()}');
          });
        }
      }
    }).catchError((e) {
      print('getWislist => ERROR : ${e.toString()}');
    });
  }

  void getBannerList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      bannerLoading = true;
    });
    var http = Client();
    print('getBannerList => storeBannerUri : $storeBannerUri || store_id : ${store_id.toString()}');
    http.post(storeBannerUri, body: {'store_id': '$store_id'}).then((value) {
      print('getBannerList => value.body : ${value.body}');
      if (value.statusCode == 200) {
        BannerModel data1 = BannerModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          print('Banner : '+value.body);
          setState(() {
            bannerList.clear();
            bannerList = List.from(data1.data);
            print('bannerList : ${bannerList.toString()}');
            print('bannerList.length : ${bannerList.length.toString()}');
            print('bannerList.banner_name : ${bannerList[0].banner_name.toString()}');
          });
        }
      }
      setState(() {
        bannerLoading = false;
      });
    }).catchError((e) {
      setState(() {
        bannerLoading = false;
      });
      print('getBannerList => ERROR : ${e.toString()}');
    });
  }

  void getWhatsNewList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      whatsnewLoading = true;
    });
    var http = Client();
    print('getWhatsNewList => whatsNewUri : $whatsNewUri || store_id : ${store_id.toString()}');
    http.post(whatsNewUri, body: {'store_id': '$store_id'}).then((value) {
      logger.log('getWhatsNewList => value.body : ${value.body}');
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            whatsNewList.clear();
            whatsNewList = List.from(data1.data);
            print('whatsNewList : ${whatsNewList.toString()}');
            print('whatsNewList.length : ${whatsNewList.length.toString()}');
            print('whatsNewList.storeId : ${whatsNewList[0].storeId.toString()}');
          });
        }
      }
      setState(() {
        whatsnewLoading = false;
      });
    }).catchError((e) {
      setState(() {
        whatsnewLoading = false;
      });
      print('getWhatsNewList => ERROR : ${e.toString()}');
    });
  }

  void getDealProductsList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      dealProductLoading = true;
    });
    var http = Client();
    print('getDealProductsList => dealProductUri : $dealProductUri || store_id : ${store_id.toString()}');
    http.post(dealProductUri, body: {'store_id': '$store_id'}).then((value) {
      logger.log('getDealProductsList => value.body : ${value.body}');
      if (value.statusCode == 200) {
        DealProductModel data1 = DealProductModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            dealProductList.clear();
            dealProductList = List.from(data1.data);
            print('dealProductList : ${dealProductList.toString()}');
            print('dealProductList.length : ${dealProductList.length.toString()}');
            print('dealProductList.del_range : ${dealProductList[0].del_range.toString()}');
          });
        }
      }
      setState(() {
        dealProductLoading = false;
      });
    }).catchError((e) {
      setState(() {
        dealProductLoading = false;
      });
      print('getDealProductsList => ERROR : ${e.toString()}');
    });
  }

  void getTopCategoryList() async {
    //CATEGORY
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      topCatLoading = true;
    });
    var http = Client();
    print('getTopCategoryList => topCatUri : $topCatUri || store_id : ${store_id.toString()}');
    http.post(topCatUri, body: {'store_id': '$store_id'}).then((value) {
      logger.log('getTopCategoryList => value.body : ${value.body}');
      if (value.statusCode == 200) {
        TopCategoryModel data1 = TopCategoryModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            topCategoryList.clear();
            topCategoryList = List.from(data1.data);
            print('topCategoryList : ${topCategoryList.toString()}');
            print('topCategoryList.length : ${topCategoryList.length.toString()}');
            print('topCategoryList.title : ${topCategoryList[0].title.toString()}');
          });
        }
      }
      setState(() {
        topCatLoading = false;
      });
    }).catchError((e) {
      setState(() {
        topCatLoading = false;
      });
      print('getTopCategoryList => ERROR : ${e.toString()}');
    });
  }

  void getRecentSaleList() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      recentSaleLoading = true;
    });
    var http = Client();
    print('getRecentSaleList => recentSellingUri : $recentSellingUri || store_id : ${store_id.toString()}');
    http.post(recentSellingUri, body: {'store_id': '$store_id'}).then((value) {
      logger.log('getRecentSaleList => value.body : ${value.body}');
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            recentSaleList.clear();
            recentSaleList = List.from(data1.data);
            print('recentSaleList : ${recentSaleList.toString()}');
            print('recentSaleList.length : ${recentSaleList.length.toString()}');
            print('recentSaleList.stock : ${recentSaleList[0].stock.toString()}');
          });
        }
      }
      setState(() {
        recentSaleLoading = false;
      });
    }).catchError((e) {
      setState(() {
        recentSaleLoading = false;
      });
      print('getRecentSaleList => ERROR : ${e.toString()}');
    });
  }

  void getTopSellingList() async {
    //TOP RATED
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      topSellingLoading = true;
    });
    var http = Client();
    print('getTopSellingList => topSellingUri : $topSellingUri || store_id : ${store_id.toString()}');
    http.post(topSellingUri, body: {'store_id': '$store_id'}).then((value) {
      logger.log('getTopSellingList => value.body : ${value.body}');
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            topSaleList.clear();
            topSaleList = List.from(data1.data);
            print('topSaleList : ${topSaleList.toString()}');
            print('topSaleList.length : ${topSaleList.length.toString()}');
            print('topSaleList.productId : ${topSaleList[0].productId.toString()}');
          });
        }
      }
      setState(() {
        topSellingLoading = false;
      });
    }).catchError((e) {
      setState(() {
        topSellingLoading = false;
      });
      print('getTopSellingList => ERROR : ${e.toString()}');
    });
  }

  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    print('hitAppInfo => appInfoUri : $appInfoUri');
    http.get(appInfoUri).then((value) {
      print('hitAppInfo => value.body : ${value.body}');
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('hitAppInfo => data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            apCurrency = '${data1.currency_sign}';
          });
          prefs.setString('app_name', '${data1.app_name}');
          prefs.setString('app_currency', '${data1.currency_sign}');
          prefs.setString('country_code', '${data1.country_code}');
          prefs.setString('numberlimit', '${data1.phone_number_length}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setInt('last_loc', int.parse('${data1.last_loc}'));
        }
      }
    }).catchError((e) {
      print('hitAppInfo => ERROR : ${e.toString()}');
    });
  }

  void hitAppNotice() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    print('hitAppNotice => appNoticeUri : $appNoticeUri');
    http.get(appNoticeUri).then((value) {
      print('hitAppNotice => value.body : ${value.body}');
      // print(value.body);
      if (value.statusCode == 200) {
        AppNotice data1 = AppNotice.fromJson(jsonDecode(value.body));
        print('hitAppNotice => data - ${data1.toString()}');
        if ('${data1.status}' == '1') {
          setState(() {
            appnoticetext = '${data1.data.notice}';
            appnoticeStatus = ('${data1.data.status}' == '1');
            print('notice text - $appnoticetext');
          });
        }
      }
    }).catchError((e) {
      print('hitAppNotice => ERROR : ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    print('shownMessage : ${shownMessage.toString()}');
    contextmain = context;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
          drawer: Theme(
              data: Theme.of(context).copyWith(
                // Set the transparency here
                canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
              ),
              child: buildDrawer(context, userName,emailAddress,_image, islogin, onHit: () {
              SharedPreferences.getInstance().then((pref) {
                pref.clear().then((value) {
                  // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
                  //     MaterialPageRoute(builder: (context) {
                  //       return GroceryLogin();
                  //     }), (Route<dynamic> route) => false);
                  Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
                });
              });
            }),
          ),

        body: Column(
          children: [
            // SizedBox(height: 12.0),
            Container(
              // height: 80,
              width: MediaQuery.of(context).size.width,
              // color: kMainTextColor,
              child: Stack(
                children: [
                  // Image.asset('assets/header.png',fit: BoxFit.fill,),
                  Container(
                    // height: 52,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    // decoration: BoxDecoration(
                    //   color: kWhiteColor,
                    //   borderRadius: BorderRadius.circular(10),
                    // ),
                    child: AppBar(
                      centerTitle: true,
                      actions: [
                        //QR CODE ICON
                        Visibility(
                          visible: (storeFinderData != null && storeFinderData.store_id != null),
                          child: Container(
                            height: 30,
                            width: 30,
                            // padding: EdgeInsets.all(6),
                            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 13),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                            ),
                            child: IconButton(
                              icon: ImageIcon(AssetImage('assets/icon_qrcode.png')),
                              iconSize: 15,
                              onPressed: () async {
                                scanProductCode(context);
                              },
                            ),
                          ),
                        ),
                        //SHOPPING ICON
                        Container(
                          height: 30,
                          width: 30,
                          // padding: EdgeInsets.all(6),
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 13),
                          decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                          ),
                          child: IconButton(
                            icon: ImageIcon(AssetImage('assets/icon_shopping_cart.png')),
                            iconSize: 15,
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                                Navigator.pushNamed(context, PageRoutes.cartPage);
                              } else {
                                Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                              }
                            },
                          ),
                        ),
                        //MY LOCATION ICON
                        Container(
                          height: 30,
                          width: 30,
                          // padding: EdgeInsets.all(6),
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 13),
                          decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                          ),
                          child: IconButton(
                            icon:
                                // ImageIcon(AssetImage('assets/icon_shopping_cart.png')),
                                Icon(Icons.my_location),
                            iconSize: 15,
                            onPressed: () {
                              showAlertDialog(context, locale, currentAddress);
                              // _getLocation();
                            },
                          ),
                        )
                      ],
                      title: Center(child: Text(locale.home, style: Theme.of(context).textTheme.headline6.copyWith(color: kMainHomeText, fontSize: 18))),
                      // TextFormField(
                      //   readOnly: true,
                      //   onTap: () {
                      //     if (storeFinderData != null) {
                      //       Navigator.pushNamed(
                      //           context, PageRoutes.searchhistory,
                      //           arguments: {
                      //             'category': topCategoryList,
                      //             'recentsale': recentSaleList,
                      //             'storedetails': storeFinderData,
                      //             'wishlist': wishModel,
                      //           }).then((value) {
                      //         getWislist();
                      //       });
                      //     }
                      //   },
                      //   style: Theme.of(context)
                      //       .textTheme
                      //       .headline6
                      //       .copyWith(color: Colors.black, fontSize: 18),
                      //   decoration: InputDecoration(
                      //       hintText: '${locale.searchOnGroShop}$appname',
                      //       hintStyle: Theme.of(context).textTheme.subtitle2,
                      //       contentPadding: EdgeInsets.symmetric(vertical: 10),
                      //       border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(8),
                      //           borderSide: BorderSide.none)),
                      // ),
                      leading: Builder(
                        builder: (BuildContext context) {
                          return Container(
                            // padding: EdgeInsets.all(6),
                            margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                            ),
                            child: IconButton(
                              icon: ImageIcon(AssetImage('assets/Icon_awesome_align_right.png',)),
                              iconSize: 15,
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (appnoticeStatus && appnoticetext != null && appnoticetext.length > 15),
              child: Container(
                height: 50,
                // margin: EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: kMainTextColor,
                  // image: DecorationImage(
                  //   image: AssetImage('assets/header.png'),
                  //   fit: BoxFit.fill
                  // )
                ),
                alignment: Alignment.center,
                child: (appnoticeStatus && appnoticetext != null && appnoticetext.length > 15)
                    ? Marquee(
                        text: appnoticetext,
                        style: TextStyle(fontWeight: FontWeight.bold, color: kMarqueeColor),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        blankSpace: 5.0,
                        velocity: 100.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      )
                    : SizedBox.shrink(),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 1),
                child: (storeFinderData != null || (topCatLoading || bannerLoading || topSellingLoading || whatsnewLoading || recentSaleLoading || dealProductLoading))
                    ? SingleChildScrollView(
                        primary: true,
                        child: Column(
                          children: [

                            //SEARCH BAR
                            GestureDetector(
                              onTap: () {
                                if (storeFinderData != null)
                                {
                                  Navigator.pushNamed(
                                      context, PageRoutes.searchhistory,
                                      arguments: {'category': topCategoryList, 'recentsale': recentSaleList, 'storedetails': storeFinderData, 'wishlist': wishModel}).then((value) {
                                    getWislist();
                                  });
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                                decoration: BoxDecoration(
                                  color: kSearchBack,
                                  borderRadius: BorderRadius.circular(45),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //       blurRadius: 5,
                                  //       color: Colors.black12,
                                  //       spreadRadius: 1)
                                  // ],
                                ),
                                child: GestureDetector(
                                  child: Stack(
                                    children: [
                                      IconButton(
                                        icon: ImageIcon(AssetImage('assets/ic_search.png')),
                                        iconSize: 15,
                                        color: kSearchIconColour,
                                        onPressed: () {},
                                      ),
                                      Positioned(
                                        left: 50,
                                        top: 15,
                                        child: Text(locale.search, style: Theme.of(context).textTheme.headline6.copyWith(color: kSearchIconColour, fontSize: 15)),
                                      ),
                                      // TextFormField(
                                      //   readOnly: true,
                                      //   onTap: (){},
                                      //   style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black, fontSize: 18),
                                      //   decoration: InputDecoration(
                                      //       hintText: '${locale.searchOnGroShop}$appname',
                                      //       hintStyle: Theme.of(context).textTheme.subtitle2,
                                      //       contentPadding: EdgeInsets.symmetric(vertical: 10),
                                      //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //CATEGORY TITLE
                            Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(bottom: 20),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, PageRoutes.all_category,
                                    arguments: {'store_id': storeFinderData.store_id, 'storedetail': storeFinderData});
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(locale.shopbycategory, style: TextStyle(color: kTextBlack, fontSize: 18, fontWeight: FontWeight.bold)),
                                        // SizedBox(width: 5),
                                        // Icon(Icons.arrow_forward_ios_sharp,size: 15)
                                        Container(
                                          padding:EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: kWhiteColor,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                                          ),
                                          child:Icon(Icons.arrow_forward_ios_rounded,size: 15,color: kRoundButton,),
                                            // ImageIcon(AssetImage('assets/ic_view_all.png')),
                                            // onPressed: () {},
                                          ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //CATEGORY LIST
                            Container(
                              height: 96,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: topCategoryList.length,
                                itemBuilder: (contexts, index) {
                                  return buildCategoryRow(colors1[(index % 4)], colors2[(index % 4)], context, topCategoryList[index], storeFinderData);
                                }),
                            ),
                            SizedBox(height: 16.0),

                            //SLIDER
                            Visibility(
                              visible: bannerList.length>0,
                              child: Stack(
                                children: [
                                  CarouselSlider(
                                    items: bannerList.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context, PageRoutes.cat_product,
                                                  arguments: {'title': i.title, 'storeid': storeFinderData.store_id, 'cat_id': i.cat_id, 'storedetail': storeFinderData});
                                            },
                                            child: Container(
                                              child: CachedNetworkImage(
                                              imageUrl: '${i.banner_image}',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                Align(
                                                  widthFactor: 50,
                                                  heightFactor: 50,
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(5.0),
                                                    width: 50, height: 50,
                                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRoundButton))),
                                              ),
                                              errorWidget: (context, url, error) => Image.asset('assets/icon.png'))
                                                //     Image(image: NetworkImage(i.banner_image))
                                                ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                    options: CarouselOptions(
                                      autoPlay: true,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      onPageChanged: (index, reason) {
                                        setState(() {  _current = index; });
                                      }),
                                  ),
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    start: 20.0,
                                    bottom: 0.0,
                                    child: Row(
                                      children: bannerList.map((i) {
                                        int index = bannerList.indexOf(i);
                                        return Container(
                                          width: 12.0,
                                          height: 3.0,
                                          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: _current == index ? Colors.white : Colors.white.withOpacity(0.5),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            //Fresh Arrived
                            (!whatsnewLoading)
                              ? Visibility(
                                  visible: (whatsNewList != null && whatsNewList.length > 0),
                                  child: buildCompleteVerticalList(locale, context, whatsNewList, locale.fresharrived, wishModel, () {getWislist();}, storeFinderData))
                              : buildCompleteVerticalSHList(context),

                            //Top Rated
                            (!topSellingLoading)
                                ? Visibility(
                                    visible: (topSaleList != null && topSaleList.length > 0),
                                    child: buildProduct(locale, context, topSaleList, locale.topRated, wishModel, () {getWislist();}, storeFinderData))
                                : buildCompleteVerticalSHList(context),
                            //Featured Products
                            (!recentSaleLoading)
                                ? Visibility(
                                    visible: (recentSaleList != null && recentSaleList.length > 0),
                                    child: buildProduct(locale, context, recentSaleList, locale.featuredProducts, wishModel, () {getWislist();}, storeFinderData))
                                : buildCompleteVerticalSHList(context),
                            (!dealProductLoading)
                                ? Visibility(
                                    visible: (dealProductList != null && dealProductList.length > 0),
                                    child: buildDealProduct(locale, context, dealProductList, locale.discountedItems, wishModel, () {getWislist();}, storeFinderData))
                                : buildCompleteVerticalSHList(context),
                            SizedBox(height: 20.0),
                          ],
                        ),
                      )
                    : Align(alignment: Alignment.center, child: Text(shownMessage)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///TODO: CATEGORY LIST
  GestureDetector buildCategoryRow(Color color1, Color color2, BuildContext context, TopCategoryDataModel categories, StoreFinderData storeFinderData) {
    return GestureDetector(
      onTap: () {
        print(' ==========> ON TAP CATEGORY LIST ITEM <========== ');
        Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
          'title': categories.title,
          'storeid': categories.store_id,
          'cat_id': categories.cat_id,
          'storedetail': storeFinderData});
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(left: 16),
        // padding: EdgeInsets.all(10),
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhiteColor,
          // image: DecorationImage(
          //     image: NetworkImage(categories.image), fit: BoxFit.fill)
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(categories.image, fit: BoxFit.cover)),
            Container(
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: new LinearGradient(
                  // colors: [const Color(0xFF3366FF),const Color(0xFf00CCFF)],
                    colors: [color1, color2],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // Clip it cleanly.
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                child: Container(
                  padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                  color: Colors.grey.withOpacity(0.3),
                  alignment: Alignment.topCenter,
                  child: Text(categories.title, style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///TODO : Top Rated
  ///TODO: Featured Products
  Column buildCompleteVerticalSHList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Shimmer(
            duration: Duration(seconds: 3),
            color: Colors.white,
            enabled: true,
            direction: ShimmerDirection.fromLTRB(),
            child: Container(height: 15, width: 150, color: Colors.grey[300]),
          ),
        ),
        // buildShList(context),
        Container(
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width /3,
                    // child: buildProductShHCard(context),
                    child: Shimmer(
                      duration: Duration(seconds: 3),
                      color: Colors.white,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 2.5,
                                  height: MediaQuery.of(context).size.width / 2.5,
                                  child: Container(
                                    color: Colors.grey[300],
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Container(height: 10, color: Colors.grey[300]),
                          // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                          SizedBox(height: 4),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(height: 10, width: 30, color: Colors.grey[300]),
                                Container(
                                    height: 10,
                                    width: 30,
                                    color: Colors.grey[300]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }

  ///TODO : Fresh Arrived
  Column buildCompleteVerticalList(AppLocalizations locale, BuildContext context, List<WhatsNewDataModel> products, String heading, List<WishListDataModel> wishModel, Function callback, StoreFinderData storeFinderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(heading , style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: kTextBlack)),
              // IconButton(icon: ImageIcon(AssetImage( 'assets/ic_view_all.png', ),),iconSize: 15,onPressed: () {},),
            ],
          ),
        ),
        buildList(products, wishModel, () { callback(); }, apCurrency, storeFinderData),
      ],
    );
  }

  Container buildList(List<WhatsNewDataModel> products, List<WishListDataModel> wishModel, Function callback, String apCurrency, StoreFinderData storeFinderData) {
    return Container(
      height: MediaQuery.of(contextmain).size.height/3,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
              ),
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductCard(context, products[index], wishModel, () { callback(); }, apCurrency, storeFinderData),
            );
          }),
    );
  }

  Column buildDealProduct(AppLocalizations locale, BuildContext context, List<DealProductDataModel> products, String heading, List<WishListDataModel> wishModel, Function callback, StoreFinderData storeFinderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(heading, style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: kTextBlack)),
              // IconButton(icon: ImageIcon(AssetImage('assets/ic_view_all.png', ),),iconSize: 15, onPressed: () {}),
            ],
          ),
        ),
        buildDealList(products, wishModel, () {callback();}, apCurrency, storeFinderData),
      ],
    );
  }

  Container buildDealList(List<DealProductDataModel> products, List<WishListDataModel> wishModel, Function callback, String apCurrency, StoreFinderData storeFinderData) {
    return Container(
      height: MediaQuery.of(contextmain).size.height/3,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            WhatsNewDataModel whatsNewM = WhatsNewDataModel(
                productId: products[index].product_id,
                productName: products[index].product_name,
                productImage: products[index].product_image,
                price: products[index].price,
                mrp: products[index].mrp,
                unit: products[index].unit,
                quantity: products[index].quantity,
                varientId: products[index].varient_id,
                varientImage: products[index].varient_image,
                description: products[index].description,
                tags: [],
                stock: products[index].stock,
                storeId: products[index].store_id);
            return Container(
              margin: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
              ),
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductCard(context, whatsNewM, wishModel, () {
                callback();
              }, apCurrency, storeFinderData),
            );
          }),
    );
  }

  Widget buildProductCard(BuildContext context, WhatsNewDataModel products,List<WishListDataModel> wishModel, Function callback, String apCurrency,StoreFinderData storeFinderData, {bool favourites = false}) {
    return GestureDetector(
      onTap: () {
        print('FEATURED PRODUCT ON TAP');
        ProductDataModel modelP = ProductDataModel(
          pId: products.productId,
          productImage: products.productImage,
          productName: products.productName,
          tags: products.tags,
          //=======> OLD <========
          // varients: <ProductVarient>[
          //   ProductVarient(
          //     varientId: products.varientId,
          //     description: products.description,
          //     price: products.price,
          //     mrp: products.mrp,
          //     varientImage: products.varientImage,
          //     unit: products.unit,
          //     quantity: products.quantity,
          //     stock: products.stock,
          //     storeId: products.storeId),
          // ],
          //========> NEW <========
          varientsData: products.varientsData,
          varients: products.productVarient
      );

        print('modelP : ${modelP.toString()}');
        print('modelP.varientsData : ${modelP.varientsData.toString()}');
        print('products.varientsData : ${products.varientsData.toString()}');
        // print('modelP.varientsData : ${modelP.varientsData[0].base_price .toString()}');
        // print('varients : ${modelP.varients[0].price}');
        // print('modelP.varients.length : ${modelP.varients.length.toString()}');
        // print('modelP.varients[0].description : ${modelP.varients[0].description.toString()}');
        try {
          // print('modelP.varients.length : ${modelP.varients[1].description.toString()}');
          print('products.varientsData : ${products.varientsData.toString()}');
          print('modelP.varients.length 0 : ${products.varientsData.toString()}');
          // print('modelP.varients.length 1 : ${products.varientsData[1].varient_id.toString()}');
        } catch(e) {
          print('modelP ERROR : ${e.toString()}');
        }
        int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varientId}','', '', '', '', '', '', '', '', '', '', '',[],[],[]));
        print('idd : $idd');
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': modelP,
          'storedetails': storeFinderData,
          'isInWish': (idd >= 0),
        }).then((value) { callback(); });
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductInfo(image,name,productid,price,varientid,storeid)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
              child: Container(
                // width: MediaQuery.of(context).size.width / 2.5,
                // height: MediaQuery.of(context).size.width / 2.5,
                child: CachedNetworkImage(
                  imageUrl: '${products.productImage}',
                  imageBuilder: (context, imageProvider) => Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                  ),
                  placeholder: (context, url) => Align(
                    widthFactor: 50,
                    heightFactor: 50,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRoundButton))),
                  ),
                  errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                ),
              ),
            ),
            // Stack(
            //   children: [
            //     ClipRRect(
            //       borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
            //       child: Container(
            //         // width: MediaQuery.of(context).size.width / 2.5,
            //         // height: MediaQuery.of(context).size.width / 2.5,
            //         child: CachedNetworkImage(
            //           imageUrl: '${products.productImage}',
            //           imageBuilder: (context, imageProvider) => Container(
            //             width: 80.0,
            //             height: 80.0,
            //             decoration: BoxDecoration(
            //               shape: BoxShape.rectangle,
            //               image: DecorationImage(
            //                   image: imageProvider, fit: BoxFit.cover),
            //             ),
            //           ),
            //           placeholder: (context, url) => Align(
            //             widthFactor: 50,
            //             heightFactor: 50,
            //             alignment: Alignment.center,
            //             child: Container(
            //               padding: const EdgeInsets.all(5.0),
            //               width: 50,
            //               height: 50,
            //               child: CircularProgressIndicator(
            //                 valueColor: AlwaysStoppedAnimation<Color>(kRoundButton),
            //               ),
            //             ),
            //           ),
            //           errorWidget: (context, url, error) =>
            //               Image.asset('assets/icon.png'),
            //         ),
            //       ),
            //     ),
            //     // Image.network(
            //     //   image,
            //     //
            //     //   fit: BoxFit.fill,
            //     // ),
            //     // favourites
            //     //     ? Align(
            //     //         alignment: Alignment.topRight,
            //     //         child: IconButton(
            //     //           onPressed: () {},
            //     //           icon: Icon(
            //     //             Icons.favorite,
            //     //             color: Theme.of(context).primaryColor,
            //     //           ),
            //     //         ),
            //     //       )
            //     //     : SizedBox.shrink(),
            //   ],
            // ),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(products.productName, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: kTextBlack))),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text('${products.quantity} ${products.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          SizedBox(height: 4),
          Container(
            margin: EdgeInsets.only(left: 10 ,right: 10),
            // width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$apCurrency ${products.price}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)),
                Flexible(
                  child: Visibility(
                    visible: ('${products.price}' == '${products.mrp}') ? false : true,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('$apCurrency${products.mrp}', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w300, fontSize: 13, decoration: TextDecoration.lineThrough)),
                    ),
                  ),
                ),
                // buildRating(context),
              ],
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Container buildRating(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 4, right: 3),
      //width: 30,
      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text("4.2", textAlign: TextAlign.center, style: Theme.of(context).textTheme.button.copyWith(fontSize: 10)),
          SizedBox(width: 1),
          Icon(Icons.star, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
        ],
      ),
    );
  }

  Column buildProduct(AppLocalizations locale, BuildContext context, List<WhatsNewDataModel> products, String heading, List<WishListDataModel> wishModel, Function callback, StoreFinderData storeFinderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(heading, style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: kTextBlack)),
              // IconButton(icon: ImageIcon(AssetImage( 'assets/ic_view_all.png', ),),iconSize: 15,onPressed: () {}),
            ],
          ),
        ),
        buildProductList(products, wishModel, () {callback();}, apCurrency, storeFinderData),
      ],
    );
  }

  Container buildProductList(List<WhatsNewDataModel> products, List<WishListDataModel> wishModel, Function callback, String apCurrency, StoreFinderData storeFinderData) {
    return Container(
      height: MediaQuery.of(contextmain).size.height/3,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
              width: MediaQuery.of(context).size.width / 2.5,
              child: buildProductCard(context, products[index], wishModel, () { callback(); }, apCurrency, storeFinderData),
            );
          }),
    );
  }

  void _getLocation() async {
    var locale = AppLocalizations.of(contextmain);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('last_loc') == 0 || (!prefs.containsKey('lat') && !prefs.containsKey('lng'))) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        bool isLocationServiceEnableds = await Geolocator.isLocationServiceEnabled();
        if (isLocationServiceEnableds) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          if (position != null) {
            Timer(Duration(seconds: 5), () async {
              double lat = position.latitude;
              double lng = position.longitude;
              prefs.setString("lat", lat.toStringAsFixed(8));
              prefs.setString("lng", lng.toStringAsFixed(8));
              final coordinates = new Coordinates(lat, lng);
              await Geocoder.local.findAddressesFromCoordinates(coordinates).then((value) {
                setState(() {
                  currentAddress = value[0].addressLine;
                });
              });
              _goToTheLake(lat, lng);
            });
          } else {
            _getLocation();
          }
        } else {
          await Geolocator.openLocationSettings().then((value) {
            if (value) {
              _getLocation();
            } else {
              Toast.show(locale.locationPermission, context, duration: Toast.LENGTH_SHORT);
            }
          }).catchError((e) {
            Toast.show(locale.locationPermission, context, duration: Toast.LENGTH_SHORT);
          });
        }
      } else if (permission == LocationPermission.denied) {
        LocationPermission permissiond = await Geolocator.requestPermission();
        if (permissiond == LocationPermission.whileInUse || permissiond == LocationPermission.always) {
          _getLocation();
        } else {
          Toast.show(locale.locationPermission, context, duration: Toast.LENGTH_SHORT);
        }
      } else if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings().then((value) {
          _getLocation();
        }).catchError((e) {
          Toast.show(locale.locationPermission, context, duration: Toast.LENGTH_SHORT);
        });
      }
    } else {
      lat = double.parse('${prefs.getString('lat')}');
      lng = double.parse('${prefs.getString('lng')}');
      _goToTheLake(lat, lng);
    }
  }

  showAlertDialog(BuildContext context, AppLocalizations locale, String currentAddress) {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        clearAllList();
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(locale.saveLoc, style: TextStyle(fontSize: 13, color: kWhiteColor)),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(locale.notext, style: TextStyle(fontSize: 13, color: kWhiteColor)),
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(locale.locateyourself),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: kGooglePlex,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    buildingsEnabled: false,
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                    },
                    onCameraIdle: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("lat", lat.toStringAsFixed(8));
                      prefs.setString("lng", lng.toStringAsFixed(8));
                      final coordinates = new Coordinates(lat, lng);
                      return await Geocoder.local.findAddressesFromCoordinates(coordinates).then((value) {
                        setState(() {
                          currentAddress = value[0].addressLine;
                        });
                        //
                        print('${currentAddress}');
                      });
                    },
                    onCameraMove: (post) {
                      lat = post.target.latitude;
                      lng = post.target.longitude;
                    },
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop('locpage');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        child: Row(
                          children: [
                            Icon(Icons.my_location, size: 25),
                            SizedBox(width: 10),
                            Expanded(child: Text('$currentAddress', maxLines: 2, style: TextStyle(fontSize: 12, color: kMainTextColor))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 36.0),
                        child: Image.asset('assets/map_pin.png', height: 36),
                      ))
                ],
              ),
            ),
            actions: [clear, no],
          );
        });
      },
    ).then((value) {
      print('dialog value - ${value}');
      if ('$value' == 'locpage') {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return LocationPage(lat, lng);
        })).then((value) {
          print(value);
          setState(() {
            lat = double.parse('${value[0]}');
            lng = double.parse('${value[1]}');
          });
          clearAllList();
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  void clearAllList() async {
    setState(() {
      bannerList.clear();
      whatsNewList.clear();
      recentSaleList.clear();
      topSaleList.clear();
      dealProductList.clear();
      topCategoryList.clear();
      wishModel.clear();
      bannerLoading = true;
      topCatLoading = true;
      topSellingLoading = true;
      whatsnewLoading = true;
      recentSaleLoading = true;
      dealProductLoading = true;
    });
    getStoreId();
  }

  void getStoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bannerLoading = true;
    });
    var http = Client();
    print('$getNearestStoreUri lat : $lat lng : $lng');
    http.post(getNearestStoreUri, body: {'lat': '${lat}', 'lng': '${lng}'}).then((value) {
      print('getStoreId => loc - ${value.body}');
      if (value.statusCode == 200) {
        StoreFinderBean data1 = StoreFinderBean.fromJson(jsonDecode(value.body));
        setState(() {
          shownMessage = '${data1.message}';
          print('getStoreId shownMessage data1.message : ${data1.message.toString()}');
        });
        if ('${data1.status}' == '1') {
          setState(() {
            store_id = '${data1.data.store_id}';
            prefs.setString('store_id', store_id);
            storeName = '${data1.data.store_name}';
            storeFinderData = data1.data;
            if (prefs.containsKey('storelist') && prefs.getString('storelist').length > 0) {
              var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
              List<StoreFinderData> dataFinderL = [];
              dataFinderL = List.from(storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
              int idd1 = dataFinderL.indexOf(data1.data);
              if (idd1 < 0) {
                dataFinderL.add(data1.data);
              }
              prefs.setString('storelist', dataFinderL.toString());
            } else {
              List<StoreFinderData> dataFinderLd = [];
              dataFinderLd.add(data1.data);
              prefs.setString('storelist', dataFinderLd.toString());
            }
            prefs.setString('store_id_last', '${storeFinderData.store_id}');
          });
        } else {
          Toast.show(data1.message, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      }
      if (store_id != null && store_id.toString().length > 0) {
        hitAsyncList();
      } else {
        bannerLoading = false;
        topCatLoading = false;
        topSellingLoading = false;
        whatsnewLoading = false;
        recentSaleLoading = false;
        dealProductLoading = false;
      }
    }).catchError((e) {
      print('getStoreId ERROR : ${e.toString()}');
      if (store_id != null && store_id.toString().length > 0) {
        hitAsyncList();
      } else {
        bannerLoading = false;
        topCatLoading = false;
        topSellingLoading = false;
        whatsnewLoading = false;
        recentSaleLoading = false;
        dealProductLoading = false;
      }
    });
  }
}









// Container buildShList(context) {
//   return Container(
//     height: MediaQuery.of(context).size.height / 3,
//     child: ListView.builder(
//         physics: BouncingScrollPhysics(),
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         itemCount: 10,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Container(
//               width: MediaQuery.of(context).size.width /3,
//               // child: buildProductShHCard(context),
//               child: Shimmer(
//                 duration: Duration(seconds: 3),
//                 color: Colors.white,
//                 enabled: true,
//                 direction: ShimmerDirection.fromLTRB(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Stack(
//                       children: [
//                         Container(
//                           alignment: Alignment.center,
//                           child: SizedBox(
//                             width: MediaQuery.of(context).size.width / 2.5,
//                             height: MediaQuery.of(context).size.width / 2.5,
//                             child: Container(
//                               color: Colors.grey[300],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(height: 4),
//                     Container(height: 10, color: Colors.grey[300]),
//                     // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
//                     SizedBox(height: 4),
//                     Container(
//                       width: MediaQuery.of(context).size.width / 2,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(height: 10, width: 30, color: Colors.grey[300]),
//                           Container(
//                               height: 10,
//                               width: 30,
//                               color: Colors.grey[300]),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//   );
// }

// Widget buildProductShHCard(BuildContext context) {
//   return Shimmer(
//     duration: Duration(seconds: 3),
//     color: Colors.white,
//     enabled: true,
//     direction: ShimmerDirection.fromLTRB(),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             Container(
//               alignment: Alignment.center,
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width / 2.5,
//                 height: MediaQuery.of(context).size.width / 2.5,
//                 child: Container(
//                   color: Colors.grey[300],
//                 ),
//               ),
//             )
//           ],
//         ),
//         SizedBox(height: 4),
//         Container(height: 10, color: Colors.grey[300]),
//         // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
//         SizedBox(height: 4),
//         Container(
//           width: MediaQuery.of(context).size.width / 2,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(height: 10, width: 30, color: Colors.grey[300]),
//               Container(
//                 height: 10,
//                 width: 30,
//                 color: Colors.grey[300]),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
