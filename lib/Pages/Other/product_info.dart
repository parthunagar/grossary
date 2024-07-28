import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Components/constantfile.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Other/seller_info.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/cart/addtocartbean.dart';
import 'package:groshop/beanmodel/cart/cartitembean.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/ratting/rattingbean.dart';
import 'package:groshop/beanmodel/storefinder/storefinderbean.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';
import 'package:groshop/beanmodel/wishlist/addorremovewish.dart';
import 'package:groshop/beanmodel/wishlist/wishdata.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:developer' as logger;

class ProductInfo extends StatefulWidget {
  // ProductInfo(this.image, this.name, this.productid, this.price, this.varientid, this.storeid);

  @override
  _ProductInfoState createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  ProductDataModel productDetails;
  var http = Client();
  List<ProductVarient> varaintList = [];
  List<Tags> tagsList = [];
  List<WhatsNewDataModel> sellerProducts = [];
  List<WishListDataModel> wishModel = [];
  List<CartItemData> cartItemd = [];
  StoreFinderData storedetails;
  bool progressadd = false;
  bool isWishList = false;
  String image;
  String name;
  String productid;
  String price;
  var varientid;
  String storeid;
  String desp;
  bool enterFirst = false;
  bool inCart = false;
  dynamic apCurrency;

  int ratingvalue = 0;
  double avrageRating = 0.0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getCartList();
  }

  void getRatingValue(dynamic store_id, dynamic varient_id) async {
    print('$getProductRatingUri  store_id  : $store_id   varient_id : $varient_id');
    http.post(getProductRatingUri,body: {'store_id':'$store_id', 'varient_id':'$varient_id'}).then((value) {
      print('getRatingValue => value.body :${value.body.toString()} ');
      if (value.statusCode == 200) {
        ProductRating data1 = ProductRating.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            List<ProductRatingData> dataL = List.from(data1.data);
            ratingvalue = dataL.length;
            if(ratingvalue>0){
              double rateV = 0.0;
              for(int i=0;i<dataL.length;i++){
                rateV = rateV+double.parse('${dataL[i].rating}');
                if(dataL.length == i+1){
                  avrageRating = rateV/dataL.length;
                }
              }
            }else{
              avrageRating = 5.0;
            }
          });
        }
      }
    }).catchError((e) {
      print('getRatingValue => ERROR : ${e.toString()}');
    });
  }

  void getWislist(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {'user_id': '${userId}', 'store_id': '${storeid}'}).then((value) {
      print('getWislist => value.body : ${value.body}');
      if (value.statusCode == 200) {
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {
      print('getWislist => ERROR : $e');
    });
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      progressadd = true;
      apCurrency = preferences.getString('app_currency');
    });
    var http = Client();
    print("getCartList => showCartUri : $showCartUri || user_id : ${preferences.getInt('user_id')}");
    http.post(showCartUri, body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
      print('getCartList RESPONSE : ${value.body}');
      if (value.statusCode == 200) {
        CartItemMainBean data1 = CartItemMainBean.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cartItemd.clear();
            cartItemd = List.from(data1.data);
            if (varientid != null) {
              int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '', '$varientid', '', '', '', '', '', '', '', ''));
              if (ind1 >= 0) {    inCart = true;  }
              else {   inCart = false;  }
            }
          });
        } else {
          setState(() {
            cartItemd.clear();
            if (data1.data.length > 0) {
              cartItemd = List.from(data1.data);
              if (varientid != null) {
                int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
                    '$varientid', '', '', '', '', '', '', '', ''));
                if (ind1 >= 0) {   inCart = true;   }
                else {   inCart = false;  }
              }
            } else {    inCart = false;  }
          });
        }
      }
      setState(() {   progressadd = false;   });
    }).catchError((e) {
      setState(() {   progressadd = false;   });
      print('getCartList => ERROR : $e');
    });
  }

  void getTopSellingList(dynamic storeid) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    print("getTopSellingList => topSellingUri : $topSellingUri || store_id : $storeid");
    http.post(topSellingUri, body: {'store_id': '$storeid'}).then((value) {
      print('getTopSellingList RESPONSE : ${value.body}');
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
      print('getTopSellingList ERROR : $e}');
    });
  }

  void addOrRemove(dynamic storeid, dynamic varientId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userid = preferences.getInt('user_id');
    print('addOrRemove => url : $addRemWishlistUri || store_id : $storeid || user_id : $userid || varient_id : $varientId || product_id : $productid');
    var http = Client();
    http.post(addRemWishlistUri, body: {
      'store_id': '$storeid',
      'user_id': '$userid',
      'varient_id': '$varientId',
      'product_id': '$productid'
    }).then((value) {
      print('addOrRemove => value.body : ${value.body}');
      if (value.statusCode == 200) {
        AddRemoveWishList data1 = AddRemoveWishList.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() { isWishList = true;  });
        } else if (data1.status == "2" || data1.status == 2) {
          setState(() {  isWishList = false; });
        }
        Toast.show(data1.message, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
    }).catchError((e) {
      print('addOrRemove => ERROR : $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    print('receivedData : ${receivedData.toString()}');

    setState(() {
      if (!enterFirst) {
        print('enterFirst : $enterFirst');
        enterFirst = true;
        productDetails = receivedData['pdetails'];

        print('productDetails : ${productDetails.storeId.toString()}');
        print('productDetails.productId : ${productDetails.productId.toString()}');

        // print('productDetails : ${productDetails.varients.toString()}');
        // print('productDetails : ${productDetails.varients.length.toString()}');
        // print('productDetails : ${productDetails.varients[0].toString()}');
        // try{
        //   print('productDetails : ${productDetails.varients[1].toString()}');
        // }catch(e) {
        //   print('ERROR : -========> ${e.toString()}');
        // }
        storedetails = receivedData['storedetails'];

        image = productDetails.productImage;
        name = productDetails.productName;
        productid = '${productDetails.productId}';
        print('productid =====> : ${productid.toString()}');


        //=====> OLD <=======
        // price = '${productDetails.varients[0].price}';
        // varientid = '${productDetails.varients[0].varientId}';
        // desp = productDetails.varients[0].description;

        //=====> NEW <=======
        // print('productDetails.varients.length : ${productDetails.varients.length.toString()}');
        if(productDetails.varients == null) {
          print('productDetails.varients 1 : ${productDetails.varients}');
          print('productDetails.varientsData 1 : ${productDetails.varientsData}');
          price = '${productDetails.price}';
          productid = '${productDetails.productId}';
          print('productDetails.price : ${productDetails.price.toString()}');
          varientid = '${productDetails.varientId}';
          print('productDetails.varientId : ${productDetails.varientId.toString()}');
          desp = productDetails.description;
          print('productDetails.description : ${productDetails.description.toString()}');

        }
        else{
          print('productDetails.varients 2 : ${productDetails.varients}');
          print('productDetails.varientsData 2 : ${productDetails.varientsData}');
          price = productDetails.varients[0].base_price == null ? '${productDetails.varients[0].price}' : '${productDetails.varients[0].base_price}';
          print('productDetails.varientsData 2 price : $price');
          varientid = '${productDetails.varients[0].varientId}';
          desp = productDetails.varients[0].description;
          try{
            print('productDetails.varients.storeId 2 : ${productDetails.varients[0].storeId}');
            productid = '${productDetails.varients[0].product_id.toString()}';
            print('==========> productid <=========== : ${productid.toString()}');
            // print('productDetails.productId : ${productDetails.varientsData[0].product_id.toString()}');
          }
          catch(e){
            print('productid => ERROR : $e');
          }

        }

        storeid = '${storedetails.store_id}';
        if(cartItemd!=null && cartItemd.length>0) {
          int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '', '$varientid', '', '', '', '', '', '', '', ''));
          if (ind1 >= 0) {
            setState(() {  inCart = true;   });
          }
        }
        isWishList = receivedData['isInWish'];
        varaintList.clear();

        //=====> OLD <=======
        // varaintList = List.from(productDetails.varients);

        //=====> NEW <=======
        if(productDetails.varients == null) {
          // varaintList = List.from(productDetails.varientsData);
          print("productDetails.storeId : ${productDetails.storeId}");
          print('productDetails.price : ${productDetails.price.toString()}');
          //productDetails.varients[0].base_price
          // print("productDetails.varients[0].base_price : ${productDetails.varients}");
          varaintList = <ProductVarient>[
            ProductVarient(
              storeId: productDetails.storeId,
              stock: productDetails.stock,
              varientId: productDetails.varientId,
              description: productDetails.description,
              price: productDetails.price,
              mrp: productDetails.mrp,
              varientImage: productDetails.varientImage,
              unit: productDetails.unit,
              quantity: productDetails.quantity),
          ];
          print('varaintList null ====> : ${varaintList[0].varientId.toString()}');
        }
         if(productDetails.varients != null) {
          varaintList = List.from(productDetails.varients);
          print('varaintList ====> : ${varaintList[0].varientId.toString()}');
        }


        tagsList.clear();
        tagsList = List.from(productDetails.tags);
        selectedIndex = 0;
        print("receivedData['isInWish'] : ${receivedData['isInWish'].toString()}");
        print('isWishList : ${isWishList}');
        getRatingValue(storeid, varientid);
        getTopSellingList(storeid);
        getWislist(storeid);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Stack(
                children: [
                  //Container(),
                  Positioned.fill(
                    child:  CachedNetworkImage(
                      imageUrl: '$image',
                      fit: BoxFit.cover,
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
                      errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                    ),
                      // child: Image.network(image, fit: BoxFit.fill)
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
                              Navigator.pop(context,'Back');
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
                                  print('value d');
                                  getCartList();
                                }).catchError((e) {
                                  print('dd');
                                  getCartList();
                                });
                                // Navigator.pushNamed(context, PageRoutes.cart)

                              } else {
                                Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                              }
                            },
                            iconSize: 15,
                            icon: ImageIcon(AssetImage('assets/icon_shopping_cart.png'))),
                      )),
                ],
              ),
            ),
            Stack(
              children: [
                Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 10,
                    end: 10,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                            addOrRemove(storeid, varientid, context);
                          } else {
                            Toast.show(locale.loginfirst1, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                          }
                        },
                        icon: Icon(isWishList ? Icons.favorite : Icons.favorite_border),
                        iconSize: 15,
                        color: kMainColor1,
                      ),
                    )),
                Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(name, style: Theme.of(context).textTheme.headline3.copyWith(color: kMainTextColor, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Text('${storedetails.store_name}', style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(child: Text("$apCurrency ${price}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20,color: kMainPriceText)),),
                    SizedBox(height: 5),
                    Center(child: buildRating(context,avrageRating: avrageRating)),
                    SizedBox(height: 12),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(45),
                          border: Border.all(
                            color: kMainColor1,
                            style: BorderStyle.solid,
                            width: 1.0,
                          ),
                        ),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, PageRoutes.reviewsall,arguments: {
                                'store_id':'$storeid',
                                'v_id':'$varientid',
                                'title':'$name'
                              }).then((value){
                                getRatingValue(storeid, varientid);
                              });
                              // name,varientid
                            },
                            child: Text('${locale.readAllReviews1} $ratingvalue ${locale.readAllReviews2}', style: TextStyle(color: kMainColor1, fontSize: 13),)),
                      ),
                    ),
                    // Icon(Icons.arrow_forward_ios,
                    //     size: 10, color: Color(0xffa9a9a9)),
                    SizedBox(height: 12),
                    Visibility(
                      visible: (desp != null && '$desp'.toUpperCase() != 'NULL'),
                      child: Text(
                        '${desp}',
                        softWrap: true,
                        style: TextStyle(
                          color: kTextBlack,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Visibility(
                      visible: (varaintList != null && varaintList.length > 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.varient,style: TextStyle(
                            // color: Theme.of(context).backgroundColor,
                              color:kTextBlack,
                              fontSize: 18,fontWeight: FontWeight.w700),),
                          SizedBox(height: 10,),
                          Container(
                            height: 35,
                            child: ListView.builder(
                                itemCount: varaintList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        print('selectedIndex : ${selectedIndex}');
                                        // price = '${varaintList[selectedIndex].price}'; //OLd
                                        price = '${varaintList[selectedIndex].base_price}'; //NEW
                                        print("varaintList[selectedIndex].price : ${varaintList[selectedIndex].price}");
                                        // mrp = '${varaintList[selectedIndex].mrp}';
                                        desp = '${varaintList[selectedIndex].description}';
                                        print("varaintList[selectedIndex].description : ${varaintList[selectedIndex].description}");
                                        varientid = productDetails.varients[selectedIndex].varientId;
                                        print("productDetails.varients[selectedIndex].varientId : ${productDetails.varients[selectedIndex].varientId}");
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: (selectedIndex == index) ? kVariantBorder : kWhiteColor,
                                            width: (selectedIndex == index) ? 2 : 1),
                                        color: (selectedIndex == index) ? kWhiteColor : kWhiteColor,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('${varaintList[index].quantity}\t${varaintList[index].unit}',style: TextStyle(color: kTextBlack, fontSize: 14),)
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],

            ),
            (!progressadd)
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                        onTap: () async {
                          print('BUTTON PRESS');
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          if (!inCart) {
                            setState(() {   progressadd = true;  });
                            if (prefs.containsKey('islogin') &&
                                prefs.getBool('islogin')) {
                              addtocart(storeid, varientid, 1, '0');
                            } else {
                              setState(() {
                                progressadd = false;
                              });
                              Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            }
                          } else {
                            if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                              Navigator.pushNamed(context,PageRoutes.cartPage).then((value) {
                                print('Navigator.pushNamed(context,PageRoutes.cartPage) value : ${value.toString()}');
                                getCartList();
                              }).catchError((e) {
                                print('Navigator.pushNamed(context,PageRoutes.cartPage) ERROR : ${e.toString()}');
                                getCartList();
                              });
                            } else {
                              Toast.show(locale.loginfirst, context, gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                            }
                          }
                        },
                        // height: 60,
                        iconGap: 12,
                        color: kRoundButton,
                        imageAssets: (inCart)?'assets/go_to_cart.png':'assets/Add_to_cart.png',

                        // prefixIcon: ImageIcon(
                        //   AssetImage('assets/ic_cart.png'),
                        //   color: Colors.white,
                        //   size: 16,
                        // ),
                        label: (inCart) ? locale.goToCart : locale.addToCart,
                        // label: locale.goToCart,
                      ),
                  ],
                )
                : Container(
                    height: 52,
                    alignment: Alignment.center,
                    child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRoundButton)))),
            SizedBox(height: 10),
            Visibility(
              visible: (tagsList != null && tagsList.length > 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    child: Text(locale.tags,style: TextStyle(color: kTextBlack,fontWeight: FontWeight.w700, fontSize: 18))),
                  SizedBox(height: 10,),
                  Container(
                    height: 35,
                    margin: EdgeInsets.only(left: 10),
                    child: ListView.builder(
                        itemCount: tagsList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pushNamed(context, PageRoutes.tagproduct,
                                arguments: {'storedetail': storedetails, 'tagname': tagsList[index].tag}).then((value) {
                                print('Navigator.pushNamed(context, PageRoutes.tagproduct value : ${value.toString()}');
                                getCartList();
                              }).catchError((e) {
                                print('Navigator.pushNamed(context, PageRoutes.tagproduct ERROR : ${e.toString()}');
                                getCartList();
                              });
                            },
                            child: Container(
                              // width: 75,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: kVariantBorder, width: 1),
                                color: kWhiteColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${productDetails.tags[index].tag.toString().replaceAll('[', '').replaceAll(']', '')}')
                                ],
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SellerInfo(storedetails, wishModel)));
                },
                child: RichText(
                  text: TextSpan(
                      text: '${locale.moreBy} ',
                      style: TextStyle(color: kTextBlack, fontWeight: FontWeight.bold, fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(text: locale.seller, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                      ]),
                ),
              ),
              // trailing:IconButton(
              //   icon: ImageIcon(AssetImage('assets/ic_view_all.png' )),
              //   iconSize: 15,
              //   onPressed: () {},
              // ),
              //
              // FlatButton(
              //     onPressed: () {
              //       // Navigator.push(context,MaterialPageRoute(builder: (context) =>CategoryProduct(locale.viewAll)));
              //     },
              //     child: Text(locale.viewAll,style: TextStyle(color: Colors.grey[500], fontSize: 12))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildGridViewP(context,sellerProducts, apCurrency, wishModel, storedetails),
            ),
          ],
        ),
      ),
    );
  }

  void addtocart(
    String storeid, String varientid, dynamic qnty, String special) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String s = 'data';
    print("addtocart => url : $addToCartUri || user_id : ${preferences.getInt('user_id')} || qty : $qnty || store_id : ${storedetails.store_id} || varient_id : $varientid || special : $special");
    var http = Client();
    http.post(addToCartUri, body: {
      'user_id': '${preferences.getInt('user_id')}', 'qty': '$qnty', 'store_id': '${storedetails.store_id}',
      'varient_id': '$varientid', 'special': '$special'}).then((value) {
      print('addtocart => value.body : ${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 = AddToCartMainModel.fromJson(jsonDecode(value.body));
        logger.log(value.body);
        if (data1.status == "1" || data1.status == 1) {
          setState(() {    inCart = true;    });
        }
      }
      setState(() {  progressadd = false;  });
    }).catchError((e) {
      print('addtocart => ERROR : $e');
      setState(() {  progressadd = false;   });
    });
  }
}

