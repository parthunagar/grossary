import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Components/entry_field_profile.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/productmodel/categorylist.dart';
import 'package:vendor/beanmodel/productmodel/storeprodcut.dart';

class EditItemPage extends StatefulWidget {
  @override
  EditItemPageState createState() => EditItemPageState();
}

class EditItemPageState extends State<EditItemPage> {
  var https = Client();
  StoreProductData productData;
  Varients productVarient;
  int varaint_id;
  bool isLoading = false;
  bool entered = false;
  List<CategoryListData> categoryList = [];
  CategoryListData catData;
  List<String> tags = [];

  TextEditingController pDescC = TextEditingController();
  TextEditingController pPriceC = TextEditingController();
  TextEditingController pMrpC = TextEditingController();
  TextEditingController pQtyC = TextEditingController();
  TextEditingController pUnitC = TextEditingController();
  TextEditingController eanC = TextEditingController();

  // String catString = 'Select Item Category';

  String _scanBarcode;

  EditItemPageState() {
    catData = CategoryListData('', 'Select Item Category', '', '', '', '', '', '', '');
    categoryList.add(catData);
  }

  @override
  void initState() {
    super.initState();
    getCategoryList(1);
  }

  @override
  void dispose() {
    https.close();
    super.dispose();
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
        // _scanBarcode = value;
        // eanC.text = _scanBarcode;
      });
      print('scancode - ${_scanBarcode}');
    }).catchError((e) {
      print('scanProductCode ERROR : ${e.toString()}');
    });
  }
  
  void getCategoryList(dynamic pid) async {
    setState(() { isLoading = true; });
    print('getCategoryList => storeVarientsListUri : $storeVarientsListUri  '+'product_id : '+ '$pid');
    https.post(storeVarientsListUri, body: {'product_id': '$pid'}).then((value) {
      if (value.statusCode == 200) {
        print('getCategoryList => value.body : ${value.body.toString()}');
        CategoryListMain categoryListMain = CategoryListMain.fromJson(jsonDecode(value.body));
        if ('${categoryListMain.status}' == '1') {
          setState(() {
            categoryList.clear();
            categoryList = List.from(categoryListMain.data);
            catData = categoryList[0];
          });
        }
      }
      setState(() {  isLoading = false;  });
    }).catchError((e) {
      print('getCategoryList => ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }
  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if(output == '') {
      return true;
    }
    return false;
  }



  var selectUnit;
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> argd = ModalRoute.of(context).settings.arguments;
    if(!entered){
      setState(() {
        entered = true;
        productData = argd['pData'];
        varaint_id = argd['vid'];
        if(productData.tags!=null && productData.tags.length>0){
          for(Tags tg in productData.tags){
            tags.add(tg.tag);
          }
        }
        // pDescC.text = productData.varients
        int indexd = productData.varients.indexOf(Varients(varientId: varaint_id));
        productVarient = productData.varients[indexd];
        pDescC.text = '${productVarient.description}';
        pMrpC.text = '${productVarient.mrp}';
        pPriceC.text = '${productVarient.price}';
        // pUnitC.text = '${productVarient.unit}';
        pUnitC.text = '${productVarient.unit.replaceAll(' ', '').replaceAll(RegExp(r'[^0-9,.]+'), '')}';
        pQtyC.text = '${productVarient.quantity}';
        eanC.text = '${productVarient.ean}';
       try{
          selectUnit = productVarient.unit.toString().replaceAll(' ', '').replaceAll(RegExp(r'[0-9,.]+'), '').toString() == 'null' ? "Select Unit" : productVarient.unit.toString().replaceAll(' ', '').replaceAll(RegExp(r'[0-9,.]+'), '');
          print('selectUnit  : $selectUnit');
        }catch(e){
         print('ERORR: $e');
       }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.updateItem, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
          ),
          height: 30,
          width: 30,
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
      body: Stack(
        children: [
          ListView(
            children: [
              // Divider(
              //   thickness: 2,
              //   color: Colors.grey[100],
              //   height: 30,
              // ),
              // buildHeading(context, locale.description),
              SizedBox(height: 50),
              EntryFieldProfile(
                textInputAction: TextInputAction.next,
                maxLines: 4,
                label: locale.briefYourProduct,
                hint: locale.enterDescription,
                labelFontSize: 18,
                labelFontWeight: FontWeight.normal,
                controller: pDescC,
              ),
              // Divider(
              //   thickness: 8,
              //   color: Colors.grey[100],
              //   height: 30,
              // ),
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
                      controller: pPriceC,
                  )),
                  Expanded(
                    child: EntryFieldProfile(
                      textInputAction: TextInputAction.next,
                      label: locale.sellProductMrp,
                      hint:locale.enterMrp,
                      labelFontSize: 18,
                       keyboardType: TextInputType.number,
                      labelFontWeight: FontWeight.normal,
                      controller: pMrpC,
                  )),
                ],
              ),
              // Divider(
              //   thickness: 8,
              //   color: Colors.grey[100],
              //   height: 30,
              // ),
              // buildHeading(context, locale.qntyunit),
              SizedBox(height: 8),

              // Text(productVarient.unit.toString().replaceAll(' ', '').replaceAll(RegExp(r'[0-9,.]+'), '')),

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
                      controller: pQtyC,
                    )),
                  Expanded(
                    child: EntryFieldProfile(
                      textInputAction: TextInputAction.next,
                      label: locale.unit1,
                      hint: locale.unit2,
                      labelFontSize: 18,
                      keyboardType: TextInputType.number,
                      labelFontWeight: FontWeight.normal,
                      controller: pUnitC,
                    )),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: DropdownButton<String>(
                      hint: Text("Select Unit",style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: kEntryFieldLable,
                          fontSize:  14)),
                      items: <String>['Select Unit', 'G', 'KG', 'Ltrs', 'Ml'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,style: Theme.of(context).textTheme.subtitle1.copyWith(color: kEntryFieldLable, fontSize:  14)),
                        );
                      }).toList(),
                      value: selectUnit,//  selectUnit == null ? 'Select Unit' : selectUnit,
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
              // Divider(
              //   thickness: 8,
              //   color: Colors.grey[100],
              //   height: 30,
              // ),
              Row(
                children: [
                  Expanded(
                    child: EntryFieldProfile(
                      textInputAction: TextInputAction.done,
                      label: locale.ean1,
                      hint: locale.ean2,
                      labelFontSize: 18,
                      labelFontWeight: FontWeight.normal,
                      controller: eanC,
                  )),
                  IconButton(
                    // icon: Icon(Icons.qr_code_scanner),
                    icon: ImageIcon(AssetImage('assets/icon_qrcod.png')),
                    onPressed: () {
                      scanProductCode(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                  ? SizedBox(width: 40, height: 40, child: CircularProgressIndicator())
                  : CustomButton(
                    label: locale.updateItem,
                    imageAssets: 'assets/Icon_update_alt.png',
                    iconGap: 12,
                    onTap: () {
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
                                                    if(eanC.text !=null && eanC.text.length>0 && eanC.text!='-1'&& !isAllSpaces(eanC.text)){
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      addProduct(context);
                                                    }else{
                                                      Toast.show(locale.scanProduct, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
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
                                  Toast.show(locale.enterValidProductMrp, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
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
                        // if (pDescC.text != null && pDescC.text.length > 0&& !isAllSpaces(pDescC.text)) {
                        //   if (pPriceC.text != null && pPriceC.text.length > 0&& !isAllSpaces(pPriceC.text)&& double.parse(pPriceC.text)>0) {
                        //     if (pMrpC.text != null && pMrpC.text.length > 0&& !isAllSpaces(pMrpC.text)&& double.parse(pMrpC.text)>0) {
                        //       if(double.parse(pPriceC.text)<=double.parse(pMrpC.text)){
                        //         if (pQtyC.text != null && pQtyC.text.length > 0&& !isAllSpaces(pQtyC.text)&& int.parse(pQtyC.text)>0) {
                        //           if (pUnitC.text != null && pUnitC.text.length > 0&& !isAllSpaces(pUnitC.text)&& int.parse(pUnitC.text)>0) {
                        //             if(eanC.text !=null && eanC.text.length>0 && eanC.text!='-1'&& !isAllSpaces(eanC.text)){
                        //               setState(() {
                        //                 isLoading = true;
                        //               });
                        //               addProduct(context);
                        //             }else{
                        //               Toast.show('Please scan bar code properly.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        //             }
                        //           }
                        //           else{
                        //             Toast.show('Please enter product unit.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        //           }
                        //         }
                        //         else{
                        //           Toast.show('Please enter product quantity.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        //         }
                        //       }else{
                        //         Toast.show('Selling price should less or equal to MRP.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        //         // addProduct();
                        //       }
                        //
                        //     }
                        //     else{
                        //       Toast.show('Please enter product mrp.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        //     }
                        //   }
                        //   else{
                        //     Toast.show('Please enter product price.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        //   }
                        // }else{
                        //   Toast.show('Please enter product description.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        // }
                      },
                    ),
                ],
              )
            ],
          ),
          // Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         isLoading
          //             ? SizedBox(
          //                 width: 40,
          //                 height: 40,
          //                 child: CircularProgressIndicator(),
          //               )
          //             : CustomButton(
          //                 onTap: () {
          //                   if (pDescC.text != null && pDescC.text.length > 0) {
          //                     if (pPriceC.text != null && pPriceC.text.length > 0) {
          //                       if (pMrpC.text != null && pMrpC.text.length > 0) {
          //                         if (pQtyC.text != null && pQtyC.text.length > 0) {
          //                           if (pUnitC.text != null &&
          //                               pUnitC.text.length > 0) {
          //                             setState(() {
          //                               isLoading = true;
          //                             });
          //                             addProduct(context);
          //                           }
          //                         }
          //                       }
          //                     }
          //                   }
          //                 },
          //                 label: locale.updateItem),
          //       ],
          //     )),
        ],
      ),
    );
  }

  Padding buildHeading(BuildContext context, String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
      child: Text(heading, style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w500)),
    );
  }

  void addProduct(BuildContext context) async {
    int unit = int.parse(pUnitC.text);
    String sUnit = unit.toString();
    print('addProduct => storeVarientsUpdateUri : $storeVarientsUpdateUri '
    + '|| varient_id  : '+ '${productVarient.varientId}'
    + '|| quantity : '+'${pQtyC.text}'
    + '|| unit : '+ '${sUnit}'
    + '|| price : '+ '${pPriceC.text}'
    + '|| mrp : ' '${pMrpC.text}'
    + '|| description : '+ '${pDescC.text}'
    + '|| ean : '+ '${eanC.text}' );
    https.post(storeVarientsUpdateUri, body: {
      'varient_id': '${productVarient.varientId}',
      'quantity': '${pQtyC.text}',
      'unit': '${sUnit} $selectUnit',
      'price': '${pPriceC.text}',
      'mrp': '${pMrpC.text}',
      'description': '${pDescC.text}',
      'ean': '${eanC.text}',
    }).then((value) {
      print('addProduct => value.body : ${value.body}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        Navigator.of(context).pop(true);
        setState(() {
          tags.clear();
          pDescC.clear();
          pMrpC.clear();
          pPriceC.clear();
          pQtyC.clear();
          pUnitC.clear();
          eanC.clear();
        });
        Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('addProduct => ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }
}
