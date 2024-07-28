import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';

class RefferScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RefferScreenState();
  }
}

class RefferScreenState extends State<RefferScreen> {
  var refferText = '';
  var appLink = '';
  var userName;
  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;
  bool islogin;
  var refferCode = '';
  bool isFetchStore = false;

  dynamic elestxt = 'Fetching data..';

  dynamic appname = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      hitAppInfo();
    });

  }

  void showAlertDialog(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!islogin){
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(locale.heyUser),
            content: Text(locale.pleaseLogin),
            actions: <Widget>[
              TextButton(
                onPressed: () => SharedPreferences.getInstance().then((pref) {
                  pref.clear().then((value) {
                    // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
                    //     MaterialPageRoute(builder: (context) {
                    //       return GroceryLogin();
                    //     }), (Route<dynamic> route) => false);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        PageRoutes.signInRoot, (Route<dynamic> route) => false);
                  });
                }),
                child: Text(locale.ok,style: TextStyle(color: kRoundButton,fontSize: 16),),
              ),
            ],
          ));
    }

  }

  void hitAppInfo() async{
    var locale = AppLocalizations.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('islogin');
      print(islogin);
      userName = prefs.getString('user_name');
      emailAddress = prefs.getString('user_email');
      mobileNumber = prefs.getString('user_phone');
      _image = '$imagebaseUrl${prefs.getString('user_image')}';
      elestxt = locale.fetchingReward;
      isFetchStore = true;
      refferCode = prefs.getString('refferal_code');
      SchedulerBinding.instance.addPostFrameCallback((_) => showAlertDialog(context));
    });
    var http = Client();
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            refferText = '${data1.refertext}';
            appLink = '${data1.app_link}';
            appname = '${data1.app_name}';
            prefs.setString('app_currency', '${data1.currency_sign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
          });
        }
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  void getRefferCode() async {
    // setState(() {
    //   elestxt = 'Fetching share code..';
    //   isFetchStore = true;
    // });
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int userId = prefs.getInt('user_id');
    // var url = promocode_regenerate;
    // var client = http.Client();
    // client.post(url, body: {
    //   'user_id': '${userId}',
    // }).then((value) {
    //   if (value.statusCode == 200) {
    //     var redemData = jsonDecode(value.body);
    //     print('${value.body}');
    //     if (redemData['status'] == 1) {
    //       prefs.setString('refferal_code', '${redemData['PromoCode']}');
    //       print('${value.body}');
    //       setState(() {
    //         refferCode = redemData['PromoCode'];
    //       });
    //       Toast.show(redemData['message'], context,
    //           duration: Toast.LENGTH_SHORT);
    //     }
    //   }
    //   setState(() {
    //     isFetchStore = false;
    //   });
    // }).catchError((e) {
    //   setState(() {
    //     isFetchStore = false;
    //   });
    //   print(e);
    // });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kWhiteColor,
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.signInRoot, (Route<dynamic> route) => false);
            });
          });
        }),
      ),

      appBar: AppBar(
        title: Text(
          locale.inviteNEarn,
          style: TextStyle(color: kMainHomeText, fontSize: 18),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              // padding: EdgeInsets.all(6),
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                ],
              ),
              child: IconButton(
                icon: ImageIcon(
                  AssetImage(
                    'assets/Icon_awesome_align_right.png',
                  ),
                ),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/language_back.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: (!isFetchStore)
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
              child: Column(
                  // alignment: Alignment.topCenter,
          crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(height: h*0.06),
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Image.asset(
                        'assets/logo_big_new.png',
                        height: 120,
                      ),
                    ),
                    // Positioned(
                    //     top: 40,
                    //     child: ),
                    // Container(
                    //   width: 200,
                    //   height: 150,
                    //   decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //           image: AssetImage(
                    //               'images/refernearn/refernearn.jpg'),
                    //           fit: BoxFit.fill)),
                    // ),
                     SizedBox(height: h*0.06),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
height: h*0.05,
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          alignment: Alignment.center,
                          child: Text(
                            '${refferText}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize:26,
                                color: kTextBlack),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            locale.sahreYourCode,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: kSearchIconColour),
                          ),
                        ),
                      ],
                    ),

                    // Positioned(
                    //   top: 210,
                    //   left: 20,
                    //   right: 20,
                    //   child: ,
                    // ),
                    // Positioned(
                    //   top: 270,
                    //   left: 20,
                    //   right: 20,
                    //   child:
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if(!islogin){
                              showAlertDialog(context);
                            }else{
                              if(refferCode!=null&&refferCode!='null'){
                                Clipboard.setData(ClipboardData(text: refferCode));
                                Toast.show(locale.codeCpied, context,
                                    duration: Toast.LENGTH_SHORT);
                              }else{
                                Toast.show(locale.sorryForInconvenience, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              }

                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            height: h*0.05,
                            width: w*0.3,
                            decoration: BoxDecoration(
                              color: kTextBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 30),
                            margin: EdgeInsets.only(top: h*0.05),
                            // width: 150,
                            // height: 80,
                            child: Text(
                              '$refferCode',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: kMainPriceText),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      locale.tapTOCopy,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: kTextBlack),
                    ),
                    // SizedBox(height: 50),
                    SizedBox(height: h*0.09),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          // height: h*0.05,
                          // width: w*0.4,
                          color: kRoundButton,
                          iconGap: w*0.05,
                          label:locale.inviteFriends,
                          imageAssets: 'assets/Invite_Friends_btn.png',
                          onTap: (){
                            if(!islogin){
                              showAlertDialog(context);
                            }else{
                              if (refferCode != null && refferCode.length > 0&&refferCode!='null') {
                                share(locale.shareheading,locale.sharetext);
                              } else {
                                Toast.show(
                                    locale.sorryForInconvenience, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                                // getRefferCode();
                              }
                            }


                          },
                        ),
                      ],
                    ),

                    // Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 50,vertical: 15),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //
                    //     },
                    //     child: Container(
                    //       alignment: Alignment.center,
                    //       height: 52,
                    //       margin: EdgeInsets.symmetric(horizontal: 20),
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.all(Radius.circular(10)),
                    //           color: kMainColor),
                    //       child: Text(
                    //         locale.inviteFriends,
                    //         style: TextStyle(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.w400,
                    //             color: kWhiteColor),
                    //       ),
                    //     ),
                    //   ),
                    // )
                    // Positioned(
                    //     bottom: 90,
                    //     child: ),
                    // Positioned(
                    //     bottom: 15,
                    //     left: 0.0,
                    //     right: 0.0,
                    //     child: )
                  ],
                ),
            )
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '$elestxt',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: kTextBlack),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> share(String share, String sharetext) async {
    await FlutterShare.share(
        title: appname,
        text: '${refferText}\n$sharetext ${refferCode}.',
        linkUrl: '${appLink}',
        chooserTitle: '$share ${appname}');
  }
}
