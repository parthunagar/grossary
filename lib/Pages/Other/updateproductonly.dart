import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Components/entry_field_profile.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/productmodel/categorylist.dart';
import 'package:vendor/beanmodel/productmodel/storeprodcut.dart';

class UpdateProductPage extends StatefulWidget {
  @override
  UpdateProductPageState createState() => UpdateProductPageState();
}

class UpdateProductPageState extends State<UpdateProductPage> {
StoreProductData productData;
  var https = Client();
  bool isLoading = false;
  List<String> tags = [];

  TextEditingController pNamec = TextEditingController();
  // TextEditingController pDescC = TextEditingController();
  TextEditingController pTagsC = TextEditingController();
  TextEditingController eanC = TextEditingController();

  List<File> imageList = [];

  File _image;
  final picker = ImagePicker();
  var prodId;

  var productImage;
  UpdateProductPageState(){
    imageList.add(File(''));
  }

  bool entered = false;

 bool view = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    https.close();
    super.dispose();
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
        view= true;
        _image = File(pickedFile.path);
        imageList.add(_image);
      } else {
        view = true;
        print('_imgFromCamera : No image selected.');
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
        print('file.extension : ${file.extension.toString()}');
        if (file.extension == 'png' || file.extension == 'jpg' || file.extension == 'jpeg') {
          print('result.files.single.path : ${result.files.single.path.toString()}');
          _image = File(result.files.single.path);
          imageList.add(_image);
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
    //       _image = File(pickedFile.path);
    //       imageList.add(_image);
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
            children: [
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
                  setState(() {
                    view=false;
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
    Map<String,dynamic> argd = ModalRoute.of(context).settings.arguments;
    if(!entered){
      setState(() {
        entered = true;
        productData = argd['pData'];
        prodId = productData.productId;
        pNamec.text = productData.productName;
        if(productData.tags!=null && productData.tags.length>0){
          for(Tags tg in productData.tags){
            tags.add(tg.tag);
          }
        }
        productImage = productData.productImage;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMyAccountBack,
        title: Text(locale.updateItem, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
        centerTitle: true,
        leading: Container(
          height: 30,
          width: 30,
          margin: EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            iconSize: 15,
            color: kRoundButtonInButton,
            onPressed: () {
              Navigator.pop(context);
            }),
        ),

        // actions: [
        //   Visibility(
        //     visible: ('${productDetails.order_status}'.toUpperCase()=='PENDING'),
        //     child: CustomButton(
        //       onTap: (){
        //         if(!isLoading){
        //           setState(() {
        //             isLoading = true;
        //           });
        //           cancelOrder(context);
        //         }
        //       },
        //       height: 60,
        //       iconGap: 12,
        //       label: locale.cancelOrdr,
        //     ),
        //   )
        // ],
      ),
      body: Visibility(
        visible: view,
        child: Stack(
          children: [
            ListView(
              children: [
                SizedBox(height: 8),
                buildHeading(context, locale.pimage1),
                Container(
                  height:130,
                  width:130,
                  child: Center(
                    child: Container(
                      height:130, width:130,
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                      ),
                      child: Image.network(productImage,fit: BoxFit.cover,),
                  )),
                ),
                // Divider( thickness: 8, color: Colors.grey[100],  height: 30, ),
                Container(
                  height: 130,
                  color: kMyAccountBack,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: (){
                          if(index ==0){
                            _showPicker(context);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200].withOpacity(index == 0 ? 1 : 0.9),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    Colors.grey[100].withOpacity(index == 0 ? 1 : 0.9),
                                    index != 0 ? BlendMode.dst : BlendMode.clear),
                                image: index==0?AssetImage('assets/ProductImages/lady finger.png'):FileImage(imageList[index]),
                                fit: BoxFit.fill)),
                            child: index == 0
                                ? Icon(Icons.camera_alt, color: Theme.of(context).primaryColor, size: 30)
                                : SizedBox.shrink(),
                        ),
                      );
                    }),
                ),
                // Divider( thickness: 8, color: Colors.grey[100], height: 30, ),
                // buildHeading(context, locale.itemInfo),
                SizedBox(height: 20),
                EntryFieldProfile(
                  label: locale.productTitle,
                  hint: locale.enterTitle,
                  labelFontSize: 18,
                  labelFontWeight: FontWeight.normal,
                  controller: pNamec,
                ),
                // Divider(
                //   thickness: 8,
                //   color: Colors.grey[100],
                //   height: 30,
                // ),
                // // buildHeading(context, locale.description),
                // // EntryField(
                // //   maxLines: 4,
                // //   label: locale.briefYourProduct,
                // //   labelFontSize: 16,
                // //   labelFontWeight: FontWeight.w400,
                // //   controller: pDescC,
                // // ),
                // // Divider(
                // //   thickness: 8,
                // //   color: Colors.grey[100],
                // //   height: 30,
                // // ),
                // // Row(
                // //   children: [
                // //     Expanded(
                // //         child: EntryField(
                // //           label: locale.ean1,
                // //           hint: locale.ean2,
                // //           labelFontSize: 16,
                // //           labelFontWeight: FontWeight.w400,
                // //           controller: eanC,
                // //         )),
                // //     IconButton(
                // //       icon: Icon(Icons.qr_code_scanner),
                // //       onPressed: () {
                // //         // setState(() {
                // //         //   tags.add(pTagsC.text.toUpperCase());
                // //         //   pTagsC.clear();
                // //         // });
                // //       },
                // //     ),
                // //   ],
                // // ),
                // Divider(
                //   thickness: 8,
                //   color: Colors.grey[100],
                //   height: 30,
                // ),
                // buildHeading(context, locale.productTag1),
                SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: EntryFieldProfile(
                            label: locale.productTag2,
                            hint: locale.enterProduct,
                            labelFontSize: 18,
                            labelFontWeight: FontWeight.normal,
                            controller: pTagsC,
                          )),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if(pTagsC.text!=null && pTagsC.text.length>0&& !isAllSpaces(pTagsC.text)){
                              int idd = tags.indexOf(pTagsC.text.toUpperCase());
                              if(idd<0){
                                setState(() {
                                  tags.add(pTagsC.text.trim());
                                  pTagsC.clear();
                                });
                              }
                            }else{
                              Toast.show(locale.enterValidTag, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                            }
                          },
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(child: Text('${tags[index].toString().replaceAll("[", '').replaceAll("]", '')}',textAlign: TextAlign.start,)),
                              IconButton(
                                icon: Icon(Icons.delete_forever,color: kRoundButtonInButton),
                                onPressed: () {
                                  setState(() {  tags.removeAt(index); });
                                },
                              ),
                            ],
                          ),
                        );
                      })
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                     ? SizedBox(width: 40, height: 40, child: CircularProgressIndicator())
                     : CustomButton(
                      onTap: () {
                        if(pNamec.text!=null && pNamec.text.length>0 && !isAllSpaces(pNamec.text)){
                          if(tags.length>0){
                            setState(() { isLoading = true; });
                            if(_image!=null){
                              String fid = _image.path.split('/').last;
                              if(fid!=null && fid.length>0){
                                updateProductWithImage(fid,context);
                              }else{
                                updateProduct(context);
                              }
                            }else{
                              updateProduct(context);
                            }
                          }else{
                            Toast.show(locale.addOneTag, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                          }
                        } else{
                          Toast.show(locale.enterProductTitle, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        }
                      },
                      label: locale.updateItem,
                      iconGap: 12,
                    ),
                  ],
                ),
                SizedBox(height: 50),
              ],
            ),
            // Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         isLoading?SizedBox(
            //           width: 40,
            //           height: 40,
            //           child: CircularProgressIndicator(),
            //         ):CustomButton(
            //             onTap: (){
            //               if(pNamec.text!=null && pNamec.text.length>0&& !isAllSpaces(pNamec.text)){
            //                 if(tags.length>0){
            //                   setState(() {
            //                     isLoading = true;
            //                   });
            //                   if(_image!=null){
            //                     String fid = _image.path.split('/').last;
            //                     if(fid!=null && fid.length>0){
            //                       updateProductWithImage(fid,context);
            //                     }else{
            //                       updateProduct(context);
            //                     }
            //                   }else{
            //                     updateProduct(context);
            //                   }
            //                 }else{
            //                   Toast.show('Please enter at least one tag', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
            //                 }
            //               } else{
            //                 Toast.show('Please enter product title', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
            //               }
            //             },
            //             label: locale.updateItem,
            //           iconGap: 12,
            //         ),
            //       ],
            //     )),
          ],
        ),
      ),
    );
  }

  Padding buildHeading(BuildContext context, String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
      child: Text(heading, style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w500,color: kRoundButtonInButton,fontSize: 16)),
    );
  }


  void updateProductWithImage(String fid, BuildContext context) async{
    var requestMulti = http.MultipartRequest('POST', storeProductsUpdateUri);
    print('updateProductWithImage => storeProductsUpdateUri : $storeProductsUpdateUri ' +'product_id : '+'$prodId,'
        +'product_name : '+'${pNamec.text},'
        +'tags : ' +'${tags.toString()} ,'+ 'product_image : ');
    requestMulti.fields["product_id"] = '$prodId';
    requestMulti.fields["product_name"] = '${pNamec.text}';
    requestMulti.fields["tags"] = '${tags.toString()}';
    http.MultipartFile.fromPath('product_image', _image.path, filename: fid).then((pic) {
      requestMulti.files.add(pic);
      requestMulti.send().then((values) {
        values.stream.toBytes().then((value) {
          var responseString = String.fromCharCodes(value);
          var jsonData = jsonDecode(responseString);
          print('updateProductWithImage => jsonData : ${jsonData.toString()}');
          if('${jsonData['status']}'=='1'){
            Navigator.of(context).pop(true);
          }
          Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
          setState(() { isLoading = false;   });
        }).catchError((e) {
          print('updateProductWithImage => ERROR 1 : ${e.toString()}');
          setState(() { isLoading = false;  });
        });
      }).catchError((e) {
        print('updateProductWithImage => ERROR 2 : ${e.toString()}');
        setState(() { isLoading = false;  });
        print('updateProductWithImage => ERROR 3 : ${e.toString()}');
      });
    }).catchError((e) {
      setState(() {  isLoading = false;  });
      print('updateProductWithImage => ERROR 4 : ${e.toString()}');
    });
  }

  void updateProduct(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('updateProduct => storeProductsUpdateUri : $storeProductsUpdateUri ' +'product_id : '+'$prodId,'
        +'|| product_name : '+'${pNamec.text},'
        +'|| tags : ' +'${tags.toString()} ,'+ 'product_image : ');
    https.post(storeProductsUpdateUri,body: {
      'product_id':'$prodId',
      'product_name':'${pNamec.text}',
      'tags':'${tags.toString()}',
      'product_image':'',
    }).then((value){
      var jsonData = jsonDecode(value.body);
      print('updateProduct => value.body : ${value.body}');
      if('${jsonData['status']}'=='1'){
        Navigator.of(context).pop(true);
      }
      Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      setState(() {  isLoading = false;   });
    }).catchError((e){
      print('updateProduct => ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }
}