GridView buildGridViewP(BuildContext context,List<WhatsNewDataModel> products, apCurrency,
    List<WishListDataModel> wishModel, StoreFinderData storeFinderData,
    {bool favourites = false}) {
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
          // margin: EdgeInsets.only( top: 10, bottom: 10),
          decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)]),
          child: buildProductCard(context, products[index], apCurrency, wishModel, storeFinderData),
        );
      });
}

Widget buildProductCard(
  BuildContext context,
  WhatsNewDataModel products,
  dynamic apCurrency,
  List<WishListDataModel> wishModel,
  StoreFinderData storeFinderData,
) {
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
          //   varientId: products.varientId,
          //       description: products.description,
          //       price: products.price,
          //       mrp: products.mrp,
          //       varientImage: products.varientImage,
          //       unit: products.unit,
          //       quantity: products.quantity,
          //       stock: products.stock,
          //       storeId: products.storeId)
          //   ]
          //========> NEW <========
          varientsData: products.varientsData,
          varients: products.productVarient
      );
      int idd = wishModel.indexOf(WishListDataModel('', '', '${products.varientId}','', '', '', '', '', '', '', '', '', '', '',[],[],[]));
      Navigator.pushNamed(context, PageRoutes.product, arguments: {
        'pdetails': modelP,
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
            // width: MediaQuery.of(context).size.width / 2.5,
            // height: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: '${products.productImage}',
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
                errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(products.productName,maxLines: 1,
          style:TextStyle(fontWeight: FontWeight.bold, color: kTextBlack)),
        ),
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
              Flexible(
                child: Text('$apCurrency ${products.price}',
                   overflow: TextOverflow.ellipsis,
                  // textAlign: TextAlign.left,

                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: kMainPriceText)
                ),
              ),
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
        SizedBox(height: 4),
      ],
    ),
  );
}
