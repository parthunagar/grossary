import 'dart:convert';
import 'dart:developer' as logger;
import 'package:driver/Const/constant.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/completedorderhistory.dart';
import 'package:driver/beanmodel/driverstatus.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/Pages/home_page.dart';
import 'package:driver/Routes/routes.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class InsightPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: AccountDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          locale.insight,
          style: TextStyle(
            fontFamily: 'Philosopher-Regular',
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0.0,
        leading: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState.openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                  color: kWhiteColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.012,
                        horizontal: MediaQuery.of(context).size.width * 0.022),
                    child: Image.asset("assets/images/awesome_align_right.png"),
                  )),
            )),
        // actions: <Widget>[
        //   FlatButton(
        //     onPressed: (){},
        //     child: Row(
        //       children: [
        //         Text(locale.today),
        //         Icon(Icons.arrow_drop_down),
        //       ],
        //     ),
        //   ),
        // ],
      ),
      body: Insight(),
    );
  }
}

class Insight extends StatefulWidget {
  @override
  InsightState createState() {
    return InsightState();
  }
}

class InsightState extends State<Insight> {
  var http = Client();
  bool isLoading = false;
  List<OrderHistoryCompleted> newOrders = [];
  int totalOrder = 0;
  double totalincentives = 0.0;
  dynamic apCurrency;

