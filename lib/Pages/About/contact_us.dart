import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Components/entry_field_profile.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController numberC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController messageC = TextEditingController();
  var userName;
  var userNumber;
  int numberlimit = 1;

  var http = Client();

  bool isLoading = false;
  // static  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getProfileDetails();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getProfileDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userName = preferences.getString('store_name');
      userNumber = preferences.getString('phone_number');
      numberlimit = int.parse('${preferences.getString('numberlimit')}');
      nameC.text = '$userName';
      numberC.text = '${userNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: Theme(
          data: Theme.of(context).copyWith(
            // Set the transparency here
            canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
          ),
          child: buildDrawer(context: context)),
      // appBar: AppBar(
      //   title: Text(
      //     locale.contactUs,
      //     style: TextStyle(color: kMainTextColor),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 30),
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/t_c_back.png"), fit: BoxFit.cover)),
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
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                        ),
                        height: 30,
                        width: 30,
                        child: IconButton(
                          icon: ImageIcon(AssetImage('assets/Icon_awesome_align_right.png')),
                          iconSize: 15,
                          onPressed: () {
                            _scaffoldKey.currentState.openDrawer();
                          },
                          color: kRoundButtonInButton,
                          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                        ),
                      ),
                    ),
                    Center(child: Text(locale.helpCentre, style: Theme.of(context).textTheme.headline6.copyWith(color: kRoundButtonInButton, fontSize: 18),)),
                  ],
                ),
              ),
              Image.asset('assets/image_shop.png', scale: 1, height: 280),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(locale.callBackReq2,textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1..copyWith(fontSize: 16,color: kTextBlack),),
                    ),
                    SizedBox(height: 20),
                    isLoading?Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        widthFactor: 40,
                        heightFactor: 40,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                    ):Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          iconGap: 10,
                          color: kRoundButton,
                          label: locale.callBackReq1,
                          imageAssets: 'assets/icon_phone.png',
                          onTap: (){
                            if (!isLoading) {
                              setState(() {
                                isLoading = true;
                              });
                              sendCallBackRequest();
                            }
                          },
                        ),
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
                    //         sendCallBackRequest();
                    //       }
                    //     },
                    //     child: Text(locale.callBackReq1),
                    //   ),
                    // )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical:20.0,horizontal: 5),
                child: Text(locale.or, textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1.copyWith(color: kSearchIconColour,fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical:10.0,horizontal: 5),
                child: Text(locale.letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures, textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 16,color: kTextBlack),),
              ),
              Divider(thickness: 3.5, color: Colors.transparent),
              EntryFieldProfile(
                  labelFontSize: 16,
                  controller: nameC,
                  readOnly: true,
                  labelFontWeight: FontWeight.w400,
                  label: locale.fullName),
              EntryFieldProfile(
                  controller: numberC,
                  labelFontSize: 16,
                  maxLength: numberlimit,
                  readOnly: true,
                  labelFontWeight: FontWeight.w400,
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
                    hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: kHintColor, fontSize: 14, fontWeight: FontWeight.w400),
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
              // EntryFieldProfile(
              //     hint: locale.enterYourMessage,
              //     controller: messageC,
              //     labelFontSize: 16,
              //     labelFontWeight: FontWeight.w400,
              //     label: locale.yourFeedback),
              Divider(thickness: 3.5, color: Colors.transparent),
              isLoading?Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: Align(
                  widthFactor: 40,
                  heightFactor: 40,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ):Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    label: locale.submit,
                    iconGap: 10,
                    color: kRoundButton,
                    imageAssets: 'assets/icon_send.png',
                    onTap: () {
                      if(!isLoading){
                        setState(() { isLoading = true; });
                        if (messageC.text != null&&messageC.text != ''&&!isAllSpaces(messageC.text)) {
                          sendFeedBack(messageC.text);
                        }else{
                          Toast.show(locale.enterMessage, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
                          setState(() { isLoading = false;  });
                        }
                      }
                    },
                  ),
                ],
              ),
              Divider(thickness: 3.5, color: Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }
  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if(output == '') {
      return true;
    }
    return false;
  }
  void sendFeedBack(dynamic message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('sendCallBackRequest => url : $storeCallbackReqUri ||store_id : ${preferences.getInt('store_id')} || feedback : $message');
    http.post(storeFeedbackUri, body: {'store_id': '${preferences.getInt('store_id')}', 'feedback': '$message'}).then((value) {
      if (value.statusCode == 200) {
        var jsData = jsonDecode(value.body);
        print('sendFeedBack => jsData : $jsData');
        if('${jsData['status']}' == '1'){
           Toast.show(jsData['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
           setState(() {  messageC.text = '';   });
        }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('sendFeedBack ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }

  void sendCallBackRequest() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('sendCallBackRequest => url : $storeCallbackReqUri ||store_id : ${preferences.getInt('store_id')}');
    http.post(storeCallbackReqUri, body: {'store_id': '${preferences.getInt('store_id')}'}).then((value) {
      if (value.statusCode == 200) {
        var jsData = jsonDecode(value.body);
        print('sendCallBackRequest => jsData : $jsData');
        if('${jsData['status']}' == '1'){
          Toast.show(jsData['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('sendCallBackRequest ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }
}
