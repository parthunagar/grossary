import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendor/Auth/login_navigator.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/appinfomodel.dart';
import 'package:vendor/beanmodel/signmodel/signmodel.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SignIn extends StatefulWidget {
  final VoidCallback onVerificationDone;

  SignIn(this.onVerificationDone);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool showProgress = false;
  int numberLimit = 10;
  var countryCodeController = TextEditingController();
  var phoneNumberController = TextEditingController();
  AppInfoModel appInfoModeld;
  int checkValue = -1;

  var passwordController = TextEditingController();

  FirebaseMessaging messaging;
  dynamic token;

  int count = 0;
  bool _obscureText = true;
  bool _isHidden = true;
  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    hitAppInfo();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
  }

  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() { showProgress = true;  });
    var http = Client();
    print('hitAppInfo => appInfoUri : ${appInfoUri.toString()}');
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('hitAppInfo data1 : ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            appInfoModeld = data1;
            countryCodeController.text = '${data1.country_code}';
            numberLimit = int.parse('${data1.phone_number_length}');
            prefs.setString('app_currency', '${data1.currency_sign}');
            prefs.setString('app_name', '${data1.app_name}');
            prefs.setString('app_referaltext', '${data1.refertext}');
            prefs.setString('numberlimit', '$numberLimit');
            showProgress = false;
          });
        } else {
          setState(() { showProgress = false; });
        }
      } else {
        setState(() { showProgress = false;  });
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
      print('hitAppInfo ERROR : ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   locale.welcomeTo,
                //   style: Theme.of(context).textTheme.headline3,
                //   textAlign: TextAlign.center,
                // ),
                Divider(thickness: 1.0, color: Colors.transparent),
                Image.asset("assets/Logos/logo_seller.png", scale: 1, height: 150),
                SizedBox(height: 50),
                EntryField(
                  textInputAction: TextInputAction.next,
                  label: locale.emailAddress,
                  hint: locale.enterEmailAddress,
                  controller: phoneNumberController,
                ),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/et_border.png"), fit: BoxFit.fill,)),
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          obscureText: _isHidden,
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: locale.password2,
                            hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: kHintColor, fontSize: 18.3),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off,
                                // size: 40.0,
                                color: kTextBlack,
                              ),
                              onPressed: _togglePasswordView,
                            ),
                            // suffix: GestureDetector(
                            //   onTap: _togglePasswordView,
                            //   child: Icon(
                            //     _isHidden
                            //         ? Icons.visibility
                            //         : Icons.visibility_off,
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Container(
                          color: kWhiteColor,
                          padding: const EdgeInsets.only(left: 5, right: 5, top: 2),
                          child: Text(locale.password1, style: Theme.of(context).textTheme.headline6.copyWith(color: kLightTextColor, fontWeight: FontWeight.normal, fontSize: 14)),
                        ),
                      ),
                    ],
                    // child: Container(
                    //   alignment: Alignment.bottomCenter,
                    //   decoration: BoxDecoration(
                    //     image: DecorationImage(
                    //       image: AssetImage("assets/et_border.png"),
                    //       fit: BoxFit.fill,
                    //     ),
                    //   ),
                    //   child: TextField(
                    //     obscureText: _isHidden,
                    //     controller: passwordController,
                    //     decoration: InputDecoration(
                    //       hintText: locale.password2,
                    //       border: InputBorder.none,
                    //       focusedBorder: InputBorder.none,
                    //       enabledBorder: InputBorder.none,
                    //       errorBorder: InputBorder.none,
                    //       disabledBorder: InputBorder.none,
                    //       suffix: InkWell(
                    //         onTap: _togglePasswordView,
                    //         child: Icon(
                    //           _isHidden
                    //               ? Icons.visibility
                    //               : Icons.visibility_off,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
                // EntryField(
                //   label: locale.password1,
                //   hint: locale.password2,
                //   controller: passwordController,
                // ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (showProgress)
                        ? Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            child: CircularProgressIndicator())
                        : CustomButton(
                      label: locale.singIn,
                      imageAssets: 'assets/login.png',
                      iconGap: 12,
                      onTap: () {
                        if (!showProgress) {
                          setState(() {
                            showProgress = true;
                          });
                          if(phoneNumberController.text != null && phoneNumberController.text != ''){
                              if(emailValidator(phoneNumberController.text)){
                                if(passwordController.text != null && passwordController.text != '' ){
                                  if(passwordController.text.length > 4){
                                    print('Ok');
                                    hitLoginUrl('${phoneNumberController.text}', passwordController.text, context);
                                  }else{
                                    Toast.show(locale.enter5Characters, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                    setState(() {    showProgress = false;  });
                                  }
                                }else{
                                  Toast.show(locale.enterPass, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                  setState(() {  showProgress = false;   });
                                }
                              }else{
                                Toast.show(locale.enterValidEmail, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                setState(() {  showProgress = false; });
                              }
                          }else{
                            Toast.show(locale.enterEmail, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            setState(() {  showProgress = false;  });
                          }
                          // if (phoneNumberController.text != null &&
                          //     emailValidator(phoneNumberController.text)) {
                          //   if (passwordController.text != null &&
                          //       passwordController.text.length > 4) {
                          //     hitLoginUrl('${phoneNumberController.text}',
                          //         passwordController.text, context);
                          //   } else {
                          //     Toast.show(locale.incorectPassword, context,
                          //         gravity: Toast.CENTER,
                          //         duration: Toast.LENGTH_SHORT);
                          //     setState(() {
                          //       showProgress = false;
                          //     });
                          //   }
                          // } else {
                          //   Toast.show(locale.incorectEmail, context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          //   setState(() {
                          //     showProgress = false;
                          //   });
                          // }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool emailValidator(email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void hitLoginUrl(dynamic user_phone, dynamic user_password, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      var http = Client();
      print('hitLoginUrl => storeLoginUri : $storeLoginUri | user_password : $user_password | user_phone : $user_phone | device_id token : $token');
      http.post(storeLoginUri, body: {
        'email': '$user_phone',
        'password': '$user_password',
        'device_id': '$token',
      }).then((value) {
        print('hitLoginUrl sign value.body : ${value.body}');
        if (value.statusCode == 200) {
          var jsData = jsonDecode(value.body);
          SignMain signInData = SignMain.fromJson(jsData);
          print('hitLoginUrl signInData : ${signInData.toString()}');
          if (signInData.status == "0" || signInData.status == 0) {
            Toast.show(signInData.message, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            // Navigator.pushNamed(context, SignInRoutes.signUp, arguments: {
            //   'user_phone': '${user_phone}',
            //   'numberlimit': numberLimit,
            //   'appinfo': appInfoModeld,
            // });
          } else if (signInData.status == "1" || signInData.status == 1) {
            var userId = int.parse('${signInData.data.store_id}');
            prefs.setInt("store_id", userId);
            prefs.setString("store_name", '${signInData.data.store_name}');
            prefs.setString("owner_name", '${signInData.data.employee_name}');
            prefs.setString("email", '${signInData.data.email}');
            prefs.setString("store_email", '${signInData.data.email}');
            prefs.setString("store_photo", '${signInData.data.store_photo}');
                // "store_photo", '$imagebaseUrl${signInData.data.store_photo}');
            prefs.setString("phone_number", '${signInData.data.phone_number}');
            prefs.setString("password", '${signInData.data.password}');
            prefs.setString("city", '${signInData.data.city}');
            prefs.setString("admin_share", '${signInData.data.admin_share}');
            prefs.setString("admin_approval", '${signInData.data.admin_approval}');
            prefs.setString("store_status", '${signInData.data.store_status}');
            prefs.setString("address", '${signInData.data.address}');
            prefs.setString("lat", '${signInData.data.lat}');
            prefs.setString("lng", '${signInData.data.lng}');
            prefs.setBool("islogin", true);
            // Navigator.pushAndRemoveUntil(context,
            //     MaterialPageRoute(builder: (context) {
            //       return GroceryHome();
            //     }), (Route<dynamic> route) => false);
            // Navigator.popAndPushNamed(context, SignInRoutes.home);
            widget.onVerificationDone();
          }
        }
        setState(() {    showProgress = false;  });
      }).catchError((e) {
        setState(() {   showProgress = false;   });
        print('hitLoginUrl ERROR : ${e.toString()}');
      });
    } else {
      if (count == 0) {
        count = 1;
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitLoginUrl(user_phone, user_password, context);
          });
        });
      } else {
        setState(() { showProgress = false;  });
      }
    }
  }
}
