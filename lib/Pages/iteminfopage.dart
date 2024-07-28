import 'package:driver/Locale/locales.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemInformation extends StatefulWidget {
  @override
  ItemInformationState createState() {
    return ItemInformationState();
  }
}

class ItemInformationState extends State<ItemInformation> {
  List<ItemsDetails> order_details = [];

  var apCurrency;

  bool enterfirst = true;

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    if (enterfirst) {
      setState(() {
        enterfirst = false;
        order_details = receivedData['details'];
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Card(
              color: kWhiteColor,
              child: Icon(Icons.keyboard_arrow_left_rounded, size: 25, color: kRedColor)),
          ),
        ),
        title: Text( locale.itemInfo, style: TextStyle(color: kMainTextColor, fontFamily: 'Philosopher-Regular', fontWeight: FontWeight.bold, fontSize: 17),),
      ),
      body: (order_details != null && order_details.length > 0)
          ? ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, index) {
                return
                    // Card(
                    // elevation: 3,
                    // clipBehavior: Clip.hardEdge,
                    // color: kWhiteColor,
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          order_details[index].varientImage == null|| order_details[index].varientImage==""
                          ? Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              // color: Colors.grey[300],
                              border: Border.all(color: kRedLightColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.fromLTRB(12,12,17,12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset('assets/images/place_holder_image.png', fit: BoxFit.fill)),
                          ) :
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              // color: Colors.grey[300],
                              // border: Border.all(color: kRedLightColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            // padding: EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network('${order_details[index].varientImage}', fit: BoxFit.fill)),
                          ),

                          SizedBox(width: 10),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text(
                              //   '${order_details[index].productName} (${order_details[index].quantity} ${order_details[index].unit})',
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     color: kWhiteColor,
                              //     fontWeight: FontWeight.bold
                              //   ),
                              // ),
                              Text(
                                '${order_details[index].productName}',
                                style: TextStyle(
                                    fontSize: 16,
                                    // color: kWhiteColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text('(${order_details[index].quantity} ${order_details[index].unit}) - ${locale.invoice2h}: ${order_details[index].qty}', style: TextStyle(fontSize: 13, color: kGreyBlack)),
                              SizedBox(height: 10),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                      decoration: BoxDecoration(color: kRedLightColor, borderRadius: BorderRadius.circular(30)),
                                      child: Text(
                                        '${locale.invoice3h} - $apCurrency ${(double.parse('${order_details[index].price}') / double.parse('${order_details[index].qty} '))}',
                                        overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: kWhiteColor),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      '${locale.invoice4h} ${locale.invoice3h}: $apCurrency ${order_details[index].price} ',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w400
                                          // color: kWhiteColor,
                                          ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )),
                        ],
                      ),
                    );
                // );
              },
              separatorBuilder: (context, indext) {
                return Divider(
                  thickness: 0.1,
                  color: Colors.transparent,
                );
              },
              itemCount: order_details.length)
          : SizedBox.shrink(),
    );
  }
}
