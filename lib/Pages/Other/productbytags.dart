import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class TagsProduct extends StatefulWidget {

  @override
  _TagsProductState createState() => _TagsProductState();
}

class _TagsProductState extends State<TagsProduct> {
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
    print('getWislist => url : $url || user_id : $userId || store_id : $storeid');
    http.post(url, body: {'user_id': '$userId', 'store_id':'$storeid'}).then((value){
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
      print('getWislist => ERROR : $e');
    });
  }

  void getCategory(dynamic title, dynamic storeid) async{
    var http = Client();
    print('getCategory => url : $tagProductUri || tag_name : $title || store_id : $storeid');
    http.post(tagProductUri,body: {'tag_name':'$title', 'store_id':'$storeid'}).then((value){
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
      setState(() {   isLoading = false;   });
    }).catchError((e){
      print('getCategory => ERROR : $e');
      setState(() {  isLoading = false;   });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        storedetail = receivedData['storedetail'];
        store_id = storedetail.store_id;
        title = receivedData['tagname'];
        getWislist(store_id);
        getCategory(title, store_id);
      }
    });
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            iconSize: 15,
            color: kRoundButtonInButton,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
        title: Text(title.toString().replaceAll('[', '').replaceAll(']', ''), style: TextStyle(color: kRoundButtonInButton)),
        centerTitle: true,
        actions: [
          Container(
            width: 30,
            margin: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
            ),
            child: IconButton(
              icon: ImageIcon(AssetImage('assets/go_to_cart.png')),
              iconSize: 15,
              color: kTextBlack,
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
                  Navigator.pushNamed(context,PageRoutes.cartPage);
                }else{
                  Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          primary: true,
          child: (isLoading)
              ? buildGridShView()
              : buildGridView(context,products,wishModel,'$apCurrency',storedetail),
        ),
      ),
    );
  }

  GridView buildGridView(BuildContext context,List<ProductDataModel> listName, List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail,{bool favourites = false}) {
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
            crossAxisSpacing: w * 0.03, // horozintal space
            mainAxisSpacing: h * 0.025
          // mainAxisSpacing: 5
        ),
        itemBuilder: (context, index) {
          return Container(
            // margin: EdgeInsets.only( top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
            ),
            child: buildProductCard(context, listName[index], wishModel, '$apCurrency', storedetail, favourites: favourites),
          );
        });
  }

  Widget buildProductCard(
      BuildContext context,ProductDataModel product,
      List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail,
      {bool favourites = false}) {
    return GestureDetector(
      onTap: () {
        print('wish_id : ${wishModel[0].wish_id}');
        print('user_id : ${wishModel[0].user_id}');
        print('varient_id : ${wishModel[0].varient_id}');
        print('quantity : ${wishModel[0].quantity}');
        print('unit : ${wishModel[0].unit}');
        print('price : ${wishModel[0].price}');
        print('mrp : ${wishModel[0].mrp}');
        print('product_name : ${wishModel[0].product_name}');
        print('description : ${wishModel[0].description}');
        print('varient_image : ${wishModel[0].varient_image}');
        print('store_id : ${wishModel[0].store_id}');
        print('product_id : ${wishModel[0].product_id}');
        print('created_at : ${wishModel[0].created_at}');
        print('updated_at : ${wishModel[0].updated_at}');
        print('tags : ${wishModel[0].tags[0].tag}');
        print('varients : ${wishModel[0].varients[0].base_price}');
        print('varientsData : ${wishModel[0].varientsData[0].description}');

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
                // width: MediaQuery.of(context).size.width / 2.5,
                // height: MediaQuery.of(context).size.width / 3,
                decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                  child: Image.network(
                    '${product.productImage}',
                    // width: MediaQuery.of(context).size.width / 2.5,
                    // height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                // Stack(
                //   children: [
                //     Container(
                //       alignment: Alignment.center,
                //       width: MediaQuery.of(context).size.width / 2.5,
                //       height: MediaQuery.of(context).size.width / 2.5,
                //       child: Image.network(
                //         '${product.productImage}',
                //         // width: MediaQuery.of(context).size.width / 2.5-20,
                //         // height: 90,
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //     // favourites
                //     //     ? Align(
                //     //   alignment: Alignment.topRight,
                //     //   child: IconButton(
                //     //     onPressed: () {},
                //     //     icon: Icon(
                //     //       Icons.favorite,
                //     //       color: Theme.of(context).primaryColor,
                //     //     ),
                //     //   ),
                //     // )
                //     //     : SizedBox.shrink(),
                //   ],
                // ),
              ),
            ),
            SizedBox(height: 5),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Text('${product.productName}', maxLines: 2,style: TextStyle(fontWeight: FontWeight.w500))),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Text('${product.varients[0].quantity} ${product.varients[0].unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
            SizedBox(height: 4),
            Container(
              margin: EdgeInsets.only(left: 10,right: 10),
              width: MediaQuery.of(context).size.width / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$apCurrency ${product.varients[0].price}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)),
                  Visibility(
                    visible: ('${product.varients[0].price}'=='${product.varients[0].mrp}')?false:true,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text('$apCurrency ${product.varients[0].mrp}', style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
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
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
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
        });
  }
}





