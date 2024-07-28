import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class SearchEan extends StatefulWidget {
  SearchEan();

  @override
  _SearchEanState createState() => _SearchEanState();
}

class _SearchEanState extends State<SearchEan> {
  List<ProductDataModel> products = [];
  dynamic title;
  bool enterFirst = false;
  bool isLoading = false;
  List<WishListDataModel> wishModel = [];
  StoreFinderData storedetails;
  dynamic apCurency;

  @override
  void initState() {
    super.initState();
    getWislist();
  }

  void getWislist() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {  apCurency = prefs.getString('app_currency');  });
    dynamic userId = prefs.getInt('user_id');
    dynamic storeId = prefs.getInt('store_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {'user_id': '$userId', 'store_id':'$storeId'}).then((value){
      print('getWislist => value.body : ${value.body}');
      if(value.statusCode == 200){
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e){
    });
  }

  void getCategory(dynamic ean_code, dynamic storeid, BuildContext context) async{
    var locale = AppLocalizations.of(context);
    var http = Client();
    http.post(searchUri,body: {
      'ean_code':'${ean_code}',
      // 'ean_code':'HXBCX',
      'store_id':'${storeid}'
    }).then((value){
      print('getCategory : ${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            products.clear();
            products = List.from(data1.data);
          });
        }
        Toast.show(data1.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      Toast.show(locale.checkInternet, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      // title = receivedData['title'];
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        storedetails = receivedData['storedetails'];
        getCategory(receivedData['ean_code'], storedetails.store_id, context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.scanProduct,
          style: TextStyle(color: kRoundButtonInButton),
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
                      blurRadius: 5,
                      color: Colors.black12,
                      spreadRadius: 1)
                ],
              ),
              child: IconButton(
                icon:Icon(Icons.arrow_back_ios_rounded),
                // ImageIcon(
                //   AssetImage(
                //     'assets/Icon_awesome_align_right.png',
                //   ),
                // ),
                color: kRoundButtonInButton,
                iconSize: 15,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: MaterialLocalizations.of(context)
                    .openAppDrawerTooltip,
              ),
            );
          },
        ),
        actions: [
          Container(
            height: 30,
            width: 30,
            // padding: EdgeInsets.all(6),
            margin:
            EdgeInsets.symmetric(horizontal: 10, vertical: 13),
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
            child: IconButton(
              icon: ImageIcon(
                AssetImage(
                  'assets/icon_shopping_cart.png',
                ),
              ),
              iconSize: 15,
              onPressed: () async {
                SharedPreferences prefs =
                await SharedPreferences.getInstance();
                if (prefs.containsKey('islogin') &&
                    prefs.getBool('islogin')) {
                  Navigator.pushNamed(
                      context, PageRoutes.cartPage);
                } else {
                  Toast.show(locale.loginfirst, context,
                      gravity: Toast.CENTER,
                      duration: Toast.LENGTH_SHORT);
                }
              },
            ),
          ),
          // IconButton(
          //   icon: ImageIcon(AssetImage(
          //     'assets/ic_cart.png',
          //   )),
          //   onPressed: () async{
          //     SharedPreferences prefs = await SharedPreferences.getInstance();
          //     if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
          //       Navigator.pushNamed(context,PageRoutes.cartPage);
          //     }else{
          //       Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
          //     }
          //   },
          // ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          primary: true,
          child: (isLoading)?buildGridShView():buildGridView(context,products,wishModel,storedetails,apCurency),
        ),
      ),
    );
  }
}

GridView buildGridView(BuildContext context,List<ProductDataModel> listName, List<WishListDataModel> wishModel,StoreFinderData storedetails,dynamic apCurency,{bool favourites = false}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: listName.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio:
          MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
          crossAxisSpacing:
          w * 0.03, // horozintal space
          mainAxisSpacing:
          h * 0.025
      ),
      itemBuilder: (context, index) {
        print('apCurency : ${apCurency.toString()}');
        print('storedetails : ${storedetails.toString()}');
        print('listName[index] : ${listName[index].toString()}');
        return Container(
          // margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
            ],
          ),
          child: buildProductCard(
              context,listName[index],
              wishModel,
              storedetails,
              apCurency,
              favourites: favourites),
        );
      });
}

Widget buildProductCard(
    BuildContext context,ProductDataModel products,List<WishListDataModel> wishModel,StoreFinderData finderDetails,dynamic apCurency,
    {bool favourites = false}) {
  print('ProductDataModel.tags : ${products.catId}');
  print('ProductDataModel.varients : ${products.varients}');
  return GestureDetector(
    onTap: () {
      int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varients[0].varientId}','', '', '', '', '', '', '', '', '', '', '',[],[],[]));
      Navigator.pushNamed(context, PageRoutes.product,arguments: {
        'pdetails':products,
        'storedetails':finderDetails,
        'isInWish': (idd>=0),
      });
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            // width: MediaQuery.of(context).size.width / 2.5,
            // height: MediaQuery.of(context).size.width / 3,
            // alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
              child: Image.network(
                '${products.productImage}',

                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Stack(
        //   children: [
        //     Container(
        //       width: MediaQuery.of(context).size.width / 2.5,
        //       height: MediaQuery.of(context).size.width / 3,
        //       // alignment: Alignment.center,
        //       child: Image.network(
        //         '${products.productImage}',
        //
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //     favourites
        //         ? Align(
        //       alignment: Alignment.topRight,
        //       child: IconButton(
        //         onPressed: () {},
        //         icon: Icon(
        //           Icons.favorite,
        //           color: Theme.of(context).primaryColor,
        //         ),
        //       ),
        //     )
        //         : SizedBox.shrink(),
        //   ],
        // ),
        SizedBox(height: 5),
        Container(
            padding: EdgeInsets.only(left: 10),
            child: Text('${products.productName}',maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500))),
        Container(
            padding: EdgeInsets.only(left: 10),
            child: Text(products.varients.length ==0 ? '0 00' : '${products.varients[0].quantity} ${products.varients[0].unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.only(left: 10,right: 10),
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text( products.varients.length ==0 ? '${apCurency}0' : '$apCurency ${products.varients[0].price}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)),
              Visibility(
                visible: ( false??'${products.varients[0].price}'=='${products.varients[0].mrp}')?false:true,
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text( products.varients.length == 0 ? '${apCurency}0' : '$apCurency ${products.varients[0].mrp}',
                      style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
                ),
              ),
              // buildRating(context),
            ],
          ),
        ),
        SizedBox(height: 5),
      ],
    ),
  );
}

GridView buildGridShView() {
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return buildProductShCard(
            context);
      });
}

Widget buildProductShCard(BuildContext context) {
  return Shimmer(
    duration: Duration(seconds: 3),
    color: Colors.white,
    enabled: true,
    direction: ShimmerDirection.fromLTRB(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.width / 2.5,
                child: Container(
                  color: Colors.grey[300],
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 4),
        Container(height: 10,color: Colors.grey[300],),
        // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 10,width: 30,color: Colors.grey[300],),
              Container(height: 10,width: 30,color: Colors.grey[300],),
            ],
          ),
        ),
      ],
    ),
  );
}

Container buildRating(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 4, right: 3),
    //width: 30,
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Text(
          "4.2",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button.copyWith(fontSize: 10),
        ),
        SizedBox(
          width: 1,
        ),
        Icon(
          Icons.star,
          size: 10,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    ),
  );
}
