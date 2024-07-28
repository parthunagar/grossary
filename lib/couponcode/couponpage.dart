import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/couponbean/couponlistbean.dart';
import 'package:toast/toast.dart';

class CouponPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CouponPageState();
  }
}

class CouponPageState extends State<CouponPage> {
  List<CouponListData> couponList = [];
  var http = Client();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCouponList();
  }

  void getCouponList() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('getCouponList => stCouponlistUri : $stCouponlistUri ' + 'store_id :' + '${prefs.getInt('store_id')}');
    http.post(stCouponlistUri, body: {'store_id': '${prefs.getInt('store_id')}'}).then((value) {
      if (value.statusCode == 200) {
        CouponListMain main = CouponListMain.fromJson(jsonDecode(value.body));
        print('getCouponList => value.body : '+value.body);
        if ('${main.status}' == '1') {
          setState(() {
            couponList.clear();
            couponList = List.from(main.data);
          });
        }
      }
      setState(() {  isLoading = false;  });
    }).catchError((e) {
      print('getCouponList => ERROR : $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(locale.coupon, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(PageRoutes.createcoupon).then((value) {
                    getCouponList();
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30,
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                  ),
                  child: Icon(Icons.add_rounded, size: 20, color: kRoundButtonInButton),
                )),
          )
        ],

        // iconTheme: new IconThemeData(color: Colors.white),
      ),
      drawer: Theme(
          data: Theme.of(context).copyWith(
            // Set the transparency here
            canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
          ),
          child: buildDrawer(context: context)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: (!isLoading && couponList != null && couponList.length > 0)
                  ? ListView.separated(
                      itemCount: couponList.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      separatorBuilder: (context, indexd) {
                        return Divider(thickness: 1.5, color: Colors.transparent);
                      },
                      itemBuilder: (contexts, index) {
                        var startDate = DateTime.parse(couponList[index].startDate);
                        var endDate = DateTime.parse(couponList[index].endDate);

                        print('startDate : ${startDate.day}-${startDate.month}-${startDate.year}');
                        print('formate startDate : ${DateFormat("yyyy-MM-dd").format(DateTime.parse(couponList[index].startDate))}');
                        print('formate endDate : ${DateFormat("yyyy-MM-dd").format(DateTime.parse(couponList[index].endDate))}');
                        print('couponList[index].startDate : ${couponList[index].startDate.toString().replaceAll(startDate.hour.toString(), '')}');
                        print('couponList[index].endDate : ${couponList[index].endDate}');

                        // return
                        // ;
                        return FocusedMenuHolder(
                          menuWidth: MediaQuery.of(context).size.width * 0.60,
                          blurSize: 5.0,
                          menuItemExtent: 45,
                          menuBoxDecoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                          duration: Duration(milliseconds: 600),
                          animateMenuItems: true,
                          blurBackgroundColor: Colors.black54,
                          openWithTap: true,
                          // Open Focused-Menu on Tap rather than Long Press
                          menuOffset: 5.0,
                          // Offset value to show menuItem from the selected item
                          bottomOffsetHeight: 80.0,
                          // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                                title: Text(locale.editcouponcode),
                                trailingIcon: Icon(Icons.open_in_new),
                                onPressed: () {
                                  Navigator.pushNamed(context, PageRoutes.editcoupon, arguments: {'c_data': couponList[index]}).
                                    then((value) {
                                    getCouponList();
                                  });
                                }),
                            // FocusedMenuItem(
                            //     title: Text(locale.sharecouponcode),
                            //     trailingIcon: Icon(Icons.share),
                            //     onPressed: () {
                            //       hitShareFeature(couponList[index]);
                            //     }),
                            FocusedMenuItem(
                                title: Text(locale.delete, style: TextStyle(color: Colors.redAccent)),
                                trailingIcon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() { isLoading = true; });
                                  deleteCoupon(couponList[index].couponId,context);
                                }),
                          ],
                          onPressed: () {},
                          child: Container(
                            margin: EdgeInsets.only(right: 20, left: 20.0),
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text('${couponList[index].couponCode}'.trim(), textAlign: TextAlign.start, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextBlack)),
                                          SizedBox(height: 5),
                                          Text('${couponList[index].couponDescription}', textAlign: TextAlign.start, style: TextStyle(fontSize: 14, color: kSearchIconColour),),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                                                  decoration: BoxDecoration(color: kRoundButtonInButton2, borderRadius: BorderRadius.circular(45)),
                                                  child: Text('${locale.cartvalue} : ${couponList[index].cartValue}',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 14, color: kMainPriceText, fontWeight: FontWeight.w700)),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text('${locale.restriction} : ${couponList[index].usesRestriction}',
                                                    overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.normal)),
                                              ),
                                            ],
                                          ),
                                          // Text('\n${locale.duration} : ${couponList[index].startDate}\t \n to \t${couponList[index].endDate}\n', style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.normal)),
                                          Text('\n${locale.duration} : ${DateFormat("yyyy-MM-dd").format(DateTime.parse(couponList[index].startDate))}\t to \t${DateFormat("yyyy-MM-dd").format(DateTime.parse(couponList[index].endDate))}\n', style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.normal)),
                                          Container(width: MediaQuery.of(context).size.width - 20, height: 2, color: kBorderColor),
                                          Text('\n${locale.coupontype} - ${couponList[index].type}', style: TextStyle(fontSize: 14, color: kTextBlack, fontWeight: FontWeight.normal)),
                                        ],
                                      )),
                                      onTap: () {},
                                      behavior: HitTestBehavior.opaque,
                                    ),
                                    // Image.asset('images/category/more.png',height: appbarsize*0.5,width: appbarsize*0.5,)
                                    // FaIcon(FontAwesomeIcons.optinMonster)
                                    Positioned(
                                      bottom: 12,
                                      right: 0,
                                      child: Icon(Icons.more_vert, color: kRoundButtonInButton, size: 30))
                                    // Icon(Icons.height,size: appbarsize*0.5,)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                  : Center(
                      child: (!isLoading)
                        ? Text(locale.notyetcoupon, textAlign: TextAlign.center, style: TextStyle(color: kMainTextColor, fontSize: 14, fontWeight: FontWeight.w500),)
                        : SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
                    ),
            ),
            Visibility(
              visible: (!isLoading && couponList != null && couponList.length > 0) ? false : true,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0, bottom: 10.0),
                child: Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(PageRoutes.createcoupon).then((value) {
                          getCouponList();
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(45), color: kMainColor),
                        alignment: Alignment.center,
                        // margin: EdgeInsets.only(left: 50, right: 50),
                        padding: EdgeInsets.all(10),
                        child: Text(locale.createCouponCode, style: TextStyle(fontSize: 14, color: kWhiteColor, fontWeight: FontWeight.bold)),
                      ),
                    )),
              ),
            ),
            Container(height: statusBarHeight),
          ],
        ),
      ),
    );
  }

  RelativeRect buttonMenuPosition(BuildContext context) {
    final RenderBox bar = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    const Offset offset = Offset.zero;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(bar.size.centerRight(offset), ancestor: overlay),
        bar.localToGlobal(bar.size.centerRight(offset), ancestor: overlay),
      ),
      offset & overlay.size,
    );
    return position;
  }

  void hitShareFeature(CouponListData couponList) async {
    Uri fallbackUrl = Uri.parse('{\"coupon_id\"=\"${couponList.couponId}\"}');
    PackageInfo.fromPlatform().then((value) {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: '${imagebaseUrl}admin',
        link: Uri.parse('${imagebaseUrl}'),
        androidParameters: AndroidParameters(
          packageName: '${value.packageName}',
          minimumVersion: 125,
          fallbackUrl: fallbackUrl,
        ),
        iosParameters: IosParameters(
          bundleId: '${value.packageName}',
          minimumVersion: '1.0.1',
          appStoreId: '123456789',
          fallbackUrl: fallbackUrl,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: '${value.appName}',
            description: '${imagebaseUrl}admin',
            imageUrl: Uri.parse('${imagebaseUrl}')),
      );

      parameters.buildUrl().then((value) {
        Share.share('${value}', subject: '${couponList.couponCode}\n${couponList.couponDescription}');
      });
    });
  }

  void deleteCoupon(dynamic couponId,BuildContext context) async {
    var locale = AppLocalizations.of(context);
    bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(locale.confirmation),
          content: Text(locale.confirmationSure),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false); // dismisses only the dialog and returns false
              },
              child: Text(locale.no,style: TextStyle(color: kRoundButtonInButton)),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true); // dismisses only the dialog and returns true
              },
              child: Text(locale.yes,style: TextStyle(color: kRoundButtonInButton)),
            ),
          ],
        );
      },
    );
    if(result){
      print('deleteCoupon => stDeleteCouponUri : $stDeleteCouponUri ' + 'coupon_id : ' + '$couponId');
      http.post(stDeleteCouponUri, body: {'coupon_id': '$couponId'}).then((value) {
        if (value.statusCode == 200) {
          var js = jsonDecode(value.body);
          if ('${js['status']}' == '1') {
            Toast.show(js['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
            getCouponList();
          } else {
            setState(() { isLoading = false;   });
          }
        } else {
          setState(() { isLoading = false;  });
        }
      }).catchError((e) {
        print('deleteCoupon ERROR : ${e.toString()}');
        setState(() { isLoading = false;  });
      });
    }else{
      setState(() { isLoading = false;  });
    }

  }
}
