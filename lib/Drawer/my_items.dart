import 'package:flutter/material.dart';
import 'package:vendor/Components/custom_button_wallet.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Pages/Other/adminproductpage.dart';
import 'package:vendor/Pages/Other/storeproductpage.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';

class MyItemsPage extends StatefulWidget {
  @override
  _MyItemsPageState createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> with
    SingleTickerProviderStateMixin {
  TabController tabController;
  int lastIndex = -1;
  int pageIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    tabController.addListener(() {
      setState(() {
        pageIndex = tabController.index;
        print('pageindex : '+pageIndex.toString());
      });
    });

  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
          title: Text(locale.myItems, style: TextStyle(color: kRoundButtonInButton, fontSize: 18)),
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
            Container(
              width: 30,
              // padding: EdgeInsets.all(6),
              margin: EdgeInsets.symmetric(
              horizontal:13, vertical: 13),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
              ),
              child: IconButton(
                icon: ImageIcon(AssetImage('assets/Icon_plus.png')),
                iconSize: 15,
                onPressed: () {
                  setState(() {
                    lastIndex = tabController.index;
                    tabController.index = (lastIndex==0)?1:0;
                  });
                  Navigator.pushNamed(context, PageRoutes.addItem).then((value) {
                    setState(() { tabController.index = lastIndex;  });
                  }).catchError((e) {
                    print('ERROR : ${e.toString()}');
                  });
                },
                color: kRoundButtonInButton,
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
          // iconTheme: new IconThemeData(color: Colors.white),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(height: 10),
            TabBar(
              tabs: [
                CustomButtonWallet(
                  iconGap: 5,
                  color:pageIndex==0 ?kRoundButtonInButton:kWhiteColor,
                  borderColor: kRoundButtonInButton,
                  textColor: pageIndex==0?kWhiteColor:kRoundButtonInButton,
                  imageAssets: 'assets/Icon_store.png',
                  label:locale.storepheading),
                CustomButtonWallet(
                  iconGap: 5,
                  color:pageIndex==1 ?kRoundButtonInButton:kWhiteColor,
                  borderColor: kRoundButtonInButton,
                  textColor: pageIndex==1?kWhiteColor:kRoundButtonInButton,
                  imageAssets: 'assets/Icon_user.png',
                  label:locale.adminpheading),
                // Card(
                //   color: Colors.grey[200],
                //   elevation: 3,
                //   child: Container(
                //     width: MediaQuery.of(context).size.width / 2,
                //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                //     child: Text(
                //       locale.storepheading,
                //       textAlign: TextAlign.center,
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),
                // ),
                // Card(
                //   color: Colors.grey[200],
                //   elevation: 3,
                //   child: Container(
                //     width: MediaQuery.of(context).size.width / 2,
                //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                //     child: Text(
                //       locale.adminpheading,
                //       textAlign: TextAlign.center,
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),
                // )
              ],
              isScrollable: false,
              controller: tabController,
              indicatorWeight: 1,
              indicatorColor: Colors.transparent,
              labelPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  MyStoreProduct(),
                  MyAdminProduct(),
                ],
              ),
            )
          ],
        ),
      ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Theme.of(context).primaryColor,
//         child: Icon(
//           Icons.add,
//           color: Theme.of(context).scaffoldBackgroundColor,
//           size: 32,
//         ),
//         onPressed: () {
//           setState(() {
//             lastIndex = tabController.index;
//             tabController.index = (lastIndex==0)?1:0;
//           });
//           Navigator.pushNamed(context, PageRoutes.addItem).then((value) {
//             setState(() {
// tabController.index = lastIndex;
//             });
//           }).catchError((e) {
//             print(e);
//           });
//         },
//       ),
    );
  }
}
