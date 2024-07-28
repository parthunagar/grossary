import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Components/entry_field_profile.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/beanmodel/productmodel/storeprodcut.dart';
import 'package:vendor/beanmodel/profilebean/storeprofile.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:toast/toast.dart';
import 'package:mime/mime.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  TextEditingController sellerNameC = TextEditingController();
  TextEditingController storeNameC = TextEditingController();
  TextEditingController emailAddressC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController addressC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  var storeImage;
  bool isLoading = false;
  File _image;
  final picker = ImagePicker();

  bool view = true;

  // static  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  void getProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storeid = prefs.getInt('store_id');
    setState(() {
      isLoading = true;
      storeNameC.text = '${prefs.getString('store_name')}';
      sellerNameC.text = '${prefs.getString('owner_name')}';
      phoneNumberC.text = '${prefs.getString('store_phone')}';
      emailAddressC.text = '${prefs.getString('store_email')}';
      addressC.text = '${prefs.getString('store_address')}';
      passwordC.text = '${prefs.getString('store_password')}';
      storeImage = '$imagebaseUrl${prefs.getString('store_photo')}';
    });
    var https = http.Client();
    print('getProfileData => storeProfileUri : $storeProfileUri store_id :$storeid');
    https.post(storeProfileUri, body: {'store_id': '$storeid'}).then((value) {
      if (value.statusCode == 200) {
        StoreProfileMain jsData = StoreProfileMain.fromJson(jsonDecode(value.body));
        if ('${jsData.status}' == '1') {
          print('getProfileData => value.body : ${value.body}');
          setState(() {
            sellerNameC.text = '${jsData.data.owner_name}';
            storeNameC.text = '${jsData.data.store_name}';
            phoneNumberC.text = '${jsData.data.phone_number}';
            emailAddressC.text = '${jsData.data.email}';
            addressC.text = '${jsData.data.address}';
            passwordC.text = '${jsData.data.password}';
            storeImage = Uri.parse('$imagebaseUrl${jsData.data.store_photo}');
          });
          prefs.setString('store_name', storeNameC.text);
          prefs.setString('owner_name', sellerNameC.text);
          prefs.setString('store_phone', phoneNumberC.text);
          prefs.setString('store_email', emailAddressC.text);
          prefs.setString('store_address', addressC.text);
          prefs.setString('store_photo', '${jsData.data.store_photo}');
          prefs.setString('store_password', passwordC.text);
        }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('getProfileData => ERROR : $e');
      setState(() {  isLoading = false;  });
    });
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        view = true;
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
        if (file.extension == 'png' || file.extension == 'jpg' || file.extension == 'jpeg') {
          print(result.files.single.path);
          _image = File(result.files.single.path);
        } else {
          Toast.show(locale.selectValidImage, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      });
    } else {
      // User canceled the picker
    }
    // picker.getImage(source: ImageSource.gallery).then((pickedFile) {
    //   setState(() {
    //     if (pickedFile != null) {
    //       String file = pickedFile.path;
    //       final mimeType = lookupMimeType(file); // 'image/jpeg'
    //       print (file);
    //       if(mimeType =='image/jpeg'||mimeType=='image/png'||mimeType =='image/jpg'){
    //         _image = File(pickedFile.path);
    //       }else{
    //         Toast.show(
    //             'Please select png or jpg image from gallery.',
    //             context,
    //             gravity: Toast.CENTER,
    //             duration: Toast.LENGTH_SHORT);
    //       }
    //
    //
    //     } else {
    //       print('No image selected.');
    //     }
    //   });
    // }).catchError((e) => print(e));
  }

  void _showPicker(context) {
    var locale = AppLocalizations.of(context);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(locale.photolib),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(locale.camera),
                    onTap: () {
                      setState(() { view = false; });
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

  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if (output == '')
    { return true;  }
    return false;
  }

  bool phoneValidator(phone) {
    print('phone : ' + phone);
    return RegExp(r"^[0-9]{10}$").hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      // onTap: () {
      //   final FocusScopeNode currentScope = FocusScope.of(context);
      //   if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      //     FocusManager.instance.primaryFocus.unfocus();
      //   }
      // },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Theme(
            data: Theme.of(context).copyWith(
              // Set the transparency here
              canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
            ),
            child: buildDrawer(context: context, image: storeImage)),
        // appBar: AppBar(
        //   backgroundColor: kTransparentColor,
        //   title: Text(
        //     locale.myProfile,
        //     style: Theme.of(context)
        //         .textTheme
        //         .headline6
        //         .copyWith(color: kRoundButtonInButton, fontSize: 18),
        //   ),
        //   centerTitle: true,
        //   leading: Builder(
        //     builder: (BuildContext context) {
        //       return Container(
        //         // padding: EdgeInsets.all(6),
        //         margin: EdgeInsets.symmetric(
        //             horizontal: 13, vertical: 13),
        //         decoration: BoxDecoration(
        //           color: kWhiteColor,
        //           borderRadius: BorderRadius.circular(5),
        //           boxShadow: [
        //             BoxShadow(
        //                 blurRadius: 5,
        //                 color: Colors.black12,
        //                 spreadRadius: 1)
        //           ],
        //         ),
        //         child: IconButton(
        //           icon: ImageIcon(
        //             AssetImage(
        //               'assets/Icon_awesome_align_right.png',
        //             ),
        //           ),
        //           iconSize: 15,
        //           onPressed: () {
        //             Scaffold.of(context).openDrawer();
        //           },
        //           color: kRoundButtonInButton,
        //           tooltip: MaterialLocalizations.of(context)
        //               .openAppDrawerTooltip,
        //         ),
        //       );
        //     },
        //   ),
        // ),
        body: Container(
          // margin: EdgeInsets.only(top: 30),
          color: kMyAccountBack,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Visibility(
              visible: view,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
                    margin: EdgeInsets.only(top: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stack(
                        //   children: [
                        //     Image(
                        //       image: (_image != null)
                        //           ? FileImage(_image)
                        //           : NetworkImage('$storeImage'),
                        //       height: 230,
                        //       width: MediaQuery.of(context).size.width,
                        //       fit: BoxFit.fill,
                        //     ),
                        //     Positioned.directional(
                        //         top: 40,
                        //         textDirection: Directionality.of(context),
                        //         child: IconButton(
                        //             onPressed: () {
                        //               Navigator.pop(context);
                        //             },
                        //             icon: Icon(
                        //               Icons.arrow_back_ios,
                        //               color: Colors.white,
                        //             ))),
                        //     Positioned.directional(
                        //       textDirection: Directionality.of(context),
                        //       start: 20,
                        //       bottom: 20,
                        //       child: GestureDetector(
                        //         onTap: () {
                        //           _showPicker(context);
                        //         },
                        //         behavior: HitTestBehavior.opaque,
                        //         child: Row(
                        //           children: [
                        //             Icon(
                        //               Icons.camera_alt,
                        //               color: Colors.white,
                        //             ),
                        //             SizedBox(
                        //               width: 15,
                        //             ),
                        //             Text(
                        //               locale.changeCoverImage,
                        //               style: Theme.of(context).textTheme.bodyText1,
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 90.0),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 22.0, vertical: 12),
                        //   child: Text(
                        //     locale.setProfileInfo,
                        //     style: Theme.of(context)
                        //         .textTheme
                        //         .subtitle2
                        //         .copyWith(fontWeight: FontWeight.w500),
                        //   ),
                        // ),
                        EntryFieldProfile(
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          label: locale.storename1,
                          hint: locale.storename2,
                          labelFontSize: 18,
                          labelFontWeight: FontWeight.normal,
                          controller: storeNameC,

                          // onSubmit: () {
                          //   final FocusScopeNode currentScope = FocusScope.of(context);
                          //   if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                          //     FocusManager.instance.primaryFocus.unfocus();
                          //   }
                          //   },
                          //
                          // autofocus: false,
                        ),
                        EntryFieldProfile(
                            autofocus: true,
                          textInputAction: TextInputAction.next,
                          label: locale.sellerName,
                          hint: locale.sellerName1,
                          labelFontSize: 18,
                          labelFontWeight: FontWeight.normal,
                          controller: sellerNameC),
                        EntryFieldProfile(
                            autofocus: true,
                          textInputAction: TextInputAction.next,
                          label: locale.emailAddress,
                          labelFontSize: 18,
                          readOnly: true,
                          labelFontWeight: FontWeight.normal,
                          controller: emailAddressC),
                        EntryFieldProfile(
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                          label: locale.password1,
                          hint: locale.password2,
                          readOnly: true,
                          labelFontSize: 18,
                          labelFontWeight: FontWeight.normal,
                          controller: passwordC),
                        EntryFieldProfile(
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                          maxLength: 10,
                          label: locale.phoneNumber,
                          hint: locale.storenumber2,
                          labelFontSize: 18,
                          // readOnly: true,
                          keyboardType: TextInputType.number,
                          labelFontWeight: FontWeight.normal,
                          controller: phoneNumberC),
                        // Divider(
                        //   height: 30,
                        //   thickness: 8,
                        //   color: Colors.grey[100],
                        // ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(locale.setSellerAddress, style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.normal, fontSize: 18, color: kEntryFieldLable),),),
                        // Padding(
                        //   padding:
                        //   const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
                        //   child: Column(
                        //     children: [
                        //       // Row(
                        //       //   children: [
                        //       //     Text(
                        //       //       locale.selectOnMap,
                        //       //       style: Theme.of(context)
                        //       //           .textTheme
                        //       //           .bodyText2
                        //       //           .copyWith(
                        //       //               fontWeight: FontWeight.w400, fontSize: 16),
                        //       //     ),
                        //       //     Spacer(),
                        //       //     Icon(
                        //       //       Icons.location_on,
                        //       //       color: Theme.of(context).primaryColor,
                        //       //     ),
                        //       //   ],
                        //       // ),
                        //
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            // maxLines: 2,
                            controller: addressC,
                            textInputAction: TextInputAction.done,
                            readOnly: true,
                            decoration: InputDecoration(
                                suffixIcon: Icon(Icons.location_on, color: kTextBlack),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kTextBlack))),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (!isLoading)
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: CustomButton(
                                      iconGap: 10,
                                      imageAssets: 'assets/Icon_update_alt.png',
                                      onTap: () {
                                        print(phoneNumberC.text);
                                        if (storeNameC.text != null && storeNameC.text != '' && !isAllSpaces(storeNameC.text)) {
                                          if (sellerNameC.text != null && sellerNameC.text != '' && !isAllSpaces(sellerNameC.text)) {
                                            if (emailAddressC.text != null && emailValidator(emailAddressC.text)) {
                                              if (phoneValidator(phoneNumberC.text.toString())) {
                                                String fid = (_image != null) ? _image.path.split('/').last : null;
                                                if (fid != null && fid.length > 0)
                                                { updateWithImage(fid); }
                                                else {  updateProfileData();   }
                                              } else {
                                                setState(() { isLoading = false;  });
                                                Toast.show(locale.enterValidMobile, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                              }
                                            } else {
                                              setState(() { isLoading = false;  });
                                              Toast.show(locale.incorectEmail, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                            }
                                          } else {
                                            setState(() {  isLoading = false;  });
                                            Toast.show(locale.enterSellerName, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                          }
                                        } else {
                                          setState(() { isLoading = false;   });
                                          Toast.show(locale.enterStoreName, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                                        }
                                      },
                                      label: locale.update,
                                    ))
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 52,
                                    alignment: Alignment.center,
                                    child: Align(
                                      widthFactor: 30,
                                      heightFactor: 30,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    ),
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
                                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
                                height: 30,
                                width: 30,
                                child: IconButton(
                                  icon: ImageIcon(AssetImage('assets/Icon_awesome_align_right.png')),
                                  iconSize: 15,
                                  onPressed: () {
                                    _scaffoldKey.currentState.openDrawer();
                                    // if(_scaffoldKey.currentState.openDrawer()){}
                                    // FocusScope.of(context).unfocus();
                                  },
                                  color: kRoundButtonInButton,
                                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                                ),
                              ),
                            ),
                            Center(child: Text(locale.myProfile, style: Theme.of(context).textTheme.headline6.copyWith(color: kRoundButtonInButton, fontSize: 18))),
                          ],
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 30),
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 50,
                      //   padding: EdgeInsets.symmetric(horizontal: 15),
                      //   child: Stack(
                      //     children: [
                      //       Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //             color: kWhiteColor,
                      //             borderRadius: BorderRadius.circular(5),
                      //             boxShadow: [
                      //               BoxShadow(
                      //                   blurRadius: 5,
                      //                   color: Colors.black12,
                      //                   spreadRadius: 1)
                      //             ],
                      //           ),
                      //           height: 30,
                      //           width: 30,
                      //           child: IconButton(
                      //             icon: Icon(Icons.arrow_back_ios_rounded),
                      //             iconSize: 15,
                      //             onPressed: () {
                      //               Navigator.pop(context);
                      //             },
                      //             tooltip: MaterialLocalizations.of(context)
                      //                 .openAppDrawerTooltip,
                      //           ),
                      //         ),
                      //       ),
                      //       Center(
                      //           child: Text(
                      //             locale.myProfile,
                      //             style: Theme.of(context)
                      //                 .textTheme
                      //                 .headline6
                      //                 .copyWith(color: kMainHomeText, fontSize: 18),
                      //           )),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 20),
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
                                child: (_image != null)
                                    ? Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kWhiteColor,
                                          // boxShadow: [
                                          //   BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                                          // ],
                                        ),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(300.0), child: Image.file(_image, fit: BoxFit.cover)))
                                    : (storeImage != null)
                                        ? CachedNetworkImage(
                                            imageUrl: '$storeImage',
                                            imageBuilder: (context, imageProvider) =>
                                              Container(
                                                width: 150.0,
                                                height: 150.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover))),
                                            // height: 100,
                                            // width: 100,
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) =>
                                              Container(padding: const EdgeInsets.all(5.0), width: 150, height: 150, child: Image(image: AssetImage('assets/user.png'))),
                                            errorWidget: (context, url, error) =>
                                                Container(
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
                                                    child: Image.asset('assets/user.png', fit: BoxFit.cover))),
                                          )
                                        : AssetImage('assets/user.png'),
                                // CircleAvatar(
                                //   backgroundImage: (_image != null)
                                //       ? FileImage(_image)
                                //       : (storeImage!=null)?NetworkImage('$storeImage'):AssetImage('assets/icon.png'),
                                //       // : (storeImage!=null)?NetworkImage('$storeImage'):AssetImage('assets/icon.png'),
                                //   radius: 75.0,
                                // ),
                              ),
                              Positioned(
                                bottom: 1.0,
                                right: 1.0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _showPicker(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
                                    child: Image(image: AssetImage('assets/edit.png'), height: 40, width: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool emailValidator(email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void updateWithImage(String fileP) async {
    setState(() { isLoading = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var requestMulti = http.MultipartRequest('POST', storeUpdateProfileUri);
    requestMulti.fields["store_id"] = '${prefs.getInt('store_id')}';
    requestMulti.fields["owner_name"] = '${sellerNameC.text}';
    requestMulti.fields["store_name"] = '${storeNameC.text}';
    requestMulti.fields["store_phone"] = '${phoneNumberC.text}';
    requestMulti.fields["store_email"] = '${emailAddressC.text}';
    requestMulti.fields["password"] = '${passwordC.text}';
    http.MultipartFile.fromPath('store_image', _image.path, filename: fileP).then((pic) {
      requestMulti.files.add(pic);
      requestMulti.send().then((values) {
        values.stream.toBytes().then((value) {
          var responseString = String.fromCharCodes(value);
          var jsonData = jsonDecode(responseString);
          print('${jsonData.toString()}');
          // if (values.statusCode == 200) {
          //   print('status 200');
          StoreProfileMain jsData = StoreProfileMain.fromJson(jsonData);
          if ('${jsData.status}' == '1') {
            print('status 1');
            // setState(() {
            //   sellerNameC.text = '${jsData.data.store_name}';
            //   phoneNumberC.text = '${jsData.data.phone_number}';
            //   emailAddressC.text = '${jsData.data.email}';
            //   addressC.text = '${jsData.data.address}';
            //   storeImage = Uri.parse('$imagebaseUrl${jsData.data.store_photo}');
            // });
            // prefs.setString('store_name', sellerNameC.text);
            // prefs.setString('store_phone', phoneNumberC.text);
            // prefs.setString('store_email', emailAddressC.text);
            // prefs.setString('store_address', addressC.text);
            // prefs.setString('store_photo', storeImage);
            getProfileData();
            Toast.show('${jsData.message}', context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          }
          // }
          setState(() {  isLoading = false;  });
        }).catchError((e) {
          print('updateWithImage ERROR 1 : ${e.toString()}');
          setState(() { isLoading = false;  });
        });
      }).catchError((e) {
        setState(() {  isLoading = false;   });
        print('updateWithImage ERROR 2 : ${e.toString()}');
      });
    }).catchError((e) {
      setState(() {   isLoading = false;  });
      print('updateWithImage ERROR 3 : ${e.toString()}');
    });
  }

  void updateProfileData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var https = http.Client();
    print('updateProfileData => storeUpdateProfileUri : $storeUpdateProfileUri ' +
        '|| store_id ' + '${prefs.getInt('store_id')} ' +
        '|| owner_name ' + '${sellerNameC.text} ' +
        '|| store_name ' + '${storeNameC.text} ' +
        '|| store_phone ' + '${phoneNumberC.text} ' +
        '|| store_email ' + '${emailAddressC.text} ' +
        '|| password ' + '${passwordC.text} ' +
        '|| store_image ' ' 37');
    https.post(storeUpdateProfileUri, body: {
      'store_id': '${prefs.getInt('store_id')}',
      'owner_name': '${sellerNameC.text}',
      'store_name': '${storeNameC.text}',
      'store_phone': '${phoneNumberC.text}',
      'store_email': '${emailAddressC.text}',
      'password': '${passwordC.text}',
      // 'store_image': '37',
    }).then((value) {
      print('updateProfileData => value.body : ${value.body.toString()}');
      if (value.statusCode == 200) {
        StoreProfileMain jsData = StoreProfileMain.fromJson(jsonDecode(value.body));
        if ('${jsData.status}' == '1') {
          setState(() {
            storeNameC.text = '${jsData.data.store_name}';
            sellerNameC.text = '${jsData.data.owner_name}';
            phoneNumberC.text = '${jsData.data.phone_number}';
            emailAddressC.text = '${jsData.data.email}';
            addressC.text = '${jsData.data.address}';
            storeImage = Uri.parse('$imagebaseUrl${jsData.data.store_photo}');
          });
          prefs.setString('store_name', storeNameC.text);
          prefs.setString('owner_name', sellerNameC.text);
          prefs.setString('store_phone', phoneNumberC.text);
          prefs.setString('store_email', emailAddressC.text);
          prefs.setString('store_address', addressC.text);
          prefs.setString('store_photo', '${jsData.data.store_photo}');
          Toast.show('${jsData.message}', context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      } else {
        Toast.show('${value.body}', context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('updateProfileData => ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }
}
