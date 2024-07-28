import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/addressbean/showaddress.dart';
import 'package:groshop/beanmodel/cart/cartitembean.dart';
import 'package:groshop/beanmodel/cart/makeorderbean.dart';
import 'package:horizontal_calendar_widget/date_helper.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<int> radioButtons = [0, -1, -1];
  bool isAddressLoading = false;
  bool isMakeingOrder = false;
  bool enterFirst = false;
  List<ShowAllAddressMain> allAddressData = [];
  List<CartItemData> cartItemd = [];
  dynamic cart_id;
  dynamic store_id;
  CartStoreDetails storeDetails;
  int seletedValue = -1;
  bool addressSelection = false;
  AddressData selectedAddrs;
  DateTime firstDate;
  DateTime lastDate;
  List<DateTime> dateList = [];
  List<dynamic> radioList = [];
  String dateTimeSt = '';
  String apCurrency = '';
  int idd = 0;
  int idd1 = 0;
  bool isFetchingTime = false;

  void getAddressByUserId(dynamic storeid) async {
    setState(() {
      isAddressLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showAddressUri;
    var http = Client();
    print('address url : $url' );
    print('address userId : ${userId}');
    print('address store id : ${storeid}');

    await http.post(url, body: {
      'user_id': '${userId}',
      'store_id': '${storeid}'
    }).then((response) {
      print('getAddressByUserId : Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var js = jsonDecode(response.body) as List;
        if (js != null && js.length > 0) {
          allAddressData =
              js.map((e) => ShowAllAddressMain.fromJson(e)).toList();
          int indexd = -1;
          for (int i = 0; i < allAddressData.length; i++) {
            indexd = allAddressData[i].data.indexOf(AddressData(
                '', '', '', '', '', '', '', '', '', '', '', '', '', 1, '', ''));
            if (indexd >= 0) {
              setState(() {
                selectedAddrs = allAddressData[i].data[indexd];
                seletedValue =
                    int.parse('${allAddressData[i].data[indexd].address_id}');
              });
            }
          }
        }
      }
      setState(() {
        isAddressLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isAddressLoading = false;
      });
      print(e);
    });
  }

  @override
  void initState() {
    super.initState();
    firstDate = toDateMonthYear(DateTime.now());
    prepareData(firstDate);
    dateTimeSt =
        '${firstDate.year}-${(firstDate.month.toString().length == 1) ? '0' + firstDate.month.toString() : firstDate.month}-${firstDate.day}';
    lastDate = toDateMonthYear(firstDate.add(Duration(days: 9)));
  }

  void prepareData(firstDate) {
    lastDate = toDateMonthYear(firstDate.add(Duration(days: 9)));
    dateList = getDateList(firstDate, lastDate);
  }

  void hitDateCounter(date) async {
    setState(() {
      isFetchingTime = true;
    });
    var http = Client();
    print('$timeSlotUri  selected_date: $date store_id : $store_id');
    http.post(timeSlotUri, body: {
      'selected_date': '${date}',
      'store_id': '${store_id}',
    }).then((value) {
      print('time s - ${value.body}');
      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var rdlist = jsonData['data'] as List;
          print('list $rdlist');
          setState(() {
            radioList.clear();
            radioList = rdlist;
          });
        } else {
          setState(() {
            radioList = [];
          });
          Toast.show(jsonData['message'], context,
              duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          radioList = [];
          // radioList = rdlist;
        });
      }
      setState(() {
        isFetchingTime = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchingTime = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 7;
    final double itemWidth = size.width / 2;
    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        store_id = receivedData['store_id'];
        storeDetails = receivedData['store_d'];
        cartItemd = receivedData['cartdetails'];
        dynamic date =
            '${firstDate.day}-${(firstDate.month.toString().length == 1) ? '0' + firstDate.month.toString() : firstDate.month}-${firstDate.year}';
        getAddressByUserId(store_id);
        hitDateCounter(date);
      }
    });
    return Scaffold(
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
                        icon: Icon(Icons.arrow_back_ios_rounded),
                        iconSize: 15,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      ),
                    ),
                  ),
                  Center(
                      child: Text(
                        locale.selectAddress,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: kMainHomeText, fontSize: 18),
                      )),
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              primary: true,
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(5)),
                    //     border: Border.all(color: kMainColor, width: 1.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: size.width,
                            color: kWhiteColor,
                            padding: EdgeInsets.only( top: 5, bottom: 5),
                            child: Text(
                              locale.timedate,
                              style: TextStyle(color: kTextBlack,fontSize: 18,fontWeight:FontWeight.bold),
                            )),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: size.width * 0.30 - 10,
                              height: 250,
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                color: kBorderColor,
                                width: 1,
                              ))),
                              child: ListView.separated(
                                itemCount: dateList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: ScrollPhysics(),
                                itemBuilder: (context, index) {
                                  DateFormat formatter =
                                      DateFormat('dd MMM yyyy');
                                  var dateCount =
                                      formatter.format(dateList[index]);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        idd = index;
                                        dateTimeSt =
                                            '${dateList[index].year}-${(dateList[index].month.toString().length == 1) ? '0' + dateList[index].month.toString() : dateList[index].month}-${dateList[index].day}';
                                        dynamic date =
                                            '${dateList[index].day}-${(dateList[index].month.toString().length == 1) ? '0' + dateList[index].month.toString() : dateList[index].month}-${dateList[index].year}';

                                        hitDateCounter(date);
                                        print('${dateTimeSt}');
                                      });
                                    },
                                    child: Container(
                                      // height: 30,
                                      padding: EdgeInsets.only(
                                          right: 5, left: 5, top: 5, bottom: 5),
                                      margin: EdgeInsets.only(right: 5, left: 5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: (idd == index)
                                              ? kWhiteColor
                                              : kWhiteColor,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: (idd == index)
                                                  ? kMainColor1
                                                  : kBorderColor)),
                                      child: Text(
                                        '${dateCount}',
                                        style: TextStyle(
                                            color: (idd == index)
                                                ? kMainColor1
                                                : kTextBlack,
                                            fontSize: 13),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index1) {
                                  return Divider(
                                    thickness: 1.5,
                                    color: Colors.transparent,
                                  );
                                },
                              ),
                            ),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 0.70 - 12,
                              height: 250,
                              child: (!isFetchingTime && radioList.length > 0)
                                  ? Container(
                                      padding: EdgeInsets.only(right: 5, left: 5),
                                      child: GridView.builder(
                                        itemCount: radioList.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 4.0,
                                          mainAxisSpacing: 4.0,
                                          childAspectRatio:
                                              (itemWidth / itemHeight),
                                        ),
                                        controller: ScrollController(
                                            keepScrollOffset: false),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                idd1 = index;
                                                print('${radioList[idd1]}');
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 5,
                                                  left: 5,
                                                  top: 5,
                                                  bottom: 5),
                                              height: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: (idd1 == index)
                                                      ? kWhiteColor
                                                      : kWhiteColor,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: (idd1 == index)
                                                          ? kMainColor1
                                                          : kBorderColor)),
                                              child: Text(
                                                '${radioList[index].toString()}',
                                                style: TextStyle(
                                                    color: (idd1 == index)
                                                        ? kMainColor1
                                                        : kTextBlack,
                                                    fontSize: 10),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.70 -
                                          12,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Visibility(
                                              visible: isFetchingTime,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    width: 30,
                                                    child: Align(
                                                      widthFactor: 30,
                                                      heightFactor: 30,
                                                      alignment: Alignment.center,
                                                      child:
                                                          CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(kRoundButton),),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  )
                                                ],
                                              )),
                                          Expanded(
                                            child: Text(
                                              (isFetchingTime)
                                                  ? locale.fetchingTimeSlotText
                                                  : locale.noTimeSlotText,
                                              textAlign: (isFetchingTime)
                                                  ? TextAlign.start
                                                  : TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: kMainTextColor),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(locale.shippingTo,style: TextStyle(fontWeight: FontWeight.bold, color: kTextBlack,fontSize: 18)),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, PageRoutes.addaddressp)
                                .then((value) {
                              getAddressByUserId(store_id);
                            }).catchError((e) {
                              print(e);
                            });
                          },
                            child: Text(locale.addLocation,style: TextStyle(fontWeight: FontWeight.w700, color: kTextBlack,fontSize: 14,decoration: TextDecoration.underline,))),

                        // IconButton(
                        //     icon: Icon(Icons.add),
                        //     onPressed: () {
                        //       Navigator.pushNamed(context, PageRoutes.addaddressp)
                        //           .then((value) {
                        //         getAddressByUserId(store_id);
                        //       }).catchError((e) {
                        //         print(e);
                        //       });
                        //     }),
                      ],
                    ),
                  ),
                  (!isAddressLoading &&
                          allAddressData != null &&
                          allAddressData.length > 0)
                      ? ListView.builder(
                          itemCount: allAddressData.length,
                          shrinkWrap: true,
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return buildRAddressTile(
                                context,
                                allAddressData[index].type,
                                allAddressData[index].data);
                          })
                      : Container(
                          alignment: Alignment.center,
                          child: (isAddressLoading)
                              ? Align(
                                  widthFactor: 50,
                                  heightFactor: 50,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor:AlwaysStoppedAnimation<Color>(kRoundButton),
                                  ),
                                )
                              : Text(locale.nosaveaddress),
                        ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            )),
            (addressSelection || isMakeingOrder)
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    alignment: Alignment.center,
                    child: Align(
                      widthFactor: 40,
                      heightFactor: 40,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(kRoundButton),),
                    ),
                  )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: CustomButton(

                        color: kRoundButton,
                          iconGap: 12,
                          onTap: () {
                            if (!isAddressLoading) {
                              if (!isMakeingOrder) {
                                setState(() {
                                  isMakeingOrder = true;
                                });
                                makeOrderRequest();
                              }
                            }
                          },
                        ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget buildRAddressTile(
      BuildContext context, String heading, List<AddressData> address) {
    var locale = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
              itemCount: address.length,
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                AddressData addData = address[index];
                String addressshow =
                    '${locale.name} - ${addData.receiver_name}\n${locale.cnumber} - ${addData.receiver_phone}\n${addData.house_no}${addData.landmark}${addData.society}${addData.city}(${addData.pincode})${addData.state}';
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio(
                              value: int.parse('${addData.address_id}'),
                              groupValue: seletedValue,
                              activeColor: kMainColor1,
                              onChanged: (int value) {

                                if (seletedValue !=
                                    int.parse('${addData.address_id}')) {
                                  selectAddress(addData.address_id, addData);
                                }
                                setState(() {
                                  seletedValue = value;
                                  // for (int i = 0; i < radioButtons.length; i++) {
                                  //   radioButtons[i] = -1;
                                  // }
                                  // radioButtons[index] = value;
                                });
                              }),
                          Expanded(
                              child: Text(
                                heading,
                                 style: TextStyle(fontWeight: FontWeight.w700, color: kTextBlack,fontSize: 14),
                                textAlign: TextAlign.start,
                                softWrap: true,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context)
                                  .pushNamed(PageRoutes.editAddress, arguments: {
                                'address_d': addData,
                              }).then((value) {
                                getAddressByUserId(store_id);
                              }).catchError((e) {
                                getAddressByUserId(store_id);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.black12,
                                      spreadRadius: 1)
                                ],
                              ),
                              child: Image(
                                image: AssetImage('assets/edit.png'),
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          addressshow,
                          textAlign: TextAlign.start,
                          softWrap: true,
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(left: 40,right: 20,bottom: 10),
                      //   child: ListView.builder(
                      //       itemCount: address.length,
                      //       shrinkWrap: true,
                      //       primary: false,
                      //       physics: NeverScrollableScrollPhysics(),
                      //       itemBuilder: (context, index) {
                      //         AddressData addData = address[index];
                      //         String addressshow =
                      //             '${locale.name} - ${addData.receiver_name}\n${locale.cnumber} - ${addData.receiver_phone}\n${addData.house_no}${addData.landmark}${addData.society}${addData.city}(${addData.pincode})${addData.state}';
                      //         return Row(
                      //           children: [
                      //             // Radio(
                      //             //     value: int.parse('${addData.address_id}'),
                      //             //     groupValue: seletedValue,
                      //             //     onChanged: (int value) {
                      //             //       // setState(() {
                      //             //       //   for (int i = 0; i < radioButtons.length; i++) {
                      //             //       //     radioButtons[i] = -1;
                      //             //       //   }
                      //             //       //   radioButtons[index] = value;
                      //             //       // });
                      //             //       if (seletedValue !=
                      //             //           int.parse('${addData.address_id}')) {
                      //             //         selectAddress(addData.address_id, addData);
                      //             //       }
                      //             //     }),
                      //             Expanded(
                      //                 child: Text(
                      //               addressshow,
                      //               textAlign: TextAlign.start,
                      //               softWrap: true,
                      //             )),
                      //             // SizedBox(
                      //             //   width: 10,
                      //             // ),
                      //             // IconButton(
                      //             //     icon: Icon(
                      //             //       Icons.edit,
                      //             //       color: Color(0xff686868),
                      //             //       size: 20,
                      //             //     ),
                      //             //     onPressed: () {
                      //             //       Navigator.of(context)
                      //             //           .pushNamed(PageRoutes.editAddress, arguments: {
                      //             //         'address_d': addData,
                      //             //       }).then((value) {
                      //             //         getAddressByUserId(store_id);
                      //             //       }).catchError((e) {
                      //             //         getAddressByUserId(store_id);
                      //             //       });
                      //             //     }),
                      //           ],
                      //         );
                      //       }),
                      // )
                    ],
                  ),
                );
              }),
          // SizedBox(
          //   height: 10,
          // ),

        ],
      ),
    );
  }

  void selectAddress(dynamic address_id, AddressData addData) async {
    setState(() {
      addressSelection = true;
    });
    var http = Client();
    http.post(selectAddressUri, body: {'address_id': '${address_id}'}).then(
        (value) {
      print('address selection - ${value.body}');
      selectedAddrs = addData;
      setState(() {

        addressSelection = false;
      });
    }).catchError((e) {
      setState(() {
        addressSelection = false;
      });
      print(e);
    });
  }

  void makeOrderRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id  = prefs.getInt('user_id');
    var http = Client();
    print('$makeOrderUri  user_id : $id  delivery_date : $dateTimeSt  time_slot : ' + '${radioList[idd1]}');
    http.post(makeOrderUri, body: {
      'user_id': '${prefs.getInt('user_id')}',
      'delivery_date': '${dateTimeSt}',
      'time_slot': '${radioList[idd1]}',
    }).then((value) {
      print('making order value - ${value.body}');
      if (value.statusCode == 200) {
        MakeOrderBean orderBean =
            MakeOrderBean.fromJson(jsonDecode(value.body));
        if ('${orderBean.status}' == '1') {
          Navigator.pushNamed(context, PageRoutes.orderdetailspage, arguments: {
            'cart_id': '${orderBean.data.cart_id}',
            'cartdetails': cartItemd,
            'storedetails': storeDetails,
            'orderdetails': orderBean.data,
            'address': selectedAddrs,
          });
        }
      }
      setState(() {
        isMakeingOrder = false;
      });
    }).catchError((e) {
      setState(() {
        isMakeingOrder = false;
      });
      print(e);
    });
  }
}
