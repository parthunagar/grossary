import 'dart:convert';

import 'package:driver/Components/custom_button.dart';
import 'package:driver/Components/entry_field.dart';
import 'package:driver/Components/progressbar.dart';
import 'package:driver/Const/constant.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController numberC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController messageC = TextEditingController();
  var userName;
  var userNumber;
  int numberlimit = 1;
  bool islogin = false;
  bool callbackRequestLoader = false;

  bool isLoading = false;

  var http = Client();

  @override
  void initState() {
    getProfileDetails();
    super.initState();
  }

  void getProfileDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('boy_name');
      userNumber = preferences.getString('boy_phone');
      numberlimit = int.parse('${preferences.getString('numberlimit')}');
      nameC.text = '$userName';
      numberC.text = '$userNumber';
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            "assets/images/t_c_back.png",
            fit: BoxFit.fill,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          drawer: AccountDrawer(context),
          key: _scaffoldKey,
          appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState.openDrawer();
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Card(
                      color: kWhiteColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.012,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.022),
                        child: Image.asset(
                            "assets/images/awesome_align_right.png"),
                      )),
                )),
            title: Text(
              // locale.contactUs,
              "Help Centre",
              style: TextStyle(
                color: kMainTextColor,
                fontFamily: 'Philosopher-Regular',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/images/help_center_logo.png',
                    scale: 2.5,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            locale.callBackReq2,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    fontSize: 18,
                                    color: kGreyBlack,
                                    fontFamily: balooRegular
                                    // fontWeight: FontWeight.w400
                                    ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(40),
                        //   child: RaisedButton(
                        //     onPressed: () {
                        //       if (!isLoading) {
                        //         setState(() {
                        //           isLoading = true;
                        //         });
                        //         sendCallBackRequest(context);
                        //       }
                        //     },
                        //     child: Text(locale.callBackReq1),
                        //   ),
                        // )
                        callbackRequestLoader == true
                            ? Container(
                                height: 25,
                                width: 25,
                                child: ProgressBarIndicator())
                            : CustomRedButton(
                                label: locale.callBackReq1,
                                fontFamily: balooExtraBold,
                                fontSize: 17,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width *0.03),
                                padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.02,
                                    left: MediaQuery.of(context).size.width *
                                        0.02),
                                // margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.22),
                                margin: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.24,
                                    right: MediaQuery.of(context).size.width *
                                        0.24),
                                prefixIcon: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: kRedLightColor,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Image.asset(
                                      "assets/images/phone_call.png",
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (!isLoading) {
                                    setState(() {
                                      isLoading = true;
                                      callbackRequestLoader = true;
                                    });
                                    sendCallBackRequest(context);
                                  }
                                },
                              )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 5),
                    child: Text(
                      locale.or,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 15,
                          color: kGrey,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 25),
                    child: Text(
                      locale.letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 18,
                          color: kGreyBlack,
                          fontFamily: balooRegular),
                    ),
                  ),
                  Divider(
                    thickness: 3.5,
                    color: Colors.transparent,
                  ),
                  EntryField(
                    // verticalPadding: 0,
                    // contentPadding: EdgeInsets.all(0),
                    textInputAction: TextInputAction.next,
                    labelFontSize: 18,
                    controller: nameC,
                    labelFamily: balooRegular,
                    labelFontWeight: FontWeight.w700,
                    label: locale.fullName,
                    hintFamily: balooRegular,
                    hint: locale.enterFullName,
                    inputTextFamily: balooMedium,
                    inputTextSize: 17,
                    // labelColor: kGrey,
                  ),
                  EntryField(
                    textInputAction: TextInputAction.next,
                    controller: numberC,
                    labelFontSize: 18,
                    maxLength: numberlimit,
                    readOnly: true,
                    labelFontWeight: FontWeight.bold,
                    labelFamily: balooRegular,
                    label: locale.phoneNumber,
                    hintFamily: balooRegular,
                    inputTextFamily: balooMedium,
                    inputTextSize: 17,
                    // labelColor: kGrey,
                    onTap: () {
                      Toast.show(
                          locale.youCanNotYourChangeMobileNumber, context,
                          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                    },
                  ),
                  EntryField(
                    // hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                    //     color: kHintColor,
                    //     fontSize: 17,
                    //     fontWeight: FontWeight.w400),
                    // horizontalPadding: 0,
                    textInputAction: TextInputAction.done,
                    hint: locale.enterYourMessage,
                    labelFamily: balooRegular,
                    controller: messageC,
                    labelFontSize: 18,
                    labelFontWeight: FontWeight.bold,
                    label: locale.yourFeedback,
                    hintFamily: balooRegular,
                    inputTextSize: 17,
                    inputTextFamily: balooMedium,
                    // labelColor: kGrey,
                    maxLines: 5,
                    keyboardType: TextInputType.text,
                  ),
                  Divider(
                    thickness: 3.5,
                    color: Colors.transparent,
                  ),
                  isLoading && callbackRequestLoader == false
                      ? ProgressBarIndicator()
                      // Container(
                      //     height: 60,
                      //     width: MediaQuery.of(context).size.width,
                      //     child: Align(
                      //       widthFactor: 40,
                      //       heightFactor: 40,
                      //       alignment: Alignment.center,
                      //       child: CircularProgressIndicator(),
                      //     ),
                      //   )
                      // : CustomButton(
                      //     label: locale.submit,
                      //     onTap: () {
                      //       if (!isLoading) {
                      //         setState(() {
                      //           isLoading = true;
                      //         });
                      //         if (messageC.text != null) {
                      //           sendFeedBack(messageC.text);
                      //         } else {
                      //           setState(() {
                      //             isLoading = false;
                      //           });
                      //         }
                      //       }
                      //     },
                      //   )
                      : CustomRedButton(
                          label: locale.submit,
                          fontFamily: balooExtraBold,
                          fontSize: 17,
                          height: MediaQuery.of(context).size.height * 0.06,
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02),
                          // margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.33),
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.35,
                              right: MediaQuery.of(context).size.width * 0.35),
                          prefixIcon: Container(
                            height: 30,
                            width: 30,
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kRedLightColor,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Image.asset(
                              "assets/images/done_all.png",
                            ),
                            // ),
                          ),
                          // onTap: () {
                          //   if (!isLoading) {
                          //     setState(() {
                          //       isLoading = true;
                          //     });
                          //     if (messageC.text != null) {
                          //       sendFeedBack(messageC.text);
                          //     } else {
                          //       setState(() {
                          //         isLoading = false;
                          //       });
                          //     }
                          //   }
                          onTap: () {
                            RegExp regexAccountNumber =
                                new RegExp(phonePattern);
                            if (!isLoading) {
                              if (nameC.text.isEmpty && messageC.text.isEmpty) {
                                Toast.show(locale.pleaseallfield, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              } else if (nameC.text.isEmpty) {
                                Toast.show(locale.fullNameIsRequired, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              } else if (regexAccountNumber
                                  .hasMatch(nameC.text)) {
                                Toast.show(
                                    locale.numericValueNotAllowedInFullName,
                                    context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              } else if (messageC.text.isEmpty) {
                                Toast.show(locale.feedbackIsRequired, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              } else {
                                if (numberC.text != null &&
                                    numberC.text.length > 0) {
                                  if (nameC.text != null &&
                                      nameC.text.length > 0) {
                                    if (messageC.text != null &&
                                        messageC.text.length > 0) {
                                      if (messageC.text != null &&
                                          messageC.text.length > 0) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        sendFeedBack(messageC.text);
                                      } else {
                                        Toast.show(
                                            locale.pleaseallfield, context,
                                            duration: Toast.LENGTH_SHORT,
                                            gravity: Toast.CENTER);
                                      }
                                    } else {
                                      Toast.show(locale.pleaseallfield, context,
                                          duration: Toast.LENGTH_SHORT,
                                          gravity: Toast.CENTER);
                                    }
                                  } else {
                                    Toast.show(locale.pleaseallfield, context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.CENTER);
                                  }
                                } else {
                                  Toast.show(locale.pleaseallfield, context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.CENTER);
                                }
                              }
                            }
                          },
                        ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void sendFeedBack(dynamic message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('$driverFeedbackUrl  ' +
        'dboy_id : ' +
        '${preferences.getInt('db_id')}' +
        'feedback : ' +
        '$message');
    http.post(driverFeedbackUrl, body: {
      'dboy_id': '${preferences.getInt('db_id')}',
      'feedback': '$message'
    }).then((value) {
      print('ddv - ${value.body}');
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          messageC.clear();
        }
        Toast.show(js['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void sendCallBackRequest(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int id = preferences.getInt('db_id');
    print('$driverCallbackReqUrl  ' + 'driver_id : ' + '$id');
    http.post(driverCallbackReqUrl, body: {
      'driver_id': '${preferences.getInt('db_id')}',
    }).then((value) {
      print('ddv - ${value.body}');
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        Toast.show(js['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        isLoading = false;
        callbackRequestLoader = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
        callbackRequestLoader = false;
      });
    });
  }
}
