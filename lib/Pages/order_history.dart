import 'dart:math';

import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:driver/main.dart';
import 'package:flutter/material.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Locale/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  OrderHistory orderDetaials;
  List<ItemsDetails> order_details = [];
  bool enterFirst = false;
  bool isLoading = false;
  dynamic distance;
  dynamic time;
  dynamic apCurency;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2) {
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kms_per_min = 0.5;
    double mins_taken = kms / kms_per_min;
    double min = mins_taken;
    if (min < 60) {
      return "" + '${min.toInt()}' + " mins";
    } else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60).toStringAsFixed(2)}' + " hour " + minutes + " mins";
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final Map<String, Object> dataObject = ModalRoute.of(context).settings.arguments;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetaials = dataObject['OrderDetail'];
        order_details = orderDetaials.items;
        distance = calculateDistance(
          double.parse('${orderDetaials.userLat}'),
          double.parse('${orderDetaials.userLng}'),
          double.parse('${orderDetaials.storeLat}'),
          double.parse('${orderDetaials.storeLng}'))
          .toStringAsFixed(2);
        time = calculateTime(
          double.parse('${orderDetaials.userLat}'),
          double.parse('${orderDetaials.userLng}'),
          double.parse('${orderDetaials.storeLat}'),
          double.parse('${orderDetaials.storeLng}'));
        print('distance : $distance');
        print('time : $time');
      });
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            setState(() {  Navigator.pop(context); });
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Card(color: kWhiteColor, child: Icon(Icons.keyboard_arrow_left_rounded, size: 25, color: kRedColor))),
        ),
        title: Text('${locale.order} - #${orderDetaials.cartId}', style: TextStyle(fontFamily: 'Philosopher-Regular', fontSize: 17, fontWeight: FontWeight.bold),
          // '\n${locale.deliveryDate} ${orderDetaials.deliveryDate}'
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  (order_details != null && order_details.length > 0)
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container( // Card( elevation: 3, clipBehavior: Clip.hardEdge, child:
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              order_details[index].varientImage == null || order_details[index].varientImage ==""
                              ? Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(border: Border.all(color: kRedLightColor), borderRadius: BorderRadius.circular(50)),
                                padding: EdgeInsets.fromLTRB(12,12,17,12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset('assets/images/place_holder_image.png', fit: BoxFit.fill)),
                              )
                              : Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network('${order_details[index].varientImage}', fit: BoxFit.fill))),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${order_details[index].productName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('${order_details[index].quantity} ${order_details[index].unit} - ${locale.invoice2h}: ${order_details[index].qty}', style: TextStyle(fontSize: 13, color: kGrey,)),
                                  SizedBox(height: 10),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                          decoration: BoxDecoration(color: kRedLightColor, borderRadius: BorderRadius.circular(30)),
                                          child: Text('${locale.invoice3h} - $apCurency ${(double.parse('${order_details[index].price}') / double.parse('${order_details[index].qty}'))}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: kWhiteColor)),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(child: Text('${locale.invoice4h} ${locale.invoice3h} - $apCurency ${order_details[index].price}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13))),
                                    ],
                                  )
                                ],
                              )),
                            ],
                          ),
                          // ),
                        );
                      },
                      separatorBuilder: (context, indext) {
                        return Divider(thickness: 0.1, color: Colors.transparent);
                      },
                      itemCount: order_details.length)
                  : SizedBox.shrink(),
                  Divider(height: 5, thickness: 0.8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    color: kRoundButtonInButton2,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${locale.deliveryDate} ${orderDetaials.deliveryDate}', style: TextStyle(fontSize: 20, color: kGreyBlack)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${locale.paymentmode}', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15, color: kGreyBlack)),
                                  SizedBox(height: 3),
                                  Text('${orderDetaials.paymentMethod}', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15, color: kRedLightColor)),
                                ],
                              ),
                            ),
                            Spacer(),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${locale.invoice4h} ${locale.invoice3h}', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15, color: kGreyBlack),),
                                  SizedBox(height: 3),
                                  Text('$apCurency ${orderDetaials.remainingPrice}', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15, color: kRedLightColor)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expanded(child: Container(color: Colors.grey[100],)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                    child: Row(
                      children: [
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.fade,
                            text: TextSpan(children: [
                              TextSpan(text: locale.distance + '\n', style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                              TextSpan(text: '$distance km', style: Theme.of(context).textTheme.bodyText1.copyWith(color: kRedLightColor, height: 1.5, fontWeight: FontWeight.bold, fontSize: 16)),
                              TextSpan(text: ' ($time)', style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w300, fontSize: 16)),
                          ])),
                        ),
                        // Spacer(
                        //   flex: 2,
                        // ),
                        // RichText(text: TextSpan(children: <TextSpan>[
                        //   TextSpan(text: locale.earnings+'\n',style: Theme.of(context).textTheme.bodyText1),
                        //   TextSpan(text: '\$ 5.20',style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.green,height: 1.5)),
                        // ])),
                        // Spacer(),
                      ],
                    ),
                  ),
                  Divider(height: 5),
                  ListTile(
                    // leading: Icon(Icons.location_on,color: Colors.green,size: 24,),
                    leading: Image.asset("assets/images/Home.png", height: 35),
                    title: Text('${orderDetaials.storeName}', style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16)),
                    subtitle: Text('${orderDetaials.storeAddress}', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12,color: kGreyBlack))),
                  SizedBox(height: 5,),
                  ListTile(
                    // leading: Icon(Icons.navigation,color: Colors.green,size: 24,),
                    leading: Image.asset("assets/images/place.png", height: 35),
                    title: Text('${orderDetaials.userName}', style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16)),
                    subtitle: Text('${orderDetaials.userAddress}', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12,color: kGreyBlack))),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
          // CustomButton(
          //   onTap: () {
          //     Navigator.pushAndRemoveUntil(context,
          //         MaterialPageRoute(builder: (context) {
          //       return DeliveryBoyHome();
          //     }), (Route<dynamic> route) => false);
          //   },
          //   label: locale.backToHome,
          // ),
          SizedBox(height: 10),
          CustomRedButton(
            label: locale.backToHome,
            height: MediaQuery.of(context).size.height * 0.06,
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.28),
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                return DeliveryBoyHome();
              }), (Route<dynamic> route) => false);
            },

          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
