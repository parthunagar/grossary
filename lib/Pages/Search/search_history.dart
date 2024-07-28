import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Search/search_result.dart' as search;
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/category/topcategory.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistory extends StatefulWidget {
  @override
  _SearchHistoryState createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  final List<String> _searchList = [];
  List<WhatsNewDataModel> recentSaleList = [];
  List<TopCategoryDataModel> topCategoryList = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storeDetails;
  bool enterFirst = false;
  dynamic apCurrency;

  TextEditingController searchController = TextEditingController();

  List<Color> colors1 = [kCategoryColor1, kCategoryColor2, kCategoryColor3, kCategoryColor4];
  List<Color> colors2 = [kCategoryColor11, kCategoryColor22, kCategoryColor33, kCategoryColor44];

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        topCategoryList = receivedData['category'];
        recentSaleList = receivedData['recentsale'];
        storeDetails = receivedData['storedetails'];
        wishModel = receivedData['wishlist'];
      }
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Theme(
          data: new ThemeData(primaryColor: kMainColor1, primaryColorDark: kMainColor1),
          child: TextField(
            controller: searchController,
            onSubmitted: (s) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => search.SearchResult(wishModel, storeDetails, apCurrency, s)));
              setState(() {
                _searchList.add(s);
                searchController.text = '';
              });
            },
            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black, fontSize: 18),
            decoration: InputDecoration(
              hintText: '${locale.searchOnGroShop}$appname',
              hintStyle: Theme.of(context).textTheme.subtitle2,
              suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.grey[400]),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        search.SearchResult(wishModel, storeDetails, apCurrency, searchController.text)));
                    setState(() {
                      _searchList.add(searchController.text);
                      searchController.text = '';
                    });

                  }
                  // => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => search.SearchResult(wishModel,
                  //             storeDetails, apCurrency, searchController.text))),
                  ),
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.grey[400]),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(45), borderSide: BorderSide(width: 1)),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          _searchList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                      child: Text(locale.recentlySearched, style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black), textAlign: TextAlign.left),
                    ),
                    Container(
                      height: 144.0,
                      child: ListView.builder(
                        itemCount: _searchList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                                child: Icon(Icons.youtube_searched_for, color: Theme.of(context).backgroundColor)),
                              Text(_searchList[index], style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Text(locale.chooseCategory, style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20)),
          ),
          SizedBox(height: 12),
          Container(
            height: 96,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: topCategoryList.length,
                itemBuilder: (context, index) {
                  return buildCategoryRow(context, colors1[(index % 4)], colors2[(index % 4)], topCategoryList[index], storeDetails);
                }),
          ),
          Padding(
            padding: EdgeInsets.all(10),
              child: Text(locale.featuredProducts, style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildGridViewP(context,recentSaleList, apCurrency, wishModel, storeDetails)),
        ],
      ),
    );
  }
}

GestureDetector buildCategoryRow(BuildContext context, Color color1, Color color2, TopCategoryDataModel categories, StoreFinderData storeFinderData) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
        'title': categories.title,
        'storeid': categories.store_id,
        'cat_id': categories.cat_id,
        'storedetail': storeFinderData,
      });
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      margin: EdgeInsets.only(left: 16),
      // padding: EdgeInsets.all(10),
      width: 96,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhiteColor,
          image: DecorationImage(image: NetworkImage(categories.image), fit: BoxFit.fill)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: new LinearGradient(
                  // colors: [const Color(0xFF3366FF),const Color(0xFf00CCFF)],
                  colors: [color1, color2],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12), // Clip it cleanly.
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                color: Colors.grey.withOpacity(0.3),
                alignment: Alignment.topCenter,
                child: Text(categories.title, style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          // Text(
          //   categories.title,
          //   style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600),
          // ),
        ],
      ),
    ),
  );
}

GridView buildGridViewP(BuildContext context,List<WhatsNewDataModel> products, apCurrency,
    List<WishListDataModel> wishModel, StoreFinderData storeFinderData,
    {bool favourites = false}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;

  return GridView.builder(
      // padding: EdgeInsets.symmetric(vertical: 10),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio:
          MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
          crossAxisSpacing: w * 0.03, // horozintal space
          mainAxisSpacing: h * 0.025
      ),
      itemBuilder: (context, index) {
        return Container(child: buildProductCard(context, products[index], apCurrency, wishModel, storeFinderData));
      });
}

Widget buildProductCard(BuildContext context, WhatsNewDataModel products, dynamic apCurrency, List<WishListDataModel> wishModel, StoreFinderData storeFinderData) {
  double w = MediaQuery.of(context).size.width;
  return Container(
    margin: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: kWhiteColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
    child: GestureDetector(
      onTap: () {
        ProductDataModel modelP = ProductDataModel(
            pId: products.productId,
            productImage: products.productImage,
            productName: products.productName,
            tags: products.tags,
            varientsData: products.varientsData,
            varients: products.productVarient
            // varients: <ProductVarient>[
            //   ProductVarient(
            //       varientId: products.varientId,
            //       description: products.description,
            //       price: products.price,
            //       mrp: products.mrp,
            //       varientImage: products.varientImage,
            //       unit: products.unit,
            //       quantity: products.quantity,
            //       stock: products.stock,
            //       storeId: products.storeId)
            // ]
        );
        int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varientId}', '','', '', '', '', '', '', '', '', '', '',[],[],[]));
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': modelP,
          'storedetails': storeFinderData,
          'isInWish': (idd >= 0),
        });
      },
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                child: CachedNetworkImage(
                  imageUrl: '${products.productImage}',
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(shape: BoxShape.rectangle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover))),
                  placeholder: (context, url) => Align(
                    widthFactor: 50,
                    heightFactor: 50,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRoundButton)),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: Text(products.productName, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: kTextBlack))),
          Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: Text('${products.quantity} ${products.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          SizedBox(height: 4),
          Container(
            margin:  EdgeInsets.only(left: w * 0.03, right: w * 0.03 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: w * 0.17,
                  // color: Colors.red[100],
                  child: Text('$apCurrency${products.price}',overflow: TextOverflow.fade,
                    textAlign: TextAlign.start, maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kMainPriceText))),
                Container(
                  width: w * 0.17,
                  // color: Colors.red[300],
                  child: Visibility(
                    visible: ('${products.price}' == '${products.mrp}') ? false : true,
                    child: Text('$apCurrency ${products.mrp}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w300, fontSize: 13, decoration: TextDecoration.lineThrough)))),
            ],),
          ),
          // Container(
          //   margin:  EdgeInsets.only(left: 10,right: 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Container(
          //         width: w * 0.18,
          //         color: Colors.red[500],
          //         // color: kNavigationButtonColor,
          //         child: Flexible(
          //           child: Text('$apCurrency${products.price}',overflow: TextOverflow.fade, textAlign: TextAlign.start, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kMainPriceText)),
          //         ),
          //       ),
          //       Container(
          //         width: w * 0.18,
          //         color: Colors.red[200],
          //         child: Flexible(
          //           child: Visibility(
          //             visible: ('${products.price}' == '${products.mrp}') ? false : true,
          //             child: Text('$apCurrency ${products.mrp}',
          //                 overflow: TextOverflow.ellipsis,
          //                 maxLines: 2,
          //                 textAlign: TextAlign.end,
          //                 style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w300, fontSize: 13, decoration: TextDecoration.lineThrough)),
          //           ),
          //         ),
          //       ),
          //       // buildRating(context),
          //     ],
          //   ),
          // ),
          SizedBox(height: 5),
        ],
      ),
    ),
  );
}
