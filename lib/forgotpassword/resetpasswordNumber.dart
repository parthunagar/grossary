import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Auth/login_navigator.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';

class NumberScreenRestPassword extends StatefulWidget {
  // final VoidCallback onVerificationDone;
  //
  // NumberScreenRestPassword(this.onVerificationDone);

  @override
  NumberScreenRestPasswordState createState() {
    return NumberScreenRestPasswordState();
  }
}

class NumberScreenRestPasswordState extends State<NumberScreenRestPassword> {
  bool showDialogBox = false;

  int checkValue = 0;

  TextEditingController emailAddressC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  AppInfoModel appinfo;
  int numberLimit = 1;

  var http = Client();
  bool phoneValidator(phone) {
    return RegExp(
        r"^[0-9]{10}$")
        .hasMatch(phone);
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final Map<String, Object> rcvdData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      appinfo = rcvdData['appinfo'];
      numberLimit = int.parse('${appinfo.phone_number_length}');
      countryCodeController.text = '${appinfo.country_code}';
    });
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left_sharp,
                  size: 30,
                ),
                onPressed: () {
                  // widget.onVerificationDone();
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                locale.resetpassword,
                style: TextStyle(color: kRoundButtonInButton),
              ),
              centerTitle: true,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                    child: Text(
                      locale.selectrp,
                      style: TextStyle(
                        fontSize: 18,
                        color: kMainTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Radio(
                                value: 0,
                                groupValue: checkValue,
                                toggleable: true,
                                activeColor: kRoundButton,
                                onChanged: (value) {
                                  // print(value);
                                  setState(() {
                                    checkValue = 0;
                                  });
                                  // print(checkValue);
                                },
                              ),
                              Container(
                                width: 5,
                              ),
                              Text(
                                locale.mobilerp,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                value: 1,
                                groupValue: checkValue,
                                toggleable: true,
                                activeColor: kRoundButton,
                                onChanged: (value) {
                                  // print(value);
                                  setState(() {
                                    checkValue = 1;
                                  });
                                  // print(checkValue);
                                },
                              ),
                              Container(
                                width: 5,
                              ),
                              Text(
                                locale.emailrp,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EntryField(
                      label: locale.selectCountry,
                      hint: locale.selectCountry,
                      controller: countryCodeController,
                      readOnly: true,
                      // suffixIcon: (Icons.arrow_drop_down),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EntryField(
                      label: locale.phoneNumber,
                      hint: locale.enterPhoneNumber,
                      maxLines: 1,
                      maxLength: numberLimit,
                      keyboardType: TextInputType.number,
                      readOnly: showDialogBox,
                      controller: phoneNumberC,
                    ),
                  ),
                  Visibility(
                    visible: (checkValue == 1),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EntryField(
                        label: locale.emailAddress,
                        hint: locale.enterEmailAddress,
                        controller: emailAddressC,
                        readOnly: showDialogBox,
                      ),
                    ),
                  ),
                  showDialogBox
                      ? Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Align(
                      widthFactor: 40,
                      heightFactor: 40,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor:AlwaysStoppedAnimation<Color>(kRoundButton),
                      ),
                    ),
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        iconGap: 10,
                        color: kRoundButton,
                        imageAssets: 'assets/icon_feather_save.png',
                        onTap: () {
                          // widget.onVerificationDone();
                          if (!showDialogBox) {

                            if (checkValue == 1) {
                              if (phoneNumberC.text != null &&
                                  phoneNumberC.text.length == numberLimit && phoneValidator(phoneNumberC.text)) {
                                if (emailAddressC.text != null &&
                                    emailValidator(emailAddressC.text)) {
                                  setState(() {
                                    showDialogBox = true;
                                  });
                                  hitForgetByNumber();
                                } else {
                                  setState(() {
                                    showDialogBox = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  showDialogBox = false;
                                });
                                Toast.show(locale.validPhone, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              }
                            } else {
                              if (phoneNumberC.text != null &&
                                  phoneNumberC.text.length == numberLimit && phoneValidator(phoneNumberC.text)) {
                                if ('${appinfo.firebase}'.toUpperCase() == 'ON') {

                                  Navigator.pushNamed(
                                      context, PageRoutes.restpassword2,
                                      arguments: {
                                        'appinfo': appinfo,
                                        'number': phoneNumberC.text,
                                      });
                                } else {
                                  hitForgetByNumber();
                                }
                              } else {
                                Toast.show(locale.validPhone, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                                setState(() {
                                  showDialogBox = false;
                                });
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            )),

          ],
        ),
      ),
    );
  }

  bool emailValidator(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void hitForgetByNumber() async {
    http.post(forGetPasswordByPhoneUri, body: {
      'user_phone': '${phoneNumberC.text}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, PageRoutes.restpassword2, arguments: {
            'appinfo': appinfo,
            'number': phoneNumberC.text,
          });
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitForgetByEmail() async {
    http.post(forGetPasswordByPhoneUri, body: {
      'user_phone': '${phoneNumberC.text}',
      'user_email': '${emailAddressC.text}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          Navigator.pushNamed(context, PageRoutes.restpassword2, arguments: {
            'appinfo': appinfo,
            'number': phoneNumberC.text,
          });
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
    });
  }
}
