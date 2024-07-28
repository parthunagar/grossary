import 'dart:convert';

import 'package:driver/Components/drawer_Shape.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/appinfo.dart';
import 'package:driver/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDrawer extends StatelessWidget {
  BuildContext _buildContext;

  // Get Select Language
  String language;

  AccountDrawer(this._buildContext);

  Future getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // hitAppInfo();
    language = prefs.getString('language');
    print("language Drawer : " + language.toString());
    return prefs.getString('boy_name');
  }

  getLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getString('language');
    return language;
  }

  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    print('$appInfoUri');
    http.get(appInfoUri).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          prefs.setString('app_currency', '${data1.currency_sign}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setString('numberlimit', '${data1.phone_number_length}');
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);
    // Theme(
    //     data: Theme.of(context).copyWith(
    //       // Set the transparency here
    //       canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
    //     ),
    return Theme(
      data: Theme.of(context).copyWith(
        // Set the transparency here
        canvasColor: Colors
            .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
      ),
      child: Drawer(
        child: FutureBuilder(
            future: getLang(),
            builder: (context, snapshot) {
              return Container(
                decoration: BoxDecoration(
                    // color: kWhiteColor,
                  image: DecorationImage(
                  image: AssetImage(language == "ar"
                      ? 'assets/images/menubg_revrse.png'
                      : 'assets/images/menubg.png'),
                  fit: BoxFit.fill,
                )),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.045),
                        Padding(
                          // padding: EdgeInsets.fromLTRB(20,12,20,10),
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.04,
                              MediaQuery.of(context).size.height * 0.022,
                              MediaQuery.of(context).size.width * 0.06,
                              0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.only(bottom: 30),
                            // color: kGrey Black,
                            child: FutureBuilder(
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  hitAppInfo();
                                }
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          (snapshot.hasData != null) ? locale.hey + ', ' + '${snapshot.data}' : '${locale.hey}\, User',
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.headline5),
                                    ),
                                    Container(
                                      height: h * 0.062,
                                      width: w * 0.13,
                                      decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(40)),
                                      child: Center(
                                        child: Text(
                                          (snapshot.hasData != null) ? '${snapshot.data[0].toUpperCase()}' : 'User',
                                          style: Theme.of(context).textTheme.headline6.copyWith(fontSize: h * 0.04, color: kRedLightColor))),
                                    ),
                                  ],
                                );
                              },
                              future: getSharedValue(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              buildListTile(
                                  context,
                                  // Icons.home,
                                  "assets/images/menu_home.png",
                                  locale.home,
                                  // HomePage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.homePage)),

                              // buildListTile(context, Icons.account_balance_wallet, locale.wallet, () => Navigator.popAndPushNamed(context, PageRoutes.walletPage)),
                              buildListTile(
                                  context,
                                  // Icons.account_box,
                                  "assets/images/menu_profile.png",
                                  locale.myAccount,
                                  // EditProfilePage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.editProfilePage)),
                              buildListTile(
                                  context,
                                  // Icons.insert_chart,
                                  "assets/images/menu_information_circle.png",
                                  locale.insight,
                                  // InsightPage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.insightPage)),
                              buildListTile(
                                  context,
                                  // Icons.food_bank_sharp,
                                  "assets/images/menu_bank.png",
                                  locale.sendToBank,
                                  // AddToBank()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.addToBank)),
                              buildListTile(
                                  context,
                                  // Icons.view_list,
                                  "assets/images/menu_information.png",
                                  locale.aboutUs,
                                  // AboutUsPage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.aboutus)),
                              buildListTile(
                                  context,
                                  // Icons.admin_panel_settings_rounded,
                                  "assets/images/menu_terms_and_conditions.png",
                                  locale.tnc,
                                  // TNCPage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.tnc)),
                              buildListTile(
                                  context,
                                  // Icons.chat,
                                  "assets/images/menu_question_circle.png",
                                  locale.helpCenter,
                                  // ContactUsPage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.contactUs)),
                              buildListTile(
                                  context,
                                  // Icons.language,
                                  "assets/images/menu_language.png",
                                  locale.language,
                                  // LanguagePage()),
                                  () => Navigator.popAndPushNamed(context, PageRoutes.languagePage)),
                              LogoutTile(),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                        // color: kLightTextColor,
                        height: h * 0.025,
                        width: w * 0.05,
                        margin: EdgeInsets.only(top: h * 0.04, left: w * 0.04, right: w * 0.04),
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            print("close");
                          },
                          child: Image.asset("assets/images/menu_close.png", height: h * 0.018))),
                  ],
                ),
              );
            }),
      ),
    );
  }

  // ListTile buildListTile(
  //     BuildContext context, IconData icon, String text, Function onTap) {
  //   var theme = Theme.of(context);
  //
  //   return ListTile(
  //     leading: Icon(icon, color: theme.primaryColor),
  //     title: Text(text.toUpperCase(),
  //         style: theme.textTheme.headline6
  //             .copyWith(fontSize: 18, letterSpacing: 0.8)
  //             .copyWith(color: theme.scaffoldBackgroundColor)),
  //     onTap: onTap,
  //   );
  // }
  ListTile buildListTile(
      BuildContext context,
      var icon,
      String text,
      // Widget onTap
      Function onTap) {
    var theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      dense: true,
      leading: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.04,
          right: MediaQuery.of(context).size.width * 0.035),
        height: MediaQuery.of(context).size.height * 0.025,
        width: MediaQuery.of(context).size.width * 0.05,
        // padding: EdgeInsets.only(left: 15.0),
        child: Image.asset(
          icon,
          // height: MediaQuery.of(context).size.height * 0.025,
        ),
      ),
      title: Container(
        // color: Colors.red,
        margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.2),
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headline6.copyWith(fontSize: MediaQuery.of(context).size.height * 0.024,).copyWith(color: theme.scaffoldBackgroundColor)), // letterSpacing: 0.8
      ),
      // onTap:  (){
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (context) => onTap));
      // }
      onTap: onTap,
    );
  }
}

class LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var theme = Theme.of(context);
    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  // title: Text(locale.loggingOut),
                  content: Text("Are you sure you want to logout ?"
                      // locale.areYousure
                      ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(locale.no),
                      textColor: kMainColor,
                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                        child: Text(locale.yes),
                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
                        textColor: kMainColor,
                        onPressed: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.clear().then((value) {
                            if (value) {
                              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) {
                                return DeliveryBoyLogin();
                              }), (Route<dynamic> route) => false);
                            }
                          });
                        })
                  ],
                );
              });
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.05,
          // width: 10,
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.045,
              right: MediaQuery.of(context).size.width * 0.045),
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.01,
              left: MediaQuery.of(context).size.width * 0.045,
              right: MediaQuery.of(context).size.width * 0.4),
          decoration: BoxDecoration(
              color: kWhiteColor, borderRadius: BorderRadius.circular(20)),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/menu_switch.png",
                  color: kRedLightColor,
                  height: MediaQuery.of(context).size.height * 0.025),
              SizedBox(width: 10),
              Flexible(
                child: Text(locale.logout,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headline6.copyWith(fontSize: 15, letterSpacing: 0.8, fontWeight: FontWeight.w600).copyWith(color: kRedLightColor)),
              )
            ],
          ),
        ));
    // return ListTile(
    //   leading: Icon(Icons.exit_to_app, color: kMainColor),
    //   title: Text(locale.logout.toUpperCase(),
    //       style: theme.textTheme.headline6
    //           .copyWith(fontSize: 18, letterSpacing: 0.8)
    //           .copyWith(color: theme.scaffoldBackgroundColor)),
    //   onTap: () {
    //     showDialog(
    //         context: context,
    //         barrierDismissible: false,
    //         builder: (BuildContext context) {
    //           return AlertDialog(
    //             title: Text('Logging out'),
    //             content: Text('Are you sure?'),
    //             actions: <Widget>[
    //               FlatButton(
    //                 child: Text('No'),
    //                 textColor: kMainColor,
    //                 shape: RoundedRectangleBorder(
    //                     side: BorderSide(color: Colors.transparent)),
    //                 onPressed: () => Navigator.pop(context),
    //               ),
    //               FlatButton(
    //                   child: Text('Yes'),
    //                   shape: RoundedRectangleBorder(
    //                       side: BorderSide(color: Colors.transparent)),
    //                   textColor: kMainColor,
    //                   onPressed: () async {
    //                     SharedPreferences pref =
    //                         await SharedPreferences.getInstance();
    //                     pref.clear().then((value) {
    //                       if (value) {
    //                         Navigator.pushAndRemoveUntil(context,
    //                             MaterialPageRoute(builder: (context) {
    //                           return DeliveryBoyLogin();
    //                         }), (Route<dynamic> route) => false);
    //                       }
    //                     });
    //                   })
    //             ],
    //           );
    //         });
    //   },
    // );
    //   buildListTile(context, Icons.exit_to_app, locale.logout,
    //         () async {
    //   SharedPreferences.getInstance().then((prefs) {
    //     prefs.clear().then((value) {
    //       // Phoenix.rebirth(context);
    //       Navigator.pushAndRemoveUntil(context,
    //           MaterialPageRoute(builder: (context) {
    //             return DeliveryBoyHome(false);
    //           }), (Route<dynamic> route) => false);
    //     });
    //   });
    // });
  }
}
