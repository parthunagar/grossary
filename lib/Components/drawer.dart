import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:groshop/Auth/login_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/About/about_us.dart';
import 'package:groshop/Pages/About/contact_us.dart';
import 'package:groshop/Pages/DrawerPages/my_orders_drawer.dart';
import 'package:groshop/Pages/Other/home_page.dart';
import 'package:groshop/Pages/Other/language_choose.dart';
import 'package:groshop/Pages/User/my_account.dart';
import 'package:groshop/Pages/User/wishlist.dart';
import 'package:groshop/Pages/reffernearn.dart';
import 'package:groshop/Pages/tncpage/tnc_page.dart';
import 'package:groshop/Pages/wallet/walletui.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
String lang;
Drawer buildDrawer(BuildContext context, userName, emailAddress, _image, bool islogin, {VoidCallback onHit}) {
  var locale = AppLocalizations.of(context);
  var h = MediaQuery.of(context).size.height;
  var w = MediaQuery.of(context).size.width;
  // print(locale.toString());
  return Drawer(
    child: FutureBuilder(
      builder: (context, snapshot) {
        return Container(
          // padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(lang == "ar"
                      ? 'assets/menubg_revrse.png'
                      : 'assets/menubg_main.png'),
                  fit: BoxFit.fill)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: h*0.06),
                padding: EdgeInsets.symmetric(horizontal: w*0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (userName != null)
                                ? locale.hey + ', $userName'
                                : locale.hey + ' User',
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20, letterSpacing: 0.5, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            (emailAddress != null) ? '$emailAddress' : ' ',
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15, letterSpacing: 0.5, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(width: w*0.117),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: w * 0.15,
                        height: w * 0.15,

                        // margin: EdgeInsets.only(right: w * 0.08),
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
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover))),
                          placeholder: (context, url) =>
                            Align(
                              widthFactor: w * 0.15,
                              heightFactor: w * 0.15,
                              alignment: Alignment.center,
                              child: Container(
                                // padding: const EdgeInsets.all(5.0),
                                // width: 20,
                                // height: 20,
                                child: Image(image: AssetImage('assets/user.png'), height: w * 0.15, width: w * 0.15, fit: BoxFit.fill),
                                // CircularProgressIndicator(
                                //   valueColor:
                                //       AlwaysStoppedAnimation<Color>(kRoundButton),
                                // ),
                              ),
                            ),
                          // errorWidget:(context, url, error) => Icon(Icons.error),
                        )
                            : Image(
                          image: AssetImage('assets/user.png'),
                          height: w * 0.15,
                          width: w * 0.15,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    // Stack(
                    //   alignment: Alignment.centerRight,
                    //   children: [
                    //     CustomPaint(
                    //       size: Size(w * 0.15, (w * 0.35).toDouble()),
                    //       //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                    //       painter: RPSCustomPainter(),
                    //     ),
                    //
                    //   ],
                    // ),
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
                      buildListTile(context, 'assets/DrawerImages/home.png', locale.home, HomePage()),
                      Visibility(
                        visible: islogin,
                        child: buildListTile(context, 'assets/DrawerImages/profile.png', locale.myProfile, MyAccount())),
                      Visibility(
                        visible: islogin,
                        child: buildListTile(context, 'assets/DrawerImages/My_order.png', locale.myOrders, MyOrdersDrawer())),
                      // buildListTile(context, Icons.local_offer, locale.offers, OffersPage()),
                      Visibility(
                          visible: islogin,
                          child: buildListTile(context, 'assets/DrawerImages/whishlist.png', locale.myWishList, MyWishList())),
                      Visibility(
                        visible: islogin,
                        child: buildListTile(context, 'assets/DrawerImages/wallet.png', locale.mywallet, Wallet())),
                          buildListTile(context, 'assets/DrawerImages/information.png', locale.aboutUs, AboutUsPage()),
                          buildListTile(context, 'assets/DrawerImages/terms-and-conditions.png', locale.tnc, TNCPage()),
                          buildListTile(context, 'assets/DrawerImages/Help_Centre.png', locale.helpCentre, ContactUsPage()),
                          buildListTile(context, 'assets/DrawerImages/invite_n_earn.png', locale.inviteNEarn, RefferScreen()),
                          buildListTile(context, 'assets/DrawerImages/language.png', locale.language, ChooseLanguage()),
                      // Container(
                      //   // margin: EdgeInsets.only(top: 20,right:60 ,left: 15,bottom: 20),
                      //   decoration: BoxDecoration(
                      //     color:  kWhiteColor,
                      //     borderRadius: BorderRadius.all(Radius.circular(45)),),
                      //   child: ListTile(
                      //     onTap: () {
                      //       onHit();
                      //     },
                      //     leading: Image(
                      //       height: 20,
                      //       width: 20,
                      //       image: AssetImage( 'assets/DrawerImages/log_out.png'),
                      //     ),
                      //     title: Text(
                      //       islogin ? locale.logout : locale.login,
                      //       style: TextStyle(color: kMainHomeText,fontSize: 15),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: h * 0.03),
                      Row(
                        children: [
                          Container(
                            // width: w*0.5,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.all(Radius.circular(45))),
                            child: GestureDetector(
                              onTap: () {
                                onHit();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image(height: 20, width: 20, image: AssetImage('assets/DrawerImages/log_out.png')),
                                  // Spacer(),
                                  SizedBox(width: 10),
                                  Text(islogin ? locale.logout : locale.login, style: TextStyle(color: kMainHomeText, fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.03),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
      future: getSharedValue(),
    ),
  );
}
Future getSharedValue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // hitAppInfo();

  lang = '${prefs.getString('language')}';
  print('image : ' + lang);
  return '${prefs.getString('language')}';
}
ListTile buildListTile(BuildContext context, String icon, String title,
    Widget onPress) {
  return ListTile(
    onTap: () {
      // Navigator.pop(context);
      // Navigator.pop(context);
      //  Navigator.push(context, MaterialPageRoute(builder: (context) => onPress));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => onPress));
      // BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.HomePageClickedEvent);
    },
    leading: Image(
      height: 20,
      width: 20,
      image: AssetImage(icon),
    ),
    title: Text(
      title,
      style: TextStyle(letterSpacing: 2),
    ),
  );
}
// : AssetImage('assets/icon.png'),

// Image.asset('assets/icon.png')
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = kRoundButtonInButton
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.2450000, size.height * -0.0060000);
    path_0.quadraticBezierTo(size.width * 0.2600000, size.height * 0.0170000,
        size.width * 0.2600000, size.height * 0.1000000);
    path_0.cubicTo(
        size.width * 0.3525000,
        size.height * 0.2640000,
        size.width * 0.8975000,
        size.height * 0.2360000,
        size.width,
        size.height * 0.4980000);
    path_0.cubicTo(
        size.width * 0.9275000,
        size.height * 0.7490000,
        size.width * 0.3625000,
        size.height * 0.7510000,
        size.width * 0.2450000,
        size.height * 0.9000000);
    path_0.quadraticBezierTo(size.width * 0.2362500, size.height * 1.0775000,
        size.width * 0.2450000, size.height);
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
