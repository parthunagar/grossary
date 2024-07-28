import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';
import 'package:groshop/beanmodel/whatsnew/whatsnew.dart';

class WishListModel{

  dynamic status,message;
  List<WishListDataModel> data;

  WishListModel(this.status, this.message, this.data);

  factory WishListModel.fromJson(dynamic json){
    var subc = json['data'] as List;
    List<WishListDataModel> subchildRe = [];
    if (subc.length > 0) {
    subchildRe = subc.map((e) => WishListDataModel.fromJson(e)).toList();
    }
    return WishListModel(json['status'], json['message'], subchildRe);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class WishListDataModel{

  dynamic wish_id,user_id,varient_id,quantity,unit,price,mrp,product_name;
  dynamic description,varient_image,store_id,product_id,created_at,updated_at;
  List<Tags> tags;
  List<ProductVarient> varients;
  List<VarientsData> varientsData;

  WishListDataModel(
      this.wish_id, this.user_id, this.varient_id, this.quantity, this.unit, this.price, this.mrp,
      this.product_name, this.description, this.varient_image, this.store_id,this.product_id,
      this.created_at, this.updated_at,
      this.tags,this.varients,this.varientsData
      );

  WishListDataModel.fromJson(Map<String, dynamic> json) {
    wish_id = json['wish_id'];
    user_id = json['user_id'];
    varient_id = json['varient_id'];
    quantity = json['quantity'];
    unit = json['unit'];
    price = json['price'];
    mrp = json['mrp'];
    product_name = json['product_name'];
    description = json['description'];
    varient_image = '$imagebaseUrl'+json['varient_image'];
    product_id = json['product_id'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];

    if (json['tags'] != null) {
      print("json['tags'] : ${json['tags'].toString()}");
      tags = new List<Tags>();
      json['tags'].forEach((v) {
        tags.add(new Tags.fromJson(v));
      });
    }
    else{
      print("ELSE =======> json['tags'] : ${json['tags'].toString()}");
    }

    if (json['varients'] != null) {
      print("json['varients'] 1 : ${json['varients'].toString()}");
      varients = new List<ProductVarient>();
      json['varients'].forEach((v) {
        varients.add(new ProductVarient.fromJson(v));
      });
    }
    else{
      print("ELSE 1 =======> json['varients'] : ${json['varients'].toString()}");
    }
    if (json['varients'] != null) {
      print("json['varients'] 2 : ${json['varients'].toString()}");
      varientsData = new List<VarientsData>();
      json['varients'].forEach((v) {
        varientsData.add(new VarientsData.fromJson(v));
      });
    }
    else{
      print("ELSE 2 =======> json['varients'] : ${json['varients'].toString()}");
    }

  }
  // factory WishListDataModel.fromJson(dynamic json){
  //   return WishListDataModel(
  //       json['wish_id'],
  //       json['user_id'],
  //       json['varient_id'],
  //       json['quantity'],
  //       json['unit'],
  //       json['price'],
  //       json['mrp'],
  //       json['product_name'],
  //       json['description'],
  //       '$imagebaseUrl${json['varient_image']}',
  //       json['store_id'],json['product_id'],
  //       json['created_at'],
  //       json['updated_at'],
  //
  //   );
  // }

  @override
  String toString() {
    return '{wish_id: $wish_id, user_id: $user_id, varient_id: $varient_id, quantity: $quantity, unit: $unit, price: $price, mrp: $mrp, product_name: $product_name, description: $description, varient_image: $varient_image, store_id: $store_id, product_id: $product_id, created_at: $created_at, updated_at: $updated_at}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is WishListDataModel && runtimeType == other.runtimeType && '$varient_id' == '${other.varient_id}';

  @override
  int get hashCode => varient_id.hashCode;
}