import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Auth/checkout_navigator.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/cart/addtocartbean.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  var userName;
  bool islogin = false;
  List<WishListDataModel> wishModel = [];
  StoreFinderData _storeFinderData;
  bool isLoading = false;
  dynamic apCurrency;
  var http = Client();
  dynamic emailAddress;
  dynamic mobileNumber;
  dynamic _image;
  int st;

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      islogin = prefs.getBool('islogin');
      emailAddress = prefs.getString('user_email');
      mobileNumber = prefs.getString('user_phone');
      _image = '$imagebaseUrl${prefs.getString('user_image')}';
      userName = prefs.getString('user_name');
      apCurrency = prefs.getString('app_currency');
    });
    st = -1;
    if (prefs.containsKey('store_id_last')) {
      st = int.parse('${prefs.getString('store_id_last')}');
      if (prefs.containsKey('storelist')) {
        var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
        List<StoreFinderData> dataFinderL = [];
        dataFinderL = List.from(storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
        int idd1 = dataFinderL.indexOf(StoreFinderData('', st, '', '', '', ''));
        if (idd1 >= 0) {
          _storeFinderData = dataFinderL[idd1];
        }
      }
      getWislist(st);
    } else {
      getWislist('');
    }
  }

  void getWislist(dynamic storeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    print('getWislist => url : $url || user_id : $userId || store_id : $storeId');
    await http.post(url, body: {'user_id': '$userId', 'store_id': '$storeId'}).then((value) {
      print('getWislist => value.body : ${value.body}');
      if (value.statusCode == 200) {
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
        //TODO : REMOVE WISHLIST
        // else if(data1.status == "0"){
        //   setState(() {
        //     wishModel.clear();
        //   });
        // }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('getWislist => ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.myWishList, style: TextStyle(color: kMainHomeText, fontSize: 18)),
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
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            );
          },
        ),
        actions: [
          Container(
            height: 30,
            width: 30,
            // padding: EdgeInsets.all(6),
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 13),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
            ),
            child: IconButton(
              icon: ImageIcon(AssetImage('assets/icon_shopping_cart.png')),
              iconSize: 15,
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                  Navigator.pushNamed(context, PageRoutes.cartPage);
                } else {
                  Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                }
              },
            ),
          ),
          // IconButton(
          //   icon: ImageIcon(AssetImage('assets/ic_cart.png')),
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
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: buildDrawer(context, userName, emailAddress, _image, islogin, onHit: () {
          SharedPreferences.getInstance().then((pref) {
            pref.clear().then((value) {
              // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
              //     MaterialPageRoute(builder: (context) {
              //       return GroceryLogin();
              //     }), (Route<dynamic> route) => false);
              Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
            });
          });
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: (isLoading)
                ? buildGridShView()
                : (wishModel != null && wishModel.length > 0)
                  ? buildGridView(context,wishModel, apCurrency, _storeFinderData)
                  : Container(alignment: Alignment.center, child: Text(locale.noprodwishlist)),
            ),
          ),
          Visibility(
            visible: ((_storeFinderData != null && _storeFinderData.store_id != null) && (wishModel != null && wishModel.length > 0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    onTap: () {
                      if (!isLoading) {
                        setState(() { isLoading = true; });
                        hitWishToCart();
                      }
                    },
                    color: kRoundButton,
                    iconGap: 12,
                    label: locale.continueText,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void hitWishToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('hitWishToCart => URI : $wishlistToCartUri || user_id : ${prefs.getInt('user_id')} || store_id : ${_storeFinderData.store_id}');
    http.post(wishlistToCartUri, body: {'user_id': '${prefs.getInt('user_id')}', 'store_id': '${_storeFinderData.store_id}'}).then((value) {
      print('hitWishToCart => value.body : ${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 = AddToCartMainModel.fromJson(jsonDecode(value.body));
        Toast.show(data1.message, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      getWislist(_storeFinderData.store_id);
      // setState(() {  isLoading = false;   });
    }).catchError((e) {
      print('hitWishToCart => ERRPR : $e');
      setState(() { isLoading = false;  });
    });
  }

  GridView buildGridView(BuildContext context,List<WishListDataModel> wishModel, String apCurrency, StoreFinderData finderData) {
    double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 20),
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: wishModel.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
          crossAxisSpacing: w * 0.03, // horozintal space
          mainAxisSpacing: h * 0.025
        ),
        itemBuilder: (context, index) {
          return Container(
            // margin: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
            ),
            child: buildProductCard(context, wishModel[index], '$apCurrency', finderData),
          );
        });
  }

  Widget buildProductCard(BuildContext context, WishListDataModel products,
      String apCurrency, StoreFinderData finderData) {
    return GestureDetector(
      onTap: () {
        goToSecondScreen(context, products, apCurrency, finderData);
        // if(finderData!=null){
        //   ProductDataModel modelP = ProductDataModel(
        //       pId: products.varient_id,
        //       productImage: products.varient_image,
        //       productName: products.product_name,
        //       tags: [],
        //       varients: <ProductVarient>[
        //         ProductVarient(
        //             varientId: products.varient_id,
        //             description: products.description,
        //             price: products.price,
        //             mrp: products.mrp,
        //             varientImage: products.varient_image,
        //             unit: products.unit,
        //             quantity: products.quantity,
        //             stock: 1,
        //             storeId: products.store_id)
        //       ]);
        //   Navigator.pushNamed(context, PageRoutes.product, arguments: {
        //     'pdetails': modelP,
        //     'storedetails': finderData,
        //     'isInWish': true,
        //   });
        // }else{
        //
        // }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              // width: MediaQuery.of(context).size.width / 2.5,
              // height: MediaQuery.of(context).size.width / 3,
              child: CachedNetworkImage(
                imageUrl: '${products.varient_image}',
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
          SizedBox(height: 5),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(products.product_name, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: kTextBlack))),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text('${products.quantity} ${products.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          SizedBox(height: 4),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$apCurrency ${products.price}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kMainPriceText)),
                Visibility(
                  visible: ('${products.price}' == '${products.mrp}') ? false : true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('$apCurrency ${products.mrp}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w300, fontSize: 13, decoration: TextDecoration.lineThrough)),
                  ),
                ),
                // buildRating(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void goToSecondScreen(BuildContext context, WishListDataModel products, String apCurrency, StoreFinderData finderData) async {
    var result;
    if (finderData != null) {
      ProductDataModel modelP = ProductDataModel(
          pId: products.varient_id,
          productImage: products.varient_image,
          productName: products.product_name,

          //========> NEW <========
          tags: products.tags,
          varientsData: products.varientsData,
          varients: products.varients
          //=======> OLD <========
          // tags: [],
          // varients: <ProductVarient>[
          //   ProductVarient(
          //       varientId: products.varient_id,
          //       description: products.description,
          //       price: products.price,
          //       mrp: products.mrp,
          //       varientImage: products.varient_image,
          //       unit: products.unit,
          //       quantity: products.quantity,
          //       stock: 1,
          //       storeId: products.store_id)
          // ]
      );
      result = await Navigator.pushNamed(context, PageRoutes.product, arguments: {
        'pdetails': modelP,
        'storedetails': finderData,
        'isInWish': true,
      });
    } else {}
    if (result == 'Back') {
      print('Back');
      getSharedValue();
      // getWislist(st);
    }
  }

  GridView buildGridShView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      // physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 16,
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
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Container(height: 10, color: Colors.grey[300]),
          // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          SizedBox(height: 4),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 10, width: 30, color: Colors.grey[300]),
                Container(height: 10, width: 30, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
