import 'dart:convert';
import 'package:driver/Components/progressbar.dart';
import 'package:driver/Const/constant.dart';
import 'package:driver/Pages/change_password.dart';
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

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DriverProfilePeople profilePeople;
  var http = Client();
  bool isLoading = false;
  TextEditingController nameC = TextEditingController();
  TextEditingController genderC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController emailC = TextEditingController();

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
    // print('$driverProfileUri  ' + 'dboy_id : ' + '${prefs.getString('db_id')}');
    http.post(driverProfileUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}'
    }).then((value)
        // body: {'dboy_id': '${prefs.getString('db_id')}'}).then((value)
        {
      print('dvd - ${value.body}');
      if (value.statusCode == 200) {
        DriverProfilePeople dstatus =
            DriverProfilePeople.fromJson(jsonDecode(value.body));
        if ('${dstatus.status}' == '1') {
          setState(() {
            profilePeople = dstatus;
            nameC.text = '${profilePeople.driverData.boyName}';
            phoneC.text = '${profilePeople.driverData.boyPhone}';
            emailC.text = '${profilePeople.driverData.password}';
            prefs.setString('boy_name', '${nameC.text}');
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
          locale.myAccount,
          style: TextStyle(
            fontFamily: 'Philosopher-Regular',
            fontWeight: FontWeight.bold,
          ),
        ),
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
                        vertical: MediaQuery.of(context).size.height * 0.012,
                        horizontal: MediaQuery.of(context).size.width * 0.022),
                    child: Image.asset("assets/images/awesome_align_right.png"),
                  )),
            )),
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
              nameC.text.toString() == null || nameC.text.toString() == ""
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
                      height: MediaQuery.of(context).size.height * 0.17,
                      margin: EdgeInsets.only(left: 30),
                      decoration: BoxDecoration(
                        color: kRoundButtonInButton2,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text(
                              nameC.text.isEmpty ? "" : nameC.text[0].toString().toUpperCase(),
                        style: TextStyle(fontSize: 70, color: kRedColor),
                      ))),
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
                textInputAction: TextInputAction.next,
                // label: locale.fullName.toUpperCase(),
                // height: MediaQuery.of(context).size.height * 0.04,
                label: locale.fullName,

                // labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.bold,
                labelFontSize: 17,
                controller: nameC,
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
                label: locale.phoneNumber,
                textInputAction: TextInputAction.next,

                // labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.bold,
                labelFontSize: 17,
                controller: phoneC,
                keyboardType: TextInputType.phone,
                readOnly: true,
                onTap: () {
                  Toast.show(locale.phoneNumberIsNotEdited, context,
                      gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                },
                // style: TextStyle(fontWeight: FontWeight.bold),
                // contentPadding: EdgeInsets.only(
                //     top: MediaQuery.of(context).size.height * 0.03,
                //     bottom: MediaQuery.of(context).size.height * 0.01)
              ),
              EntryField(
                textInputAction: TextInputAction.done,
                // label: locale.password1.toUpperCase(),
                // height: MediaQuery.of(context).size.height * 0.04,
                label: locale.password1,
                // labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.bold,
                labelFontSize: 17,
                controller: emailC,
                obsecureText: true,
                readOnly: true,
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePassword()));
                },
                // style: TextStyle(fontWeight: FontWeight.bold),
                // contentPadding: EdgeInsets.only(
                //     top: MediaQuery.of(context).size.height * 0.03,
                //     bottom: MediaQuery.of(context).size.height * 0.01)
              ),
              // Divider(
              //   height: 20,
              //   thickness: 8,
              //   color: Theme.of(context).dividerColor,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 16.0, bottom: 14, top: 14),
              //   child: Text(
              //     locale.documentation,
              //     style: Theme.of(context).textTheme.subtitle2,
              //   ),
              // ),
              // ListTile(
              //     leading: Icon(
              //       Icons.verified_user,
              //       color: Colors.green,
              //     ),
              //     title: Text(
              //       locale.governmentID + '\n',
              //       style: Theme.of(context)
              //           .textTheme
              //           .subtitle2
              //           .copyWith(fontSize: 13, height: 0.8),
              //     ),
              //     subtitle: Text(
              //       'myvoterid.jpg',
              //       style: Theme.of(context).textTheme.subtitle1,
              //     ),
              //     trailing: Text(
              //       '\n\n' + locale.upload,
              //       style: TextStyle(
              //         color: Theme.of(context).primaryColor,
              //       ),
              //     )),
              // ListTile(
              //     leading: Icon(
              //       Icons.live_help,
              //       color: Colors.green,
              //     ),
              //     title: Text(
              //       locale.governmentID + '\n',
              //       style: Theme.of(context)
              //           .textTheme
              //           .subtitle2
              //           .copyWith(fontSize: 13, height: 0.8),
              //     ),
              //     subtitle: Text(
              //       locale.notUploadedYet,
              //       style: Theme.of(context)
              //           .textTheme
              //           .subtitle2
              //           .copyWith(fontWeight: FontWeight.w300),
              //     ),
              //     trailing: Text(
              //       '\n\n' + locale.upload,
              //       style: TextStyle(
              //         color: Theme.of(context).primaryColor,
              //       ),
              //     )),
              SizedBox(height: 20),

              isLoading
                  ? ProgressBarIndicator()
                  // Container(
                  //     height: 60,
                  //     width: MediaQuery.of(context).size.width,
                  //     alignment: Alignment.center,
                  //     child: Align(
                  //       heightFactor: 40,
                  //       widthFactor: 40,
                  //       child: CircularProgressIndicator(),
                  //     ),
                  //   )
                  : CustomRedButton(
                      label: locale.updateInfo,
                      fontFamily: balooExtraBold,
                      fontSize: 17,
                      height: MediaQuery.of(context).size.height * 0.06,
                      padding: EdgeInsets.only(right: w * 0.03, left: w * 0.03),
                      // margin: EdgeInsets.symmetric(
                      //     horizontal: MediaQuery.of(context).size.width * 0.29),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.3,
                          right: MediaQuery.of(context).size.width * 0.29),
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
                          if (nameC.text.isEmpty) {
                            Toast.show(locale.fullNameIsRequired, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (phoneC.text.isEmpty) {
                            Toast.show(locale.phoneNumberIsRequired, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (emailC.text.isEmpty) {
                            Toast.show(locale.passwordIsRequired, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else if (emailC.text.length < 4) {
                            Toast.show(
                                locale.minimumFourCharacterRequiredInPassword,
                                context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          } else {
                            if (nameC.text != null && nameC.text.length > 0) {
                              if (nameC.text != null && nameC.text.length > 0) {
                                if (nameC.text != null &&
                                    nameC.text.length > 0) {
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
          // Align(
          //     alignment: AlignmentDirectional.bottomCenter,
          //     child: isLoading
          //         ? Container(
          //             height: 60,
          //             width: MediaQuery.of(context).size.width,
          //             alignment: Alignment.center,
          //             child: Align(
          //               heightFactor: 40,
          //               widthFactor: 40,
          //               child: CircularProgressIndicator(),
          //             ),
          //           )
          //         : CustomRedButton(
          //             label: locale.updateInfo,
          //             // color: kRedLightColor,
          //             height: MediaQuery.of(context).size.height * 0.06,
          //             margin: EdgeInsets.symmetric(
          //                 horizontal: MediaQuery.of(context).size.width * 0.25),
          //             prefixIcon: Container(
          //               height: 30,
          //               width: 30,
          //               decoration: BoxDecoration(
          //                 color: kRedLightColor,
          //                 borderRadius: BorderRadius.circular(15.0),
          //                 // image: new DecorationImage(
          //                 //   image: new AssetImage("assets/images/system_update.png",),
          //                 //
          //                 //   // fit: BoxFit.fill,
          //                 // ),
          //               ),
          //               // child: Container(
          //               //   // height: 20,
          //               // // color: kWhiteColor,
          //               child: Image.asset(
          //                   "assets/images/system_update.png",
          //                   // fit: BoxFit.fill,
          //                   // height: 50,
          //                   // height: 30,
          //                 ),
          //               // ),
          //             ),
          //             onTap: () {
          //               if (!isLoading) {
          //                 if (nameC.text != null && nameC.text.length > 0) {
          //                   if (nameC.text != null && nameC.text.length > 0) {
          //                     if (nameC.text != null && nameC.text.length > 0) {
          //                       setState(() {
          //                         isLoading = true;
          //                       });
          //                       updateYourProfile(context);
          //                     } else {
          //                       Toast.show(locale.pleaseallfield, context,
          //                           duration: Toast.LENGTH_SHORT,
          //                           gravity: Toast.CENTER);
          //                     }
          //                   } else {
          //                     Toast.show(locale.pleaseallfield, context,
          //                         duration: Toast.LENGTH_SHORT,
          //                         gravity: Toast.CENTER);
          //                   }
          //                 } else {
          //                   Toast.show(locale.pleaseallfield, context,
          //                       duration: Toast.LENGTH_SHORT,
          //                       gravity: Toast.CENTER);
          //                 }
          //               }
          //             },
          //           )),
        ],
      ),
    );
  }

  void updateYourProfile(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('$driverupdateprofileUri  \n' +
    //     'dboy_id : ' +
    //     // '${prefs.getInt('db_id')}\n' +
    //     '${prefs.getString('db_id').toString()}\n' +
    //     'boy_name : ' +
    //     '${nameC.text.toString()}\n' +
    //     'boy_phone : ' +
    //     '${phoneC.text.toString()}\n' +
    //     'password : ' +
    //     '${emailC.text.toString()}\n'.toString());
    print("prefs.getInt('db_id') : " + prefs.getInt('db_id').toString());
    http.post(driverupdateprofileUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}', // set getSting to getInt
      'boy_name': '${nameC.text}',
      'boy_phone': '${phoneC.text}',
      'password': '${emailC.text}',
    }).then((value) {
      print('dv - ${value.body}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        prefs.setString('boy_name', '${nameC.text}');
        prefs.setString('boy_phone', '${phoneC.text}');
        prefs.setString('password', '${emailC.text}');
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
      print("ERROR : " + e.toString());
    });
  }
}
