import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Components/entry_field_profile.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/beanmodel/citybean.dart';
import 'package:groshop/beanmodel/statebean.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as Client;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  bool showDialogBox = false;
  int numberLimit = 10;
  dynamic mobileNumber;
  dynamic emailId;
  dynamic fb_id;
  var userFullNameC = TextEditingController();
  var emailAddressC = TextEditingController();
  var phoneNumberC = TextEditingController();
  var passwordC = TextEditingController();
  var referralC = TextEditingController();
  String selectCity = 'Select city';
  String selectSocity = 'Select socity/area';
  List<CityDataBean> cityList = [];
  List<StateDataBean> socityList = [];
  CityDataBean cityData;
  StateDataBean socityData;
  AppInfoModel appinfo;
  FirebaseMessaging messaging;
  dynamic token;
  File _image;
  String _Uimage;
  final picker = ImagePicker();
  int count = 0;
  int id1;
  int id2;
  bool view = true;
  @override
  void initState() {
    super.initState();
    getProfileValue();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
  }

  void getProfileValue() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      // islogin = preferences.getBool('islogin');
      dynamic userName = preferences.getString('user_name');
      dynamic emailAddress = preferences.getString('user_email');
      dynamic mobileNumber = preferences.getString('user_phone');
      dynamic user_city = preferences.getString('user_city');
      dynamic user_area = preferences.getString('user_area');
      dynamic _image1 = '$imagebaseUrl${preferences.getString('user_image')}';

      _Uimage = _image1;
      print(_Uimage);
      userFullNameC.text = '$userName';
      emailAddressC.text = '$emailAddress';
      phoneNumberC.text = '$mobileNumber';
      cityData = CityDataBean(user_city, '');
      cityList.add(cityData);
      socityData = StateDataBean(user_area, '', '', '');
      socityList.add(socityData);
      print('city : '+ user_city  + user_area );
      id1 = int.parse(user_city);
      id2 = int.parse(user_area);
      // selectCity = cityData.city_name;
      // selectSocity = socityData.society_name;
    });
    hitCityData();
  }

  void hitCityData() {
    var locale = AppLocalizations.of(context);
    setState(() {
      showDialogBox = true;
    });
    var http = Client.Client();
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${value.body}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            id1 = cityList.indexOf(cityData);
            print(id1);
            cityData = cityList[id1];
            // selectCity = cityData.city_name;
            selectCity = '${cityData.city_name}';
            print(selectCity);
            socityList.clear();
            selectSocity = locale.selectsocity2;
            // socityData = null;
          });
          if (cityList.length > 0) {
            hitSocityList(cityData.city_name, AppLocalizations.of(context));
          } else {
            selectCity = locale.selectycity2;
            cityData = null;
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
          setState(() {
            selectCity = locale.selectycity2;
            cityData = null;
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          selectCity = locale.selectycity2;
          cityData = null;
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      setState(() {
        selectCity = locale.selectycity2;
        cityData = null;
        showDialogBox = false;
      });
      print(e);
    });
  }

  void hitSocityList(dynamic cityName, locale) {
    var locale = AppLocalizations.of(context);
    var http = Client.Client();
    http.post(societyUri, body: {'city_name': '$cityName'}).then((value) {
      if (value.statusCode == 200) {
        StateBeanModel data1 = StateBeanModel.fromJson(jsonDecode(value.body));
        print('ee - ${value.body}');
        print('ee - ${socityData.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            socityList.clear();
            socityList = List.from(data1.data);
            id2 = socityList.indexOf(socityData);
            socityData = socityList[id2];
            selectSocity = socityData.society_name;
            print(selectSocity);
          });
        } else {
          setState(() {
            selectSocity = (locale != null)
                ? locale.selectsocity2
                : 'Select your socity/area';
            socityData = null;
          });
        }
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      setState(() {
        selectSocity =
            (locale != null) ? locale.selectsocity2 : 'Select your socity/area';
        socityData = null;
        showDialogBox = false;
      });
      print(e);
    });
  }
  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if(output == '') {
      return true;
    }
    return false;
  }
  _imgFromCamera() async {

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        view = true;
        print(view);
      } else {
        view = true;
        print('No image selected.');
      }
    });
  }

  _imgFromGallery() async {
    var locale = AppLocalizations.of(context);
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        PlatformFile file = result.files.first;
        print(file.extension);
        if (file.extension == 'png' ||
            file.extension == 'jpg' ||
            file.extension == 'jpeg') {
          print(result.files.single.path);
          _image = File(result.files.single.path);
        } else {
          Toast.show(locale.selectImage, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      });
    } else {
      // User canceled the picker
    }

    // picker.getImage(source: ImageSource.gallery).then((pickedFile) {
    //   setState(() {
    //     if (pickedFile != null) {
    //       _image = File(pickedFile.path);
    //     } else {
    //       print('No image selected.');
    //     }
    //   });
    // }).catchError((e) => print(e));
  }

  void _showPicker(context, AppLocalizations locale) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(locale.photolibrary),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(locale.camera),
                    onTap: () {
                      setState(() {
                        view = false;
                      });
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     locale.profileedit,
      //     style: TextStyle(color: kMainTextColor),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        color: kMyAccountBack,
        height: MediaQuery.of(context).size.height,
        child: Visibility(
          visible: view,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                    ],
                  ),
                  margin: EdgeInsets.only(top: 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Divider(
                      //   thickness: 2.5,
                      //   color: Colors.transparent,
                      // ),
                      // SizedBox(height: 10.0),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      //   child: GestureDetector(
                      //     behavior: HitTestBehavior.opaque,
                      //     onTap: () {
                      //       _showPicker(context,locale);
                      //     },
                      //     child: Container(
                      //       width: MediaQuery.of(context).size.width,
                      //       height: 90,
                      //       decoration: BoxDecoration(
                      //           border: Border.all(color: kMainColor),
                      //           borderRadius: BorderRadius.circular(5.0)),
                      //       child: Row(
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         children: [
                      //           Image(
                      //             image: (_image != null)
                      //                 ? FileImage(_image)
                      //                 : (_Uimage!=null)?NetworkImage(_Uimage):AssetImage('assets/icon.png'),
                      //             height: 80,
                      //             width: 80,
                      //           ),
                      //           SizedBox(
                      //             width: 20.0,
                      //           ),
                      //           Text(
                      //             locale.uploadpictext,
                      //             style: Theme.of(context)
                      //                 .textTheme
                      //                 .headline6
                      //                 .copyWith(
                      //                 color: kMainTextColor,
                      //                 fontWeight: FontWeight.bold,
                      //                 fontSize: 18),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 70.0),
                      Visibility(
                          visible: showDialogBox,
                          child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )),
                      SizedBox(height: 10.0),
                      EntryFieldProfile(
                        label: locale.fullName,
                        hint: locale.enterFullName,
                        controller: userFullNameC,
                        readOnly: showDialogBox,
                      ),
                      EntryFieldProfile(
                        label: locale.emailAddress,
                        hint: locale.enterEmailAddress,
                        controller: emailAddressC,
                        readOnly: showDialogBox,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 1),
                        child: Text(
                          locale.selectycity1,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              color: kEntryFieldLable,
                              fontWeight: FontWeight.normal,
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<CityDataBean>(
                          hint: Text(
                            selectCity,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                          isExpanded: true,
                          icon: Image.asset(
                            'assets/icondown.png',
                            height: 12,
                            width: 12,
                          ),
                          iconEnabledColor: kMainTextColor,
                          iconDisabledColor: kMainTextColor,
                          iconSize: 30,
                          items: cityList.map((value) {
                            return DropdownMenuItem<CityDataBean>(
                              value: value,
                              child: Text(value.city_name,
                                  overflow: TextOverflow.clip),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectCity = value.city_name;
                              cityData = value;
                              socityList.clear();
                              selectSocity = locale.selectsocity2;
                              socityData = null;
                              showDialogBox = true;
                            });
                            hitSocityList(value.city_name, locale);
                            print(value);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 1),
                        child: Text(
                          locale.selectsocity1,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              color: kEntryFieldLable,
                              fontWeight: FontWeight.normal,
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<StateDataBean>(
                          hint: Text(
                            selectSocity,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                          iconEnabledColor: kMainTextColor,
                          iconDisabledColor: kMainTextColor,
                          icon: Image.asset(
                            'assets/icondown.png',
                            height: 12,
                            width: 12,
                          ),
                          iconSize: 30,
                          isExpanded: true,
                          items: socityList.map((value) {
                            return DropdownMenuItem<StateDataBean>(
                              value: value,
                              child: Text(value.society_name,
                                  overflow: TextOverflow.clip),
                            );
                          }).toList(),
                          onChanged: (valued) {
                            setState(() {
                              selectSocity = valued.society_name;
                              socityData = valued;
                            });
                          },
                        ),
                      ),
                      // EntryField(
                      //   label: locale.selectycity1,
                      //   hint: locale.selectycity2,
                      //   suffixIcon: Icons.arrow_drop_down,
                      // ),
                      // EntryField(
                      //   label: locale.selectsocity1,
                      //   hint: locale.selectsocity2,
                      //   suffixIcon: Icons.arrow_drop_down,
                      // ),
                      EntryFieldProfile(
                        label: locale.phoneNumber,
                        hint: locale.enterPhoneNumber,
                        maxLines: 1,
                        maxLength: numberLimit,
                        readOnly: false,
                        keyboardType: TextInputType.number,
                        controller: phoneNumberC,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            onTap: () {
                              // int numLength = (mobileNumber!=null && mobileNumber.toString().length>0)?numberLimit:10;
                              if (userFullNameC.text != null &&
                                  userFullNameC.text != ''&& !isAllSpaces(userFullNameC.text)) {
                                if (emailAddressC.text != null &&
                                    emailValidator(emailAddressC.text)) {
                                  if (phoneNumberC.text != null &&
                                      phoneNumberC.text.length == numberLimit && phoneValidator(phoneNumberC.text)) {
                                    try {
                                      hitSignUpUrl(
                                          userFullNameC.text,
                                          emailAddressC.text,
                                          '${phoneNumberC.text}',
                                          cityData.city_id,
                                          socityData.society_id,
                                          context);
                                    } catch (e) {
                                      setState(() {
                                        showDialogBox = false;
                                      });
                                      Toast.show(
                                          locale.selectCityAndArea, context,
                                          gravity: Toast.CENTER,
                                          duration: Toast.LENGTH_SHORT);
                                    }

                                    // if (cityData.city_name != null &&
                                    //     cityData.city_name.toString().length > 0) {
                                    //   if(socityData.society_name!=null &&
                                    //   socityData.society_name.toString().length>0){
                                    //     hitSignUpUrl(
                                    //         userFullNameC.text,
                                    //         emailAddressC.text,
                                    //         '${phoneNumberC.text}',
                                    //         cityData.city_name,
                                    //         socityData.society_name,
                                    //         context);
                                    //   }else{
                                    //     setState(() {
                                    //       showDialogBox = false;
                                    //     });
                                    //     Toast.show('Please select society/area.', context,
                                    //         gravity: Toast.CENTER,
                                    //         duration: Toast.LENGTH_SHORT);
                                    //   }
                                    //
                                    // } else {
                                    //   setState(() {
                                    //     showDialogBox = false;
                                    //   });
                                    //   Toast.show('Please select city', context,
                                    //       gravity: Toast.CENTER,
                                    //       duration: Toast.LENGTH_SHORT);
                                    // }

                                  } else {
                                    setState(() {
                                      showDialogBox = false;
                                    });
                                    Toast.show(
                                        '${locale.incorectMobileNumber}', context,
                                        gravity: Toast.CENTER,
                                        duration: Toast.LENGTH_SHORT);
                                  }
                                } else {
                                  setState(() {
                                    showDialogBox = false;
                                  });
                                  Toast.show(locale.incorectEmail, context,
                                      gravity: Toast.CENTER,
                                      duration: Toast.LENGTH_SHORT);
                                }
                              } else {
                                setState(() {
                                  showDialogBox = false;
                                });
                                Toast.show(locale.incorectUserName, context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_SHORT);
                              }
                            },
                            color: kRoundButton,
                            iconGap: 12,
                            imageAssets: 'assets/Icon_update.png',
                            label: locale.update,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                                icon: Icon(Icons.arrow_back_ios_rounded),
                                iconSize: 15,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                tooltip: MaterialLocalizations.of(context)
                                    .openAppDrawerTooltip,
                              ),
                            ),
                          ),
                          Center(
                              child: Text(
                            locale.profileedit,
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
                              child: CircleAvatar(
                                backgroundImage: (_image != null)
                                    ? FileImage(_image)
                                    : (_Uimage != null)
                                        ? NetworkImage(_Uimage)
                                        : AssetImage('assets/icon.png'),
                                radius: 75.0,
                              ),
                            ),
                            Positioned(
                              bottom: 1.0,
                              right: 1.0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _showPicker(context, locale);
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
      ),
    );
  }

  bool emailValidator(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
 bool phoneValidator(phone) {
    return RegExp(
    r"^[0-9]{10}$")
        .hasMatch(phone);
  }

  void hitSignUpUrl(dynamic user_name, dynamic user_email, dynamic user_phone,
      dynamic user_city, dynamic user_area, BuildContext context) async {
    var locale = AppLocalizations.of(context);
     print('city : : '+user_city.toString()+' : '+user_area.toString());
    if (user_city != null && user_city.toString().length > 0) {
      if (user_area != null && user_area.toString().length > 0) {
        setState(() {
          showDialogBox = true;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (token != null) {
          String fid;
          if (_image != null) {
            fid = _image.path.split('/').last;
          }
          var requestMulti = http.MultipartRequest('POST', profileEditUri);
          requestMulti.fields["user_id"] = '${prefs.getInt('user_id')}';
          requestMulti.fields["user_name"] = '${user_name}';
          requestMulti.fields["user_email"] = '${user_email}';
          requestMulti.fields["user_phone"] = '${user_phone}';
          requestMulti.fields["user_city"] = '${user_city}';
          requestMulti.fields["user_area"] = '${user_area}';
          requestMulti.fields["device_id"] = '${token}';
          if (fid != null && fid.length > 0) {
            http.MultipartFile.fromPath('user_image', _image.path,
                    filename: fid)
                .then((pic) {
              requestMulti.files.add(pic);
              requestMulti.send().then((values) {
                values.stream.toBytes().then((value) {
                  var responseString = String.fromCharCodes(value);
                  var jsonData = jsonDecode(responseString);
                  print('with Image ' + '${jsonData.toString()}');
                  // print('user_name ' + '${jsonData['data']['user_name']}');
                  // print('user_email '+ '${jsonData['data']['user_email']}');
                  // print('user_image '+ '${jsonData['data']['user_image']}');
                  // print('user_phone '+ '${jsonData['data']['user_phone']}');
                  // print('user_city '+ '${jsonData['data']['user_city']}');
                  // print('user_area '+'${jsonData['data']['user_area']}');

                  if('${jsonData['status']}'=='1'){
                    prefs.setString(
                        "user_name", '${jsonData['data']['user_name']}');
                    prefs.setString(
                        "user_email", '${jsonData['data']['user_email']}');
                    prefs.setString(
                        "user_image", '${jsonData['data']['user_image']}');
                    prefs.setString(
                        "user_phone", '${jsonData['data']['user_phone']}');
                    prefs.setString(
                        "user_city", '${jsonData['data']['user_city']}');
                    prefs.setString(
                        "user_area", '${jsonData['data']['user_area']}');
                    Toast.show(jsonData['message'], context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    setState(() {
                      showDialogBox = false;
                    });
                  }else{
                    Toast.show(jsonData['message'], context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    setState(() {
                      showDialogBox = false;
                    });
                  }
                }).catchError((e) {
                  print(e);
                  setState(() {
                    showDialogBox = false;
                  });
                });
              }).catchError((e) {
                setState(() {
                  showDialogBox = false;
                });
                print(e);
              });
            }).catchError((e) {
              setState(() {
                showDialogBox = false;
              });
              print(e);
            });
          } else {
            print('not null');
            requestMulti.fields["user_image"] = '';
            requestMulti.send().then((value1) {
              value1.stream.toBytes().then((value) {
                var responseString = String.fromCharCodes(value);
                var jsonData = jsonDecode(responseString);
                print('Without Image' + '${jsonData.toString()}');
                if('${jsonData['status']}'=='1'){
                  prefs.setString(
                      "user_name", '${jsonData['data']['user_name']}');
                  prefs.setString(
                      "user_email", '${jsonData['data']['user_email']}');
                  prefs.setString(
                      "user_image", '${jsonData['data']['user_image']}');
                  prefs.setString(
                      "user_phone", '${jsonData['data']['user_phone']}');
                  prefs.setString(
                      "user_city", '${jsonData['data']['user_city']}');
                  prefs.setString(
                      "user_area", '${jsonData['data']['user_area']}');
                  Toast.show(jsonData['message'], context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                  setState(() {
                    showDialogBox = false;
                  });
                }else{
                  Toast.show(jsonData['message'], context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                  setState(() {
                    showDialogBox = false;
                  });
                }

              }).catchError((e) {
                print(e);
                setState(() {
                  showDialogBox = false;
                });
              });
            }).catchError((e) {
              setState(() {
                showDialogBox = false;
              });
            });
          }
        } else {
          if (count == 0) {
            messaging.getToken().then((value) {
              token = value;
              count = 1;
              hitSignUpUrl(user_name, user_email, user_phone, user_city,
                  user_area, context);
            });
          }
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
        Toast.show(locale.enterSociety, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
    } else {
      setState(() {
        showDialogBox = false;
      });
      Toast.show(locale.enterCity, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }
  }
}