  void getOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      apCurrency = prefs.getString('app_currency');
    });
    print('getOrderHistory => url : $completedOrdersUrl || dboy_id : ${prefs.getInt('db_id')}');
    http.post(completedOrdersUrl, body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      print('getOrderHistory => value.body : ${value.body.toString()}');
      if (jsonDecode(value.body) != '[{\"order_details\":\"no orders found\"}]') {
        var js = jsonDecode(value.body) as List;

        if (js != null && js.length > 0) {
          newOrders.clear();
          newOrders = js.map((e) => OrderHistoryCompleted.fromJson(e)).toList();
        }
      }
      setState(() {  isLoading = false;  });
    }).catchError((e) {
      print('getOrderHistory => ERROR : ${e.toString()}');
      setState(() {  isLoading = false;   });
    });
  }

  @override
  void initState() {
    super.initState();
    getOrderHistory();
    getDrierStatus();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('getDrierStatus => url : $driverStatusUri || dboy_id : ${prefs.getInt('db_id')}');
    http.post(driverStatusUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        print('getDrierStatus => value.body : ${value.body.toString()}');
        DriverStatus dstatus = DriverStatus.fromJson(jsonDecode(value.body));
        // print("dstatus : "+dstatus.toString());
        if ('${dstatus.status}' == '1') {
          int onoff = int.parse('${dstatus.onlineStatus}');
          prefs.setInt('online_status', onoff);
          totalOrder = int.parse('${dstatus.totalOrders}');
          totalincentives = double.parse('${dstatus.totalIncentive}');
        }
      }
    }).catchError((e) {
      print('getDrierStatus => ERROR : ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: kButtonColor,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          // Divider(thickness: 6.0),
          SizedBox(height: 10),
          Container(
            // color: kWhiteColor,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.29,
                  padding: EdgeInsets.symmetric(
                    horizontal: 7,
                    // vertical: 1
                  ),
                  decoration: BoxDecoration(
                      // color: kWhiteColor,
                      border: Border.all(color: kRedLightColor,width: 1.5),
                      borderRadius: BorderRadius.circular(40)),
                  child: Row(
                    children: [
                      Image.asset("assets/images/bgorders.png", height: 27),
                      SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          // crossAxisAlignment: alignment ?? CrossAxisAlignment.center,
                          children: <Widget>[
                            // SizedBox(
                            //   height: 5.0,
                            // ),
                            Text( locale.orders, overflow: TextOverflow.ellipsis, style: theme.textTheme.headline6.copyWith(fontFamily: balooRegular, color: kRedLightColor, fontSize: 14)),
                            Text('$totalOrder', overflow: TextOverflow.ellipsis, style: theme.textTheme.subtitle2.copyWith(fontSize: 12, fontFamily: balooBold, color: kRedColor),),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.08),
                Container(
                  width: MediaQuery.of(context).size.width * 0.29,
                  padding: EdgeInsets.symmetric(
                    horizontal: 7,
                    // vertical: 1
                  ),
                  decoration: BoxDecoration(
                      // color: kRedLightColor,
                      border: Border.all(color: kRedLightColor,width: 1.5,),
                      borderRadius: BorderRadius.circular(40)),
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: kRedColor),
                  //     borderRadius: BorderRadius.circular(40)),
                  child: Row(
                    children: [
                      Image.asset("assets/images/bgearnings.png", height: 27),
                      SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          // crossAxisAlignment: alignment ?? CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(locale.earnings, overflow: TextOverflow.ellipsis, style: theme.textTheme.headline6.copyWith(fontFamily: balooRegular, color: kRedLightColor, fontSize: 14)),
                            Text('$apCurrency $totalincentives', overflow: TextOverflow.ellipsis, style: theme.textTheme.subtitle2.copyWith(fontFamily: balooBold, color: kRedColor, fontSize: 12),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // )
                // buildRowChild(theme, '$totalOrder', locale.orders),
                // buildRowChild(theme, '$apCurrency $totalincentives', locale.earnings),
              ],
            ),
          ),
          // Divider(thickness: 6),
          SizedBox(height: 10),
          (!isLoading)
              ? (newOrders != null && newOrders.length > 0)
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 0),
                      shrinkWrap: true,
                      itemCount: newOrders.length,
                      itemBuilder: (context, index) {
                        return buildTransactionCard(context, newOrders[index]);
                      })
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      alignment: Alignment.center,
                      child: Text(locale.nohistoryfound),
                    )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 0),
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return buildTransactionSHCard();
                  })
        ],
      ),
    );
  }

  Container buildTransactionCard(
      BuildContext context, OrderHistoryCompleted newOrder) {
    var locale = AppLocalizations.of(context);
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: EdgeInsets.fromLTRB(10, 6, 10, 18),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      // child: Stack(
      //   children: [
      //     Row(
      //       children: [
      //         // ClipRRect(
      //         //     borderRadius: BorderRadius.circular(8),
      //         //     child: Image.network(
      //         //       newOrder.data[0].varientImage,
      //         //       fit: BoxFit.fill,
      //         //       height: 70,
      //         //       width: 80,
      //         //     )),
      //         SizedBox(
      //           width: 10,
      //         ),
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.start,
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text('${newOrder.userName}',
      //                 style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700)),
      //             SizedBox(
      //               height: MediaQuery.of(context).size.height * 0.012,
      //             ),
      //             Text(locale.deliveryDate + ' ${newOrder.deliveryDate}',
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .subtitle2
      //                     .copyWith(fontSize: 13, height: 1.3)),
      //             SizedBox(
      //               height: MediaQuery.of(context).size.height * 0.015,
      //             ),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //               children: [
      //                 Text('$apCurrency ${newOrder.remainingPrice}'+"sad sd sad ",
      //                     style: TextStyle(fontSize: 15,
      //                         fontWeight: FontWeight.bold)),
      //                 Container(
      //                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      //                   // margin: EdgeInsets.only(
      //                   //     top: MediaQuery.of(context).size.height * 0.06),
      //                   decoration: BoxDecoration(
      //                       color: kRedLightColor,
      //                       borderRadius: BorderRadius.circular(20)),
      //                   child: Text(
      //                     // '\n\n$apCurrency ${newOrder.remainingPrice}',
      //                     // '\n\n\n'+
      //                     locale.orderID + ' ' + '#${newOrder.cartId}',
      //                     overflow: TextOverflow.ellipsis,
      //                     style: Theme.of(context).textTheme.bodyText2.copyWith(
      //                         color: '${newOrder.orderStatus}'.toUpperCase() ==
      //                             'Completed'.toUpperCase()
      //                             ? kWhiteColor
      //                             : kRedColor,
      //                         fontWeight: FontWeight.w700,
      //                         fontSize: 12),
      //                   ),
      //                 )
      //               ],
      //             ),
      //           ],
      //         ),
      //         // RichText(
      //         //     text: TextSpan(
      //         //         style: Theme.of(context).textTheme.subtitle1,
      //         //         children: <TextSpan>[
      //         //       TextSpan(
      //         //           text: '${newOrder.userName}\n',
      //         //           style: TextStyle(fontWeight: FontWeight.w700)),
      //         //       TextSpan(
      //         //           text: locale.deliveryDate +
      //         //               ' ${newOrder.deliveryDate}\n\n',
      //         //           style: Theme.of(context)
      //         //               .textTheme
      //         //               .subtitle2
      //         //               .copyWith(fontSize: 12, height: 1.3)),
      //         //       // TextSpan(
      //         //       //     text: locale.orderID + ' ',
      //         //       //     style: Theme.of(context)
      //         //       //         .textTheme
      //         //       //         .subtitle2
      //         //       //         .copyWith(height: 0.5)),
      //         //
      //         //       // TextSpan(
      //         //       //     text: '#${newOrder.cartId}',
      //         //       //     style: Theme.of(context).textTheme.bodyText2.copyWith(
      //         //       //         height: 0.5, fontWeight: FontWeight.w500)),
      //         //       TextSpan(
      //         //           text: '$apCurrency ${newOrder.remainingPrice}',
      //         //           style: Theme.of(context)
      //         //               .textTheme
      //         //               .subtitle2
      //         //               .copyWith(height: 0.5,fontWeight: FontWeight.w700)),
      //         //     ])),
      //       ],
      //     ),
      //     // Align(
      //     //   // alignment: AlignmentDirectional.bottomEnd,
      //     //   alignment: Alignment.bottomRight,
      //     //   child: Container(
      //     //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      //     //     margin: EdgeInsets.only(
      //     //         top: MediaQuery.of(context).size.height * 0.06),
      //     //     decoration: BoxDecoration(
      //     //         color: kRedLightColor,
      //     //         borderRadius: BorderRadius.circular(20)),
      //     //     child: Text(
      //     //       // '\n\n$apCurrency ${newOrder.remainingPrice}',
      //     //       // '\n\n\n'+
      //     //       locale.orderID + ' ' + '#${newOrder.cartId}',
      //     //       style: Theme.of(context).textTheme.bodyText2.copyWith(
      //     //           color: '${newOrder.orderStatus}'.toUpperCase() ==
      //     //                   'Completed'.toUpperCase()
      //     //               ? kWhiteColor
      //     //               : kRedColor,
      //     //           fontWeight: FontWeight.w700,
      //     //           fontSize: 12),
      //     //     ),
      //     //   ),
      //     // ),
      //   ],
      // ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${newOrder.userName}', overflow: TextOverflow.fade, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
          Text(locale.deliveryDate + ' ${newOrder.deliveryDate}', overflow: TextOverflow.fade, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 13, height: 1.3)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('$apCurrency ${newOrder.remainingPrice}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  // margin: EdgeInsets.only(
                  //     top: MediaQuery.of(context).size.height * 0.06),
                  decoration: BoxDecoration(color: kRedLightColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    // '\n\n$apCurrency ${newOrder.remainingPrice}',
                    // '\n\n\n'+
                    locale.orderID + ' ' + '#${newOrder.cartId}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: '${newOrder.orderStatus}'.toUpperCase() == 'Completed'.toUpperCase() ? kWhiteColor : kRedColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTransactionSHCard() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        // margin: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
        margin: EdgeInsets.fromLTRB(10, 6, 10, 18),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(height: 70, width: 70, color: Colors.grey[300])),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 10, width: 60, color: Colors.grey[300]),
                    SizedBox(height: 5),
                    Container(height: 10, width: 60, color: Colors.grey[300]),
                    SizedBox(height: 5),
                    Container(height: 10, width: 60, color: Colors.grey[300]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
