import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Components/entry_field_profile.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/productmodel/categorylist.dart';

class AddVarientPage extends StatefulWidget {
  @override
  AddVarientPageState createState() => AddVarientPageState();
}

class AddVarientPageState extends State<AddVarientPage> {
  var https = Client();
  bool isLoading = false;
  bool entered = false;

  TextEditingController pDescC = TextEditingController();
  TextEditingController pPriceC = TextEditingController();
  TextEditingController pMrpC = TextEditingController();
  TextEditingController pQtyC = TextEditingController();
  TextEditingController pUnitC = TextEditingController();
  TextEditingController eanC = TextEditingController();

  dynamic prodcutid;

  String _scanBarcode;


  bool isAllSpaces(String input) {
    String output = input.replaceAll(' ', '');
    if(output == '') {
      return true;
    }
    return false;
  }
  @override
  void initState() {
    super.initState();
  }

  void scanProductCode(BuildContext context) async {
    var locale = AppLocalizations.of(context);

  await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.DEFAULT).then((value) {
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
    print('scanProductCode => scancode : ${_scanBarcode}');
  }).catchError((e) {
    print('scanProductCode => ERROR : $e');
  });
  }

  @override
  void dispose() {
    https.close();
    super.dispose();
  }

  var selectUnit;
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> argd = ModalRoute.of(context).settings.arguments;
    if(!entered){
      setState(() {
        entered = true;
        prodcutid = argd['pId'];
      });
    }
    //          locale.addVarient,
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.addVarient, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
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
                      hint: locale.enterMrp,
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
              SizedBox(
                height: 8,
              ),
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
                    icon: ImageIcon(AssetImage('assets/icon_qrcode_light.png')),
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
                  imageAssets: 'assets/Icon_medical.png',
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
                  },
                  label: locale.addVarient),
                ],
              )
            ],
          ),
          // Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Row(
          //       children: [
          //         isLoading
          //             ? SizedBox(
          //           width: 40,
          //           height: 40,
          //           child: CircularProgressIndicator(),
          //         )
          //             : CustomButton(
          //             onTap: () {
          //               if (pDescC.text != null && pDescC.text.length > 0) {
          //                 if (pPriceC.text != null && pPriceC.text.length > 0) {
          //                   if (pMrpC.text != null && pMrpC.text.length > 0) {
          //                     if (pQtyC.text != null && pQtyC.text.length > 0) {
          //                       if (pUnitC.text != null &&
          //                           pUnitC.text.length > 0) {
          //                         setState(() {
          //                           isLoading = true;
          //                         });
          //                         addProduct(context);
          //                       }
          //                     }
          //                   }
          //                 }
          //               }
          //             },
          //             label: locale.addVarient),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unit = int.parse(pUnitC.text);
    String sUnit = unit.toString();
    print('addProduct => unit : ' + sUnit);
    print('addProduct => storeVarientsAddUri : $storeVarientsAddUri' + 'store_id' +  '${prefs.getInt('store_id')}'
    +',product_id'+ '${prodcutid}'
    +',quantity'+ '${pQtyC.text}'
    +',unit'+ '${sUnit}'
    +',price'+ '${pPriceC.text}'
    +',mrp'+ '${pMrpC.text}'
    +',description'+ '${pDescC.text}'
    +',ean'+ '${eanC.text}');
    https.post(storeVarientsAddUri, body: {
      'store_id': '${prefs.getInt('store_id')}',
      'product_id': '${prodcutid}',
      'quantity': '${pQtyC.text}',
      'unit': '${sUnit} ${selectUnit}',
      'price': '${pPriceC.text}',
      'mrp': '${pMrpC.text}',
      'description': '${pDescC.text}',
      'ean': '${eanC.text}',
    }).then((value) {
      var jsonData = jsonDecode(value.body);
      print('addProduct => value.body : '+value.body);
      if('${jsonData['status']}'=='1'){
        Navigator.of(context).pop(true);
        setState(() {
          pDescC.clear();
          pMrpC.clear();
          pPriceC.clear();
          pQtyC.clear();
          pUnitC.clear();
          eanC.clear();
        });
      }
      Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      print('addProduct => ERROR : $e');
      setState(() {
        isLoading = false;
      });
    });
  }
}
