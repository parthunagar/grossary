import 'dart:convert';
import 'package:driver/Components/progressbar.dart';
import 'package:driver/Const/constant.dart';
import 'package:driver/beanmodel/appinfo.dart';
import 'package:driver/beanmodel/signinmodel.dart';
import 'package:driver/language_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  LanguageCubit _languageCubit;
  bool showProgress = false;
  int numberLimit = 10;
  var countryCodeController = TextEditingController();
  var phoneNumberController = TextEditingController();
  AppInfoModel appInfoModeld;
  int checkValue = -1;
  List<String> languages = [];
  String selectLanguage = '';
  var passwordController = TextEditingController();
  bool _obscureText = true;
  FirebaseMessaging messaging;
  dynamic token;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
    Firebase.initializeApp();
    hitAppInfo();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showProgress = true;
    });
    var http = Client();
    print('hitAppInfo => appInfoUri : $appInfoUri');
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('hitAppInfo => data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            appInfoModeld = data1;
            countryCodeController.text = '${data1.country_code}';
            numberLimit = int.parse('${data1.phone_number_length}');
            prefs.setString('app_currency', '${data1.currency_sign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
            prefs.setString('numberlimit', '$numberLimit');
            showProgress = false;
          });
        } else {
          setState(() { showProgress = false; });
        }
      } else {
        setState(() {  showProgress = false;  });
      }
    }).catchError((e) {
      print('hitAppInfo => appInfoUri : $e');
      setState(() { showProgress = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);
    // setState(() {
    //   selectLanguage = locale.language;
    //   languages = [ locale.englishh,locale.arabicc,locale.frenchh, locale.indonesiann,locale.portuguesee,locale.spanishh];
    // });
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 28.0, left: 0, right: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text(
                    //   locale.welcomeTo,
                    //   style: Theme.of(context).textTheme.headline3,
                    //   textAlign: TextAlign.center,
                    // ),
                    Divider(thickness: 1.0, color: Colors.transparent),
                    SizedBox(height: 30),
                    Image.asset("assets/images/logo.png", height: 160),
                    SizedBox(height: 20),
                    Divider(thickness: 2.0, color: Colors.transparent),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10.0, vertical: 1),
                    //   child: Text(
                    //     locale.selectPreferredLanguage.toUpperCase(),
                    //     style: Theme.of(context).textTheme.headline6.copyWith(
                    //         color: kMainTextColor,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 21.7),
                    //   ),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 10),
                    //   child: DropdownButton<String>(
                    //     hint: Text(
                    //       selectLanguage,
                    //       overflow: TextOverflow.clip,
                    //       maxLines: 1,
                    //     ),
                    //     isExpanded: true,
                    //     iconEnabledColor: kMainTextColor,
                    //     iconDisabledColor: kMainTextColor,
                    //     iconSize: 30,
                    //     items: languages.map((value) {
                    //       return DropdownMenuItem<String>(
                    //         value: value,
                    //         child: Text(value.toString(),
                    //             overflow: TextOverflow.clip),
                    //       );
                    //     }).toList(),
                    //     onChanged: (value) {
                    //       setState(() {
                    //         selectLanguage = value;
                    //         if (selectLanguage == locale.englishh) {
                    //           _languageCubit.selectEngLanguage();
                    //         } else if (selectLanguage == locale.arabicc) {
                    //           _languageCubit.selectArabicLanguage();
                    //         } else if (selectLanguage == locale.portuguesee) {
                    //           _languageCubit.selectPortugueseLanguage();
                    //         } else if (selectLanguage == locale.frenchh) {
                    //           _languageCubit.selectFrenchLanguage();
                    //         } else if (selectLanguage == locale.spanishh) {
                    //           _languageCubit.selectSpanishLanguage();
                    //         } else if (selectLanguage == locale.indonesiann) {
                    //           _languageCubit.selectIndonesianLanguage();
                    //         }
                    //       });
                    //       print(value);
                    //     },
                    //   ),
                    // ),
                    Divider(thickness: 2.0, color: Colors.transparent),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          TextField(
                            controller: phoneNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            decoration: new InputDecoration(
                              counter: SizedBox.shrink(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: kGrey
                                    // kRedLightColor
                                    ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: kGrey),
                              ),
                              suffixIconConstraints: BoxConstraints(minHeight: 22, minWidth: 22),
                              hintText: locale.enterPhoneNumber,
                              labelText: locale.phoneNumber,
                              labelStyle: TextStyle(color: kGrey),
                              suffixIcon: Container(
                                  margin: EdgeInsets.only(right: 15),
                                  child: Image.asset(
                                    "assets/images/phone_call_login.png",
                                    // fit: BoxFit.contain,
                                    height: 18,
                                    width: 18,
                                    // color: kGreyBlack.withOpacity(0.7),
                                  )),
                            ),
                          ),
                          SizedBox(height: 40),
                          TextField(
                            controller: passwordController,
                            // keyboardType: TextInputType.phone,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: kGrey
                                    // kRedLightColor
                                    ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: kGrey),
                              ),
                              suffixIconConstraints: BoxConstraints(minHeight: 22, minWidth: 22),
                              hintText: locale.password2,
                              labelText: locale.password1,
                              labelStyle: TextStyle(color: kGrey),
                              suffixIcon: IconButton(
                                  onPressed: () { _toggle();  },
                                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: kGrey)),
                              // suffixStyle: const TextStyle(color: Colors.green)
                            ),
                          ),
                          SizedBox(height: 30),
                          (showProgress)
                          ?
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.stretch,
                          //   children: [
                          //     Divider(
                          //       thickness: 1.0,
                          //       color: Colors.transparent,
                          //     ),
                          //     Container(
                          //         alignment: Alignment.center,
                          //         margin: EdgeInsets.only(top: 10, bottom: 10),
                          //         child: CircularProgressIndicator()),
                          //     Divider(
                          //       thickness: 1.0,
                          //       color: Colors.transparent,
                          //     ),
                          //   ],
                          // )
                          ProgressBarIndicator()
                          : CustomRedButton(
                                  fontFamily: balooExtraBold,
                                  fontSize: 17,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  padding: EdgeInsets.only(right: w * 0.03, left: w*0.05),
                                  // margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width *  0.25),
                                  margin: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.27,
                                    right: MediaQuery.of(context).size.width * 0.28),
                                  prefixIcon: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(color: kRedLightColor, borderRadius: BorderRadius.circular(15.0)),
                                    child: Padding(padding: EdgeInsets.all(8.0), child: Image.asset("assets/images/feather_save.png"),
                                    ),
                                  ),
                                  onTap: () {
                                    // RegExp regexEmail = new RegExp(emailPattern);
                                    // RegExp regexName = new RegExp(namePattern);
                                    if (!showProgress) {
                                      setState(() { showProgress = true;  });
                                      if (phoneNumberController.text.isEmpty &&
                                          passwordController.text.isEmpty) {
                                        Toast.show(locale.phoneNumberAndPaswordisRequired, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                        setState(() {  showProgress = false; });
                                      } else if (phoneNumberController.text.isEmpty) {
                                        Toast.show(locale.phoneNumberIsRequired, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                        setState(() { showProgress = false; });
                                      } else if (phoneNumberController.text.length < 10) {
                                        Toast.show(locale.phoneNumberMustBe10Digits, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                        setState(() {  showProgress = false;  });
                                      } else if (passwordController.text.isEmpty) {
                                        Toast.show(locale.passwordIsRequired, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                        setState(() {  showProgress = false;  });
                                      } else {
                                        if (phoneNumberController.text != null && phoneNumberController.text.length >= 10) {
                                          if (passwordController.text != null && passwordController.text.length > 4) {
                                            hitLoginUrl('${phoneNumberController.text}', passwordController.text, context);
                                          } else {
                                            Toast.show(locale.incorectPassword, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                            setState(() {  showProgress = false;  });
                                          }
                                        } else {
                                          Toast.show('${locale.incorectMobileNumber} $numberLimit', context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                          setState(() {  showProgress = false;  });
                                        }
                                      }
                                    }
                                  },
                                ),
                        ],
                      ),
                    ),
                    // EntryField(
                    //   label: locale.phoneNumber,
                    //   hint: locale.enterPhoneNumber,
                    //   controller: phoneNumberController,
                    //   maxLength: numberLimit,
                    // ),
                    // EntryField(
                    //   label: locale.password1,
                    //   hint: locale.password2,
                    //   controller: passwordController,
                    // ),
                  ],
                ),
              )),
              // (showProgress)
              //     ?
              //     // Column(
              //     //   crossAxisAlignment: CrossAxisAlignment.stretch,
              //     //   children: [
              //     //     Divider(
              //     //       thickness: 1.0,
              //     //       color: Colors.transparent,
              //     //     ),
              //     //     Container(
              //     //         alignment: Alignment.center,
              //     //         margin: EdgeInsets.only(top: 10, bottom: 10),
              //     //         child: CircularProgressIndicator()),
              //     //     Divider(
              //     //       thickness: 1.0,
              //     //       color: Colors.transparent,
              //     //     ),
              //     //   ],
              //     // )
              //     ProgressBarIndicator()
              //     : CustomRedButton(
              //         height: MediaQuery.of(context).size.height * 0.07,
              //         padding: EdgeInsets.symmetric(horizontal: 0),
              //         margin: EdgeInsets.symmetric(
              //             horizontal: MediaQuery.of(context).size.width * 0.29),
              //         prefixIcon: Container(
              //           height: 30,
              //           width: 30,
              //           decoration: BoxDecoration(
              //             color: kRedLightColor,
              //             borderRadius: BorderRadius.circular(15.0),
              //           ),
              //           child: Image.asset(
              //             "assets/images/feather_save.png",
              //           ),
              //         ),
              //         onTap: () {
              //           if (!showProgress) {
              //             setState(() {
              //               showProgress = true;
              //             });
              //             if (phoneNumberController.text != null) {
              //               if (passwordController.text != null &&
              //                   passwordController.text.length > 4) {
              //                 hitLoginUrl('${phoneNumberController.text}',
              //                     passwordController.text, context);
              //               } else {
              //                 Toast.show(locale.incorectPassword, context,
              //                     gravity: Toast.CENTER,
              //                     duration: Toast.LENGTH_SHORT);
              //                 setState(() {
              //                   showProgress = false;
              //                 });
              //               }
              //             } else {
              //               Toast.show(
              //                   '${locale.incorectMobileNumber} $numberLimit',
              //                   context,
              //                   gravity: Toast.CENTER,
              //                   duration: Toast.LENGTH_SHORT);
              //               setState(() {
              //                 showProgress = false;
              //               });
              //             }
              //           }
              //         },
              //       ),
              // SizedBox(
              //   height: 10,
              // )
              // CustomButton(
              //   onTap: () {
              //     if (!showProgress) {
              //       setState(() {
              //         showProgress = true;
              //       });
              //       if (phoneNumberController.text != null) {
              //         if (passwordController.text != null &&
              //             passwordController.text.length > 4) {
              //           hitLoginUrl('${phoneNumberController.text}', passwordController.text, context);
              //         } else {
              //           Toast.show(locale.incorectPassword, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
              //           setState(() {
              //             showProgress = false;
              //           });
              //         }
              //       } else {
              //         Toast.show('${locale.incorectMobileNumber} $numberLimit', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
              //         setState(() {
              //           showProgress = false;
              //         });
              //       }
              //     }
              //   },
              // ),
            ],
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
    print('hitLoginUrl => token ; $token');
    if (token != null) {
      var http = Client();
      print('hitLoginUrl => loginUrl : $loginUrl || phone : $user_password || password : $user_password || device_id : $token');
      http.post(loginUrl, body: {
        'phone': '$user_phone',
        'password': '$user_password',
        'device_id': '$token',
      }).then((value) {
        print('hitLoginUrl => value.body : ${value.body}');
        if (value.statusCode == 200) {
          DeliveryBoyLogin dbLogin = DeliveryBoyLogin.fromJson(jsonDecode(value.body));
          if ('${dbLogin.status}' == '1') {
            try {
              prefs.setInt('db_id', int.parse('${dbLogin.data.adDboyId}'));
              prefs.setInt('sn_db_id', int.parse('${dbLogin.data.adDboyId}'));
              // prefs.setString('db_id', '${dbLogin.data.adDboyId}');
              // prefs.setString('sn_db_id', '${dbLogin.data.adDboyId}');
              prefs.setString('boy_name', '${dbLogin.data.boyName}'.toString());
              prefs.setString('boy_phone', '${dbLogin.data.boyPhone}'.toString());
              prefs.setString('boy_city', '${dbLogin.data.boyCity}'.toString());
              prefs.setString('password', '${dbLogin.data.password}'.toString());
              prefs.setString('boy_loc', '${dbLogin.data.boyLoc}');
              prefs.setString('lat', '${dbLogin.data.lat}');
              prefs.setString('lng', '${dbLogin.data.lng}');
              prefs.setString('status', '${dbLogin.data.status}');
              prefs.setString('added_by', '${dbLogin.data.addedBy}');
              prefs.setString('rem_by_admin', '${dbLogin.data.remByAdmin}');
              prefs.setString('ad_dboy_id', '${dbLogin.data.adDboyId}');
              prefs.setBool('islogin', true);
              widget.onVerificationDone();
            } catch (e) {
              print(' ***** ERROR ****** - $e');
            }
          } else {
            Toast.show('User Not Found.\nInvalid phone number and password', context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
            prefs.setBool('islogin', false);
          }
        } else {
          prefs.setBool('islogin', false);
        }
        setState(() { showProgress = false; });
      }).catchError((e) {
        print('hitLoginUrl => ERROR : $e');
        prefs.setBool('islogin', false);
        setState(() { showProgress = false; });
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
        setState(() {
          showProgress = false;
        });
      }
    }
  }
}
