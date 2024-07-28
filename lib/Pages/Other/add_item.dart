import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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

class AddItemPage extends StatefulWidget {
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {

  var https = Client();
  bool isLoading = false;
  List<CategoryListData> categoryList = [];
  CategoryListData catData;
  List<String> tags = [];
  dynamic _scanBarcode;
  TextEditingController pNamec = TextEditingController();
  TextEditingController pDescC = TextEditingController();
  TextEditingController pPriceC = TextEditingController();
  TextEditingController pMrpC = TextEditingController();
  TextEditingController pQtyC = TextEditingController();
  TextEditingController pUnitC = TextEditingController();
  TextEditingController pTagsC = TextEditingController();
  TextEditingController eanC = TextEditingController();

  List<File> imageList = [];

  File _image;
  final picker = ImagePicker();

  String catString = 'Select Item Category';

  bool view = true;

  AddItemPageState(){
    imageList.add(File(''));
    catData = CategoryListData('', 'Select Item Category', '', '', '', '', '', '', '');
    categoryList.add(catData);
  }

  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if(output == '') {
      return true;
    }
    return false;
  }
  void scanProductCode(BuildContext context) async {
    var locale = AppLocalizations.of(context);
    await FlutterBarcodeScanner.scanBarcode("#ff6666", locale.cancel, true, ScanMode.DEFAULT).then((value) {
      setState(() {
        if(value!='-1'&& value!= null &&value!= 'null'){
          _scanBarcode = value;
          eanC.text = _scanBarcode;
        }else{
          eanC.text = null;
          Toast.show(locale.scanBarcode, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
        }
      });
      print('scancode - $_scanBarcode');
    }).catchError((e) {});
  }

  @override
  void initState() {
    super.initState();
    getCategoryList();
  }

  @override
  void dispose() {
    https.close();
    super.dispose();
  }

  void getCategoryList() async {
    setState(() {
      isLoading = true;
    });
    print('getCategoryList => catListUri : $catListUri');
    https.get(catListUri).then((value) {
      if (value.statusCode == 200) {
        CategoryListMain categoryListMain = CategoryListMain.fromJson(jsonDecode(value.body));
        print('getCategoryList => value.body : '+value.body);
        if ('${categoryListMain.status}' == '1') {
          setState(() {
            categoryList.clear();
            categoryList = List.from(categoryListMain.data);
            catData = categoryList[0];
          });
        }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('getCategoryList => ERROR : $e');
      setState(() { isLoading = false;  });
    });
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        view = true;
        _image = File(pickedFile.path);
        imageList.add(_image);
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
      allowedExtensions: ['jpg', 'png']);

    if (result != null) {
      setState(() {
        PlatformFile file = result.files.first;
        print('_imgFromGallery => file.extension : '+file.extension);
        if (file.extension == 'png' || file.extension == 'jpg' || file.extension == 'jpeg') {
          print('_imgFromGallery => result.files.single.path : '+result.files.single.path);
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
                      setState(() { view=false; });
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

  var selectUnit;
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    //locale.addItem
    return Scaffold(
      backgroundColor: kMyAccountBack,
      // appBar:
      body: SingleChildScrollView(
        child: Visibility(
          visible: view,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: AppBar(
                      backgroundColor: kMyAccountBack,
                      title: Text(locale.addItem,style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
                      centerTitle: true,
                      leading: Container(
                        height: 30,
                        width: 30,
                        margin: EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded),
                          iconSize: 15,
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
                  ),
                  Container(
                    height: 90,
                    width: MediaQuery.of(context).size.width-20,
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
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.grey[200].withOpacity(index == 0 ? 1 : 0.9),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                    Colors.grey[100].withOpacity(index == 0 ? 1 : 0.9),
                                    index != 0 ? BlendMode.dst :  BlendMode.dst),
                                  // image:FileImage(imageList[index]),
                                  image: index==0?AssetImage('assets/icon.png'):FileImage(imageList[index]),
                                  fit: BoxFit.fill)),
                            child: index == 0
                              ? SizedBox.shrink()
                              // Icon(
                              //   Icons.camera_alt,
                              //   color: Theme
                              //       .of(context)
                              //       .primaryColor,
                              //   size: 30,
                              // )
                              : SizedBox.shrink(),
                          ),
                        );
                      }),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 280),
                padding: EdgeInsets.only(top: 80),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
                  color: kWhiteColor,
                  boxShadow: [BoxShadow(blurRadius:5 , color: Colors.black12,offset: Offset(0.0, 0.75))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    // buildHeading(context, locale.itemInfo),
                    EntryFieldProfile(
                        textInputAction: TextInputAction.next,
                      label: locale.productTitle,
                      hint :locale.enterTitle,
                      labelFontSize: 18,
                      labelFontWeight: FontWeight.normal,
                      controller: pNamec),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                            child: Text(locale.itemCategory, style: TextStyle(fontSize: 16, color: kHintColor,fontWeight:FontWeight.normal)),
                          ),
                          DropdownButton<CategoryListData>(
                            isExpanded: true,
                            value: catData,
                            underline: Container(height: 1.0, color: kMainTextColor),
                            icon: Image.asset('assets/icondown.png', height: 12, width: 12),
                            iconEnabledColor: kMainTextColor,
                            iconDisabledColor: kMainTextColor,
                            iconSize: 30,
                            items: categoryList.map((values) {
                              return DropdownMenuItem<CategoryListData>(value: values, child: Text(values.title));
                            }).toList(),
                            onChanged: (area) {
                              setState(() { catData = area; });
                              // getSubCategoryList(area.category_id);
                            },
                          )
                        ],
                      ),
                    ),
                    Divider(thickness: 8, color: Colors.grey[100], height: 30),
                    // buildHeading(context, locale.description),
                    EntryFieldProfile(
                        textInputAction: TextInputAction.next,
                      maxLines: 4,
                      label: locale.briefYourProduct,
                      hint: locale.enterDescription,
                      labelFontSize: 18,
                      labelFontWeight: FontWeight.normal,
                      controller: pDescC),
                    Divider(thickness: 8, color: Colors.grey[100], height: 30),
                    // buildHeading(context, locale.pricingStock),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: EntryFieldProfile(
                              textInputAction: TextInputAction.next,
                            label: locale.sellProductPrice,
                            hint: locale.enterPrice,
                            labelFontSize: 18,
                            keyboardType: TextInputType.number,
                            labelFontWeight: FontWeight.normal,
                            controller: pPriceC)),
                        Expanded(
                          child: EntryFieldProfile(
                              textInputAction: TextInputAction.next,
                            label: locale.sellProductMrp,
                            hint: locale.enterMrp,
                            keyboardType: TextInputType.number,
                            labelFontSize: 18,
                            labelFontWeight: FontWeight.normal,
                            controller: pMrpC)),
                      ],
                    ),
                    Divider(thickness: 8, color: Colors.grey[100], height: 30),
                    // buildHeading(context, locale.qntyunit),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: EntryFieldProfile(
                              textInputAction: TextInputAction.next,
                            label: locale.qnty1,
                            hint: locale.qnty2,
                            labelFontSize: 18,
                            keyboardType: TextInputType.number,
                            labelFontWeight: FontWeight.normal,
                            controller: pQtyC)),
                        Expanded(
                          child: EntryFieldProfile(
                              textInputAction: TextInputAction.next,
                            label: locale.unit1,
                            hint: locale.unit2,
                            labelFontSize: 18,
                            keyboardType: TextInputType.number,
                            labelFontWeight: FontWeight.normal,
                            controller: pUnitC)),
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          height: MediaQuery.of(context).size.height * 0.085,
                          child: DropdownButton<String>(
                            hint: Text("Select Unit",style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: kEntryFieldLable,
                                fontSize:  14)),
                            items: <String>['G', 'KG', 'Ltrs', 'Ml'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,style: Theme.of(context).textTheme.subtitle1.copyWith(color: kEntryFieldLable, fontSize:  14)),
                              );
                            }).toList(),
                            value: selectUnit,
                            onChanged: (val) {
                              setState(() {
                                print('val : $val');
                                selectUnit = val;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(thickness: 8, color: Colors.grey[100], height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: EntryFieldProfile(
                              textInputAction: TextInputAction.next,
                            label: locale.ean1,
                            hint: locale.ean2,
                            labelFontSize: 18,
                            labelFontWeight: FontWeight.normal,
                            controller: eanC)),
                        IconButton(
                          icon: Icon(Icons.qr_code_scanner),
                          onPressed: () {
                            scanProductCode(context);
                          },
                        ),
                      ],
                    ),
                    Divider(thickness: 8, color: Colors.grey[100], height: 30),
                    // buildHeading(context, locale.productTag1),
                    SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: EntryFieldProfile(
                                  textInputAction: TextInputAction.done,
                                label: locale.productTag2,
                                hint: locale.enterProduct,
                                labelFontSize: 18,
                                labelFontWeight: FontWeight.normal,
                                controller: pTagsC)),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                if(pTagsC.text!=null && pTagsC.text.length>0 && !isAllSpaces(pTagsC.text)){
                                  int idd = tags.indexOf(pTagsC.text.toUpperCase());
                                  if(idd<0){
                                    setState(() {
                                      tags.add(pTagsC.text.trim());
                                      pTagsC.clear();
                                    });
                                  }
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
                                    icon: Icon(Icons.delete_forever),
                                    onPressed: () {
                                      setState(() {
                                        tags.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          })
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isLoading
                        ? SizedBox(width: 40, height: 40, child: CircularProgressIndicator())
                        : CustomButton(
                            onTap: (){
                              if(pNamec.text != null && pNamec.text.length > 0&& !isAllSpaces(pNamec.text)){
                                if (pDescC.text != null && pDescC.text.length > 0&& !isAllSpaces(pDescC.text)) {
                                  if (pPriceC.text != null && pPriceC.text.length > 0&& !isAllSpaces(pPriceC.text)) {
                                    if (pMrpC.text != null && pMrpC.text.length > 0&& !isAllSpaces(pMrpC.text)) {
                                      try{
                                        if(double.parse(pPriceC.text)>0){
                                          try{
                                            if(double.parse(pMrpC.text)>0){
                                              if(double.parse(pPriceC.text)<=double.parse(pMrpC.text)){
                                                if (pQtyC.text != null && pQtyC.text.length > 0&& !isAllSpaces(pQtyC.text)) {
                                                  try{
                                                    if(int.parse(pQtyC.text)>0){
                                                      if (pUnitC.text != null && pUnitC.text.length > 0&& !isAllSpaces(pUnitC.text)) {
                                                        try{
                                                          if(int.parse(pUnitC.text)>0){

                                                            if(selectUnit != "" && selectUnit != null && selectUnit != 'Select Unit'){
                                                              if(catData.title!=null && '${catData.title}'!=catString){
                                                                if(eanC.text!=null&&eanC.text!='' && !isAllSpaces(eanC.text)){
                                                                  if(tags.length>0){
                                                                    if(_image!=null){
                                                                      String fid = _image.path.split('/').last;
                                                                      if(fid!=null && fid.length>0){
                                                                        setState(() {
                                                                          isLoading = true;
                                                                        });
                                                                        addProductWithImage(fid);
                                                                      }else{
                                                                        Toast.show(locale.addImage, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                                      }
                                                                    }else{
                                                                      Toast.show(locale.addImage, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                                    }
                                                                  }else{
                                                                    Toast.show(locale.addOneTag, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                                  }
                                                                }
                                                                else{
                                                                  Toast.show(locale.scanProduct, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                                }
                                                              }
                                                              else{
                                                                Toast.show(locale.selectCategory, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                              }
                                                            }
                                                            else{
                                                              Toast.show('Please select unit.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                            }




                                                          }else{
                                                            Toast.show(locale.enterUnit, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                          }
                                                        }catch(e){
                                                          Toast.show(locale.enterValidUnit, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                        }
                                                      }
                                                      else{
                                                        Toast.show(locale.enterUnit, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                      }
                                                    }else{
                                                      Toast.show(locale.enterQuantity, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                    }
                                                  }catch(e){
                                                    Toast.show(locale.enterValidQuantity, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                  }
                                                }
                                                else{
                                                  Toast.show(locale.enterQuantity, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                }
                                              }else{
                                                Toast.show(locale.priceLessOrEqual, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                // addProduct();
                                              }
                                            }else{
                                              Toast.show(locale.enterProductMrp, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                            }
                                          }catch(e){
                                            Toast.show(locale.enterValidProductMrp , context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                          }
                                        }else{
                                          Toast.show(locale.enterProductPrice, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                        }
                                      }catch(e){
                                        Toast.show(locale.enterValidProductPrice , context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                      }
                                    }
                                    else{
                                      Toast.show(locale.enterProductMrp, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                    }
                                  }
                                  else{
                                    Toast.show(locale.enterProductPrice, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                  }
                                }else{
                                  Toast.show(locale.enterProductDescription, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                }
                              }else{
                                Toast.show(locale.enterProductTitle, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                              }
                            },
                            imageAssets: 'assets/Icon_medical.png',
                            iconGap: 12,
                            label: locale.addItem),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:200),
                width: double.infinity,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                        ),
                        child: CircleAvatar(
                          backgroundImage: (_image != null) ? FileImage(_image) : AssetImage('assets/icon.png'),
                          // (_Uimage!=null)?NetworkImage(_Uimage):AssetImage('assets/icon.png'),
                          radius: 75.0,
                        ),
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
                              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                            ),
                            child: Image(image: AssetImage('assets/edit.png'), height: 40, width: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
              //               if(pNamec.text!=null && pNamec.text.length>0){
              //                 if(pDescC.text!=null && pDescC.text.length>0){
              //                   if(pPriceC.text!=null && pPriceC.text.length>0){
              //                     if(pMrpC.text!=null && pMrpC.text.length>0){
              //                       if(pQtyC.text!=null && pQtyC.text.length>0){
              //                         if(pUnitC.text!=null && pUnitC.text.length>0){
              //                           if(catData.title!=null && '${catData.title}'!=catString){
              //                             setState(() {
              //                               isLoading = true;
              //                             });
              //                             if(_image!=null){
              //                               String fid = _image.path.split('/').last;
              //                               if(fid!=null && fid.length>0){
              //                                 addProductWithImage(fid);
              //                               }else{
              //                                 addProduct();
              //                               }
              //                             }else{
              //                               addProduct();
              //                             }
              //                           }
              //                         }
              //                       }
              //                     }
              //                   }
              //                 }
              //               }
              //             },
              //             imageAssets: 'assets/Icon_medical.png',
              //             iconGap: 12,
              //             label: locale.addItem),
              //       ],
              //     )),
            ],
          ),
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

  //TODO: ADD ITEM WITH TAGS
  void addProductWithImage(String fid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unit = int.parse(pUnitC.text);
    String sUnit = unit.toString();
    print('addProductWithImage=> storeProductsAddUri : $storeProductsAddUri ' + 'store_id : ' +'${prefs.getInt('store_id')}'
    + ',cat_id : '  + '${catData.cat_id}' + ',product_name : ' +  '${pNamec.text}'
    + ',quantity : ' +  '${pQtyC.text}'  + ',unit  : ' +'${sUnit}'
    + ',price : ' + '${pPriceC.text}' + ',mrp : ' + '${pMrpC.text}'
    + ',description : ' + '${pDescC.text}' + ',ean : '+ '${eanC.text}'
    + ',tags' + '${tags.toString()}');

    var requestMulti = http.MultipartRequest('POST', storeProductsAddUri);
    requestMulti.fields["store_id"] = '${prefs.getInt('store_id')}';
    requestMulti.fields["cat_id"] = '${catData.cat_id}';
    requestMulti.fields["product_name"] = '${pNamec.text}';
    requestMulti.fields["quantity"] = '${pQtyC.text}';
    requestMulti.fields["unit"] = '${sUnit}';
    requestMulti.fields["price"] = '${pPriceC.text}';
    requestMulti.fields["mrp"] = '${pMrpC.text}';
    requestMulti.fields["description"] = '${pDescC.text}';
    requestMulti.fields["ean"] = '${eanC.text}';
    requestMulti.fields["tags"] = '${tags.toString()}';
    http.MultipartFile.fromPath('product_image', _image.path, filename: fid).then((pic) {
      requestMulti.files.add(pic);
      requestMulti.send().then((values) {
        values.stream.toBytes().then((value) {
          var responseString = String.fromCharCodes(value);
          var jsonData = jsonDecode(responseString);
          print('addProductWithImage => jsonData : ${jsonData.toString()}');
          // RegistrationModel signInData = RegistrationModel.fromJson(jsonData);
          if('${jsonData['status']}'=='1'){
            setState(() {
              imageList.removeAt(1);
              pNamec.clear();
              tags.clear();
              pDescC.clear();
              pMrpC.clear();
              pPriceC.clear();
              pQtyC.clear();
              pUnitC.clear();
              eanC.clear();
            });
          }
          Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
          setState(() { isLoading = false;  });
          Navigator.pop(context);
        }).catchError((e) {
          print('addProductWithImage ERROR 1 : ${e.toString()}');
          setState(() { isLoading = false;  });
        });
      }).catchError((e) {
        print('addProductWithImage ERROR 2 : ${e.toString()}');
        setState(() { isLoading = false;  });
      });
    }).catchError((e) {
      print('addProductWithImage ERROR 3 : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }

  void addProduct() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    https.post(storeProductsAddUri,body: {
      'store_id':'${prefs.getInt('store_id')}',
      'cat_id':'${catData.cat_id}',
      'product_name':'${pNamec.text}',
      'quantity':'${pQtyC.text}',
      'unit':'${pUnitC.text}',
      'price':'${pPriceC.text}',
      'mrp':'${pMrpC.text}',
      'description':'${pDescC.text}',
      'ean':'${eanC.text}',
      'tags':'${tags.toString()}',
      'product_image':'',
    }).then((value){
      var jsonData = jsonDecode(value.body);
      if('${jsonData['status']}'=='1'){
        setState(() {
          imageList.removeAt(1);
          pNamec.clear();
          tags.clear();
          pDescC.clear();
          pMrpC.clear();
          pPriceC.clear();
          pQtyC.clear();
          pUnitC.clear();
          eanC.clear();
        });
      }
      Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      setState(() { isLoading = false;  });
    }).catchError((e){
      setState(() { isLoading = false;  });
    });
  }
}
