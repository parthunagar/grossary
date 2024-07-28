import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/cart/addtocartbean.dart';
import 'package:groshop/beanmodel/cart/cartitembean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:groshop/Components/custom_button.dart';

class CartPage extends StatefulWidget {
  // final VoidCallback onBackButtonPressed;
  //
  // CartPage(this.onBackButtonPressed);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItemData> cartItemd = [];
  CartStoreDetails storeDetails;
  List<int> count = [1, 1, 1];
  bool progressadd = false;
  dynamic totalPrice = 0.0;
  dynamic promocodeprice = 0.0;
  dynamic deliveryFee = 0.0;
  dynamic cart_id;
  dynamic apcurrency;

  @override
  void initState() {
    super.initState();
    getCartList();
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apcurrency = preferences.getString('app_currency');
      progressadd = true;
    });
    var http = Client();

    print('getCartList => showCartUri : $showCartUri ' + 'user_id : ' + '${preferences.getInt('user_id')}');
    http.post(showCartUri,
        body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
      print('cart - ${value.body}');
      if (value.statusCode == 200) {
        CartItemMainBean data1 =
            CartItemMainBean.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            totalPrice = data1.total_price;
            cartItemd.clear();
            cartItemd = List.from(data1.data);
            cart_id = cartItemd[0].order_cart_id;
            storeDetails = data1.store_details;
            deliveryFee = double.parse('${data1.delivery_charge}');
          });
        } else {}
      }
      setState(() {  progressadd = false;   });
    }).catchError((e) {
      setState(() {   progressadd = false;   });
      print('getCartList => ERROR : $e');
    });
  }

  void addtocart(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context) async {
    setState(() {  progressadd = true;  });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(addToCartUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'qty': '${qnty}',
      'store_id': '${storeid}',
      'varient_id': '${varientid}',
      'special': '${special}',
    }).then((value) {
      print('cart add${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 = AddToCartMainModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            totalPrice =
                (data1.total_price != null || '${data1.total_price}' != 'null') ? data1.total_price : 0.0;
            if (data1.cart_items == null || data1.cart_items.length <= 0) {
              cartItemd.clear();
            }
          });
        }
        Toast.show(data1.message, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() {   progressadd = false;   });
    }).catchError((e) {
      setState(() {   progressadd = false;    });
      print('addtocart => ERROR : $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //     leading: IconButton(
      //       icon: Icon(Icons.arrow_back),
      //       onPressed: () {
      //        Navigator.of(context).pop();
      //       },
      //     ),
      //   // automaticallyImplyLeading: true,
      //     elevation: 0,
      //     title: Text(
      //       locale.yourCart,
      //       style: TextStyle(color: kMainTextColor),
      //     ),
      //     iconTheme: IconThemeData(color: Colors.black),
      //     centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                      ),
                      height: 30,
                      width: 30,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded),
                        iconSize: 15,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      ),
                    ),
                  ),
                  Center(child: Text(locale.yourCart, style: Theme.of(context).textTheme.headline6.copyWith(color: kMainHomeText, fontSize: 18))),
                ],
              ),
            ),
            Expanded(
                child: (cartItemd != null && cartItemd.length > 0)
                    ? Container(
                        child: SingleChildScrollView(
                          primary: true,
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cartItemd.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: kWhiteColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: cartItemd[index].varient_image,
                                              height: 95,
                                              width: 90,
                                              placeholder: (context, url) => Align(
                                                widthFactor: 50,
                                                heightFactor: 50,
                                                alignment: Alignment.center,
                                                child: Container(padding: const EdgeInsets.all(5.0), width: 50, height: 50, child: CircularProgressIndicator())),
                                              errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                                            ),
                                            // child: Image.network(cartItemd[index].varient_image,width: 90,height: 95 )
                                        ),
                                        SizedBox(width: w * 0.04),
                                        Container(
                                          color: Colors.yellow,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            // mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                color: Colors.green,
                                                width: w *0.42,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(color: Colors.green[100], child: Text(cartItemd[index].product_name, style: TextStyle(color: kTextBlack, fontWeight: FontWeight.bold, fontSize: 16))),// style: Theme.of(context).textTheme.subtitle1,
                                                    SizedBox(height: h * 0.012),
                                                    Text('${cartItemd[index].quantity} ${cartItemd[index].unit}', style: TextStyle(color: kTextBlack, fontWeight: FontWeight.normal, fontSize: 12)),// style: Theme.of(context).textTheme.subtitle2,
                                                    SizedBox(height: h * 0.029),
                                                    Container(
                                                      color: Colors.red[100],
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        // mainAxisSize: MainAxisSize.max,
                                                        // crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          buildIconButton(Icons.remove, index, cartItemd, context),
                                                          SizedBox(width: w * 0.04),
                                                          Text('${cartItemd[index].qty}', style: Theme.of(context).textTheme.subtitle1),
                                                          SizedBox(width: w * 0.04),
                                                          buildIconButton(Icons.add, index, cartItemd, context),
                                                          // SizedBox(width: 40),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text('$apcurrency ${cartItemd[index].price}',
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kMainPriceText)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      )
                    : Container(alignment: Alignment.center, child: Text(!progressadd ? locale.cart1 : '', textAlign: TextAlign.center))),// style: TextStyle(fontSize: 16,color: kTextBlack,fontWeight: FontWeight.normal),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight:  Radius.circular(30)),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
              // color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 5),
                  Visibility(
                    visible: (totalPrice != null && double.parse('$totalPrice') > 0),
                    child: buildAmountRow(locale.cartTotal, '$apcurrency $totalPrice', kTextBlack)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: kRatingStarNull)),
                  Visibility(
                      visible: ((cartItemd != null && cartItemd.length > 0) && (deliveryFee != null && double.parse('$deliveryFee') > 0)),
                      child: buildAmountRow(locale.deliveryFee, '$apcurrency $deliveryFee', kTextBlack)),
                  Visibility(
                    visible: ((cartItemd != null && cartItemd.length > 0) && (deliveryFee != null && double.parse('$deliveryFee') > 0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: kRatingStarNull),
                    ),
                  ),
                  Visibility(
                    visible: ((cartItemd != null && cartItemd.length > 0)),
                    child: buildAmountRow(locale.total, '$apcurrency ${(totalPrice + deliveryFee)}', kMainPriceText)),
                  // buildAmountRow(locale.promoCode, '-$apcurrency $promocodeprice'),
                  SizedBox(height: 5),
                  (!progressadd)
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // width: MediaQuery.of(context).size.width,
                              child: (cartItemd != null && cartItemd.length > 0)
                                ? CustomButton(
                                    onTap: () {
                                      if ((cartItemd != null && cartItemd.length > 0)) {
                                        Navigator.pushNamed(context,
                                          PageRoutes.selectAddress,
                                          arguments: {
                                            'store_id': '${storeDetails.store_id}',
                                            'store_d': storeDetails,
                                            'cartdetails': cartItemd});
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    iconGap: 12,
                                    color: kRoundButton,
                                    imageAssets: 'assets/checkout_now.png',
                                    label: locale.checkoutNow,
                                  )
                                : Text(locale.shownow, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: kWhiteColor)),
                            ),
                          ],
                        ))
                    : Container(
                        height: 52,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRoundButton)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildAmountRow(String text, String price, Color kMainPriceText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kMainPriceText)),
          Spacer(),
          Text(price, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kMainPriceText)),
        ],
      ),
    );
  }

  Container buildIconButton(IconData icon, int index, List<CartItemData> items, BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
        // border: Border.all(color: Colors.grey[400], width: 0)
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            if (icon == Icons.remove) {
              int ct = int.parse('${items[index].qty}');
              if (ct > 0) {
                ct--;
                items[index].qty = '$ct';
                addtocart('${items[index].store_id}', '${items[index].varient_id}', ct, '0', context);
              }
            } else {
              int ct = int.parse('${items[index].qty}');
              ct++;
              items[index].qty = '$ct';
              addtocart('${items[index].store_id}', '${items[index].varient_id}', ct, '0', context);
            }
          });
        },
        icon: Icon(icon, color: Colors.black, size: 16),
      ),
    );
  }
}
