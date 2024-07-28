import 'dart:convert';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/coustom_date_picker_widget.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Components/entry_field_profile.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/couponbean/couponlistbean.dart';


class EditCouponCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditCouponCodeState();
  }
}

class EditCouponCodeState extends State<EditCouponCode> {
  CustomDatePickerController _customController = CustomDatePickerController();

  CouponListData couponData;
  DatePickerController _controller = DatePickerController();
  DateTime _selectedValue = DateTime.now();
  int indexSelected = 0;
  DateTime startDate;
  DateTime endDate;
  TextEditingController couponcodeC = TextEditingController();
  TextEditingController cartVC = TextEditingController();
  TextEditingController couponNameC = TextEditingController();
  TextEditingController couponDespC = TextEditingController();
  TextEditingController couponDistC = TextEditingController();
  TextEditingController couponResC = TextEditingController();
  bool isLoading = false;

  var http = Client();

  bool enteredFirst = false;
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

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    double appbarsize = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    Map<String, dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    if(!enteredFirst){
      setState(() {
        enteredFirst = true;
        couponData = receivedData['c_data'];
        couponNameC.text = '${couponData.couponName}';
        couponcodeC.text = '${couponData.couponCode}';
        couponDespC.text = '${couponData.couponDescription}';
        couponResC.text = '${couponData.usesRestriction}';
        cartVC.text = '${couponData.cartValue}';
        couponDistC.text = '${couponData.amount}';
        startDate = DateTime.parse('${couponData.startDate}');
        endDate = DateTime.parse('${couponData.endDate}');
        if('${couponData.type}'.toUpperCase()=='PRICE'){
          indexSelected = 0;
        }else {
          indexSelected = 1;
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: appbarsize,
                width: MediaQuery.of(context).size.width,
                color: kWhiteColor,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                            ),
                            child: Icon(Icons.arrow_back_ios_rounded, size: 20,color: kRoundButtonInButton))),
                    ),
                    // SizedBox(width: 80,),
                    Center(child: Text(locale.updatecoupon, textAlign: TextAlign.center, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),)
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:EdgeInsets.only(top: 20,left: 20,bottom: 10),
                      child: Text(locale.selectcoupontype,style: TextStyle(color: kSearchIconColour,fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Radio(value: 0, groupValue: indexSelected, onChanged: (value){
                              setState(() {
                                indexSelected = value;
                                couponDistC.text='';
                              });
                            }),
                            Text(locale.invoice3h,style: TextStyle(color: kMainTextColor,fontSize: 16, fontWeight: FontWeight.w500),),
                            SizedBox(width: 20,),
                            Radio(value: 1, groupValue: indexSelected, onChanged: (value){
                              setState(() {
                                indexSelected = value;
                                couponDistC.text='';
                              });
                            }),
                            Text(locale.percentage,style: TextStyle(color: kMainTextColor,fontSize: 16, fontWeight: FontWeight.w500),),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width-20,
                        height: 2,
                        color: kBorderColor,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                            child: Text(locale.startdate,style: TextStyle(color: kSearchIconColour,fontSize: 16, fontWeight: FontWeight.bold),),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                            child: Text((startDate!=null)?startDate.toString():_selectedValue.toString(),style: TextStyle(color: kTextBlack,fontSize: 15, fontWeight: FontWeight.w500),),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        child: CustomDatePicker(
                                          DateTime.now(),
                                          width: 60,
                                          height: 90,
                                          customController: _customController,
                                          initialSelectedDate: (startDate!=null && !startDate.isBefore(DateTime.now()))?startDate:DateTime.now(),
                                          selectionColor: kRoundButtonInButton,
                                          // selectedTextColor: kWhiteColor,
                                          monthTextStyle: TextStyle(color: kSearchIconColour,fontSize: 12,fontWeight: FontWeight.w700),
                                          dateTextStyle: TextStyle(color: kSearchIconColour,fontSize: 24,fontWeight: FontWeight.w700),
                                          dayTextStyle:TextStyle(color: kSearchIconColour,fontSize: 12,fontWeight: FontWeight.w700) ,
                                          onDateChange: (date) {
                                            // New date selected
                                            setState(() {
                                              startDate = date;
                                            });
                                            print('${date.toString()}');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                            child: Text(locale.enddate,style: TextStyle(color: kMainTextColor,fontSize: 16, fontWeight: FontWeight.w500)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                            child: Text((endDate!=null)?endDate.toString():_selectedValue.toString(),style: TextStyle(color: kMainTextColor,fontSize: 15, fontWeight: FontWeight.w500)),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        child: CustomDatePicker(
                                          DateTime.now(),
                                          width: 60,
                                          height: 90,
                                          customController: _customController,
                                          initialSelectedDate: (endDate!=null && !endDate.isBefore(DateTime.now()))?endDate:DateTime.now(),
                                          selectionColor: kRoundButtonInButton,
                                          // selectedTextColor: kWhiteColor,

                                          monthTextStyle: TextStyle(color: kSearchIconColour,fontSize: 12,fontWeight: FontWeight.w700),
                                          dateTextStyle: TextStyle(color: kSearchIconColour,fontSize: 24,fontWeight: FontWeight.w700),
                                          dayTextStyle:TextStyle(color: kSearchIconColour,fontSize: 12,fontWeight: FontWeight.w700) ,

                                          onDateChange: (date) {
                                            // New date selected
                                            setState(() {
                                              endDate = date;
                                            });
                                            print('${endDate.toString()}');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                                EntryFieldProfile(
                                  textInputAction: TextInputAction.next,
                                  label: locale.couponcodetitle1,
                                  hint: locale.couponcodetitle2,
                                  controller: couponcodeC,
                                  maxLength: 10,
                                  hintStyle: TextStyle(color: kButtonTextColor,fontSize: 14),
                                  readOnly: isLoading,
                                ),
                                EntryFieldProfile(
                                  textInputAction: TextInputAction.next,
                                  label: locale.couponcarttitle1,
                                  hint: locale.couponcarttitle2,
                                  controller: cartVC,
                                  maxLength: 6,
                                  hintStyle: TextStyle(color: kButtonTextColor,fontSize: 14),
                                  readOnly: isLoading,
                                ),
                                EntryFieldProfile(
                                  textInputAction: TextInputAction.next,
                                  label: locale.couponnametitle1,
                                  hint: locale.couponnametitle2,
                                  controller: couponNameC,
                                  maxLength: 20,
                                  hintStyle: TextStyle(color: kButtonTextColor,fontSize: 14),
                                  readOnly: isLoading,
                                ),
                                EntryFieldProfile(
                                  textInputAction: TextInputAction.next,
                                  label: locale.coupondesc1,
                                  hint: locale.coupondesc2,
                                  controller: couponDespC,
                                  hintStyle: TextStyle(color: kButtonTextColor,fontSize: 14),
                                  readOnly: isLoading,
                                ),
                                EntryFieldProfile(
                                  textInputAction: TextInputAction.next,
                                  label: locale.coupondis1,
                                  hint: locale.coupondis2,
                                  controller: couponDistC,
                                  keyboardType: TextInputType.number,
                                  maxLength: (indexSelected==0)?6:2,
                                  hintStyle: TextStyle(color: kButtonTextColor,fontSize: 14),
                                  readOnly: isLoading,
                                ),
                                EntryFieldProfile(
                                  textInputAction: TextInputAction.done,
                                  label: locale.couponresttitle1,
                                  hint: locale.couponresttitle2,
                                  controller: couponResC,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  hintStyle: TextStyle(color: kButtonTextColor,fontSize: 14),
                                  readOnly: isLoading,
                                ),
                                Visibility(
                                    visible: isLoading,
                                    child: CircularProgressIndicator(
                                      valueColor:AlwaysStoppedAnimation<Color>(kRoundButtonInButton),
                                    )),
                                Container(
                                  height: MediaQuery.of(context).size.height*0.06,
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  // padding: EdgeInsets.only(left: 20,right: 20),
                                  child: GestureDetector(
                                    onTap: (){
                                      try{
                                        if(endDate.isAfter(startDate)){
                                          if(couponcodeC.text!=null && couponcodeC.text.length>0&& !isAllSpaces(couponcodeC.text)){
                                            if(cartVC.text!=null && cartVC.text.length>0 && !isAllSpaces(cartVC.text)&& double.parse(cartVC.text)>0){
                                              if(couponNameC.text!=null && couponNameC.text.length>0 && !isAllSpaces(couponNameC.text)){
                                                if(couponDespC.text!=null && couponDespC.text.length>0 && !isAllSpaces(couponDespC.text)){
                                                  if(couponDistC.text!=null && couponDistC.text.length>0 && !isAllSpaces(couponDistC.text)){
                                                    try{
                                                      if(double.parse(couponDistC.text)>0){
                                                        if(couponResC.text!=null && couponResC.text.length>0 && !isAllSpaces(couponResC.text)){
                                                          try{
                                                            if(int.parse(couponResC.text)>0){
                                                              setState(() {
                                                                isLoading = true;
                                                              });
                                                              updateCoupon(context);
                                                            }else{
                                                              Toast.show(locale.couponresterror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                            }
                                                          }catch(e){
                                                            Toast.show(locale.enterValidRestriction, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                          }
                                                        }else{
                                                          Toast.show(locale.couponresterror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                        }

                                                      }else{
                                                        Toast.show(locale.coupondiserror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                      }
                                                    }catch(e){
                                                      Toast.show(locale.enterValidAmount, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                    }
                                                  }else{
                                                    Toast.show(locale.coupondiserror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                  }
                                                }else{
                                                  Toast.show(locale.coupondescerror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                                }
                                              }else{
                                                Toast.show(locale.couponnameerror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                              }
                                            }else{
                                              Toast.show(locale.cartVerror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                            }
                                          }else{
                                            Toast.show(locale.couponcodeerror, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                          }
                                        }else{
                                          Toast.show(locale.coupondatevalidate, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                        }
                                      }catch(e){
                                        Toast.show(locale.selectValidDate, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                      }
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      // height: appbarsize,
                                      width: MediaQuery.of(context).size.width*0.4,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(45.0), color: kMainColor),
                                      child:
                                      // (isLoading)?Align(
                                      //   widthFactor: 30,
                                      //   heightFactor: 30,
                                      //   child: CircularProgressIndicator(
                                      //     valueColor:AlwaysStoppedAnimation<Color>(kWhiteColor),
                                      //   ),
                                      // ):
                                      Text(locale.updatecoupon,style: TextStyle(color: kWhiteColor, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(height: statusBarHeight),
                              ],
                            ),
                          )
                      )
                    ],
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }

  void updateCoupon(BuildContext context) async{
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    print('updateCoupon => url : $stCouponAddUri '
      + '|| coupon_id : '+'${couponData.couponId}'
      + '|| coupon_name : '+'${couponNameC.text}'
      + '|| coupon_code : '+'${couponcodeC.text}'
      + '|| valid_to : ' +'${startDate.toString()}'
      + '|| valid_from : '+'${endDate.toString()}'
      + '|| coupon_desc : '+'${couponDespC.text}'
      + '|| cart_value : '+'${cartVC.text}'
      + '|| coupon_type : '+'${(indexSelected==0)?'Price':'Percentage'}'
      + '|| coupon_discount : '+'${couponDistC.text}'
      + '|| restriction : ' +'${couponResC.text}');

    http.post(stUpdateCouponUri,body: {
      'coupon_id':'${couponData.couponId}',
      'coupon_name':'${couponNameC.text}',
      'coupon_code':'${couponcodeC.text}',
      'valid_to':'${startDate.toString()}',
      'valid_from':'${endDate.toString()}',
      'coupon_desc':'${couponDespC.text}',
      'cart_value':'${cartVC.text}',
      'coupon_type':'${(indexSelected==0)?'Price':'Percentage'}',
      'coupon_discount':'${couponDistC.text}',
      'restriction':'${couponResC.text}',
    }).then((value){
      print('updateCoupon => value.body : ${value.body }');
      if(value.statusCode == 200){
        var js = jsonDecode(value.body);
        print(value.body);
        if('${js['status']}'=='1'){
          setState(() {
            startDate = null;
            endDate = null;
            couponcodeC.clear();
            cartVC.clear();
            couponNameC.clear();
            couponDespC.clear();
            couponDistC.clear();
            couponResC.clear();
            indexSelected = 0;
          });
          Navigator.of(context).pop(true);
        }
        Toast.show(js['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      print('updateCoupon => ERROR : $e');
      setState(() {
        isLoading = false;
      });

    });
  }
}