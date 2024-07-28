import 'dart:convert';
import 'package:driver/Components/progressbar.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/driverprofile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Components/entry_field.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:developer' as logger;
import 'package:driver/Const/constant.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DriverProfilePeople profilePeople;
  var http = Client();
  bool isLoading = false;
  bool oldPass = false;
  bool newPass = false;
  bool conPass = false;
  TextEditingController oldPassC = TextEditingController();
  TextEditingController newPassC = TextEditingController();
  TextEditingController conPassC = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDrierStatus();
  }

  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    print('$driverProfileUri  ' + 'dboy_id : ' + '${prefs.getInt('db_id')}');
    http.post(driverProfileUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      print('change password dvd - ${value.body}');
      if (value.statusCode == 200) {
        DriverProfilePeople dstatus =
            DriverProfilePeople.fromJson(jsonDecode(value.body));
        if ('${dstatus.status}' == '1') {
          setState(() {
            profilePeople = dstatus;
            logger.log("profilePeople : " + profilePeople.toString());
            // oldPassC.text = '${profilePeople.driverData.password}';
            // newPassC.text = '${profilePeople.driverData.boyPhone}';
            // conPassC.text = '${profilePeople.driverData.password}';
            // prefs.setString('boy_name', '${profilePeople.driverData.boyName}');
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: AccountDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          locale.changePassword,
          // locale.myAccount,
          style: TextStyle(
            fontFamily: 'Philosopher-Regular',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Card(
                color: kWhiteColor,
                child: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  size: 25,
                  color: kRedColor,
                )),
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            "assets/images/edit_profile.png",
            fit: BoxFit.cover,
          ),
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              // Divider(
              //   thickness: 8,
              //   color: Theme.of(context).dividerColor,
              // ),
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
              //   child: Text(
              //     locale.featureImage,
              //     style: Theme.of(context).textTheme.subtitle2,
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Image.asset(
              //         'assets/imgprofile.png',
              //         height: 100,
              //         fit: BoxFit.fill,
              //       ),
              //       SizedBox(
              //         width: 25,
              //       ),
              //       Icon(
              //         Icons.camera_alt,
              //         size: 26,
              //       ),
              //       SizedBox(
              //         width: 15,
              //       ),
              //       Text(
              //         locale.uploadPhoto,
              //         style: TextStyle(
              //             color: Theme.of(context).focusColor, height: 1.5),
              //       )
              //     ],
              //   ),
              // ),
              // Divider(
              //   // thickness: 8,
              //   color: Theme.of(context).dividerColor,
              //   height: 10,
              // ),
              SizedBox(
                height: 20,
              ),
              profilePeople == null || profilePeople == ""
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.17,
                      margin: EdgeInsets.only(left: 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/user.png",
                          fit: BoxFit.cover,
                        ),
                      ))
                  : Container(
                      // color: kRedLightColor,
                      // height: MediaQuery.of(context).size.height * 0.17,
                      height: MediaQuery.of(context).size.height * 0.17,
                      margin: EdgeInsets.only(left: 30),
                      decoration: BoxDecoration(
                        color: kRoundButtonInButton2,
                        shape: BoxShape.circle,
                        // borderRadius: BorderRadius.circular(100)
                      ),
                      child: Center(
                          child: Text(
                        profilePeople.driverData.boyName[0]
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(fontSize: 70, color: kRedColor),
                      )),
                      // child: Image.asset(
                      //   "assets/images/driver_logo.png",
                      //   // height: MediaQuery.of(context).size.height * 0.3,
                      //   fit: BoxFit.contain,
                      // ),
                    ),
              SizedBox(
                height: 20,
              ),
              // Divider(
              //   thickness: 1,
              //   color: Theme.of(context).dividerColor,
              //   height: 2,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 16.0, bottom: 14),
              //   child: Text(
              //     locale.profileInfo,
              //     style: Theme.of(context).textTheme.subtitle2,
              //   ),
              // ),
              EntryField(
                // label: locale.fullName.toUpperCase(),
                // height: MediaQuery.of(context).size.height * 0.04,
                label: locale.oldPassword,
                // locale.fullName,
                // labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.bold,
                labelFontSize: 16,
                controller: oldPassC,
                suffixIcon: oldPass ? Icons.visibility_off : Icons.visibility,
                obsecureText: !oldPass,
                suffixIconColor: kGrey,
                suffixIconSize: 25,
                onSuffixPressed: () {
                  setState(() {
                    oldPass = !oldPass;
                  });
                },
                // suffixIcon: IconButton(
                //     onPressed: () {
                //       setState(() {
                //
                //       });
                //     },
                //     icon: Icon(
                //       oldPass
                //           ? Icons.visibility
                //           : Icons.visibility_off,
                //       color: kGrey,
                //     )),
                // style: TextStyle(fontWeight: FontWeight.bold),
                // contentPadding: EdgeInsets.only(
                //     top: MediaQuery.of(context).size.height * 0.03,
                //     bottom: MediaQuery.of(context).size.height * 0.01)
              ),
              // EntryField(
              //   label: locale.gender.toUpperCase(),
              //   labelColor: Theme.of(context).disabledColor,
              //   labelFontWeight: FontWeight.w500,
              //   labelFontSize: 16,
              //   suffixIcon: Icons.keyboard_arrow_down,
              //   controller: genderC,
              // ),
              EntryField(
                // label: locale.phoneNumber.toUpperCase(),
                // height: MediaQuery.of(context).size.height * 0.04,
                label: locale.newPassword,
                //locale.phoneNumber,
                // labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.bold,
                labelFontSize: 16,
                controller: newPassC,
                suffixIcon: newPass ? Icons.visibility_off : Icons.visibility ,
                obsecureText: !newPass,
                suffixIconColor: kGrey,
                suffixIconSize: 25,
                onSuffixPressed: () {
                  setState(() {
                    newPass = !newPass;
                  });
                },
                // keyboardType: TextInputType.phone,

                // style: TextStyle(fontWeight: FontWeight.bold),
                // contentPadding: EdgeInsets.only(
                //     top: MediaQuery.of(context).size.height * 0.03,
                //     bottom: MediaQuery.of(context).size.height * 0.01)
              ),
              EntryField(
                // label: locale.password1.toUpperCase(),
                // height: MediaQuery.of(context).size.height * 0.04,
                label: locale.confirmPassword,
                //locale.password1,
                // labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.bold,
                labelFontSize: 16,
                controller: conPassC,
                suffixIcon: conPass ?  Icons.visibility_off : Icons.visibility,
                obsecureText: !conPass,
                suffixIconColor: kGrey,
                suffixIconSize: 25,
                onSuffixPressed: () {
                  setState(() {
                    conPass = !conPass;
                  });
                },
                // obsecureText: true,
                // style: TextStyle(fontWeight: FontWeight.bold),
                // contentPadding: EdgeInsets.only(
                //     top: MediaQuery.of(context).size.height * 0.03,
                //     bottom: MediaQuery.of(context).size.height * 0.01)
              ),
              SizedBox(height: 20),
              isLoading
                  ? ProgressBarIndicator()
                  : CustomRedButton(
                      fontFamily: balooExtraBold,
                      fontSize: 17,
                      label: locale.save,
                      // locale.,
                      height: MediaQuery.of(context).size.height * 0.06,
                      padding: EdgeInsets.symmetric(horizontal: w*0.025),
                      // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.29),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.34,
                          right: MediaQuery.of(context).size.width * 0.34),
                      prefixIcon: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: kRedLightColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/system_update.png",
                          ),
                        ),
                      ),
                      onTap: () {
                        if (!isLoading) {
                          if (oldPassC.text.isEmpty &&
                              newPassC.text.isEmpty &&
                              conPassC.text.isEmpty) {
                            Toast.show(locale.pleaseallfield, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (oldPassC.text.isEmpty) {
                            Toast.show(locale.oldPasswordIsRequired, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (oldPassC.text.toString() !=
                              profilePeople.driverData.password) {
                            Toast.show(locale.oldPasswordIsMisMatched, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (newPassC.text.isEmpty) {
                            Toast.show(locale.newPasswordIsRequired, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (conPassC.text.isEmpty) {
                            Toast.show(
                                locale.confirmPasswordIsRequired, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (conPassC.text.length < 4 ||
                              newPassC.text.length < 4) {
                            Toast.show(
                                locale.minimumFourCharacterRequiredInPassword,
                                context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (newPassC.text.toString() !=
                              conPassC.text.toString()) {
                            Toast.show(
                                locale.oldAndNewPasswordMustbeSame, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else {
                            if (oldPassC.text != null &&
                                oldPassC.text.length > 0) {
                              if (newPassC.text != null &&
                                  newPassC.text.length > 0) {
                                if (conPassC.text != null &&
                                    conPassC.text.length > 0) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  updateYourProfile(context);
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
                    )
            ],
          ),
        ],
      ),
    );
  }

  void updateYourProfile(BuildContext context) async {
    logger
        .log("driverupdatePasswordUri : " + driverupdatePasswordUri.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('$driverupdatePasswordUri  ' +
        'dboy_id : ' +
        '${prefs.getInt('db_id')}\n' +
        'boy_name : ' +
        '${profilePeople.driverData.boyName}\n' +
        'old_password : ' +
        '${oldPassC.text}\n' +
        'new_password : ' +
        '${newPassC.text}\n');
    http.post(driverupdatePasswordUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      'old_password': '${oldPassC.text}',
      'new_password': '${newPassC.text}',
    }).then((value) {
      print('****************************************');
      print('RESPONSE CHANGE PASSWORD dv - ${value.body}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        // prefs.setString('boy_name', '${nameC.text}');
        // prefs.setString('boy_phone', '${phoneC.text}');
        prefs.setString('password', '${newPassC.text}');
      }
      Toast.show(js['message'], context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
  }
}
