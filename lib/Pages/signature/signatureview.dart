import 'dart:convert';
import 'dart:math';
import 'package:driver/Components/progressbar.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:toast/toast.dart';

class SignatureView extends StatefulWidget {
  @override
  SignatureViewState createState() => SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  final SignatureController _controller = SignatureController(penStrokeWidth: 5, penColor: Colors.red, exportBackgroundColor: kWhiteColor);

  OrderHistory orderDetaials;
  bool enterFirst = false;
  bool isLoading = false;
  dynamic apCurency;
  dynamic distance;
  dynamic time;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    getSharedValue();
    _controller.addListener(() {
      // showHint = true;
      setHint();
    });
  }

  setHint() {
    setState(() { showHint = true;  });
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2) {
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kms_per_min = 0.5;
    double mins_taken = kms / kms_per_min;
    double min = mins_taken;
    if (min < 60) {
      return "" + '${min.toInt()}' + " mins";
    } else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60).toStringAsFixed(2)}' + " hour " + minutes + " mins";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);
    final Map<String, Object> dataObject = ModalRoute.of(context).settings.arguments;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetaials = dataObject['OrderDetail'];
        distance = calculateDistance(
          double.parse('${orderDetaials.userLat}'),
          double.parse('${orderDetaials.userLng}'),
          double.parse('${orderDetaials.storeLat}'),
          double.parse('${orderDetaials.storeLng}')).toStringAsFixed(2);
        time = calculateTime(
          double.parse('${orderDetaials.userLat}'),
          double.parse('${orderDetaials.userLng}'),
          double.parse('${orderDetaials.storeLat}'),
          double.parse('${orderDetaials.storeLng}'));
        print('distance : $distance');
        print('time : $time');
      });
    }

    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: AppBar(
            centerTitle: true,
            leading:  GestureDetector(
              onTap: () {
                setState(() { Navigator.pop(context); });
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Card(
                  color: kWhiteColor,
                  child: Icon(Icons.keyboard_arrow_left_rounded,size: 25,color: kRedColor,)),
              ),
            ),
            automaticallyImplyLeading: true,
            backgroundColor: kWhiteColor,
            title: Container(
              margin: EdgeInsets.only(right: w * 0.1),
              child: Column(
                children: [
                  Text('${locale.order} - #${orderDetaials.cartId}', style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.bold, color: kMainTextColor, fontFamily: 'Philosopher-Regular', fontSize: 17)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${locale.order} ${locale.invoice3h} - ',style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w600, color: kMainTextColor, fontFamily: 'Philosopher-Regular',fontSize: 13)),
                      Text('$apCurency ${orderDetaials.remainingPrice}', style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w600, color: kRedLightColor, fontFamily: 'Philosopher-Regular', fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            // actions: <Widget>[
            //   Padding(
            //     padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
            //     child: RaisedButton(
            //       onPressed: () {
            //         setState(() => _controller.clear());
            //       },
            //       child: Text(
            //         locale.clearview,
            //         style: TextStyle(
            //             color: kWhiteColor, fontWeight: FontWeight.w400),
            //       ),
            //       color: kMainColor,
            //       highlightColor: kMainColor,
            //       focusColor: kMainColor,
            //       splashColor: kMainColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30.0),
            //       ),
            //     ),
            //   )
            // ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            // height: h * 0.3,
            margin: EdgeInsets.only(
              top: h * 0.03,
              left: w * 0.04,
              right: w * 0.04,
              bottom: h * 0.23),
            // child: Positioned( top: 10.0, left: 10.0, right: 10.0, bottom: 50.0,
            child: Signature(
              controller: _controller,
              width: w - 20,
              height: h - 280,
              backgroundColor: kWhiteColor,
            ),
            // ),
          ),
          showHint == false
          ? Container(
              margin: EdgeInsets.only(bottom: h * 0.1),
              alignment: Alignment.center,
              child: Text(locale.yourSignaturePlease, style: TextStyle(color: kGrey, fontWeight: FontWeight.bold, fontSize: 18)))
          : Offstage(),
          Positioned(
            bottom: 80.0,
            width: w,
            child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.clear();
                      showHint = false;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  // child: Card(
                  //   elevation: 5,
                  //   clipBehavior: Clip.antiAlias,
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    // margin: EdgeInsets.symmetric(horizontal: w * 0.2 ),
                    margin: EdgeInsets.only(
                        left: w * 0.24,
                        right: w * 0.25),
                    // width: w - 170,
                    height: h * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: kWhiteColor, border: Border.all(color: kRedLightColor), borderRadius: BorderRadius.circular(40)),
                    child: Text(locale.clearview, textAlign: TextAlign.center, style: TextStyle(color: kRedLightColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    // ),
                  ),
                ),
              )),
          Positioned(
            bottom: 10.0,
            width: w,
            child: isLoading
              ? ProgressBarIndicator()
               // Container(
               //    width: w - 100,
               //    height: 52,
               //    alignment: Alignment.center,
               //    child: Align(
               //      heightFactor: 40,
               //      widthFactor: 40,
               //      alignment: Alignment.center,
               //      child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(kRedLightColor),),
               //    ),
               //  )
              // : Align(
              //     alignment: Alignment.center,
              //     child: GestureDetector(
              //       onTap: () {
              //         if (!isLoading) {
              //           setState(() {
              //             isLoading = true;
              //           });
              //           uploadSignature(context);
              //         }
              //       },
              //       behavior: HitTestBehavior.opaque,
              //       child: Card(
              //         elevation: 5,
              //         clipBehavior: Clip.antiAlias,
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(20.0)),
              //         child: Container(
              //           width: w - 100,
              //           height: 52,
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             color: kMainColor,
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //           child: Text(
              //             locale.markAsDelivered,
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //                 color: kWhiteColor,
              //                 fontWeight: FontWeight.w600,
              //                 fontSize: 16),
              //           ),
              //         ),
              //       ),
              //     ),
              //   )
              : Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          if (!isLoading) {
                            setState(() {
                              isLoading = true;
                            });
                            uploadSignature(context);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        // child: Card(
                        //   elevation: 5,
                        //   clipBehavior: Clip.antiAlias,
                        //   shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(25.0)),
                          child: Container(

                            // margin: EdgeInsets.symmetric(horizontal: w * 0.2 ),
                            // width: w - 170,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            margin: EdgeInsets.only(
                              left: w * 0.24,
                              right: w * 0.25),
                            height: h * 0.06,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: kRoundButton, borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    locale.markAsDelivered,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(color: kRedLightColor, borderRadius: BorderRadius.circular(15.0)),
                                  child: Image.asset("assets/images/done_all.png")),
                              ],
                            ),
                          ),
                        ),
                      // ),
                    ))
        ],
      ),
    );
  }

  void uploadSignature(context) async {
    var locale = AppLocalizations.of(context);
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (_controller != null && _controller.isNotEmpty) {
      var data = await _controller.toPngBytes();
      dynamic imageS = base64Encode(data);
      var delivery_out = deliveryCompletedUri;
      print('uploadSignature => url : delivery_out || cart_id : ${orderDetaials.cartId} || user_signature : $imageS');
      var client = http.Client();
      client.post(delivery_out, body: {'cart_id': '${orderDetaials.cartId}', 'user_signature': '$imageS'}).then((value) {
        print('uploadSignature => value.body : ${value.body}');
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          Navigator.pushNamed(context, PageRoutes.orderDeliveredPage,
            arguments: {'OrderDetail': orderDetaials, 'dis': distance, 'time': time,}).then((value) {});
        }
        Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        setState(() { isLoading = false;  });
      }).catchError((e) {
        print('uploadSignature => ERROR : $e');
        setState(() {  isLoading = false;  });
      });
    } else {
      setState(() { isLoading = false;  });
      Toast.show(locale.pleaseTryAgain, context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_SHORT);
    }
  }
}
