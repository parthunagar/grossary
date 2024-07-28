import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/beanmodel/productmodel/adminprodcut.dart';
import 'package:vendor/beanmodel/productmodel/storeprodcut.dart';

GridView buildGridView(List<StoreProductData> listName,
    {bool favourites = false,
    void callBack(int index, String type),
    void update(StoreProductData pdData, String type, int pvid),
    void addVaraient(int pid),
    void updateStock(StoreProductData pdData, String type, int varientId),BuildContext context}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;

  return GridView.builder(
    padding: EdgeInsets.all(0),
    physics: BouncingScrollPhysics(),
    shrinkWrap: true,
    itemCount: listName.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      // crossAxisCount: 3,
      // childAspectRatio: 0.75,
      crossAxisCount: 2,
      childAspectRatio:
      MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
      crossAxisSpacing:
      w * 0.03, // horozintal space
      mainAxisSpacing:
      h * 0.025
    ),
    itemBuilder: (context, index) {
      return Container(
        // height: MediaQuery.of(context).size.width*0.1,
        // margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)
          ],
        ),
        child: buildProductCard(context, listName[index],
          favourites: favourites,
          callBack: (id, type) {
            callBack(id, type);
          },
          update: (productdatad, type, vorpid) {
            update(productdatad, type, vorpid);
          },
          addVaraient: (id) => addVaraient(id),
          updateStock: (productdatad, type, vorpid) {
            updateStock(productdatad, type, vorpid);
          }),
      );
    });
}

GridView buildGridAdminView(List<StoreProductM> listName,
    {bool favourites = false,
    void callBack(int index, String type),
    void update(StoreProductM pdData, String type, int pvid),
    void addVaraient(int pid),BuildContext context}) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;

  return GridView.builder(
      padding: EdgeInsets.all(0),
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: listName.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
        crossAxisSpacing: w * 0.03, // horozintal space
        mainAxisSpacing: h * 0.025
         // childAspectRatio: 0.75
     ),
      itemBuilder: (context, index) {
        return Container(
          // margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 1)],
          ),
          child: buildProductAdminCard(context, listName[index],
              favourites: favourites, update: (pData, type, pid) {
            update(pData, type, pid);
          }),
        );
      });
}

GridView buildGridSHView(BuildContext context) {
  double w = MediaQuery.of(context).size.width,h = MediaQuery.of(context).size.height;

  return GridView.builder(
      padding: EdgeInsets.all(20.0),
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/1.55),
        crossAxisSpacing: w * 0.03, // horozintal space
        mainAxisSpacing: h * 0.025
      ),
      itemBuilder: (context, index) {
        return buildProductSHCard(context);
      });
}

