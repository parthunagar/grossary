import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/productbean/recentsale.dart';
import 'package:groshop/beanmodel/searchmodel/searchkeyword.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';


class SearchResult extends StatefulWidget {

  final List<WishListDataModel> wishModel;
  final StoreFinderData storeDetails;
  final dynamic apCurrency;
  final String searchString;


  const SearchResult(this.wishModel, this.storeDetails, this.apCurrency, this.searchString);



  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
TextEditingController searchController = TextEditingController();
  List<ProductDataModel> products = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storeDetails;
bool progressadd = false;

  @override
  void initState() {
    wishModel.clear();
    wishModel = List.from(widget.wishModel);

    storeDetails = widget.storeDetails;
    searchController.text = widget.searchString;
    super.initState();
    getSearchList(searchController.text);
  }

  void getSearchList(dynamic searchword) async{
  progressadd = true;
    var http = Client();
    print('$searchByStoreUri ' +  'keyword : ' +'$searchword'+
        'store_id : '+'${storeDetails.store_id}');
    http.post(searchByStoreUri,body: {
      'keyword':'$searchword',
      'store_id':'${storeDetails.store_id}'
    }).then((value){
      if(value.statusCode == 200){
        ProductModel pData = ProductModel.fromJson(jsonDecode(value.body));
        print(value.body);
        if('${pData.status}'=='1'){
          print(value.body);
          setState(() {
            products.clear();
            products = List.from(pData.data);
            progressadd = false;
          });
        }else{
          progressadd = false;
        }
      }
    }).catchError((e){

    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Theme(
          data: new ThemeData(
            primaryColor: kMainColor1,
            primaryColorDark: kMainColor1,
          ),
          child: TextFormField(
            controller: searchController,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.black, fontSize: 18),
            onFieldSubmitted: (value){
                  getSearchList(value);
            },
            decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                prefixIcon: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey[400],
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                    borderSide: BorderSide(width: 1))),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: (!progressadd) ?ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Text(
              (products!=null && products.length>0)?'${products.length} ' + locale.resultsFound:'No product found.',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.grey[400], fontSize: 16),
            ),
            SizedBox(
              height: 16,
            ),
            buildGridViewP(context,products,widget.apCurrency,wishModel,storeDetails),
          ],
        ):Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: (!progressadd) ? CircularProgressIndicator(
          valueColor:
          AlwaysStoppedAnimation<Color>(kRoundButton),
        ):Text(
          locale.noProduct,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: kTextBlack, fontSize: 16),
        ),
      ),
      ),
    );
  }
}

Widget buildProductCard(
    BuildContext context,
    ProductDataModel products,
    List<WishListDataModel> wishModel,
    dynamic apCurrency,
    StoreFinderData storeFinderData,
    ) {
  return Container(
    decoration: BoxDecoration(
      color: kWhiteColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
      ],
    ),
    child: GestureDetector(
      onTap: () {
        dynamic id = products.varientId;
print('$id');
        int idd = wishModel.indexOf(WishListDataModel('', '', '$id','', '', '', '', '', '', '', '', '', '', '',[],[],[]));
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': products,
          'storedetails': storeFinderData,
          'isInWish': (idd >= 0),
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
                  imageUrl: '${products.varients[0].varientImage}',
                  placeholder: (context, url) => Align(
                    widthFactor: 50,
                    heightFactor: 50,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/icon.png'),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(products.productName,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold, color: kTextBlack)),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text('${products.varients[0].quantity} ${products.varients[0].unit}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          SizedBox(height: 4),
          Container(
            margin: EdgeInsets.only(left: 10 ,right: 10),
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$apCurrency ${products.varients[0].price}',
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)),
                Visibility(
                  visible:
                  ('${products.varients[0].price}' == '${products.varients[0].mrp}') ? false : true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('$apCurrency ${products.varients[0].mrp}',
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough)),
                  ),
                ),
                // buildRating(context),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

GridView buildGridViewP(BuildContext context,List<ProductDataModel> products, apCurrency,
    List<WishListDataModel> wishModel, StoreFinderData storeDetails,
    {bool favourites = false}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;

  return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio:
          MediaQuery.of(context).size.width /
              (MediaQuery.of(context)
                  .size
                  .height/1.55),
          crossAxisSpacing:
          w * 0.03, // horozintal space
          mainAxisSpacing:
          h * 0.025
      ),
      itemBuilder: (context, index) {
        return buildProductCard(
            context, products[index], wishModel, apCurrency,storeDetails);
      });
}
