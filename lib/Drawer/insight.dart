import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:vendor/Components/custom_button_wallet.dart';
import 'package:vendor/Components/custom_button_wallet_insight.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/revenue/topselling.dart';

class TopSellingItem {
  TopSellingItem(this.img, this.name, this.sold, this.price);

  String img,name,sold,price;
}

class InsightPage extends StatefulWidget {
  @override
  _InsightPageState createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage> {
  var http = Client();

  List<TopSellingItemsR> topSellingItems = [];
  TopSellingRevenueOrdCount orderCount;
  bool isLoading = true;
  dynamic apCurrency;

  String storeImage = '';

  @override
  void initState() {
    super.initState();
    getRevenue();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getRevenue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      storeImage = prefs.getString('store_photo');
      apCurrency = prefs.getString('app_currency');
    });
    print('getRevenue => storeProductRevenueUri : $storeProductRevenueUri ' + 'store_id : '+ '${prefs.getInt('store_id')}');
    http.post(storeProductRevenueUri, body: {'store_id': '${prefs.getInt('store_id')}'}).then((value) {
      if (value.statusCode == 200) {
        print('getRevenue => value.body : '+value.body);
        TopSellingRevenueOrdCount topSellingRevenueOrdCount = TopSellingRevenueOrdCount.fromJson(jsonDecode(value.body));
        setState(() {
          orderCount = topSellingRevenueOrdCount;
        });
        if ('${topSellingRevenueOrdCount.status}' == '1') {
          setState(() {
            topSellingItems.clear();
            topSellingItems = List.from(topSellingRevenueOrdCount.data);
          });
        }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      setState(() {  isLoading = false;  });
      print('getRevenue ERROR : ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: kWhiteColor,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context: context,image: storeImage)),
      body: Stack(
        children: [
          // (storeImage!=null&&storeImage.length>0)?Image.network(
          //   '$storeImage',
          //   height: 180,
          //   width: MediaQuery.of(context).size.width,
          //   fit: BoxFit.fill,
          // ):Container(
          //   height: 180,
          //   width: MediaQuery.of(context).size.width,
          // ),
          AppBar(
            title: Text(locale.insight, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext context) {
                return Container(
                  // padding: EdgeInsets.all(6),
                  margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                  ),
                  child: IconButton(
                    icon: ImageIcon(AssetImage('assets/Icon_awesome_align_right.png')),
                    iconSize: 15,
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    color: kRoundButtonInButton,
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                );
              },
            ),
            // iconTheme: new IconThemeData(color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(top: 150),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(height: 15),
                // Container(
                //   child: Image.asset('assets/charts.png',fit: BoxFit.fill,),
                //   height: 200,
                //   margin: EdgeInsets.symmetric(horizontal: 10),
                //   decoration: BoxDecoration(
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey[400],
                //         blurRadius: 0.0, // soften the shadow
                //         spreadRadius: 0.5, //extend the shadow
                //       ),
                //     ],
                //     borderRadius: BorderRadius.circular(8),
                //     color: Theme.of(context).scaffoldBackgroundColor,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                  child: Text(locale.topSellingItems, style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 20,color: kTextBlack,fontWeight: FontWeight.w500)),
                ),
                (!isLoading)?
                (topSellingItems!=null && topSellingItems.length>0) ?
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 0),
                    shrinkWrap: true,
                    itemCount: topSellingItems.length,
                    itemBuilder: (context, index) {
                      return buildTopSellingItemCard(
                          context,
                          topSellingItems[index].varientImage,
                          topSellingItems[index].productName,
                          '${topSellingItems[index].count}',
                          '${topSellingItems[index].revenue}');
                    })
                    : Container(
                        height: MediaQuery.of(context).size.height/1.5,
                        child: Center(child: Text(locale.nohistoryfound,style: TextStyle(color: kMainTextColor, fontSize: 14, fontWeight: FontWeight.w500))),
                    )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 0),
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return buildTopSellingSHItemCard();
                        }),
              ],
            ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: 100,
            start: 0,
            end: 0,
            child: (!isLoading && orderCount!=null)?buildOrderCard(context, orderCount):buildOrderSHCard()),
        ],
      ),
    );
  }

  Container buildOrderCard(BuildContext context, TopSellingRevenueOrdCount orderCount) {
    var locale = AppLocalizations.of(context);
    return Container(

      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButtonWalletInsight(
              width: MediaQuery.of(context).size.width/3.5,
              color:kWhiteColor,
              borderColor: kRoundButtonInButton,
              textColor: kRoundButtonInButton,
              imageAssets: 'assets/orders.png',
              label:locale.orders,
              label2:(orderCount.totalOrders!=null)?'${orderCount.totalOrders}':'0'),
            CustomButtonWalletInsight(
              width: MediaQuery.of(context).size.width/3.5,
              color:kWhiteColor,
              borderColor: kRoundButtonInButton,
              textColor: kRoundButtonInButton,
              imageAssets: 'assets/money.png',
              label:locale.revenue ,
              label2: (orderCount.totalRevenue!=null)?'$apCurrency ${orderCount.totalRevenue}':'$apCurrency 0.0'),
            CustomButtonWalletInsight(
              width: MediaQuery.of(context).size.width/3.5,
              color:kWhiteColor,
              borderColor: kRoundButtonInButton,
              textColor: kRoundButtonInButton,
              imageAssets: 'assets/pending.png',
              label:locale.pending,
              label2: (orderCount.pendingOrders!=null)?'${orderCount.pendingOrders}':'0'),
            // RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(children: <TextSpan>[
            //       TextSpan(
            //           text: '${locale.orders}\n',
            //           style: Theme.of(context).textTheme.subtitle2),
            //       TextSpan(
            //           text: (orderCount.totalOrders!=null)?'${orderCount.totalOrders}':'',
            //           style: Theme.of(context)
            //               .textTheme
            //               .subtitle1
            //               .copyWith(height: 2)),
            //     ])),
            // VerticalDivider(
            //   color: Colors.grey[400],
            // ),
            // RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(children: <TextSpan>[
            //       TextSpan(
            //           text: '${locale.revenue}\n',
            //           style: Theme.of(context).textTheme.subtitle2),
            //       TextSpan(
            //           text: (orderCount.totalRevenue!=null)?'$apCurrency ${orderCount.totalRevenue}':'$apCurrency 0.0',
            //           style: Theme.of(context)
            //               .textTheme
            //               .subtitle1
            //               .copyWith(height: 2)),
            //     ])),
            // VerticalDivider(
            //   color: Colors.grey[400],
            // ),
            // RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(children: <TextSpan>[
            //       TextSpan(
            //           text: '${locale.pending}\n',
            //           style: Theme.of(context).textTheme.subtitle2),
            //       TextSpan(
            //           text: (orderCount.pendingOrders!=null)?'${orderCount.pendingOrders}':'0',
            //           style: Theme.of(context)
            //               .textTheme
            //               .subtitle1
            //               .copyWith(height: 2)),
            //     ])),
          ],
        ),
      ),
    );
  }
  Widget buildOrderSHCard() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400],
              blurRadius: 0.0, // soften the shadow
              spreadRadius: 0.5, //extend the shadow
            )],
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 10, width: 60, color: Colors.grey[300]),
                  SizedBox(height: 5),
                  Container(height: 10, width: 60, color: Colors.grey[300]),
                ],
              ),
              VerticalDivider(color: Colors.grey[400]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 10, width: 60, color: Colors.grey[300]),
                  SizedBox(height: 5,),
                  Container(height: 10, width: 60, color: Colors.grey[300]),
                ],
              ),
              VerticalDivider(color: Colors.grey[400]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 10, width: 60, color: Colors.grey[300]),
                  SizedBox(height: 5,),
                  Container(height: 10, width: 60, color: Colors.grey[300]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildTopSellingItemCard(BuildContext context, String img, String name, String sold, String price) {
    var locale = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(45),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.network(img, fit: BoxFit.fill, width: 60, height: 60,)),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('$name',overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16,color: kTextBlack,fontWeight: FontWeight.w500)),
                    SizedBox(height: 10),
                    Text('${locale.apparel}', style: Theme.of(context).textTheme.subtitle2.copyWith(color: kSearchIconColour,fontSize: 12,fontWeight: FontWeight.normal)),
                    SizedBox(height: 10),
                    Row(
                     children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.subtitle2.copyWith(height: 1),
                          children: [
                            TextSpan(text: '${locale.revenue} ',style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 14,fontWeight: FontWeight.w500,color: kTextBlack)),
                            TextSpan(text: '$apCurrency $price', style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 14,fontWeight: FontWeight.w500,color: kTextBlack)),
                          ]),
                      ),
                    ],
                    ),
                  ],
                ),
              ),

              // RichText(
              //   text: TextSpan(
              //     style: Theme.of(context).textTheme.subtitle1,
              //     children: [
              //       TextSpan(text: '$name\n'),
              //       TextSpan(text: '${locale.apparel}\n\n', style: Theme.of(context).textTheme.subtitle2),
              //       TextSpan(text: '$sold ${locale.sold}', style: Theme.of(context).textTheme.bodyText2.copyWith(height: 0.5)),
              //   ])),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: Container(width: MediaQuery.of(context).size.width/4.5,
              decoration: BoxDecoration(color: kRoundButtonInButton, borderRadius: BorderRadius.circular(45)),
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
              margin: EdgeInsets.only(top: 45,right: 20,bottom: 5),
              child: Center(child: Text('$sold ${locale.sold}', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 14,fontWeight: FontWeight.w700,color: kWhiteColor))),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopSellingSHItemCard() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

// Align(
//   alignment: AlignmentDirectional.bottomEnd,
//   child: RichText(
//     text: TextSpan(
//         style:
//             Theme.of(context).textTheme.subtitle2.copyWith(height: 1),
//         children: <TextSpan>[
//           TextSpan(text: '\n\n\n\n${locale.revenue} '),
//           TextSpan(
//               text: '$apCurrency $price',
//               style: Theme.of(context)
//                   .textTheme
//                   .subtitle1
//                   .copyWith(fontSize: 14)),
//         ]),
//   ),
// ),