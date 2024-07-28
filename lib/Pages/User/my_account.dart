import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Components/entry_field_profile.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Other/add_address.dart';
import 'package:groshop/Pages/User/profileedit.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/addressbean/showaddress.dart';
import 'package:groshop/beanmodel/signinmodel.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  var nameControler = TextEditingController();
  var emailControler = TextEditingController();
  var phoneControler = TextEditingController();
  String userName;
  bool islogin = false;
  String emailAddress;
  String mobileNumber;
  String _image;
  List<ShowAllAddressMain> allAddressData = [];
  bool isAddressLoading = false;

  @override
  void initState() {
    super.initState();
    getProfileValue();
  }

  void getProfileValue() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('user_name');
      emailAddress = preferences.getString('user_email');
      mobileNumber = preferences.getString('user_phone');
      _image = '$imagebaseUrl${preferences.getString('user_image')}';
      nameControler.text = userName;
      emailControler.text = emailAddress;
      phoneControler.text = mobileNumber;
    });
    getAddressByUserId(userId);
    getProfileFromInternet(userId);
  }

  void getProfileFromInternet(dynamic userId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = myProfileUri;

    print('Response request : $url ${userId}');


    await http.post(url, body: {
      'user_id': '${userId}'
    }).then((response) {
      print('getProfileFromInternet : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if(signInData.status == "1" || signInData.status==1){
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
          setState(() {
            userName = prefs.getString('user_name');
            emailAddress = prefs.getString('user_email');
            mobileNumber = prefs.getString('user_phone');
            _image = '$imagebaseUrl${prefs.getString('user_image')}';
            nameControler.text = userName;
            emailControler.text = emailAddress;
            phoneControler.text = mobileNumber;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getAddressByUserId(dynamic userId) async{
    setState(() {
      isAddressLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = showAllAddressUri;
    await http.post(url, body: {
      'user_id': '${userId}'
    }).then((response) {
      print('getAddressByUserId : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var js = jsonDecode(response.body) as List;
        if(js!=null && js.length>0){
          allAddressData = js.map((e) => ShowAllAddressMain.fromJson(e)).toList();
        }
      }
      setState(() {
        isAddressLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isAddressLoading = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer:Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context, userName,emailAddress,_image, islogin, onHit: () {
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
      //     locale.myAccount,
      //     style: TextStyle(color: kMainTextColor),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        color: kMyAccountBack,
        child: SingleChildScrollView(
          child: Stack(
            children: [

              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                  ],
                ),
                margin: EdgeInsets.only(top: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 60,
                          ),
                          // Text(
                          //   locale.myProfile,
                          //   style: Theme.of(context).textTheme.headline6.copyWith(
                          //       fontSize: 16, letterSpacing: 1, color: Color(0xffa9a9a9)),
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // Container(
                          //   width: MediaQuery.of(context).size.width,
                          //   decoration: BoxDecoration(
                          //       border: Border.all(color: kMainColor),
                          //       borderRadius: BorderRadius.circular(5.0)),
                          //   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                          //   child: Row(
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Expanded(
                          //         child: GestureDetector(
                          //           onTap:(){
                          //             Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEdit()));
                          // },
                          //           behavior: HitTestBehavior.opaque,
                          //           child: Text(
                          //             locale.profileclickupdate,
                          //             textAlign: TextAlign.center,
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .headline6
                          //                 .copyWith(
                          //                 color: kMainColor,
                          //                 fontWeight: FontWeight.bold,
                          //                 fontSize: 16),
                          //           ),
                          //         ),
                          //       ),
                          //       SizedBox(
                          //         width: 10.0,
                          //       ),
                          //       (_image!=null)?CachedNetworkImage(
                          //         imageUrl: '${_image}',
                          //         height: 100,
                          //         width: 120,
                          //         fit: BoxFit.fill,
                          //         placeholder: (context, url) => Align(
                          //           widthFactor: 50,
                          //           heightFactor: 50,
                          //           alignment: Alignment.center,
                          //           child: Container(
                          //             padding: const EdgeInsets.all(5.0),
                          //             width: 50,
                          //             height: 50,
                          //             child: CircularProgressIndicator(
                          //                 valueColor:AlwaysStoppedAnimation<Color>(kRoundButton)
                          //             ),
                          //           ),
                          //         ),
                          //         errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                          //       ):Image(
                          //         image: AssetImage('assets/icon.png'),
                          //         height: 100,
                          //         width: 120,
                          //         fit: BoxFit.fill,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(height: 20.0),
                          EntryFieldProfile(
                            readOnly: true,
                            controller: nameControler,
                            labelFontWeight: FontWeight.w400,
                            horizontalPadding: 0,
                            label: locale.fullName,
                            labelFontSize: 18,
                            underlineColor: kTextBlack,
                          ),
                          EntryFieldProfile(
                            readOnly: true,
                            controller: emailControler,
                            labelFontWeight: FontWeight.w400,
                            horizontalPadding: 0,
                            label: locale.emailAddress,
                            labelFontSize: 18,
                            underlineColor: kTextBlack,

                          ),
                          EntryFieldProfile(
                            readOnly: true,
                            controller: phoneControler,
                            labelFontWeight: FontWeight.w400,
                            horizontalPadding: 0,
                            label: locale.phoneNumber,
                            labelFontSize: 18,
                            underlineColor: kTextBlack,
                          ),
                        ],
                      ),
                    ),
                    // Divider(
                    //   color: Colors.grey[100],
                    //   thickness: 10,
                    //   height: 40,
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            locale.myAddresses,
                            style: Theme.of(context).textTheme.headline6.copyWith(
                                fontSize: 16, letterSpacing: 1, color: Color(0xffa9a9a9)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          (!isAddressLoading && allAddressData!=null && allAddressData.length>0)?
                          ListView.builder(
                              itemCount: allAddressData.length,
                              shrinkWrap: true,
                              primary: false,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                return buildAddressTile(context,allAddressData[index].type,allAddressData[index].data);
                              }):Container(
                            alignment: Alignment.center,
                            child: (isAddressLoading)?Align(
                              widthFactor: 50,
                              heightFactor: 50,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                  valueColor:AlwaysStoppedAnimation<Color>(kRoundButton)
                              ),
                            ):Text(locale.noaddressfound),
                          )
                          // buildAddressTile(
                          //     locale.home,
                          //     '1124, Patestine Street, Jackson Tower,\nNear City Garden, New York, USA'
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // buildAddressTile(
                          //     locale.office,
                          //     '1124, Patestine Street, Jackson Tower,\nNear City Garden, New York, USA'
                          // ),
                        ],
                      ),
                    ),
                    // Spacer(),
                    Divider(
                      thickness: 3,
                      color: Colors.transparent,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          iconGap: 12,
                          imageAssets: 'assets/icon_location.png',
                          color: kRoundButton,
                          label: locale.addAddress,
                          onPress: AddAddressPage(),
                          action: () async{
                            print('action success!');
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            getAddressByUserId(pref.getInt('user_id'));
                          },
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 20,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(

                    margin: EdgeInsets.only(top: 30),
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
                                print('Pressed');
                              },
                              tooltip: MaterialLocalizations.of(context)
                                  .openAppDrawerTooltip,
                            ),
                          ),
                        ),
                        Center(
                            child: Text(
                              locale.myAccount,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(color: kMainHomeText, fontSize: 18),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.black12,
                                    spreadRadius: 1)
                              ],
                            ),
                            child:  (_image != null)
                                ? CachedNetworkImage(
                              imageUrl: '${_image}',
                              imageBuilder: (context, imageProvider) => Container(
                                width: 150.0,
                                height: 150.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              // height: 100,
                              // width: 100,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Align(
                                widthFactor: 50,
                                heightFactor: 50,
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator( valueColor:AlwaysStoppedAnimation<Color>(kRoundButton),),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kWhiteColor,
                                    // boxShadow: [
                                    //   BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                                    // ],
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(300.0),
                                      child: Image.asset('assets/icon.png'))),
                            )
                                :Container(

                                ),
                              // AssetImage('assets/icon.png')
                          ),
                          Positioned(
                            bottom: 1.0,
                            right: 1.0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEdit())).then((value) =>getProfileValue());
                                // _showPicker(context, locale);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 5,
                                        color: Colors.black12,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: Image(
                                  image: AssetImage('assets/edit.png'),
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAddressTile(BuildContext context, String heading,List<AddressData> address) {
    return Container(

      padding: EdgeInsets.symmetric(horizontal: 4,vertical: 4),
      margin: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            heading,
            style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700,color: kMainColor1),
          ),
          SizedBox(height: 5,),
          ListView.builder(
            itemCount: address.length,
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
              AddressData addData = address[index];
              // String addressshow = 'Name - ${addData.receiver_name}\nContact Number - ${addData.receiver_phone}\n${addData.house_no}${addData.landmark},\n${addData.society}${addData.city}(${addData.pincode})${addData.state}';
              String addressshow = 'Name - ${addData.receiver_name}\nContact Number - ${addData.receiver_phone}\n${addData.house_no}${addData.landmark}.';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: kTextBlack)),
                      ),
                    padding: EdgeInsets.only(bottom: 10,top: 10),
                      child: Text(
                          addressshow,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                      )
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    dynamic userId = preferences.getInt('user_id');
                    Navigator.of(context).pushNamed(PageRoutes.editAddress,arguments: {
                      'address_d':addData,
                    }).then((value){
                      getAddressByUserId(userId);
                    }).catchError((e){
                      getAddressByUserId(userId);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // boxShadow: [
                      //   BoxShadow(
                      //       blurRadius: 5,
                      //       color: Colors.black12,
                      //       spreadRadius: 1)
                      // ],
                    ),
                    child: Image(
                      image: AssetImage('assets/edit.png'),
                      height: 25,
                      width: 25,
                    ),
                  ),
                ),
                // IconButton(icon: Icon(
                //   Icons.edit,
                //   color: Color(0xff686868),
                //   size: 20,
                // ), onPressed: () async{
                //   SharedPreferences preferences = await SharedPreferences.getInstance();
                //   dynamic userId = preferences.getInt('user_id');
                //   Navigator.of(context).pushNamed(PageRoutes.editAddress,arguments: {
                //     'address_d':addData,
                //   }).then((value){
                //     getAddressByUserId(userId);
                //   }).catchError((e){
                //     getAddressByUserId(userId);
                //   });
                // }),
              ],
            );
          })
        ],
      ),
    );
  }
}
