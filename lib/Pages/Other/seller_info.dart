import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class SellerInfo extends StatefulWidget {
  final StoreFinderData storedetails;
  final List<WishListDataModel> wishModel;
  SellerInfo(this.storedetails,this.wishModel);

  @override
  _SellerInfoState createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  List<WhatsNewDataModel> sellerProducts = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storedetails;
  dynamic apCurrency;


  @override
  void initState() {
    super.initState();
    wishModel = widget.wishModel;
    storedetails = widget.storedetails;
    getTopSellingList(widget.storedetails.store_id);
  }

  void getTopSellingList(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
    var http = Client();
    http.post(topSellingUri, body: {'store_id': '${storeid}'}).then((value) {
      print('getTopSellingList => URI : $topSellingUri || storeid : $storeid');
      print('getTopSellingList => value.body : ${value.body.toString()}');
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            sellerProducts.clear();
            sellerProducts = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {
      print('getTopSellingList => ERROR : ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.75), BlendMode.dstATop),
                      image: AssetImage('assets/seller1.png'),
                    ),
                  ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 40,
                  start: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                    ),
                    height: 30,
                    width: 30,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 15,
                      icon: Icon(Icons.arrow_back_ios_rounded)),
                  )),
                Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 40,
                    end: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
                      ),
                      height: 30,
                      width: 30,
                      child: IconButton(
                          onPressed: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                              Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
                                print('Navigator.pushNamed(context, PageRoutes.cartPage) => value : ${value.toString()}');
                                // getCartList();
                              }).catchError((e) {
                                print('Navigator.pushNamed(context, PageRoutes.cartPage) => ERROR : ${e.toString()}');
                                // getCartList();
                              });
                              // Navigator.pushNamed(context, PageRoutes.cart)

                            } else {
                              Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            }
                          },
                          iconSize: 15,
                          icon: ImageIcon(AssetImage('assets/icon_shopping_cart.png'))),
                    )),
                Positioned.directional(
                  bottom: 20,
                  start: 20,
                  textDirection: TextDirection.ltr,
                  child: Text('${widget.storedetails.store_name}', style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 24, letterSpacing: 0.5, fontWeight: FontWeight.w500)),
                )
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: buildGridViewP(context,sellerProducts,apCurrency,wishModel,storedetails)),
          ],
        ),
      ),
    );
  }
}

GridView buildGridViewP(BuildContext context,List<WhatsNewDataModel> products, apCurrency,
    List<WishListDataModel> wishModel,StoreFinderData storeFinderData,{bool favourites = false}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;
  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
          crossAxisSpacing: w * 0.03, // horozintal space
          mainAxisSpacing: h * 0.025
      ),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only( top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
          ),
          child: buildProductCard(context,products[index],apCurrency,wishModel,storeFinderData),
        );
      });
}

Widget buildProductCard(BuildContext context,WhatsNewDataModel products,
    dynamic apCurrency,List<WishListDataModel> wishModel,StoreFinderData storeFinderData,) {
  return GestureDetector(
    onTap: () {
      ProductDataModel modelP = ProductDataModel(
        pId: products.productId,
        productImage: products.productImage,
        productName: products.productName,
        tags: products.tags,
        //=======> OLD <========
        // varients: <ProductVarient>[
        //   ProductVarient(
        //     varientId: products.varientId,
        //     description: products.description,
        //     price: products.price,
        //     mrp: products.mrp,
        //     varientImage: products.varientImage,
        //     unit: products.unit,
        //     quantity: products.quantity,
        //     stock: products.stock,
        //     storeId: products.storeId)
        //  ]
        //========> NEW <========
        varientsData: products.varientsData,
        varients: products.productVarient
      );
      int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varientId}','', '', '', '', '', '', '', '', '', '', '',[],[],[]));
      Navigator.pushNamed(context, PageRoutes.product,arguments: {
        'pdetails':modelP,
        'storedetails':storeFinderData,
        'isInWish': (idd>=0),
      });
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
              child: CachedNetworkImage(
                imageUrl: '${products.productImage}',
                fit: BoxFit.cover,
                placeholder: (context, url) => Align(
                  widthFactor: 50,
                  heightFactor: 50,
                  alignment: Alignment.center,
                  child: Container(padding: const EdgeInsets.all(5.0), width: 50, height: 50, child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Text(products.productName,maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500,color: kTextBlack))),
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text('${products.quantity} ${products.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
        SizedBox(height: 4),
        Container(
          margin: EdgeInsets.only(left: 10,right: 10),
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$apCurrency ${products.price}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)),
              Visibility(
                visible: ('${products.price}'=='${products.mrp}')?false:true,
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text('$apCurrency ${products.mrp}', style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
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
