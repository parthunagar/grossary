import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/grid_view.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/productmodel/storeprodcut.dart';

class MyStoreProduct extends StatefulWidget {
  @override
  MyStoreProductState createState() => MyStoreProductState();
}

class MyStoreProductState extends State<MyStoreProduct> {
  List<StoreProductData> productData = [];
  bool isLoading = false;
  bool isDelete = false;
  int pageIndex = 0;
  var http = Client();

  @override
  void initState() {
    super.initState();
    getAllProductInfo();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getAllProductInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      productData.clear();
      isLoading = true;
    });
    int id = prefs.getInt('store_id');
    print('getAllProductInfo => storeProductsUri : $storeProductsUri store_id : $id');
    http.post(storeProductsUri, body: {'store_id': '${prefs.getInt('store_id')}'}).then((value) {
      print('getAllProductInfo => value.body : ${value.body.toString()}');
      if (value.statusCode == 200) {
        StoreProductMain productMain = StoreProductMain.fromJson(jsonDecode(value.body));
        if ('${productMain.status}' == '1') {
          setState(() {
            productData.clear();
            productData = List.from(productMain.data);
          });
        }
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('getAllProductInfo ERROR : ${e.toString()}');
      setState(() { isLoading = false;  });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(5.0),
      child: (isLoading || (productData != null && productData.length > 0))
        ? (productData != null && productData.length > 0)
          ? buildGridView(productData, callBack: (id, type) async {
              if (type == 'product') {
                  deleteProductById(id,context);
              } else if (type == 'variant') {
                  deleteVarientById(id);
              }
            }, update: (pData, type, pvid) {
              if (type == 'product') {
                Navigator.pushNamed(context, PageRoutes.updateitem, arguments: {'pData': pData}).then((value) {
                  getAllProductInfo();
                }).catchError((e) {
                  print('type == "product" ERROR : ${e.toString()}');
                });
              } else if (type == 'variant') {
                Navigator.pushNamed(context, PageRoutes.editItem, arguments: {'pData': pData, 'vid': pvid}).then((value) {
                  getAllProductInfo();
                }).catchError((e) {
                  print('type == "variant" ERROR : ${e.toString()}');
                });
              }
            }, addVaraient: (id) {
              Navigator.pushNamed(context, PageRoutes.add_varinet_page, arguments: {'pId': id}).then((value) {
                getAllProductInfo();
              }).catchError((e) {
                print('ERROR : ${e.toString()}');
              });
            }, updateStock: (pData, type, pvid) {
              updateStockById(pData.productId,pvid);
            },context : context)
          : buildGridSHView(context)
      : Align(
          alignment: Alignment.center,
          child: Text(locale.itempagenomore),
        ));
  }

  void deleteVarientById(dynamic id) async {
    bool result = await showDialog(
      context: context,
      builder: (context) {
        var locale = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(locale.confirmation),
          content: Text(locale.confirmationSureVariant),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(false); // dismisses only the dialog and returns false
              },
              child: Text(locale.no,style: TextStyle(color: kRoundButtonInButton)),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true); // dismisses only the dialog and returns true
              },
              child: Text(locale.yes,style: TextStyle(color: kRoundButtonInButton)),
            ),
          ],
        );
      },
    );
    if(result){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('deleteVarientById => storeVarientsDeleteUri : $storeVarientsDeleteUri  '+ 'varient_id : '+ '$id' +'store_id : '+'${prefs.getInt('store_id')}');
      http.post(storeVarientsDeleteUri, body: {'varient_id': '$id', 'store_id':'${prefs.getInt('store_id')}'}).then((value) {
        print('deleteVarientById => value.body : ${value.body}');
        var js = jsonDecode(value.body);
        print('deleteVarientById => value.body : ${value.body}');
        if ('${js['status']}' == '1') {
          Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          getAllProductInfo();
        }
        setState(() { isDelete = false; });
      }).catchError((e) {
        print('deleteVarientById ERROR : ${e.toString()}');
        setState(() { isDelete = false;  });
      });
    }

  }

  void updateStockById(dynamic id,dynamic stock) async {
    print('updateStockById => storeStockUpdateUri : $storeStockUpdateUri '+ ',p_id : '+ '$id' +'stock : '+ '$stock');
    http.post(storeStockUpdateUri, body: {'p_id': '$id', 'stock': '$stock'}).then((value) {
      print('updateStockById => value.body : ${value.body}');
      var js = jsonDecode(value.body);
      print('updateStockById => value.body : ${value.body}');
      if ('${js['status']}' == '1') {
        Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        getAllProductInfo();
      }
      setState(() { isDelete = false; });
    }).catchError((e) {
      print('updateStockById => ERROR : ${e.toString()}');
      setState(() { isDelete = false; });
    });
  }

  void deleteProductById(dynamic id,BuildContext context) async {
    bool result = await showDialog(
      context: context,
      builder: (context) {
        var locale = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(locale.confirmation),
          content: Text(locale.confirmationSureItem),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false); // dismisses only the dialog and returns false
              },
              child: Text(locale.no,style: TextStyle(color: kRoundButtonInButton)),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true); // dismisses only the dialog and returns true
              },
              child: Text(locale.yes,style: TextStyle(color: kRoundButtonInButton)),
            ),
          ],
        );
      },
    );
    if(result){
      setState(() {
        productData.clear();
        isLoading = true;
      });
      print('deleteProductById => storeProductsDeleteUri : $storeProductsDeleteUri ' +'product_id ' + '$id' );
      http.post(storeProductsDeleteUri, body: {'product_id': '$id'}).then((value) {
        print('deleteProductById => value.body : ${value.body}');
        if (value.statusCode == 200) {
          var js = jsonDecode(value.body);
          if ('${js['status']}' == '1') {
            Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            }
          }
          getAllProductInfo();
        }).catchError((e) {
        print('deleteProductById => ERROR : ${e.toString()}');
        getAllProductInfo();
      });
    }
  }
}
