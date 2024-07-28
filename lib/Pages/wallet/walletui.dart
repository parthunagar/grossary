import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:groshop/Components/custom_button_wallet.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/wallet/rechargewallet.dart';
import 'package:groshop/Pages/wallet/spentanalysis.dart';
import 'package:groshop/Pages/wallet/wallethistory.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/walletbean/walletget.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletState();
  }
}

class WalletState extends State<Wallet> {
  var userName;
  bool islogin = false;
  dynamic amount = 0;
  String apCurrency = '';
  bool isLoading = false;
  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;

  @override
  void initState() {
    super.initState();
    getWalletAmount();
  }

  void getWalletAmount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      islogin = pref.getBool('islogin');
      userName = pref.getString('user_name');
      emailAddress = pref.getString('user_email');
      mobileNumber = pref.getString('user_phone');
      _image = '$imagebaseUrl${pref.getString('user_image')}';
      apCurrency = pref.getString('app_currency');
    });
    var url = walletAmountUri;
    var http = Client();
    http.post(url, body: {'user_id': '${pref.getInt('user_id')}'}).then(
        (value) {
      print('resp - ${value.body}');
      if (value.statusCode == 200) {
        // amount
        WalletGet data1 = WalletGet.fromJson(jsonDecode(value.body));
        print('${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            amount = data1.data;
          });
        } else {
          setState(() {
            amount = data1.data;
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context, userName, emailAddress, _image, islogin,
            onHit: () {
          SharedPreferences.getInstance().then((pref) {
            pref.clear().then((value) {
              // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
              //     MaterialPageRoute(builder: (context) {
              //       return GroceryLogin();
              //     }), (Route<dynamic> route) => false);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.signInRoot, (Route<dynamic> route) => false);
            });
          });
        }),
      ),
      appBar: AppBar(
        title: Text(
          locale.mywallet,
          style: TextStyle(color: kMainHomeText, fontSize: 18),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              // padding: EdgeInsets.all(6),
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
                icon: ImageIcon(
                  AssetImage(
                    'assets/Icon_awesome_align_right.png',
                  ),
                ),
                iconSize: 15,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            );
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(
                    locale.advancevalue,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: kTextBlack),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$apCurrency $amount/-',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                            color: kTextBlack),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Visibility(
                        visible: isLoading,
                        child: Container(
                          height: 25,
                          width: 25,
                          alignment: Alignment.center,
                          child: Align(
                            heightFactor: 15,
                            widthFactor: 15,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: 2,
            //   color: kLightTextColor.withOpacity(0.6),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomButtonWallet(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletHistory()));
                  },
                  iconGap: 5,
                  color: kWhiteColor,
                  borderColor: kMainColor1,
                  textColor: kMainColor1,
                  imageAssets: 'assets/Icon_history.png',
                  label: locale.rechargehistory,
                ),
                CustomButtonWallet(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RechargeWallet(''))).then((value) {
                      if (value) {
                        getWalletAmount();
                      }
                    }).catchError((e) {
                      print(e);
                    });
                  },
                  iconGap: 5,
                  color: kWhiteColor,
                  borderColor: kMainColor1,
                  textColor: kMainColor1,
                  imageAssets: 'assets/Icon_wallet.png',
                  label: locale.walletrecharge,
                ),
                CustomButtonWallet(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SpentAnalysisPage()));
                  },
                  iconGap: 5,
                  color: kWhiteColor,
                  borderColor: kMainColor1,
                  textColor: kMainColor1,
                  imageAssets: 'assets/Icon_analytics.png',
                  label: locale.spentanalysis,
                ),

              ],
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: kLightTextColor.withOpacity(0.6),
            ),
            Container(
              height: 30,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                primary: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  int rsValue = 500 * (index + 1);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RechargeWallet('$rsValue'))).then((value) {
                        if (value) {
                          getWalletAmount();
                        }
                      }).catchError((e) {
                        print(e);
                      });
                    },
                    child: Container(
                      height: 30,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: kBorderColor, width: 1)),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal:1, vertical: 5),
                      // margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$apCurrency $rsValue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: kTextBlack),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, i) {
                  return Divider(
                    thickness: 2,
                    color: Colors.transparent,
                  );
                },
              ),
            ),
            // ListView.separated(
            //   shrinkWrap: true,
            //   scrollDirection: Axis.horizontal,
            //   itemCount: 10,
            //   itemBuilder: (context, index) {
            //     return GestureDetector(
            //       onTap: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) =>
            //                     RechargeWallet('500'))).then((value) {
            //           if (value) {
            //             getWalletAmount();
            //           }
            //         }).catchError((e) {
            //           print(e);
            //         });
            //       },
            //       child: Card(
            //         elevation: 4,
            //         color: kWhiteColor,
            //         clipBehavior: Clip.hardEdge,
            //         child: Container(
            //           decoration: BoxDecoration(
            //               color: kWhiteColor,
            //               borderRadius: BorderRadius.all(Radius.circular(15))),
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             crossAxisAlignment: CrossAxisAlignment.stretch,
            //             children: [
            //               Container(
            //                 color: kMainColor,
            //                 padding:
            //                 EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //                 child: Row(
            //                   children: [
            //                     Image.asset(
            //                       "assets/userrlogo.png",
            //                       scale: 2.5,
            //                       height: 50,
            //                       color: kWhiteColor,
            //                     ),
            //                     SizedBox(
            //                       width: 15,
            //                     ),
            //                     Text(
            //                       'Powerd by GrowShop',
            //                       style: TextStyle(color: kWhiteColor),
            //                     )
            //                   ],
            //                 ),
            //               ),
            //               Container(
            //                 padding:
            //                 EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //                 child: Text(
            //                     'Recharge of 500 get 10% Extra amount in your wallet.'),
            //               ),
            //               Container(
            //                 alignment: Alignment.center,
            //                 margin:
            //                 EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                   children: [
            //                     Text('- - - -'),
            //                     Text('- - - -'),
            //                     Text('- - - -'),
            //                     Text('Rs 500'),
            //                   ],
            //                 ),
            //               )
            //             ],
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            //   separatorBuilder: (context,i){
            //     return Divider(thickness: 2,color: Colors.transparent,);
            //   },
            // ),
            // Expanded(
            //     child: Container(
            //   alignment: Alignment.center,
            //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            //   child: Card(
            //     elevation: 4,
            //     color: kWhiteColor,
            //     clipBehavior: Clip.hardEdge,
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: kWhiteColor,
            //           borderRadius: BorderRadius.all(Radius.circular(15))),
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.stretch,
            //         children: [
            //           Container(
            //             color: kMainColor,
            //             padding:
            //                 EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //             child: Row(
            //               children: [
            //                 Image.asset(
            //                   "assets/userrlogo.png",
            //                   scale: 2.5,
            //                   height: 50,
            //                   color: kWhiteColor,
            //                 ),
            //                 SizedBox(
            //                   width: 15,
            //                 ),
            //                 Text(
            //                   'Powerd by GrowShop',
            //                   style: TextStyle(color: kWhiteColor),
            //                 )
            //               ],
            //             ),
            //           ),
            //           Container(
            //             padding:
            //                 EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //             child: Text(
            //                 'Recharge of 500 get 10% Extra amount in your wallet.'),
            //           ),
            //           Container(
            //             alignment: Alignment.center,
            //             margin:
            //             EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //               children: [
            //                 Text('- - - -'),
            //                 Text('- - - -'),
            //                 Text('- - - -'),
            //                 Text('Rs 500'),
            //               ],
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // )),
//            Expanded(child: Container(
//              alignment: Alignment.center,
// child: Column(
//   mainAxisAlignment: MainAxisAlignment.start,
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Container(
//       margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
//       padding: EdgeInsets.symmetric(horizontal: 3,vertical: 5),
//       width: MediaQuery.of(context).size.width,
//       child: Text('Recharge values',style: TextStyle(
//           fontSize: 16,
//           color: kMainTextColor
//       ),),
//     ),
//     GestureDetector(
//       onTap: (){
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => RechargeWallet('500'))).then((value){
//           if(value){
//             getWalletAmount();
//           }
//         }).catchError((e){
//           print(e);
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: kMainColor,
//           borderRadius: BorderRadius.all(Radius.circular(5)),
//           border: Border.all(
//             color: kWhiteColor,
//             width: 2
//           )
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         child: Text('Rs - 500',style: TextStyle(
//           fontSize: 16,
//           color: kWhiteColor
//         ),),
//       ),
//     )
//   ],
// ),
//            )),
          ],
        ),
      ),
    );
  }

  Widget RowWallet(
      {IconData iconData, String widigitName, Function clickCallBack}) {
    return GestureDetector(
      onTap: () {
        clickCallBack();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
          decoration: BoxDecoration(
              // color: kLightTextColor,
              ),
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            children: [
              Icon(
                iconData,
                color: kMainColor,
                size: 30,
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                widigitName,
                style: TextStyle(color: kMainTextColor),
              )
            ],
          )),
    );
  }
}

// RowWallet(
//     iconData: Icons.account_balance_wallet,
//     widigitName: locale.rechargehistory,
//     clickCallBack: () {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) =>
//                   WalletHistory()));
//     }),
//
// RowWallet(
// iconData: Icons.money,
// widigitName: locale.walletrecharge,
// clickCallBack: () {
//
// }),
// RowWallet(
// iconData: Icons.money_off,
// widigitName: locale.spentanalysis,
// clickCallBack: () {
//
// }),
//