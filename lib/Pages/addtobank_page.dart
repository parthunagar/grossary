import 'dart:convert';
import 'package:driver/Components/progressbar.dart';
import 'package:driver/Const/constant.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/driverstatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Components/entry_field.dart';
import 'package:driver/Locale/locales.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:developer' as logger;

class AddToBank extends StatefulWidget {
  @override
  AddState createState() {
    return AddState();
  }
}

class AddState extends State<AddToBank> {
  var http = Client();
  bool isLoading = false;
  int totalOrder = 0;
  double totalincentives = 0.0;
  dynamic apCurrency;

  TextEditingController upiC = TextEditingController();
  TextEditingController accountC = TextEditingController();
  TextEditingController ifscC = TextEditingController();
  TextEditingController bankC = TextEditingController();
  TextEditingController accountHolderC = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getDrierStatus();
  }

  void setMoneyToBank() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logger.log('$driverBankUri  ' +
        'dboy_id : ' +
        '${prefs.getInt('db_id')}' +
        'ac_no :' +
        '${accountC.text}' +
        'ac_holder : ' +
        '${accountHolderC.text}' +
        'ifsc : ' +
        '${ifscC.text}' +
        'bank_name : ' +
        '${bankC.text}' +
        'upi : ' +
        '${upiC.text}');
    http.post(driverBankUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      'ac_no': '${accountC.text}',
      'ac_holder': '${accountHolderC.text}',
      'ifsc': '${ifscC.text}',
      'bank_name': '${bankC.text}',
      'upi': '${upiC.text}',
    }).then((value) {
      print('dv - ${value.body}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        accountHolderC.clear();
        accountC.clear();
        ifscC.clear();
        upiC.clear();
        bankC.clear();
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

  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      apCurrency = prefs.getString('app_currency');
    });
    print('$driverStatusUri ' + 'dboy_id : ' + '${prefs.getInt('db_id')}');
    http.post(driverStatusUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        DriverStatus dstatus = DriverStatus.fromJson(jsonDecode(value.body));
        if ('${dstatus.status}' == '1') {
          setState(() {
            int onoff = int.parse('${dstatus.onlineStatus}');
            prefs.setInt('online_status', onoff);
            totalOrder = int.parse('${dstatus.totalOrders}');
            totalincentives = double.parse('${dstatus.totalIncentive}');
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
    var locale = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          locale.sendToBank,
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
      drawer: AccountDrawer(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Card(
                      color: kWhiteColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      // text: locale.availableBalance + '\n'.toUpperCase(),
                                      text: locale.advanceValue + '\n', style: Theme.of(context).textTheme.bodyText2.copyWith(color: kRedLightColor,
                                              // fontFamily: balooMedium,
                                              // height: 2.0,
                                              fontSize: 15)),
                                  TextSpan(text: '$apCurrency $totalincentives', style: Theme.of(context).textTheme.headline4.copyWith(color: kMainTextColor, fontSize: 20)),
                                ])),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 20.0, vertical: 10),
                  //   child: Text(
                  //     locale.bankInfo.toUpperCase(),
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .headline6
                  //         .copyWith(fontSize: 15),
                  //   ),
                  // ),
                  EntryField(
                    // autoFocus: true,
                    // labelColor:  Theme.of(context).disabledColor,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    // label: locale.accountHolderName.toUpperCase(),
                    label: locale.accountHolderName,
                    // underlineColor: kRedColor,
                    labelFontSize: 17,
                    readOnly: isLoading,
                    labelFontWeight: FontWeight.w700,
                    controller: accountHolderC,
                    hint: locale.enterAccountHolderName,
                    hintStyle: TextStyle(
                      color: kEntryFieldLable,
                    ),
                  ),
                  EntryField(

                    // labelColor: Theme.of(context).disabledColor,
                    textInputAction: TextInputAction.next,
                    labelFontSize: 17,
                    labelFontWeight: FontWeight.w700,

                    textCapitalization: TextCapitalization.words,
                    // label: locale.bankName.toUpperCase(),
                    label: locale.bankName,
                    readOnly: isLoading,
                    controller: bankC,
                    hint: locale.enterYourbankName,
                    hintStyle: TextStyle(color: kEntryFieldLable),
                  ),
                  EntryField(
                    // labelColor: Theme.of(context).disabledColor,
                    textInputAction: TextInputAction.next,
                    labelFontSize: 17,
                    labelFontWeight: FontWeight.w700,
                    textCapitalization: TextCapitalization.none,
                    // label: locale.branchCode.toUpperCase(),
                    label: locale.branchCode,
                    readOnly: isLoading,
                    controller: ifscC,
                    hint: locale.enterYourBankBranchCode,
                    hintStyle: TextStyle(
                      color: kEntryFieldLable,
                    ),
                  ),
                  EntryField(
                    // labelColor: Theme.of(context).disabledColor,
                    textInputAction: TextInputAction.next,
                    labelFontSize: 17,
                    labelFontWeight: FontWeight.w700,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.phone,
                    readOnly: isLoading,
                    // label: locale.accountNumber.toUpperCase(),
                    label: locale.accountNumber,
                    controller: accountC,
                    hint: locale.enterYourBankAccounNumber,
                    hintStyle: TextStyle(
                      color: kEntryFieldLable,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 8.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: EntryField(
                      onSubmitted:() => FocusScope.of(context).unfocus(),
                      // labelColor: Theme.of(context).disabledColor,
                      textInputAction: TextInputAction.done,
                      labelFontSize: 17,
                      labelFontWeight: FontWeight.w700,
                      textCapitalization: TextCapitalization.words,
                      // label: locale.upilable.toUpperCase(),
                      label: locale.upilable,
                      controller: upiC,
                      hint: locale.enterYourBankUPINumber,
                      hintStyle: TextStyle(
                        color: kEntryFieldLable,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
            ),
          ),
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
              // : CustomButton(
              //     label: locale.sendToBank,
              //     onTap: () {
              //       if (!isLoading) {
              //         if (accountC.text != null && accountC.text.length > 0) {
              //           if (accountHolderC.text != null &&
              //               accountHolderC.text.length > 0) {
              //             if (ifscC.text != null && ifscC.text.length > 0) {
              //               if (bankC.text != null && bankC.text.length > 0) {
              //                 setState(() {
              //                   isLoading = true;
              //                 });
              //                 setMoneyToBank();
              //               } else {
              //                 Toast.show(locale.pleaseallfield, context,
              //                     duration: Toast.LENGTH_SHORT,
              //                     gravity: Toast.CENTER);
              //               }
              //             } else {
              //               Toast.show(locale.pleaseallfield, context,
              //                   duration: Toast.LENGTH_SHORT,
              //                   gravity: Toast.CENTER);
              //             }
              //           } else {
              //             Toast.show(locale.pleaseallfield, context,
              //                 duration: Toast.LENGTH_SHORT,
              //                 gravity: Toast.CENTER);
              //           }
              //         } else {
              //           Toast.show(locale.pleaseallfield, context,
              //               duration: Toast.LENGTH_SHORT,
              //               gravity: Toast.CENTER);
              //         }
              //       }
              //     },
              //   ),
              : CustomRedButton(
                  label: locale.sendToBank,
                  fontFamily: balooExtraBold,
                  fontSize: 17,
                  // color: kRedLightColor,
                  height: MediaQuery.of(context).size.height * 0.06,
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.03,
                      left: MediaQuery.of(context).size.width * 0.05),
                  // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.24),
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.27,
                      right: MediaQuery.of(context).size.width * 0.28),
                  prefixIcon: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: kRedLightColor,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Image.asset(
                        "assets/images/ios_send.png",
                      ),
                    ),
                  ),
                  onTap: () {
                    RegExp regexAccountNumber = new RegExp(phonePattern);
                    RegExp regexSpecialCharacter = new RegExp(specialCharacter);
                    if (!isLoading) {

                      // it's follow all field is empty
                      if (accountHolderC.text.isEmpty &&
                          bankC.text.isEmpty &&
                          ifscC.text.isEmpty &&
                          accountC.text.isEmpty) {
                        Toast.show(locale.pleaseallfield, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account holder name is empty
                      } else if (accountHolderC.text.isEmpty) {
                        Toast.show(locale.accountHolderNameIsRequired, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account holder name is contain number
                      } else if (regexAccountNumber
                          .hasMatch(accountHolderC.text)) {
                        Toast.show(
                            locale.numericValueNotAllowedInAccountHolderName,
                            context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account bank name is empty
                      } else if (bankC.text.isEmpty) {
                        Toast.show(locale.bankNameIsRequired, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account bank name is contain number
                      } else if (regexAccountNumber.hasMatch(bankC.text)) {
                        Toast.show(
                            locale.numericValueNotAllowedInBankName, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account bank code is empty
                      } else if (ifscC.text.isEmpty) {
                        Toast.show(locale.branchCodeIsRequired, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow bank code is contain special character
                      } else if (regexSpecialCharacter.hasMatch(ifscC.text)) {
                        Toast.show(
                            locale.specialCharacterNotAllowedInBankName,
                            context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account number is empty
                      } else if (accountC.text.isEmpty) {
                        Toast.show(locale.accountNumberIsRequired, context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                        // it's follow account number is contain character value
                      } else if (!regexAccountNumber.hasMatch(accountC.text)) {
                        Toast.show(
                            locale.onlyNumericValueAllowedInAccountNumber,
                            context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                      } else {
                        // it's follow all validation perform and all field are not blank
                        if (accountC.text != null && accountC.text.length > 0) {
                          if (accountHolderC.text != null &&
                              accountHolderC.text.length > 0) {
                            if (ifscC.text != null && ifscC.text.length > 0) {
                              if (bankC.text != null && bankC.text.length > 0) {
                                setState(() {
                                  isLoading = true;
                                });
                                setMoneyToBank();
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
    );
  }
}
