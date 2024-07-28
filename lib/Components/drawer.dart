import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/appinfomodel.dart';
import 'package:vendor/main.dart';

dynamic userName;
dynamic emailAddress;
dynamic _image;
String lang;

Future getSharedValue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // hitAppInfo();
  userName = '${prefs.getString('store_name')}';

  emailAddress = '${prefs.getString('store_email')}';

  _image = '$imagebaseUrl${prefs.getString('store_photo')}';
  lang = '${prefs.getString('language')}';
  print('getSharedValue lang : ' + lang);
  return '$imagebaseUrl${prefs.getString('store_photo')}';
}

void hitAppInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var http = Client();
  http.get(appInfoUri).then((value) {
    print('hitAppInfo value.body : ${value.body}');
    if (value.statusCode == 200) {
      AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
      if (data1.status == "1" || data1.status == 1) {
        prefs.setString('app_currency', '${data1.currency_sign}');
        prefs.setString('app_referaltext', '${data1.refertext}');
        prefs.setString('numberlimit', '${data1.phone_number_length}');
      }
    }
  }).catchError((e) {
    print('hitAppInfo ERROR : ${e.toString()}');
  });
}

Drawer buildDrawer({BuildContext context, var image}) {
  // var storeName;
  // getSharedValue().then((value) {
  //
  // });
  var locale = AppLocalizations.of(context);
  var h = MediaQuery.of(context).size.height;
  var w = MediaQuery.of(context).size.width;
  return Drawer(
    child: FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          hitAppInfo();
        }
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(lang == "ar" ? 'assets/menubg_revrse.png' : 'assets/menubg_main.png'),
              fit: BoxFit.fill)),
          // margin: EdgeInsets.symmetric(vertical: h * 0.05),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: h*0.02),
                padding: EdgeInsets.symmetric(horizontal: w*0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        // margin: EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (userName != null) ? locale.hey + ', $userName' : locale.hey + locale.user,
                              overflow: TextOverflow.fade,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 18, letterSpacing: 0.5, fontWeight: FontWeight.bold),
                            ),
                            // SizedBox(height: 10),
                            Text(
                              (emailAddress != null) ? ' $emailAddress' : ' ',
                              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15, letterSpacing: 0.5, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: w * 0.15,
                        height: w * 0.15,
                        // margin: EdgeInsets.symmetric(horizontal: w*0.08),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                        ),
                        child: (_image != null)
                            ? CachedNetworkImage(
                                imageUrl: _image,
                                imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: w * 0.15,
                                    height: w * 0.15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                ),
                                placeholder: (context, url) => Align(
                                  widthFactor: w * 0.15,
                                  heightFactor: w * 0.15,
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(5.0),
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRoundButton))
                                  ),
                                ),
// errorWidget:(context, url, error) => Icon(Icons.error),
                              )
                            : Image(image: AssetImage('assets/user.png'), height: w * 0.15, width: w * 0.15, fit: BoxFit.fill),
                      ),
                    ),
//                   Stack(
//                     alignment: Alignment.centerRight,
//                     children: [
//                       // CustomPaint(
//                       //   size: Size(w * 0.15, (w * 0.35).toDouble()),
//                       //   //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
//                       //   painter: RPSCustomPainter(),
//                       // ),
//                       Container(
//                         width: w * 0.15,
//                         height: w * 0.15,
//                         margin: EdgeInsets.only(right: w * 0.08),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                                 blurRadius: 5, color: Colors.black12, spreadRadius: 1)
//                           ],
//                         ),
//                         child: (_image != null)
//                             ? CachedNetworkImage(
//                           imageUrl: _image,
//                           imageBuilder: (context, imageProvider) => Container(
//                             width: w * 0.15,
//                             height: w * 0.15,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               image: DecorationImage(
//                                   image: imageProvider, fit: BoxFit.cover),
//                             ),
//                           ),
//                           placeholder: (context, url) => Align(
//                             widthFactor: w * 0.15,
//                             heightFactor: w * 0.15,
//                             alignment: Alignment.center,
//                             child: Container(
//                               padding: const EdgeInsets.all(5.0),
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 valueColor:
//                                 AlwaysStoppedAnimation<Color>(kRoundButton),
//                               ),
//                             ),
//                           ),
// // errorWidget:(context, url, error) => Icon(Icons.error),
//                         )
//                             : Image(
//                           image: AssetImage('assets/user.png'),
//                           height: w * 0.15,
//                           width: w * 0.15,
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ],
//                   ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildListTile(context, 'assets/Icon_shopping_cart.png', locale.myOrders, PageRoutes.newOrdersDrawer),
                      buildListTile(context, 'assets/Icon_information_circle.png', locale.insight, PageRoutes.insight),
                      buildListTile(context, 'assets/full_shopping_bag.png', locale.myItems, PageRoutes.myItemsPage),
                      buildListTile(context, 'assets/Icon_balance_wallet.png', locale.myEarnings, PageRoutes.myEarnings),
                      buildListTile(context, 'assets/coupon.png', 'Coupons', PageRoutes.couponPage),
                      buildListTile(context, 'assets/Icon_user_circle.png', locale.myProfile, PageRoutes.myProfile),
                      buildListTile(context, 'assets/information.png', locale.aboutUs, PageRoutes.aboutus),
                      buildListTile(context, 'assets/terms_conditions.png', locale.tnc, PageRoutes.tnc),
                      buildListTile(context, 'assets/Icon_circle.png', locale.helpCentre, PageRoutes.contactUs),
                      buildListTile(context, 'assets/Icon_metro_language.png', locale.language, PageRoutes.chooseLanguage),
                      Row(
                        children: [
                          Container(
// width: w*0.5,
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.all(Radius.circular(45))),
                            child: GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.clear().then((value) {
// Phoenix.rebirth(context);
                                  Navigator.pushAndRemoveUntil(context,
                                      MaterialPageRoute(builder: (context) {
                                    return GroceryStoreLogin();
                                  }), (Route<dynamic> route) => false);
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image(height: 20, width: 20, image: AssetImage('assets/Icon_metro_switch.png')),
                                  SizedBox(width: 10),
                                  Text(locale.logout, style: TextStyle(color: kMainHomeText, fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 4, color: Colors.transparent)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      future: getSharedValue(),
    ),
  );
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = kRoundButtonInButton
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.2450000, size.height * -0.0060000);
    path_0.quadraticBezierTo(size.width * 0.2600000, size.height * 0.0170000, size.width * 0.2600000, size.height * 0.1000000);
    path_0.cubicTo(size.width * 0.3525000, size.height * 0.2640000, size.width * 0.8975000, size.height * 0.2360000, size.width, size.height * 0.4980000);
    path_0.cubicTo(size.width * 0.9275000, size.height * 0.7490000, size.width * 0.3625000, size.height * 0.7510000, size.width * 0.2450000, size.height * 0.9000000);
    path_0.quadraticBezierTo(size.width * 0.2362500, size.height * 1.0775000, size.width * 0.2450000, size.height);
    path_0.lineTo(0, size.height);
    path_0.lineTo(0, size.height * -0.0060000);
    path_0.lineTo(size.width * 0.2450000, size.height * -0.0060000);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

ListTile buildListTile(BuildContext context, String icon, String title, var onPress) {
  return ListTile(
    onTap: () {
      Navigator.popAndPushNamed(context, onPress);
    },
    leading: Image(height: 20, width: 20, image: AssetImage(icon)),
    // leading: Icon(
    //   icon,
    //   color: Theme.of(context).primaryColor,
    // ),
    title: Text(title, style: TextStyle(letterSpacing: 2)),
  );
}
