import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';

class ChangePassword extends StatefulWidget {
  // final VoidCallback onVerificationDone;
  //
  // ChangePassword(this.onVerificationDone);

  @override
  ChangePasswordState createState() {
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePassword> {
  bool showDialogBox = false;
  TextEditingController password1 = TextEditingController();
  TextEditingController password2 = TextEditingController();
  AppInfoModel appinfo;
  String userNumber;

  var http = Client();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }
  bool passwordValidator(password) {
    return RegExp(
        r"^\S{6,}$")
        .hasMatch(password);
  }
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final Map<String, Object> dataRecevid =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      userNumber = dataRecevid['number'];
      appinfo = dataRecevid['appinfo'];
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(
                locale.changepassword,
                style: TextStyle(color: kRoundButtonInButton),
              ),
              centerTitle: true,
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Padding(
              //   padding:
              //       const EdgeInsets.only(right: 20, top: 10, bottom: 10),
              //   child: Text(
              //     locale.passwordheading,
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 18,
              //       color: kTextBlack,
              //       fontWeight: FontWeight.w800,
              //     ),
              //   ),
              // ),
                  SizedBox(height: 30),
              EntryField(
                label: locale.newpassword1,
                hint: locale.newpassword2,
                controller: password1,
              ),
              EntryField(
                label: locale.confirmpassword1,
                hint: locale.confirmpassword2,
                controller: password2,
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
                        setState(() {
                          showDialogBox = true;
                        });
                        if(password2.text != null && password2.text != ''&&password1.text != null && password1.text != ''){
                          if(password2.text.length >= 7 &&password1.text.length >= 7 ){
                            if(passwordValidator(password1.text) && passwordValidator(password2.text)){
                              if(password1.text == password2.text){
                                changePassword();
                              }else{
                                Toast.show(locale.enterSamePass, context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                                setState(() {
                                  showDialogBox = false;
                                });
                              }
                            }else{
                              Toast.show(locale.validPassword, context,
                                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                              setState(() {
                                showDialogBox = false;
                              });
                            }

                          }else{
                            Toast.show(locale.validPasswordCreator, context,
                                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                            setState(() {
                              showDialogBox = false;
                            });
                          }
                        }else{
                          Toast.show(locale.enterSamePass, context,
                              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                          setState(() {
                            showDialogBox = false;
                          });
                        }
                      }


                      //   if (password2.text != null &&
                      //       password2.text.length >= 7) {
                      //     if ((password1.text != null &&
                      //             password1.text.length >= 7) &&
                      //         (password1.text == password2.text)) {
                      //       changePassword();
                      //     } else {
                      //       setState(() {
                      //         showDialogBox = false;
                      //       });
                      //     }
                      //   } else {
                      //     setState(() {
                      //       showDialogBox = false;
                      //     });
                      //   }
                      // }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  void changePassword() async {
    http.post(changePasswordUri, body: {
      'user_phone': '$userNumber',
      'user_password': '${password1.text}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        print(jv.toString());
        if ('${jv['status']}' == '1') {
          Navigator.of(context).pushNamedAndRemoveUntil(
              PageRoutes.signInRoot, (Route<dynamic> route) => false);

          // widget.onVerificationDone();
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }
}
