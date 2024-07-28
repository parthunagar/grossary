import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/appinfo.dart';
import 'package:groshop/beanmodel/citybean.dart';
import 'package:groshop/beanmodel/signinmodel.dart';
import 'package:groshop/beanmodel/statebean.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
  String selectCity = 'Select your city';
  String selectSocity = 'Select society/area';
  List<CityDataBean> cityList = [];
  List<StateDataBean> socityList = [];
  CityDataBean cityData;
  StateDataBean socityData;
  AppInfoModel appinfo;
  FirebaseMessaging messaging;
  dynamic token;
  File _image;
  final picker = ImagePicker();
  int count = 0;

  BuildContext context;
  bool view = true;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
    Future.delayed(Duration.zero, () {
      hitCityData();
    });

  }

  void hitCityData() {
    var locale = AppLocalizations.of(context);
    setState(() {
      showDialogBox = true;
    });
    var http = Client();
    print('$cityUri');
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            selectCity = cityList[0].city_name;
            cityData = cityList[0];
            socityList.clear();
            selectSocity = locale.selectsocity2;
            socityData = null;
          });
          if (cityList.length > 0) {
            hitSocityList(cityList[0].city_name, AppLocalizations.of(context));
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
    var http = Client();
    print('$societyUri ' + 'city_name : ' + '$cityName');
    http.post(societyUri, body: {'city_name': '$cityName'}).then((value) {
      if (value.statusCode == 200) {
        StateBeanModel data1 = StateBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            socityList.clear();
            socityList = List.from(data1.data);
            selectSocity = socityList[0].society_name;
            socityData = socityList[0];
          });
        } else {
          setState(() {
            selectSocity = (locale != null)
                ? locale.selectsocity2
                : 'Select your society/area';
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
            (locale != null) ? locale.selectsocity2 : 'Select your society/area';
        socityData = null;
        showDialogBox = false;
      });
      print(e);
    });
  }

  _imgFromCamera() async {

    print(view);
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
  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if(output == '') {
      return true;
    }
    return false;
  }

  bool phoneValidator(phone) {
    return RegExp(
        r"^[0-9]{10}$")
        .hasMatch(phone);
  }
  bool passwordValidator(password) {
    return RegExp(
        r"^\S{6,}$")
        .hasMatch(password);
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
  Widget build(BuildContext contextc) {
    context = contextc;
    var locale = AppLocalizations.of(contextc);

    final Map<String, Object> rcvdData =
        ModalRoute.of(contextc).settings.arguments;
    setState(() {
      mobileNumber =
          rcvdData.containsKey('user_phone') ? rcvdData['user_phone'] : '';
      if (rcvdData.containsKey('user_phone')) {
        phoneNumberC.text = '${mobileNumber}';
      }
      emailId =
          rcvdData.containsKey('user_email') ? rcvdData['user_email'] : '';
      fb_id = rcvdData.containsKey('fb_id') ? rcvdData['fb_id'] : '';
      if (rcvdData.containsKey('user_email')) {
        emailAddressC.text = '${emailId}';
      }
      appinfo = rcvdData['appinfo'];
      numberLimit = rcvdData.containsKey('user_phone')
          ? mobileNumber.toString().length
          : numberLimit;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.register,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(contextc).size.height,
        child: Visibility(
          visible: view,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        thickness: 2.5,
                        color: Colors.transparent,
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
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
                                        : AssetImage('assets/icon.png'),
                                    radius: 100.0,
                                  ),
                                ),
                                Positioned(
                                  bottom: 10.0,
                                  right: 10.0,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _showPicker(contextc, locale);
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
                      ),
                      SizedBox(height: 10.0),

                      SizedBox(height: 10.0),
                      Visibility(
                          visible: showDialogBox,
                          child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kRoundButton),
                            ),
                          )),
                      SizedBox(height: 10.0),
                      EntryField(
                        label: locale.fullName,
                        hint: locale.enterFullName,
                        maxLength: 50,
                        controller: userFullNameC,
                        readOnly: showDialogBox,
                      ),
                      EntryField(
                        label: locale.emailAddress,
                        hint: locale.enterEmailAddress,
                        controller: emailAddressC,
                        readOnly: showDialogBox,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 10.0, vertical: 1),
                      //   child: Text(
                      //     locale.selectycity1,
                      //     style: Theme.of(context).textTheme.headline6.copyWith(
                      //         color: kMainTextColor,
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 21.7),
                      //   ),
                      // ),
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/et_border.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: DropdownButton<CityDataBean>(
                                hint: Text(
                                  selectCity,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                                underline: Container(color: Colors.transparent),
                                isExpanded: true,
                                iconEnabledColor: kMainTextColor,
                                iconDisabledColor: kMainTextColor,
                                // iconSize: 10,
                                icon: Image.asset(
                                  'assets/icondown.png',
                                  height: 12,
                                  width: 12,
                                ),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Container(
                              color: kWhiteColor,
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2),
                              child: Text(locale.selectycity1 ?? '',
                                  style: Theme.of(contextc)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                          color: kLightTextColoEt,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 10.0, vertical: 1),
                      //   child: Text(
                      //     locale.selectsocity1,
                      //     style: Theme.of(context).textTheme.headline6.copyWith(
                      //         color: kMainTextColor,
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 21.7),
                      //   ),
                      // ),
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/et_border.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: DropdownButton<StateDataBean>(
                                hint: Text(
                                  selectSocity,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                                underline: Container(color: Colors.transparent),
                                iconEnabledColor: kMainTextColor,
                                iconDisabledColor: kMainTextColor,
                                // iconSize: 30,
                                isExpanded: true,
                                icon:   Image.asset(
                                'assets/icondown.png',
                                height: 12,
                                width: 12,
                              ),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Container(
                              color: kWhiteColor,
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2),
                              child: Text(locale.selectsocity1 ?? '',
                                  style: Theme.of(contextc)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                          color: kLightTextColoEt,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14)),
                            ),
                          ),
                        ],
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
                      EntryField(
                        label: locale.phoneNumber,
                        hint: locale.enterPhoneNumber,
                        maxLines: 1,
                        maxLength: numberLimit,
                        readOnly: (mobileNumber.toString().length ==
                                (int.parse('${appinfo.country_code}') +
                                    numberLimit))
                            ? true
                            : false,
                        keyboardType: TextInputType.number,
                        controller: phoneNumberC,
                      ),
                      EntryField(
                        label: locale.password1,
                        hint: locale.password2,
                        maxLines: 1,
                        readOnly: showDialogBox,
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordC,
                      ),
                      EntryField(
                        label: locale.referalcode1,
                        hint: locale.referalcode2,
                        maxLines: 1,
                        readOnly: showDialogBox,
                        keyboardType: TextInputType.text,
                        controller: referralC,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                              iconGap: 10,
                              color: kRoundButton,
                              imageAssets: 'assets/icon_feather_save.png',
                              onTap: () {
                                if (!showDialogBox) {
                                  setState(() {
                                    showDialogBox = true;
                                  });
                                  // int numLength = (mobileNumber!=null && mobileNumber.toString().length>0)?numberLimit:10;
                                  if (userFullNameC.text != null&& userFullNameC.text.length <= 50 && userFullNameC.text!=''&& !isAllSpaces(userFullNameC.text)) {
                                    if (emailAddressC.text != null &&
                                        emailValidator(emailAddressC.text)) {
                                      if (passwordC.text != null &&
                                          passwordC.text.length > 6) {
                                        if(passwordValidator(passwordC.text)){
                                          if (phoneNumberC.text != null &&
                                              phoneNumberC.text.length == numberLimit&&phoneValidator(phoneNumberC.text)) {
                                            hitSignUpUrl(
                                                userFullNameC.text,
                                                emailAddressC.text,
                                                '${phoneNumberC.text}',
                                                passwordC.text,
                                                cityData.city_id,
                                                socityData.society_id,
                                                fb_id,
                                                referralC.text,
                                                contextc);
                                          } else {
                                            setState(() {
                                              showDialogBox = false;
                                            });
                                            Toast.show(
                                                '${locale.incorectMobileNumber}${numberLimit}',
                                                contextc,
                                                gravity: Toast.CENTER,
                                                duration: Toast.LENGTH_SHORT);
                                          }
                                        }else{
                                          Toast.show(locale.validPassword, contextc,
                                              gravity: Toast.CENTER,
                                              duration: Toast.LENGTH_SHORT);
                                        }

                                      } else {
                                        setState(() {
                                          showDialogBox = false;
                                        });
                                        if(passwordC.text != null&&passwordC.text!=''){
                                          Toast.show(locale.validPasswordCreator, contextc,
                                              gravity: Toast.CENTER,
                                              duration: Toast.LENGTH_SHORT);

                                        }else{
                                          Toast.show(locale.enterPassword, contextc,
                                              gravity: Toast.CENTER,
                                              duration: Toast.LENGTH_SHORT);
                                        }

                                      }
                                    } else {
                                      setState(() {
                                        showDialogBox = false;
                                      });
                                      Toast.show(locale.incorectEmail, contextc,
                                          gravity: Toast.CENTER,
                                          duration: Toast.LENGTH_SHORT);
                                    }
                                  } else {
                                    setState(() {
                                      showDialogBox = false;
                                    });
                                    Toast.show(locale.incorectUserName, contextc,
                                        gravity: Toast.CENTER,
                                        duration: Toast.LENGTH_SHORT);
                                  }
                                }
                              }),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

            ],
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

  void hitSignUpUrl(
      dynamic user_name,
      dynamic user_email,
      dynamic user_phone,
      dynamic user_password,
      dynamic user_city,
      dynamic user_area,
      dynamic fb_id,
      dynamic referral_code,
      BuildContext context) {
    print('$signupUri user_name : $user_name , user_email  : $user_email '
        ',user_phone :  $user_phone ,user_password : $user_password '
        ', user_city : $user_city ,user_area : $user_area , device_id : $token '
        ', fb_id :  $fb_id  ,referral_code  :$referral_code');

    var requestMulti = http.MultipartRequest('POST', signupUri);
    requestMulti.fields["user_name"] = '${user_name}';
    requestMulti.fields["user_email"] = '${user_email}';
    requestMulti.fields["user_phone"] = '${user_phone}';
    requestMulti.fields["user_password"] = '${user_password}';
    requestMulti.fields["user_city"] = '${user_city}';
    requestMulti.fields["user_area"] = '${user_area}';
    requestMulti.fields["device_id"] = '${token}';
    requestMulti.fields["fb_id"] = '${fb_id}';
    requestMulti.fields["referral_code"] = '${referral_code}';
    if (token != null) {
      if (_image != null) {
        String fid = _image.path.split('/').last;
        if (fid != null && fid.length > 0) {
          http.MultipartFile.fromPath('user_image', _image.path, filename: fid)
              .then((pic) {
            requestMulti.files.add(pic);
            print('Reqest With image : $requestMulti');
            requestMulti.send().then((values) {
              print(values);
              values.stream.toBytes().then((value) {
                print('Sucsess STrem to bytes');
                var responseString = String.fromCharCodes(value);
                print(responseString);
                var jsonData = jsonDecode(responseString);
                try {
                  print('${jsonData.toString()}');
                } catch (e) {
                  print(e);
                }

                SignInModel signInData = SignInModel.fromJson(jsonData);
                if (signInData.status == "0" || signInData.status == 0) {
                  print('signInData.status  ${signInData.message}');
                  Toast.show(signInData.message, context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                } else if (signInData.status == "1" || signInData.status == 1) {
                  print('signInData.status  ${signInData.status}');
                  Navigator.pushNamed(context, PageRoutes.verification,
                      arguments: {
                        'token': '${token}',
                        'user_phone': '${user_phone}',
                        'firebase': '${appinfo.firebase}',
                        'country_code': '${appinfo.country_code}',
                        'referralcode': '${referral_code}',
                        'activity': 'signup',
                      });
                } else if (signInData.status == "2" || signInData.status == 2) {
                  print('signInData.status  ${signInData.status}');
                  Navigator.pushNamed(context, PageRoutes.verification,
                      arguments: {
                        'token': '${token}',
                        'user_phone': '${user_phone}',
                        'firebase': '${appinfo.firebase}',
                        'country_code': '${appinfo.country_code}',
                        'referralcode': '${referral_code}',
                        'activity': 'signup',
                      });
                }
                setState(() {
                  showDialogBox = false;
                });
              }).catchError((e) {
                setState(() {
                  showDialogBox = false;
                });
                print('with image 1 ');
                print(e);
              });
            }).catchError((e) {
              setState(() {
                showDialogBox = false;
              });
              // print( 'with image 2');
              print(e);
            });
          }).catchError((e) {
            setState(() {
              showDialogBox = false;
            });
            // print( 'with image 3');
            print(e);
          });
        } else {
          print('not null');
          requestMulti.fields["user_image"] = '';
          print('Reqest : $requestMulti');
          requestMulti.send().then((value1) {
            value1.stream.toBytes().then((value) {
              var responseString = String.fromCharCodes(value);
              var jsonData = jsonDecode(responseString);
              print('${jsonData.toString()}');
              SignInModel signInData = SignInModel.fromJson(jsonData);
              if (signInData.status == "0" || signInData.status == 0) {
                print('signInData.status  ${signInData.status}');
                Toast.show(signInData.message, context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
              } else if (signInData.status == "1" || signInData.status == 1) {
                print('signInData.status  ${signInData.status}');
                Navigator.pushNamed(context, PageRoutes.verification,
                    arguments: {
                      'token': '${token}',
                      'user_phone': '${user_phone}',
                      'firebase': '${appinfo.firebase}',
                      'country_code': '${appinfo.country_code}',
                      'referralcode': '${referral_code}',
                      'activity': 'signup',
                    });
              } else if (signInData.status == "2" || signInData.status == 2) {
                print('signInData.status  ${signInData.status}');
                Navigator.pushNamed(context, PageRoutes.verification,
                    arguments: {
                      'token': '${token}',
                      'user_phone': '${user_phone}',
                      'firebase': '${appinfo.firebase}',
                      'country_code': '${appinfo.country_code}',
                      'referralcode': '${referral_code}',
                      'activity': 'signup',
                    });
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
          }).catchError((e) {
            setState(() {
              showDialogBox = false;
            });
          });
        }
      } else {
        print('not null');
        requestMulti.fields["user_image"] = '';
        print('Reqest : $requestMulti');
        requestMulti.send().then((value1) {
          value1.stream.toBytes().then((value) {
            var responseString = String.fromCharCodes(value);
            var jsonData = jsonDecode(responseString);
            print('${jsonData.toString()}');
            SignInModel signInData = SignInModel.fromJson(jsonData);
            if (signInData.status == "0" || signInData.status == 0) {
              print('signInData.status  ${signInData.status}');
              Toast.show(signInData.message, context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            } else if (signInData.status == "1" || signInData.status == 1) {
              print('signInData.status  ${signInData.status}');
              Navigator.pushNamed(context, PageRoutes.verification, arguments: {
                'token': '${token}',
                'user_phone': '${user_phone}',
                'firebase': '${appinfo.firebase}',
                'country_code': '${appinfo.country_code}',
                'referralcode': '${referral_code}',
                'activity': 'signup',
              });
            } else if (signInData.status == "2" || signInData.status == 2) {
              print('signInData.status  ${signInData.status}');
              Navigator.pushNamed(context, PageRoutes.verification, arguments: {
                'token': '${token}',
                'user_phone': '${user_phone}',
                'firebase': '${appinfo.firebase}',
                'country_code': '${appinfo.country_code}',
                'referralcode': '${referral_code}',
                'activity': 'signup',
              });
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
          hitSignUpUrl(user_name, user_email, user_phone, user_password,
              user_city, user_area, fb_id, referral_code, context);
        });
      }
    }
  }
}
