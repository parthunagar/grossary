import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button_wallet.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Pages/orderpage/todayorder.dart';
import 'package:vendor/Pages/orderpage/tomorroworder.dart';
import 'package:vendor/Theme/colors.dart';

class NewOrderItem {
  NewOrderItem(this.img, this.name,this.buyer);
  String img;
  String name;
  String buyer;
}

class NewOrdersDrawer extends StatefulWidget {
  @override
  _NewOrdersDrawerState createState() => _NewOrdersDrawerState();
}

class _NewOrdersDrawerState extends State<NewOrdersDrawer> with SingleTickerProviderStateMixin {

  int pageIndex = 0;
  TabController tabController;
  bool isToday = true;

  @override
  void initState() {
    super.initState();
    // tabs.clear();
    tabController = TabController(length: 2, vsync: this);

    tabController.addListener(() {
      setState(() {
        pageIndex = tabController.index;
        print('pageIndex : ${pageIndex.toString()}');
      });

    //   if (!tabController.indexIsChanging) {
    //     print(tabController.index);
    //     setState(() {
    //
    //     });
    //     if (tabController.index == 0) {
    //
    //   }
    // }
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
          child: buildDrawer(context: context)),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(locale.myOrders,style: TextStyle(color: kRoundButtonInButton, fontSize: 18),),
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
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(height: 10,),
            TabBar(
              tabs: [
                CustomButtonWallet(
                  iconGap: 5,
                  color:pageIndex==0 ?kRoundButtonInButton:kWhiteColor,
                  borderColor: kRoundButtonInButton,
                  textColor: pageIndex==0?kWhiteColor:kRoundButtonInButton,
                  imageAssets: 'assets/Icon_today.png',
                  label:locale.todayOrd ,
                ),
                CustomButtonWallet(
                  iconGap: 5,
                  color:pageIndex==1 ?kRoundButtonInButton:kWhiteColor,
                  borderColor: kRoundButtonInButton,
                  textColor: pageIndex==1?kWhiteColor:kRoundButtonInButton,
                  imageAssets: 'assets/Icon_today.png',
                  label:locale.newOrders ,
                ),
                // Card(
                //   color: Colors.grey[200],
                //   elevation: 3,
                //   child: Container(
                //     width: MediaQuery.of(context).size.width/2,
                //     padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                //     child: Text(locale.todayOrd,textAlign: TextAlign.center,style: TextStyle(
                //         fontSize: 16
                //     ),),
                //   ),
                // ),
                // Card(
                //   color: Colors.grey[200],
                //   elevation: 3,
                //   child: Container(
                //     width: MediaQuery.of(context).size.width/2,
                //     padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                //     child: Text(locale.newOrders,textAlign: TextAlign.center,style: TextStyle(
                //         fontSize: 16
                //     ),),
                //   ),
                // )
              ],
              isScrollable: false,
              controller: tabController,
              indicatorWeight: 1,
              indicatorColor: Colors.transparent,
              labelPadding: EdgeInsets.all(15),
            ),
            Expanded(
              child:
              TabBarView(
                controller: tabController,
                children: [
                  TodayOrder(),
                  TomorrowOrder(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
