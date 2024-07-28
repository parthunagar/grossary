import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/custom_button_fb_google.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/beanmodel/signinmodel.dart';
import 'package:groshop/language_cubit.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  LanguageCubit _languageCubit;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  GoogleSignIn _googleSignIn;
  bool showProgress = false;
  bool enteredFirst = false;
  int numberLimit = 10;
  var countryCodeController = TextEditingController();
  var phoneNumberController = TextEditingController();
  AppInfoModel appInfoModeld;
  int checkValue = -1;
  List<String> languages = [];
  String selectLanguage = '';
  var passwordController = TextEditingController();

  FirebaseMessaging messaging;
  dynamic token;

  int count = 0;
  bool _obscureText = true;
  bool _isHidden = true;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _languageCubit = BlocProvider.of<LanguageCubit>(context);
    Firebase.initializeApp();
    hitAppInfo();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
    _googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('initConnectivity => ERROR : $e');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          _connectionStatus = result.toString();
          hitAppInfo();
          print(_connectionStatus);
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          _connectionStatus = result.toString();
          hitAppInfo();
          print(_connectionStatus);
        });
      break;
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
          print(_connectionStatus);
        });
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {  showProgress = true;  });
    var http = Client();
    http.get(appInfoUri).then((value) {
      // print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('hitAppInfo => data1 : ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            appInfoModeld = data1;
            countryCodeController.text = '${data1.country_code}';
            numberLimit = int.parse('${data1.phone_number_length}');
            prefs.setString('app_currency', '${data1.currency_sign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
            showProgress = false;
          });
        } else {
          setState(() { showProgress = false; });
        }
      } else {
        setState(() { showProgress = false; });
      }
    }).catchError((e) {
      print('hitAppInfo => ERROR : $e');
      setState(() { showProgress = false; });
    });
  }

  Function _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _togglePasswordView() {
    setState(() { _isHidden = !_isHidden; });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    // if(!enteredFirst){
    //   setState(() {
    //     enteredFirst = true;
    //     selectLanguage = locale.language;
    //     languages = [
    //       locale.englishh,
    //       locale.arabicc,
    //       locale.frenchh,
    //       locale.indonesiann,
    //       locale.portuguesee,
    //       locale.spanishh,
    //     ];
    //   });
    // }
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0, left: 0, right: 0),
          child: SingleChildScrollView(
            primary: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text(
                //   locale.welcomeTo,
                //   style: Theme.of(context).textTheme.headline3,
                //   textAlign: TextAlign.center,
                // ),
                // Divider(
                //   thickness: 1.0,
                //   color: Colors.transparent,
                // ),
                Image.asset("assets/spalsh_icon.png", scale: 2.5, height: 150),
                Divider(thickness: 1.0, color: Colors.transparent),
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
                Divider(thickness: 1.0, color: Colors.transparent),
                EntryField(
                  label: locale.selectCountry,
                  hint: locale.selectCountryCode,
                  controller: countryCodeController,
                  readOnly: true,
                  // suffixIcon: (Icons.arrow_drop_down),
                ),
                EntryField(
                  label: locale.phoneNumber,
                  keyboardType: TextInputType.number,
                  // textInputAction: TextInputAction.done,
                  hint: locale.enterPhoneNumber,
                  maxLength: numberLimit,
                  controller: phoneNumberController,
                ),

                Visibility(
                  visible: (checkValue == -1) ? true : false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/et_border.png"),fit: BoxFit.fill)),
                          child: TextField(
                            obscureText: _isHidden,
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: locale.password2,
                              hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: kHintColor, fontSize: 16),
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
                            child: Text(locale.password1, style: Theme.of(context).textTheme.headline6.copyWith(color: kLightTextColoEt, fontWeight: FontWeight.normal, fontSize: 14)),
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
                  //   onSuffixPressed: _toggle(),
                  //   obscureText: _obscureText,
                  //   suffixIcon:
                  //       _obscureText ? Icons.visibility : Icons.visibility_off,
                  // ),
                ),

                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    // margin: EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        Radio(
                          value: 0,
                          groupValue: checkValue,
                          toggleable: true,
                          activeColor: kRoundButton,
                          onChanged: (value) {
                            // print(value);
                            setState(() {
                              if (checkValue == 0) {
                                checkValue = -1;
                              } else {
                                checkValue = 0;
                              }
                            });
                            // print(checkValue);
                          },
                        ),
                        Text(locale.loginotp, style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.w800)),
                        Visibility(
                          visible: (checkValue == -1) ? true : false,
                          child: Expanded(
                            // padding: const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(locale.or, textAlign: TextAlign.start, style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.normal)),
                                GestureDetector(
                                  onTap: () {
                                    if(appInfoModeld!=null){
                                      Navigator.pushNamed(context, PageRoutes.restpassword1, arguments: {'appinfo': appInfoModeld});
                                    }else{
                                      Toast.show(locale.noInternet, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(locale.resetpassword, textAlign: TextAlign.start, style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.w800)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      iconGap: 10,
                      color: kRoundButton,
                      imageAssets: 'assets/icon_feather_save.png',
                      onTap: () {
                        print('checkValue : $checkValue');
                        if (checkValue == 0) {
                          // checkNumber
                          if(phoneNumberController.text != null && phoneNumberController.text != ''&&phoneValidator(phoneNumberController.text)){
                            if(phoneNumberController.text.length == 10){
                              hitLoginUrl('${phoneNumberController.text}', '', 'otp', context);
                            }else{
                              Toast.show(locale.validPhone, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            }
                          }else{
                            Toast.show(locale.enterPhone, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                          }
                          // if (phoneNumberController.text == null &&
                          //     phoneNumberController.text == '') {
                          //   Toast.show('Mobile not be blank', context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          // } else if (phoneNumberController.text.length != 10) {
                          //   Toast.show('Mobile must be 10', context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          // } else {
                          //   hitLoginUrl('${phoneNumberController.text}', '',
                          //       'otp', context);
                          // }
                          // if (phoneNumberController.text != null &&
                          //     phoneNumberController.text.length == 10){
                          //   hitLoginUrl('${phoneNumberController.text}', '',
                          //       'otp', context);
                          // }else{
                          //   Toast.show(locale.incorectMobileNumber, context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          //   setState(() {
                          //     showProgress = false;
                          //   });
                          // }

                          // hitAppInfo();
                        } else {
                          if(phoneNumberController.text != null && phoneNumberController.text != ''){
                            if(phoneNumberController.text.length == 10&&phoneValidator(phoneNumberController.text)){
                              if (passwordController.text != null && passwordController.text != '') {
                                if (passwordController.text.length >= 7) {
                                  if(passwordValidator(passwordController.text)){
                                    hitLoginUrl('${phoneNumberController.text}', passwordController.text, 'password', context);
                                  }else{
                                    Toast.show(locale.validPassword, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                    setState(() { showProgress = false; });
                                  }

                                } else {
                                  Toast.show(locale.validPasswordCreator, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                  setState(() { showProgress = false; });
                                }
                              } else {
                                Toast.show(locale.enterPassword, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                setState(() { showProgress = false; });
                              }
                            }else{
                              Toast.show(locale.validPhone, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            }
                          }else{
                            Toast.show(locale.enterPhone, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            setState(() {  showProgress = false;  });
                          }
                          // if (phoneNumberController.text == null &&
                          //     phoneNumberController.text == '') {
                          //   Toast.show('Mobile not be blank', context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          //   setState(() {
                          //     showProgress = false;
                          //   });
                          // } else if (phoneNumberController.text.length != 10) {
                          //   Toast.show('Mobile must be 10', context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          //   setState(() {
                          //     showProgress = false;
                          //   });
                          // } else {
                          //   if (passwordController.text != null &&
                          //       passwordController.text != '') {
                          //     if (passwordController.text.length >= 7) {
                          //       hitLoginUrl(
                          //           '${phoneNumberController.text}',
                          //           passwordController.text,
                          //           'password',
                          //           context);
                          //     } else {
                          //       Toast.show(
                          //           'Password must be larger then 7 character', context,
                          //           gravity: Toast.CENTER,
                          //           duration: Toast.LENGTH_SHORT);
                          //       setState(() {
                          //         showProgress = false;
                          //       });
                          //     }
                          //   } else {
                          //     Toast.show('Password not be blank', context,
                          //         gravity: Toast.CENTER,
                          //         duration: Toast.LENGTH_SHORT);
                          //     setState(() {
                          //       showProgress = false;
                          //     });
                          //   }
                          // }
                          // if (phoneNumberController.text != null &&
                          //     phoneNumberController.text.length == 10) {
                          //   if (passwordController.text != null &&
                          //       passwordController.text.length >= 7) {
                          //     hitLoginUrl(
                          //         '${phoneNumberController.text}',
                          //         passwordController.text,
                          //         'password',
                          //         context);
                          //   } else {
                          //     Toast.show(locale.incorectPassword, context,
                          //         gravity: Toast.CENTER,
                          //         duration: Toast.LENGTH_SHORT);
                          //     setState(() {
                          //       showProgress = false;
                          //     });
                          //   }
                          // } else {
                          //   Toast.show(locale.incorectMobileNumber, context,
                          //       gravity: Toast.CENTER,
                          //       duration: Toast.LENGTH_SHORT);
                          //   setState(() {
                          //     showProgress = false;
                          //   });
                          // }
                        }

                        // else{
                        //   setState(() {
                        //     showProgress = false;
                        //   });
                        // }
                      },
                    ),
                  ],
                ),
                Divider(thickness: 1.0,color: Colors.transparent),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        SharedPreferences prefs =await SharedPreferences.getInstance();
                        prefs.setBool('skip', true);
                        prefs.setBool('islogin', false);
                        Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,MaterialPageRoute(builder: (context) {
                          return GroceryHome();
                        }), (Route<dynamic> route) => false);
                      },
                      child: Row(
                        children: [
                          Text(locale.skiptext,style: TextStyle(fontSize: 15,color: kTextBlack,fontWeight: FontWeight.w800)),
                          Icon(Icons.arrow_forward,color: kTextBlack,size: 20)
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1.0,color: Colors.transparent),
                Visibility(
                    visible: showProgress,
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(kRoundButton))),
                        Divider(thickness: 1.0,color: Colors.transparent),
                      ],
                    )),
                Visibility(
                  visible: checkValue==0?true:false,
                  child: Text(locale.wellSendOTPForVerification,textAlign: TextAlign.center,style: TextStyle(color: kTextBlack))),
                Text(locale.orContinueWith,textAlign: TextAlign.center),
                Divider(thickness: 1.2,color: Colors.transparent),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: CustomButtonFbGoogle(
                          // label: 'Facebook',
                          // imageAsset: 'assets/icon_f.png',
                          imageBackground: 'assets/group_facebook.png',
                          // color: Color(0xff3b45c1),
                          onTap: () {
                            if (!showProgress) {
                              setState(() {  showProgress = true;  });
                              _login(context);
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // padding: EdgeInsets.all(5.0),
                        child: CustomButtonFbGoogle(
                          // label: 'Google',
                          // imageAsset: 'assets/icon_google.png',
                          imageBackground: 'assets/group_googlee.png',
                          // color: Color(0xffff452c),
                          onTap: () {
                            if (!showProgress) {
                              setState(() { showProgress = true;  });
                              _handleSignIn(context);
                            }
                          },
                        ),
                      ),
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

  void _handleSignIn(BuildContext contextd) async {
    _googleSignIn.isSignedIn().then((value) async {
      print('${value}');
      if (value) {
        if (_googleSignIn.currentUser != null) {
          socialLogin('google', '${_googleSignIn.currentUser.email}', '', contextd);
        } else {
          _googleSignIn.signOut().then((value) async {
            await _googleSignIn.signIn().then((value) {
              var email = value.email;
              socialLogin('google', '$email', '', contextd);
              // print('${email} - ${value.id}');
            }).catchError((e) {
              print('_handleSignIn => ERROR 1 : $e');
              setState(() { showProgress = false;  });
            });
          }).catchError((e) {
            print('_handleSignIn => ERROR 2 : $e');
            setState(() { showProgress = false; });
          });
        }
      } else {
        try {
          await _googleSignIn.signIn().then((value) {
            var email = value.email;
            socialLogin('google', '$email', '', contextd);
            // print('${email} - ${value.id}');
          });
        } catch (e) {
          print('_handleSignIn => ERROR 3 : $e');
          setState(() { showProgress = false; });
        }
      }
    }).catchError((e) {
      print('_handleSignIn => ERROR 4 : $e');
      setState(() { showProgress = false; });
    });
  }

  void socialLogin(dynamic loginType, dynamic email, dynamic fb_id, BuildContext contextd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var client = Client();
    print('socialLogin => socialLoginUri : $socialLoginUri || type : $loginType || user_email : $email || fb_id : $fb_id');
    client.post(socialLoginUri, body: {
      'type': '$loginType',
      'user_email': '$email',
      'fb_id': '$fb_id',
    }).then((value) {
      print('socialLogin => ${value.statusCode} - ${value.body}');
      var jsData = jsonDecode(value.body);
      SignInModel signInData = SignInModel.fromJson(jsData);
      if ('${signInData.status}' == '1') {
        var userId = int.parse('${signInData.data.user_id}');
        prefs.setInt("user_id", userId);
        prefs.setString("user_name", '${signInData.data.user_name}');
        prefs.setString("user_email", '${signInData.data.user_email}');
        prefs.setString("user_image", '${signInData.data.user_image}');
        prefs.setString("user_phone", '${signInData.data.user_phone}');
        prefs.setString("user_password", '${signInData.data.user_password}');
        prefs.setString("wallet_credits", '${signInData.data.wallet}');
        prefs.setString("user_city", '${signInData.data.user_city}');
        prefs.setString("user_area", '${signInData.data.user_area}');
        prefs.setString("block", '${signInData.data.block}');
        prefs.setString("app_update", '${signInData.data.app_update}');
        prefs.setString("reg_date", '${signInData.data.reg_date}');
        prefs.setBool("phoneverifed", true);
        prefs.setBool("islogin", true);
        prefs.setString("refferal_code", '${signInData.data.referral_code}');
        prefs.setString("reward", '${signInData.data.rewards}');
        Navigator.pushAndRemoveUntil(contextd, MaterialPageRoute(builder: (context) {
          return GroceryHome();
        }), (Route<dynamic> route) => false);
      } else {
        if (loginType == 'google') {
          Navigator.pushNamed(contextd, PageRoutes.signUp, arguments: {
            'user_email': '${email}',
            'numberlimit': numberLimit,
            'appinfo': appInfoModeld,
          });
        } else {
          Navigator.pushNamed(contextd, PageRoutes.signUp, arguments: {
            'fb_id': '${fb_id}',
            'numberlimit': numberLimit,
            'appinfo': appInfoModeld,
          });
        }
      }
      setState(() { showProgress = false; });
    }).catchError((e) {
      print('socialLogin => ERROR : $e');
      setState(() { showProgress = false; });
    });
  }

  void _login(BuildContext contextt) async {
    await facebookSignIn.logIn(['email']).then((result) {
      print('result.status : ${result.status}');
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          socialLogin('facebook', '', '${accessToken.userId}', contextt);
          break;
        case FacebookLoginStatus.cancelledByUser:
          setState(() {   showProgress = false;  });
          break;
        case FacebookLoginStatus.error:
          setState(() {
            print('result.errorMessage : ${result.errorMessage}');
            showProgress = false;
          });
          break;
      }
    }).catchError((e) {
      print('_login => ERROR : $e');
      setState(() { showProgress = false; });
    });
  }

  void hitLoginUrl(dynamic user_phone, dynamic user_password, dynamic logintype, BuildContext context) async {
    setState(() {  showProgress = true;    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      var http = Client();
      print('$loginUri  ' +
          'user_phone : ' +
          '$user_phone'
              'user_password : ' +
          '$user_password'
              'device_id : ' +
          '$token'
              'logintype :' +
          '$logintype');
      http.post(loginUri, body: {
        'user_phone': '$user_phone',
        'user_password': '$user_password',
        'device_id': '$token',
        'logintype': '$logintype'}).then((value) {
        print('hitLoginUrl => value.body : ${value.body}');
        if (value.statusCode == 200) {
          var jsData = jsonDecode(value.body);
          LoginModel signInData = LoginModel.fromJson(jsData);
          print('${signInData.toString()}');
          if (signInData.status == "0" || signInData.status == 0) {
            Toast.show(signInData.message, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            print(signInData.status.toString());
            Navigator.pushNamed(context, PageRoutes.signUp, arguments: {
              'user_phone': '${user_phone}',
              'numberlimit': numberLimit,
              'appinfo': appInfoModeld,
            });
          } else if (signInData.status == "1" || signInData.status == 1) {
            print(signInData.status.toString());
            var userId = int.parse('${signInData.data.user_id}');
            prefs.setInt("user_id", userId);
            prefs.setString("user_name", '${signInData.data.user_name}');
            prefs.setString("user_email", '${signInData.data.user_email}');
            prefs.setString("user_image", '${signInData.data.user_image}');
            prefs.setString("user_phone", '${signInData.data.user_phone}');
            prefs.setString("user_password", '${signInData.data.user_password}');
            prefs.setString("wallet_credits", '${signInData.data.wallet}');
            prefs.setString("user_city", '${signInData.data.user_city}');
            prefs.setString("user_area", '${signInData.data.user_area}');
            prefs.setString("block", '${signInData.data.block}');
            prefs.setString("app_update", '${signInData.data.app_update}');
            prefs.setString("reg_date", '${signInData.data.reg_date}');
            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            prefs.setString("refferal_code", '${signInData.data.referral_code}');
            prefs.setString("reward", '${signInData.data.rewards}');
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return GroceryHome();
            }), (Route<dynamic> route) => false);
            // Navigator.popAndPushNamed(context, SignInRoutes.home);
          } else if (signInData.status == "2" || signInData.status == 2) {
            print(signInData.status.toString());
            Navigator.pushNamed(context, PageRoutes.verification, arguments: {
              'token': '${token}',
              'user_phone': '${user_phone}',
              'firebase': '${appInfoModeld.firebase}',
              'country_code': '${appInfoModeld.country_code}',
              'activity': 'login',
            });
          } else if (signInData.status == "3" || signInData.status == 3) {
            print(signInData.status.toString());
            Navigator.pushNamed(context, PageRoutes.verification, arguments: {
              'token': '${token}',
              'user_phone': '${user_phone}',
              'firebase': '${appInfoModeld.firebase}',
              'country_code': '${appInfoModeld.country_code}',
              'activity': 'login',
            });
          } else {
            Toast.show(signInData.message, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          }
        }
        setState(() { showProgress = false; });
      }).catchError((e) {
        print('hitLoginUrl => ERROR : $e');
        setState(() { showProgress = false; });
      });
    } else {
      if (count == 0) {
        count = 1;
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitLoginUrl(user_phone, user_password, logintype, context);
          });
        });
      } else {
        setState(() { showProgress = false; });
      }
    }
  }
  bool phoneValidator(phone) {
    return RegExp(
        r"^[0-9]{10}$")
        .hasMatch(phone);
  }
  bool passwordValidator(password) {
    return RegExp(
        r"^\S{6,}$")
        .hasMatch(password);
  }
}
