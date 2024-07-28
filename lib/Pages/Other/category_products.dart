import 'dart:convert';

import 'package:flutter/cupertino.dart';
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

// class Product {
//   Product(this.image, this.productName, this.productType, this.price);
//   String image;
//   String productName;
//   String productType;
//   String price;
// }

class CategoryProduct extends StatefulWidget {
  CategoryProduct();

  @override
  _CategoryProductState createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  List<ProductDataModel> products = [];
  dynamic title;
  dynamic store_id;
  bool enterFirst = false;
  bool isLoading = false;
  StoreFinderData storedetail;
  List<WishListDataModel> wishModel = [];
  dynamic apCurrency;
  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  void getWislist(dynamic storeid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'${storeid}'
    }).then((value){
      print('getWislist => resp - ${value.body}');
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
      print('getWislist ERROR : ${e.toString()}');
    });
  }

  void getCategory(dynamic catid, dynamic storeid) async{
    var http = Client();
    http.post(catProductUri,body: {
      'cat_id':'${catid}',
      'store_id':'${storeid}'
    }).then((value){
      print('getCategory => value.body : ${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            products.clear();
            products = List.from(data1.data);
          });
        }
      }
      setState(() { isLoading = false;   });
    }).catchError((e){
      print('getCategory ERROR : ${e.toString()}');
      setState(() { isLoading = false;   });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      title = receivedData['title'];
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        store_id = receivedData['storeid'];
        storedetail = receivedData['storedetail'];
        getWislist(store_id);
        getCategory(receivedData['cat_id'], receivedData['storeid']);
      }
    });
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     title,
      //     style: TextStyle(color: kMainTextColor),
      //   ),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: ImageIcon(AssetImage(
      //         'assets/ic_cart.png',
      //       )),
      //       onPressed: () async{
      //         SharedPreferences prefs = await SharedPreferences.getInstance();
      //         if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
      //           Navigator.pushNamed(context,PageRoutes.cartPage);
      //         }else{
      //           Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      //         }
      //       },
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(5.0),
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
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
                        height: 30,
                        width: 30,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded),
                          iconSize: 15,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                        ),
                      ),
                    ),
                    Center(child: Text(title.toString(), style: Theme.of(context).textTheme.headline6.copyWith(color: kMainHomeText, fontSize: 18))),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                        ),
                        height: 30,
                        width: 30,
                          child: IconButton(
                            icon: ImageIcon(AssetImage('assets/icon_shopping_cart.png')),
                            // iconSize: 15,
                            onPressed: () async {
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                                Navigator.pushNamed(context, PageRoutes.cartPage);
                              } else {
                                Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                              }
                            },
                          ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  primary: true,
                  child: (isLoading)?buildGridShView():
                  products.length > 0
                      ? buildGridView(context,products,wishModel,'$apCurrency',storedetail)
                      : Container(
                        height : MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(locale.noProduct, style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: kTextBlack)),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

GridView buildGridView(BuildContext context,List<ProductDataModel> listName, List<WishListDataModel>
wishModel,String apCurrency,StoreFinderData storedetail,{bool favourites = false}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;
  return  GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: listName.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
        MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
        crossAxisSpacing: w * 0.03, // horozintal space
        mainAxisSpacing: h * 0.025
        // mainAxisSpacing: 5
      ),
      itemBuilder: (context, index) {
        return Container(
          // margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
          ),
          // width: MediaQuery.of(context).size.width / 2.5,
          child: buildProductCard(context, listName[index], wishModel, '$apCurrency', storedetail, favourites: favourites),
        );
      });
}

Widget buildProductCard(
    BuildContext context,ProductDataModel product,
    List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail,
    {bool favourites = false}) {
    try{
      print('product : ${product.varients[0].price.toString()}');
    }catch(e){
      print('product ERROR : ${e.toString()}');
    }
  // print('product : ${product.varients.toString()}');
  return GestureDetector(
    onTap: () {
      int idd = wishModel.indexOf(WishListDataModel('', '', '${product.varientId}','', '', '', '', '', '', '', '', '', '', '',[],[],[]));
      Navigator.pushNamed(context, PageRoutes.product,arguments: {'pdetails':product, 'storedetails':storedetail, 'isInWish': (idd>=0)});
    },
    child: Container(
      // padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(10),
                //TODO: IMAGE NOT PROPER
                // image: DecorationImage(image: NetworkImage('${product.productImage}'))
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                child: Image.network(
                  '${product.productImage}',
                  // width: MediaQuery.of(context).size.width / 2.5-20,
                  // height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Stack(
          //   children: [
          //     Container(
          //       alignment: Alignment.center,
          //       width: MediaQuery.of(context).size.width / 2,
          //       height: MediaQuery.of(context).size.width / 2.5,
          //       child: Image.network(
          //         '${product.productImage}',
          //         // width: MediaQuery.of(context).size.width / 2.5-20,
          //         // height: 90,
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
            margin: EdgeInsets.only(left: 10),
            child: Text('${product.productName}', maxLines: 1, style:TextStyle(fontWeight: FontWeight.bold, color: kTextBlack))),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
                // product.varients.length == 0 ? '0 00' :
                '${product.varients[0].quantity} ${product.varients[0].unit}',
              // '0 00',

                style: TextStyle(color: Colors.grey[600], fontSize: 13)),),
          SizedBox(height: 4),
          Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    // product.varients.length == 0 ? '0 00' :
                    '$apCurrency${product.varients[0].price}',
                    // '0 00',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)),
                Visibility(
                  visible: (
                      // true),
                      // false ??
                      '${product.varients[0].price}'=='${product.varients[0].mrp}')?false:true,
                  child: Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: Text(
                        '$apCurrency${product.varients[0].mrp}',
                         // '123',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
                  ),
                ),
                // buildRating(context),
              ],
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
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
        crossAxisSpacing: 16
      ),
      itemBuilder: (context, index) {
        return buildProductShCard(context);
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
                child: Container(color: Colors.grey[300]),
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
        Text("4.2", textAlign: TextAlign.center, style: Theme.of(context).textTheme.button.copyWith(fontSize: 10)),
        SizedBox(width: 1),
        Icon(Icons.star, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
      ],
    ),
  );
}
