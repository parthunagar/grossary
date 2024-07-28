import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/signinmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:async';

class VerificationPage extends StatefulWidget {
  // final VoidCallback onVerificationDone;
  //
  // VerificationPage(this.onVerificationDone);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var verificaitonPin = "";
  FirebaseAuth firebaseAuth;
  var actualCode;
  AuthCredential _authCredential;
  bool firebaseOtp = false;
  dynamic user_phone;
  dynamic referralcode;
  dynamic country_code;
  dynamic activity;

  int firecount = 0;
  Timer _timer;
  int _start = 60;
  bool isTimer = true;
  void startTimer() {

    const oneSec = const Duration(seconds: 1);
    setState(() {
      _start=60;
     isTimer = true;
    });
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            isTimer = false;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
            print(_start);
          });
        }
      },
    );
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    startTimer();
    Firebase.initializeApp();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
  }

  initilizedFirebaseAuth(userNumber) async {

    firecount = 1;
    Firebase.initializeApp();
    firebaseAuth = await FirebaseAuth.instance;
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        if (showDialogBox != null && showDialogBox) {
          showDialogBox = false;
        }
        actualCode = verificationId;
      });
      print(actualCode);
      print('Code sent');
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // this.actualCode = verificationId;
      print(verificationId);
      print('Auto retrieval time out');
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        if (showDialogBox != null && showDialogBox) {
          showDialogBox = false;
        }
      });
      // print('${authException.message}');
      // setState(() {
      //
      // });
      // if (authException.message.contains('not authorized')) {
      // } else if (authException.message.contains('Network')) {
      // } else {}
    };
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
      print('${auth.providerId}');
      // setState(() {});
    };
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: userNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber(String smsCode, BuildContext context) async {
    var locale = AppLocalizations.of(context);
    print(actualCode);
    print(smsCode);
    _authCredential = await PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);
    firebaseAuth.signInWithCredential(_authCredential).then((value) {
      User uss = value.user;
      if (uss != null) {
        print('${uss.phoneNumber}\n${uss.providerData.toList().toString()}');
        if (activity == 'login') {
          hitFirebaseSuccessLoginStatus('success', context);
        } else {
          hitFirebaseSuccessStatus('success', context);
        }
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
      Toast.show(locale.validOtp, context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_SHORT);
      print('eroor ::: '+e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (firecount == 0) {
      final Map<String, Object> dataRecevid =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        token = dataRecevid['token'];
        user_phone = dataRecevid['user_phone'];
        firebaseOtp = ('${dataRecevid['firebase']}' == 'on' ||
                '${dataRecevid['firebase']}' == 'ON' ||
                '${dataRecevid['firebase']}' == 'On')
            ? true
            : false;
        referralcode = dataRecevid['referralcode'];
        country_code = dataRecevid['country_code'];
        activity = dataRecevid['activity'];
      });
      if (firebaseOtp) {
        print('firebase otp status - ${firebaseOtp}');
        print('+$country_code$user_phone');
        initilizedFirebaseAuth('+$country_code$user_phone');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.verification.toUpperCase(),
          style: TextStyle(color: kRoundButtonInButton),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48.0, vertical: 48),
                  child: Text(
                    locale.pleaseEnterVerificationCodeSentGivenNumber,
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //       top: 28.0, left: 18, right: 18, bottom: 4),
                //   child: Text(
                //     locale.enterVerificationCode,
                //     style: Theme.of(context).textTheme.headline3.copyWith(
                //         fontSize: 22,
                //         color: Theme.of(context).backgroundColor,
                //         fontWeight: FontWeight.w500),
                //   ),
                // ),
                EntryField(
                  label: locale.verificationCode,
                  controller: _controller,
                  hint: locale.enterVerificationCode,
                  maxLines: 1,
                  maxLength: firebaseOtp ? 6 : 4,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),
                Visibility(
                  visible: isTimer,
                  child: Align(
                    alignment: Alignment.center,
                      child: Text(
                        locale.otpResendIn+'$_start'+locale.seconds,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: kMainColor1),
                      ),
                    ),
                ),

                Visibility(
                  visible: !isTimer,
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        if (!showDialogBox) {
                          setState(() {
                            showDialogBox = true;
                          });
                          startTimer();
                          if (firebaseOtp) {
                            initilizedFirebaseAuth('+$country_code$user_phone');
                          } else {
                            resendOtpM();
                          }
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(locale.resend,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: kMainColor1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Visibility(
                    visible: showDialogBox,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      iconGap: 12,
                      color: kRoundButton,
                      onTap: () {
                        // widget.onVerificationDone();
                        // if (!showDialogBox) {
                        setState(() {
                          showDialogBox = true;
                        });
                        if (_controller.text != null &&_controller.text != ''){
                          print(_controller.text);
                          verificaitonPin = _controller.text;
                          if (firebaseOtp) {
                            _signInWithPhoneNumber(verificaitonPin, context);
                          } else {
                            if (activity == 'login') {
                              hitLoginService(verificaitonPin, context);
                            } else {
                              hitService(verificaitonPin, context);
                            }
                          }
                        }else{
                          Toast.show(locale.enterVerification, context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                          setState(() {
                            showDialogBox = false;
                          });
                        }

                        // }
                      },
                    ),
                  ],
                ),
              ],
            ),
          )),

        ],
      ),
    );
  }

  void resendOtpM() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = resendOtpUri;
    print('$url  ' + 'user_phone : ' + '${user_phone}');
    await http.post(url, body: {
      'user_phone': '${user_phone}',
    }).then((response) {
      print('resendOtpM : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print('resendOtpM ERROR  ' +'${e.toString()}');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitService(String verificaitonPin, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = verifyPhoneRefferalUri;
    print('$url  ' +
        'user_phone : ' +
        '${user_phone}' +
        'otp : ' +
        '$verificaitonPin' +
        'referral_code : ' +
        '${referralcode}');
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'otp': verificaitonPin,
      'referral_code': '${referralcode}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('hitService : Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if (signInData.status == "1" || signInData.status == 1) {
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
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          // widget.onVerificationDone();
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print('hitService ERROR  ' +'${e.toString()}');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitLoginService(String verificaitonPin, BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = loginVerifyPhoneUri;
    print('$url  ' +
        'user_phone : ' +
        '$user_phone'
            'otp : ' +
        verificaitonPin);
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'otp': verificaitonPin,
    }).then((response) {
      print('hitLoginService : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if (signInData.status == "1" || signInData.status == 1) {
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
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          // widget.onVerificationDone();
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print('hitLoginService ERROR  ' +'${e.toString()}');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitFirebaseSuccessStatus(String status, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = verifyViaFirebaseUri;
    print('$url  ' +
        'user_phone : ' +
        '${user_phone}' +
        'status'+ '$status' +
        'referral_code : ' +
        '${referralcode}');
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'status': status,
      'referral_code': '${referralcode}'
    }).then((response) {
      print('hitFirebaseSuccessStatus : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('hitFirebaseSuccessStatus : Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if (signInData.status == "1" || signInData.status == 1) {
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
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          // widget.onVerificationDone();
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print('hitFirebaseSuccessStatus ERROR  ' +'${e.toString()}');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitFirebaseSuccessLoginStatus(
      String status, BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = loginVerifyViaFirebaseUri;
    print('$loginVerifyViaFirebaseUri  '+
        'user_phone : '+ '${user_phone}'
      +'status : '+ '$status' );
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'status': status,
    }).then((response) {
      print('hitFirebaseSuccessLoginStatus : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if (signInData.status == "1" || signInData.status == 1) {
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
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          // widget.onVerificationDone();
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print('hitFirebaseSuccessLoginStatus ERROR  ' +'${e.toString()}');
      setState(() {
        showDialogBox = false;
      });
    });
  }
}
