import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:driver/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';

class OrderDeliveredPage extends StatefulWidget {
  @override
  _OrderDeliveredPageState createState() => _OrderDeliveredPageState();
}

class _OrderDeliveredPageState extends State<OrderDeliveredPage> {
  OrderHistory orderDetaials;
  bool enterFirst = false;
  bool isLoading = false;
  dynamic apCurency;
  dynamic distance;
  dynamic time;

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final Map<String, Object> dataObject =
        ModalRoute.of(context).settings.arguments;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetaials = dataObject['OrderDetail'];
        distance = dataObject['dis'];
        time = dataObject['time'];
        print('${distance}');
        print('${time}');
      });
    }
    return WillPopScope(
      onWillPop: () {
        return Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return DeliveryBoyHome();
        }), (Route<dynamic> route) => false);
      },
      child: Scaffold(
        body: Column(
          children: [
            Spacer(
              flex: 2,
            ),
            Image.asset(
              'assets/images/image.png',
              scale: 1,
            ),
            Spacer(),
            // SizedBox(height: 20,),
            Text(locale.deliveredSuccessfully,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 20,
                    color: kRedLightColor,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 6,
            ),
            Text(locale.thankYouForDelivering,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 16,
                    color: kTextBlack,

                    fontWeight: FontWeight.w700)),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 35,
                      child: Image.asset(
                        "assets/images/bgplace.png",
                        fit: BoxFit.cover,
                      )),
                  SizedBox(width: 10,),
                  Expanded(
                    child: RichText(
                        overflow: TextOverflow.fade,
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: locale.youDrove + '\n',

                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: kTextBlack)),
                      TextSpan(
                          text: '$time ($distance km)\n',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 15,
                                height: 1.7,
                              )),
                      TextSpan(
                        text: locale.viewOrderInfo,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kRedLightColor, // Theme.of(context).primaryColor,
                              height: 2,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(
                                context, PageRoutes.orderHistoryPage,
                                arguments: {
                                  'OrderDetail': orderDetaials,
                                });
                          },
                      ),
                    ])),
                  ),
                  // Spacer(),
                  // RichText(text: TextSpan(children: <TextSpan>[
                  //   TextSpan(text:locale.yourEarning+'\n',style: Theme.of(context).textTheme.subtitle2),
                  //   TextSpan(text: '\$ 8.50\n',style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16,height: 1.7)),
                  //   TextSpan(text: locale.viewEarnings,style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 17,color: Theme.of(context).primaryColor,height: 1.5)),
                  // ])),
                ],
              ),
            ),
            Spacer(),
            // CustomButton(
            //   onTap: (){
            //     Navigator.pushAndRemoveUntil(context,
            //         MaterialPageRoute(builder: (context) {
            //           return DeliveryBoyHome();
            //         }), (Route<dynamic> route) => false);
            //   },
            //   label: locale.backToHome,),
            CustomRedButton(
              // color: kRedColor,
              label: locale.backToHome,
              padding: EdgeInsets.symmetric(horizontal: 0),
              height: MediaQuery.of(context).size.height * 0.06,
              // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.26),
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.28,
                  right: MediaQuery.of(context).size.width * 0.29),
              onTap: () {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return DeliveryBoyHome();
                }), (Route<dynamic> route) => false);
              },

            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