Widget buildProductSHCard(BuildContext context) {
  return Shimmer(
    duration: Duration(seconds: 3),
    color: Colors.white,
    enabled: true,
    direction: ShimmerDirection.fromLTRB(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2.5,
                child: Container(color: Colors.grey[300]),
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

Widget buildProductCard(BuildContext context, StoreProductData productData,
    {bool favourites = false,
    void callBack(int index, String type),
    void update(StoreProductData pdData, String type, int varientId),
    void addVaraient(int pid),
    void updateStock(StoreProductData pdData, String type, int varientId)}) {
  var locale = AppLocalizations.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,

    children: [
      Expanded(
        flex: 1,
        child: Container(
          // width: MediaQuery.of(context).size.width / 3,
          // height: MediaQuery.of(context).size.width / 4.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: productData.productImage,
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
      SizedBox(height: 10),
      // Visibility(
      //     visible:
      //         (productData.varients != null && productData.varients.length > 0),
      //     child: SizedBox(height: 4)),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Visibility(
            visible: (productData.varients != null && productData.varients.length > 0),
            child: Text(
                '${productData.varients[0].quantity} ${productData.varients[0].unit}',
                style: TextStyle(color: kRoundButtonInButton, fontSize: 10, fontWeight: FontWeight.normal))),
      ),
      SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(productData.productName, overflow: TextOverflow.fade, maxLines: 2, style: TextStyle(fontWeight: FontWeight.w500)),),
            GestureDetector(
                onTap: () {
                  // Get.to(CategoryBasedShowPage(),arguments: {
                  //   'categorytitle': categoryList[index]
                  // });
                  // containerKey.currentContext
                  showModalBottomSheet(
                    backgroundColor: kTransparentColor,
                    context: context,
                    builder: (builder) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          color: kWhiteColor,
                          boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0.0, 0.75))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Product', style: TextStyle(color: kTextBlack, fontSize: 22, fontWeight: FontWeight.w700),),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      update(productData, 'product', productData.productId);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: kMyAccountBack)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              height: 20,
                                              width: 20,
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              child: Image.asset('assets/Icon_edit.png')),
                                          Text("Update Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: kTextBlack),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        updateStock(productData, 'product', productData.productId);
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: kMyAccountBack,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: kMyAccountBack)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                height: 20,
                                                width: 20,
                                                margin: EdgeInsets.symmetric(horizontal: 10),
                                                child: Image.asset('assets/Icon_edit.png')),
                                            Text("Update Stock", style: TextStyle(fontSize: 18),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      callBack(int.parse('${productData.productId}'), 'product');
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: kMyAccountBack,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: kMyAccountBack)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              height: 20,
                                              width: 20,
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              child: Image.asset('assets/Icon_forever.png')),
                                          Text("Delete Product", style: TextStyle(color: Colors.redAccent, fontSize: 18),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: (productData.varients != null && productData.varients.length > 0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Variant', style: TextStyle(color: kTextBlack, fontSize: 22, fontWeight: FontWeight.w700),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: (productData.varients != null &&
                                      productData.varients.length > 0),
                                  child: ListView.builder(
                                      itemCount: productData.varients.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width / 1.6,
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(border: Border.all(color: kTextBackground)),
                                                  child: Text(
                                                    '${productData.varients[index].quantity} ${productData.varients[index].unit}',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextBlack),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).pop();
                                                        update(productData, 'variant', int.parse('${productData.varients[index].varientId}'));
                                                      },
                                                      behavior: HitTestBehavior.opaque,
                                                      child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          padding: EdgeInsets.all(8),
                                                          decoration: BoxDecoration(color: kRoundButtonInButton, borderRadius: BorderRadius.circular(5),),
                                                          child: Image.asset('assets/Icon_edit_white.png')),
                                                    ),
                                                    SizedBox(width: 10),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).pop();
                                                        callBack(int.parse('${productData.varients[index].varientId}'), 'variant');
                                                      },
                                                      behavior: HitTestBehavior.opaque,
                                                      child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          padding: EdgeInsets.all(6),
                                                          decoration: BoxDecoration(border: Border.all(color: kBorderColor, width: 1),
                                                            color: kWhiteColor, borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: Image.asset('assets/delete.png')),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomButton(
                                      iconGap: 12,
                                      onTap: (){
                                        Navigator.of(context).pop();
                                        addVaraient(int.parse('${productData.productId}'));
                                      },
                                      imageAssets: 'assets/Icon_medical.png',
                                      label: locale.addVariant,
                                    ),
                                  ],
                                ),
                                // ClipRRect(
                                //   borderRadius:
                                //       BorderRadius.all(Radius.circular(50)),
                                //   child: RaisedButton(
                                //     onPressed: () {
                                //
                                //     },
                                //     child: Text('Add Varient'),
                                //   ),
                                // ),
                                Container(height: 80)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 7,horizontal: 5),
                  child: Image.asset(
                    'assets/ic_menu.png',
                    height:MediaQuery.of(context).size.width*0.04 ,
                    width: MediaQuery.of(context).size.width*0.04,
                  ),
                ))
            // GestureDetector(
            //     onTap: () {
            //       // Navigator.pushNamed(context, PageRoutes.reviewsPage,arguments: {
            //       //   'item':productData
            //       // });
            //     },
            //     child: buildRating(context)),
          ],
        ),
      ),
      SizedBox(height: 5),
    ],
  );
}

Widget buildProductAdminCard(BuildContext context, StoreProductM productData,
    {bool favourites = false,
    void callBack(int index, String type),
    void update(StoreProductM pdData, String type, int varientId),
    void addVaraient(int pid)}) {
  var locale = AppLocalizations.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        flex: 1,
        child: Container(
          // width: MediaQuery.of(context).size.width / 3,
          // height: MediaQuery.of(context).size.width / 4.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: productData.productImage,
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
      SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text('${productData.quantity} ${productData.unit}',
          style: TextStyle(
            color: kRoundButtonInButton,
            fontSize: 10,
            fontWeight: FontWeight.normal)),
      ),
      SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(productData.productName,
                overflow: TextOverflow.fade,
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.w500))),
            Visibility(
              visible: ('${productData.approved}' == '0'),
              child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (builder) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(locale.product, style: TextStyle(color: kMainColor, fontSize: 18),),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      update(productData, 'product', productData.productId);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(border: Border.all(color: kMainColor)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(locale.updateProduct, style: TextStyle(fontSize: 18)),
                                          Icon(Icons.open_in_new),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      callBack(int.parse('${productData.productId}'), 'product');
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(border: Border.all(color: kMainColor)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(locale.deleteProduct, style: TextStyle(color: Colors.redAccent, fontSize: 18)),
                                          Icon(Icons.delete, color: Colors.redAccent)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(height: 80)
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Image.asset('assets/more.png', height: 20, width: 20)),
            )
          ],
        ),
      ),
      SizedBox(height: 5),
    ],
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
        Text("4.2",textAlign: TextAlign.center, style: Theme.of(context).textTheme.button.copyWith(fontSize: 10)),
        SizedBox(width: 1),
        Icon(Icons.star, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
      ],
    ),
  );
}


