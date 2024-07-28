import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Components/entry_field_profile.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController numberC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController messageC = TextEditingController();
  var userName;
  bool islogin = false;
  var userNumber;
  int numberlimit = 1;
  List<StoreFinderData> storeDataList = [];
  StoreFinderData storeD;
  String selectCity = 'Select Store';
  bool isLoading = false;
  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;
  var http = Client();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _ContactUsPageState() {
    storeD = StoreFinderData('', '', 'Select Store', '', '', '');
    storeDataList.add(storeD);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getProfileDetails();
    });





  }

  void getProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('storelist', '');
    // prefs.setString('store_id_last', '');
    var locale = AppLocalizations.of(context);
    setState(() {
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      userNumber = prefs.getString('user_phone');
      emailAddress = prefs.getString('user_email');
      mobileNumber = prefs.getString('user_phone');
      _image = '$imagebaseUrl${prefs.getString('user_image')}';
      numberlimit = int.parse('${prefs.getString('numberlimit')}');
      nameC.text = islogin ? '$userName' : '';
      numberC.text = islogin ? '$userNumber' : '';
      SchedulerBinding.instance.addPostFrameCallback((_) => showAlertDialog(context));
    });
    int st = -1;
    if (prefs.containsKey('store_id_last') &&
        prefs.getString('store_id_last').length > 0) {
      st = int.parse('${prefs.getString('store_id_last')}');
      print('$st');
      if (prefs.containsKey('storelist')) {
        print('dd - $st');
        print('${prefs.getString('storelist')}');
        var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
        List<StoreFinderData> dataFinderL = [];
        dataFinderL = List.from(
            storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
        dataFinderL.add(StoreFinderData('', '', 'Not to store', '', '', ''));
        setState(() {
          print('${dataFinderL.toString()}');
          storeDataList.clear();
          storeDataList = dataFinderL;
        });
        int idd1 = dataFinderL.indexOf(StoreFinderData('', st, '', '', '', ''));
        if (idd1 >= 0) {
          setState(() {
            storeD = dataFinderL[idd1];
            selectCity = storeD.store_name;
            print('${storeD.toString()} - $selectCity');
          });
        }
      }
    } else {
      print('d3 - $st');
      setState(() {
        storeDataList.clear();
        storeD = null;
        selectCity = locale.selectStore;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    // final  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context, userName, emailAddress, _image, islogin,
            onHit: () {
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

      // appBar: AppBar(
      //   title: Text(
      //     locale.contactUs,
      //     style: TextStyle(color: kMainTextColor),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        padding: EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/t_c_back.png"),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.black12,
                                spreadRadius: 1)
                          ],
                        ),
                        height: 30,
                        width: 30,
                        child: IconButton(
                          icon: ImageIcon(
                            AssetImage(
                              'assets/Icon_awesome_align_right.png',
                            ),
                          ),
                          iconSize: 15,
                          onPressed: () {
                            _scaffoldKey.currentState.openDrawer();
                          },
                          tooltip: MaterialLocalizations.of(context)
                              .openAppDrawerTooltip,
                        ),
                      ),
                    ),
                    Center(
                        child: Text(
                      locale.helpCentre,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: kMainHomeText, fontSize: 18),
                    )),
                  ],
                ),
              ),
              Image.asset(
                'assets/image_shop.png',
                scale: 1,
                height: 280,
              ),
              Visibility(
                visible: (storeDataList != null && storeDataList.length > 0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<StoreFinderData>(
                          hint: Text(
                            selectCity,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                          isExpanded: true,
                          iconEnabledColor: kMainTextColor,
                          iconDisabledColor: kMainTextColor,
                          iconSize: 30,
                          icon: Image.asset(
                            'assets/icondown.png',
                            height: 12,
                            width: 12,
                          ),
                          items: storeDataList.map((value) {
                            return DropdownMenuItem<StoreFinderData>(
                              value: value,
                              child: Text(value.store_name,
                                  overflow: TextOverflow.clip),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              storeD = value;
                              selectCity = value.store_name;
                            });
                            print(value.store_name);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          locale.callBackReq2,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontSize: 16, color: kTextBlack),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                              iconGap: 10,
                              color: kRoundButton,
                              label: locale.callBackReq1,
                              imageAssets: 'assets/icon_phone.png',
                              onTap: () {
                                if (!islogin) {
                                  showAlertDialog(context);
                                } else {
                                  if (!isLoading) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (selectCity != locale.selectStore ||
                                        selectCity != locale.notToStore) {
                                      sendCallBackRequest(
                                          context, storeD.store_id);
                                    } else {
                                      sendCallBackRequest(context, '');
                                    }
                                  }
                                }
                              }),
                        ],
                      ),
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(40),
                      //   child: RaisedButton(
                      //     onPressed: () {
                      //       if (!isLoading) {
                      //         setState(() {
                      //           isLoading = true;
                      //         });
                      //         if (selectCity != 'Select Store' ||
                      //             selectCity != 'Not to store') {
                      //           sendCallBackRequest(context, storeD.store_id);
                      //         } else {
                      //           sendCallBackRequest(context, '');
                      //         }
                      //       }
                      //     },
                      //     child: Text(locale.callBackReq1),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 3.5,
                color: Colors.transparent,
              ),
              Center(
                  child: Text(
                'OR',
                style: TextStyle(color: kSearchIconColour, fontSize: 16),
              )),
              Divider(
                thickness: 3.5,
                color: Colors.transparent,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Text(
                  locale.letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontSize: 16, color: kTextBlack),
                ),
              ),
              Divider(
                thickness: 3.5,
                color: Colors.transparent,
              ),
              EntryFieldProfile(
                  labelFontSize: 18,
                  controller: nameC,
                  hint: locale.enterYourName,
                  readOnly: true,
                  keyboardType: TextInputType.name,
                  labelFontWeight: FontWeight.normal,
                  label: locale.fullName),
              EntryFieldProfile(
                  controller: numberC,
                  labelFontSize: 16,
                  maxLength: numberlimit,
                  readOnly: true,
                  labelFontWeight: FontWeight.normal,
                  label: locale.phoneNumber),
              Container(
                margin: EdgeInsets.all(10),
                // height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: kBorderColor, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: kWhiteColor,
                  // boxShadow: [
                  //   BoxShadow(blurRadius: , color: Colors.black12,offset: Offset(0.0, 0.75))
                  // ],
                ),
                child: EntryFieldProfile(
                    hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: kHintColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                    hint: locale.enterYourMessage,
                    controller: messageC,
                    labelFontSize: 18,
                    isdence : true,
                     underlineColor: Colors.transparent,
                    labelFontWeight: FontWeight.normal,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    label: locale.yourFeedback),
              ),
              Divider(
                thickness: 3.5,
                color: Colors.transparent,
              ),
              isLoading
                  ? Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        widthFactor: 40,
                        heightFactor: 40,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                            iconGap: 10,
                            color: kRoundButton,
                            imageAssets: 'assets/icon_send.png',
                            label: locale.submit,
                            onTap: () {
                              if (!islogin) {
                                showAlertDialog(context);
                              } else {
                                if (numberC.text != null &&
                                    numberC.text != '' &&
                                    nameC.text != null &&
                                    nameC.text != '' &&
                                    messageC.text != null &&
                                    messageC.text != '') {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  sendFeedBack(messageC.text, context);
                                } else {
                                  Toast.show(
                                      locale.enterMessage,
                                      context,
                                      gravity: Toast.CENTER,
                                      duration: Toast.LENGTH_SHORT);
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            }),
                      ],
                    ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

  void sendFeedBack(dynamic message, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    http.post(userFeedbackUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'feedback': '$message'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          messageC.clear();
        }
        Toast.show(js['message'], context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
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

  void sendCallBackRequest(BuildContext context, dynamic store_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    http.post(callbackReqUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'store_id': '$store_id',
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        // if('${js['status']}'=='1'){
        //   messageC.clear();
        // }
        Toast.show(js['message'], context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
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
                onPressed: () =>SharedPreferences.getInstance().then((pref) {
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
}
