import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/main.dart';

class ConfirmOrderPage extends StatefulWidget {
  // final VoidCallback onOrderCompleted;
  //
  // ConfirmOrderPage(this.onOrderCompleted);

  @override
  _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () {
        print('Backbutton pressed (device or appbar button), do whatever you want.');
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return GroceryHome();
            }), (Route<dynamic> route) => false);
        //trigger leaving and use own data
        // Navigator.pop(context, false);

        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
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
                        margin: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.black12,
                                spreadRadius: 1)
                          ],
                        ),
                        height: 30,
                        width: 30,
                        child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                            ),
                            iconSize: 15,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(builder: (context) {
                                    return GroceryHome();
                                  }), (Route<dynamic> route) => false);
                            }),
                      ),
                    ),
                    Center(
                      child: Text(
                        locale.confirmOrder,
                          style: TextStyle(color: kMainHomeText, fontSize: 18)),
                      ),
                  ],
                ),
              ),
              Spacer(
                flex: 4,
              ),
              Image.asset(
                'assets/confirm_order_image.png',
                scale: 1,
              ),
              Spacer(
                flex: 2,
              ),
              Container(
                width:MediaQuery.of(context).size.width-20,
                child: Text(
                  locale.yourOrderHasBeenPlacedSuccessfully,
                    textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 36,fontWeight: FontWeight.bold,color: kTextBlack),
                ),
              ),
              Text(
                locale.successfully,
                style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 36,fontWeight: FontWeight.bold,color: kMainPriceText),
              ),
              Spacer(),
              Text(locale.youCanCheckYourOrderProcessInMyOrdersSection,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: kTextBlack,
                      fontSize: 14)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 46),
                decoration: BoxDecoration(
                  color: kRoundButton,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: FlatButton(
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => MyOrders()));
                      Navigator.pushNamed(context, PageRoutes.myorder);
                    },
                    child: Text(
                      locale.myOrders,
                      style: TextStyle(
                          color: kWhiteColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              Spacer(
                flex: 4,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(color: kMainPriceText, width: 1),
                ),
                child: FlatButton(
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => MyOrders()));
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) {
                            return GroceryHome();
                          }), (Route<dynamic> route) => false);
                    },
                    child: Text(
                      locale.continueShopping,
                      style: TextStyle(
                          color: kMainPriceText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              Spacer(
                flex: 4,
              ),
              // CustomButton(
              //   label: locale.continueShopping,
              //   onTap:(){
              //     Navigator.pushAndRemoveUntil(context,
              //         MaterialPageRoute(builder: (context) {
              //           return GroceryHome();
              //         }), (Route<dynamic> route) => false);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
