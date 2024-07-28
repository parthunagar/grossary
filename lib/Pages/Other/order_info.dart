import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/deliveryboy/deliveryboylist.dart';
import 'package:vendor/beanmodel/orderbean/todayorderbean.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class OrderInfo extends StatefulWidget {
  final TodayOrderMain mainP;

  OrderInfo(this.mainP);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  TodayOrderMain productDetails;
  var http = Client();
  bool isLoading = false;
  dynamic apCurrency;

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  void getSharedPrefs() async {
    productDetails = widget.mainP;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
  }

  @override
  void dispose() {
    try {
      http.close();
    } catch (e) {
      print('dispose ERROR : ${e.toString()}');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                title: Text('${locale.orderinfo} - (#${productDetails.cart_id})', style: TextStyle(color: kTextBlack, fontSize: 18)),
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
              ListView.separated(
                shrinkWrap: true,
                itemCount: productDetails.order_details.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    color: kWhiteColor,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(color: kRoundButtonInButton2, borderRadius: BorderRadius.circular(45)),
                          padding: EdgeInsets.all(1),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.network('${productDetails.order_details[index].varient_image}', fit: BoxFit.cover)),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${productDetails.order_details[index].product_name} (${productDetails.order_details[index].quantity} ${productDetails.order_details[index].unit})', style: TextStyle(fontSize: 16, color: kTextBlack,fontWeight: FontWeight.w700,)),
                              SizedBox(height: 10),
                              Text('${locale.invoice2h} - ${productDetails.order_details[index].qty}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: kSearchIconColour),),
                              SizedBox(height: 5),
                              Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: kMainHomeText, borderRadius: BorderRadius.circular(45)),
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                  margin: EdgeInsets.only(right: 20),
                                  child: Text('${locale.invoice3h} - $apCurrency ${productDetails.order_details[index].price}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: kWhiteColor)),
                                ),
                                Text('${locale.invoice4h} ${locale.invoice3h} - $apCurrency ${(double.parse('${productDetails.order_details[index].price}') * double.parse('${productDetails.order_details[index].qty}'))}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: kTextBlack)),
                              ],
                            )
                          ],
                        )),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, indext) {
                  return Divider(
                    thickness: 0.1,
                    color: Colors.transparent,
                  );
                }),
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 1,width: MediaQuery.of(context).size.width-50,color: kBorderColor,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Text(locale.orderedOn + ' ${productDetails.order_details[0].order_date}', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12,color: kTextBlack,fontWeight: FontWeight.normal)),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(color: kRoundButtonInButton2, borderRadius: BorderRadius.circular(45)),
                            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                            child: Text(locale.orderID + ' #${productDetails.cart_id}', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 10,color: kTextBlack,fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(locale.deliveryDate + ' ${productDetails.delivery_date}', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12,color: kDeliveryDate,fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${productDetails.order_status}', style: Theme.of(context).textTheme.headline3.copyWith(color: kTextBlack, fontWeight: FontWeight.normal, fontSize: 12)),
                        Text('${productDetails.payment_mode} (${productDetails.payment_status})', style: Theme.of(context).textTheme.headline3.copyWith(color: kTextBlack, fontWeight: FontWeight.normal, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(text: '${locale.order1} ${locale.invoice3h}. ', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12 ,color: kOrderIdColor,fontWeight: FontWeight.normal),
                            children: <TextSpan>[
                              TextSpan(text: '$apCurrency ${productDetails.order_price}', style: TextStyle(fontSize: 12 ,color: kOrderIdColor,fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        Spacer(),
                        RichText(
                          text: TextSpan(
                            text: '${locale.qnt}. ', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12 ,color: kOrderIdColor,fontWeight: FontWeight.normal),
                            children: [
                              TextSpan(text: '${productDetails.order_details.length} items', style: TextStyle(fontSize: 12 ,color: kOrderIdColor,fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: (productDetails.delivery_boy_name != null),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(thickness: 8, color: Colors.grey[100], height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(locale.deliveryperson, style: Theme.of(context).textTheme.subtitle2.copyWith(color: kTextBlack,fontSize: 12,fontWeight: FontWeight.normal)),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: '${productDetails.delivery_boy_name}\n',
                                  style: Theme.of(context).textTheme.subtitle1.copyWith(color: kMainHomeText,fontSize: 12,fontWeight: FontWeight.normal),
                                  children: <TextSpan>[
                                    TextSpan(text: '${productDetails.delivery_boy_phone}', style: Theme.of(context).textTheme.bodyText2.copyWith(color: kTextBlack,fontSize: 12,fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              IconButton(icon: Icon(Icons.call), color: kMainColor, onPressed: () {})
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 8, color: kWhiteColor, height: 20),
              Container(
                padding: EdgeInsets.all(16),
                color: kRoundButtonInButton2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(locale.shippingAddress, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12,fontWeight: FontWeight.normal,color: kTextBlack)),
                    SizedBox(height: 15),
                    RichText(
                      text: TextSpan(
                        text: '${productDetails.user_name}\n\n',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 12,fontWeight: FontWeight.normal,color: kMainHomeText),
                        children: <TextSpan>[
                          TextSpan(text: '${productDetails.user_address}\n\n', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 10,color: kTextBlack,fontWeight: FontWeight.normal)),
                          TextSpan(text: '${productDetails.user_phone}', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12,color: kTextBlack,fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: (!(productDetails.delivery_boy_name != null)),
                    child: (isLoading)
                      ? Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Align(
                            widthFactor: 40,
                            heightFactor: 40,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : GestureDetector(
                            onTap: (){
                              setState(() { isLoading = true; });
                              assignOrderetoBoy();
                            },
                          child: Container(
                          width: MediaQuery.of(context).size.width/1.3,
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                          decoration: BoxDecoration(color: kMainColor1, borderRadius: BorderRadius.circular(45)),
                      child: Center(child: Text(locale.assignboy,style: TextStyle(color: kWhiteColor,fontWeight: FontWeight.bold,fontSize: 15),)),
                    ),
                        ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: ('${productDetails.order_status}'.toUpperCase() == 'PENDING'),
                    child:  GestureDetector(
                      onTap: (){
                        if (!isLoading) {
                          setState(() { isLoading = true; });
                          cancelOrder(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.3,
                        padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                        decoration: BoxDecoration(border: Border.all(color: kCancelOrder, width: 1), color: kWhiteColor, borderRadius: BorderRadius.circular(45)),
                        child: Center(child: Text(locale.cancelOrdr,style: TextStyle(color: kCancelOrder,fontWeight: FontWeight.normal,fontSize: 15),)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // void getDeliveryBoyList() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   http.post(nearbydboysUri,body: {
  //     'store_id':'${prefs.getInt('store_id')}'
  //   }).then((value){
  //     print(value.body);
  //     if(value.statusCode == 200){
  //       DeliveryBoyMain boyMain = DeliveryBoyMain.fromJson(jsonDecode(value.body));
  //       if('${boyMain.status}'=='1' && boyMain.data!=null && boyMain.data.length>0){
  //         _showDialog(boyMain.data);
  //       }
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }).catchError((e){
  //     print(e);
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }
  //
  // void _showDialog(List<DeliveryBoyData> data) {
  //   slideDialog.showSlideDialog(
  //     context: context,
  //     child: ListView.builder(
  //         shrinkWrap: true,
  //         itemCount: data.length,
  //         itemBuilder: (context,index){
  //           return Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Text('${data[index].boy_name}'),
  //                     SizedBox(width: 10,),
  //                     Text('(${double.parse('${data[index].distance}').toStringAsFixed(2)} km)'),
  //                   ],
  //                 ),
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(50),
  //                   child: RaisedButton(
  //                     onPressed: (){
  //
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text('Assign'),),
  //                 )
  //               ],
  //             ),
  //           );
  //         }),
  //     // barrierColor: Colors.white.withOpacity(0.7),
  //     // pillColor: Colors.red,
  //     // backgroundColor: Colors.yellow,
  //   );
  // }

  void assignOrderetoBoy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() { isLoading = true; });
    print('assignOrderetoBoy => assignBoyToOrderUri : $assignBoyToOrderUri  store_id : ${prefs.getInt('store_id')}  cart_id : ${productDetails.cart_id}');
    http.post(assignBoyToOrderUri, body: {
      'store_id': '${prefs.getInt('store_id')}',
      'cart_id': '${productDetails.cart_id}',
      // 'dboy_id':'$deliveryboyid',
    }).then((value) {
      print('assignOrderetoBoy => value.body : ${value.body.toString()}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        setState(() { productDetails.order_status = 'Confirmed';  });
      }
      Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('assignOrderetoBoy ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }

  void cancelOrder(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() { isLoading = true; });
    int id = prefs.getInt('store_id');
    print('cancelOrder => cancelOrderUri : $cancelOrderUri  store_id : $id cart_id : ' + '${productDetails.cart_id}');
    http.post(cancelOrderUri, body: {'store_id': '${prefs.getInt('store_id')}', 'cart_id': '${productDetails.cart_id}'}).then((value) {
      print('cancelOrder => value.body : ${value.body.toString()}');
      setState(() {
        productDetails.order_status = 'Cancelled';
        isLoading = false;
      });
      Navigator.of(context).pop(true);
    }).catchError((e) {
      print('cancelOrder ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }
}

