import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/walletbean/rechargehistory.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WalletHistory extends StatefulWidget {
  @override
  WalletHistoryState createState() {
    return WalletHistoryState();
  }
}

class WalletHistoryState extends State<WalletHistory> {
  bool isLoading = false;
  String apCurrency = '';
  List<RechargeData> rechargeHistory = [];
  var http = Client();

  @override
  void initState() {
    super.initState();
    getHistoryList();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getHistoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      apCurrency = prefs.getString('app_currency');
    });

    http.post(walletRechargeHistoryUri, body: {'user_id': '${prefs.getInt('user_id')}'}).then((value) {
      print('getHistoryList wallet list => ppy : ${value.body}');
      if (value.statusCode == 200) {
        WalletRechargeHistory data1 =
            WalletRechargeHistory.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            rechargeHistory.clear();
            rechargeHistory = List.from(data1.data);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      print('getHistoryList wallet list ERROR : ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            leading: Container(
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                ],
              ),
              child: IconButton(
                iconSize: 15,
                icon: Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ),
            title: Text(
              locale.rechargehistory,
              style: TextStyle(color: kMainHomeText,fontSize: 18),
            ),
            centerTitle: true,
          ),
          RowHistory(locale),
          Expanded(
            child: (!isLoading &&
                    rechargeHistory != null &&
                    rechargeHistory.length > 0)
                ? ListView.builder(
                    padding: EdgeInsets.only(top: 0),
                    shrinkWrap: true,
                    itemCount: rechargeHistory.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: index%2==0 ? kWhiteColor : kBorderColor,
                        // padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(fontSize: 14,color: kTextBlack,fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: kBorderColor, width: 2))),
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: locale.rechargeDate+' : ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(fontSize: 14,color: kTextBlack,fontWeight: FontWeight.normal),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  ' ${rechargeHistory[index].dateOfRecharge}',
                                              style: TextStyle(
                                                  color: kTextBlack,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: locale.amount + ' : ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(fontSize: 14,color: kTextBlack,fontWeight: FontWeight.normal),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  ' $apCurrency ${rechargeHistory[index].amount}',
                                              style: TextStyle(
                                                  color: kTextBlack,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: locale.paymentstatus+' : ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(fontSize: 14,color: kTextBlack,fontWeight: FontWeight.normal),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  ' - ${rechargeHistory[index].rechargeStatus}',
                                              style: TextStyle(
                                                  color: kTextBlack,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              '${rechargeHistory[index].paymentGateway}'
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(fontSize: 14,color: kTextBlack,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    })
                : (isLoading)
                    ? ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            color: kWhiteColor,
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer(
                                duration: Duration(seconds: 3),
                                color: Colors.white,
                                enabled: true,
                                direction: ShimmerDirection.fromLTRB(),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 20,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 100,
                                        ),
                                        Container(
                                          height: 10,
                                          width: 100,
                                        ),
                                        Container(
                                          height: 10,
                                          width: 100,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 10,
                                      width: 50,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                    : Align(
                        alignment: Alignment.center,
                        child: Text(locale.nohistory),
                      ),
          ),
        ],
      ),
    );
  }

  Widget RowHistory(AppLocalizations locale) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.only(top: 10),
      color: kBorderColor,
      child: Row(
        children: [
          Container(
            width: 70,
            child: Center(
              child: Text(locale.sn ,
                  style: TextStyle(
                      color: kTextBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          Container(width: MediaQuery.of(context).size.width*0.75,
            child: Center(
              child: Text(locale.paymentMode,
                  style: TextStyle(
                      color: kTextBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          )
        ],
      ),
    );
  }
}

// Expanded(
//   child: (!isLoading && rechargeHistory!=null && rechargeHistory.length>0)
//       ?ListView.builder(
//       shrinkWrap: true,
//       itemCount: rechargeHistory.length,
//       itemBuilder: (context, index) {
//         return Card(
//           elevation: 3,
//           color: kWhiteColor,
//           clipBehavior: Clip.hardEdge,
//           child: Container(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Text('${index + 1}',style: Theme.of(context)
//                   .textTheme
//                   .subtitle2
//                   .copyWith(fontSize: 16),),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left:10.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         RichText(
//                           text: TextSpan(
//                             text: locale.rechargeDate,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .subtitle2
//                                 .copyWith(fontSize: 14),
//                             children: <TextSpan>[
//                               TextSpan(
//                                   text:
//                                       ' ${rechargeHistory[index].dateOfRecharge}',
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .backgroundColor,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500)),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 5,),
//                         RichText(
//                           text: TextSpan(
//                             text: locale.amount,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .subtitle2
//                                 .copyWith(fontSize: 14),
//                             children: <TextSpan>[
//                               TextSpan(
//                                   text:
//                                       ' $apCurrency ${rechargeHistory[index].amount}',
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .backgroundColor,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500)),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 5,),
//                         RichText(
//                           text: TextSpan(
//                             text: locale.paymentstatus,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .subtitle2
//                                 .copyWith(fontSize: 14),
//                             children: <TextSpan>[
//                               TextSpan(
//                                   text:
//                                       ' - ${rechargeHistory[index].rechargeStatus}',
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .backgroundColor,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500)),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 Text('${rechargeHistory[index].paymentGateway}'.toUpperCase(),style: Theme.of(context)
//                     .textTheme
//                     .subtitle2
//                     .copyWith(fontSize: 16),),
//               ],
//             ),
//           ),
//         );
//       }):
//   (isLoading)?ListView.builder(
//       shrinkWrap: true,
//       itemCount: 10,
//       itemBuilder: (context, index) {
//         return Card(
//           elevation: 3,
//           color: kWhiteColor,
//           clipBehavior: Clip.hardEdge,
//           child: Container(
//             padding: const EdgeInsets.all(8.0),
//             child: Shimmer(
//               duration: Duration(seconds: 3),
//               color: Colors.white,
//               enabled: true,
//               direction: ShimmerDirection.fromLTRB(),
//               child: Row(
//                 children: [
//                   Container(height: 10,width: 20,),
//                   Column(
//                     children: [
//                       Container(
//                         height: 10,
//                         width: 100,
//                       ),
//                       Container(
//                         height: 10,
//                         width: 100,
//                       ),
//                       Container(
//                         height: 10,
//                         width: 100,
//                       ),
//                     ],
//                   ),
//               Container(
//                 height: 10,
//                 width: 50,
//               ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }):Align(
//     alignment: Alignment.center,
//     child: Text(locale.nohistory),
//   ),
// )
