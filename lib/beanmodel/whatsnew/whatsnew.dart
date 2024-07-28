import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/productbean/productwithvarient.dart';

// class WhatsNewModel{
//   dynamic status;
//   dynamic message;
//   List<WhatsNewDataModel> data;
//
//   WhatsNewModel(this.status, this.message, this.data);
//
//   factory WhatsNewModel.fromJson(dynamic json) {
//     var subc = json['data'] as List;
//     List<WhatsNewDataModel> subchildRe = [];
//     if (subc.length > 0) {
//       subchildRe = subc.map((e) => WhatsNewDataModel.fromJson(e)).toList();
//     }
//     return WhatsNewModel(json['status'], json['message'], subchildRe);
//   }
// }
//
// class WhatsNewDataModel{
//   dynamic store_id;
//   dynamic stock;
//   dynamic varient_id;
//   dynamic product_id;
//   dynamic product_name;
//   dynamic product_image;
//   dynamic description;
//   dynamic price;
//   dynamic mrp;
//   dynamic varient_image;
//   dynamic unit;
//   dynamic quantity;
//
//   WhatsNewDataModel(
//       this.store_id,
//       this.stock,
//       this.varient_id,
//       this.product_id,
//       this.product_name,
//       this.product_image,
//       this.description,
//       this.price,
//       this.mrp,
//       this.varient_image,
//       this.unit,
//       this.quantity);
//
//   factory WhatsNewDataModel.fromJson(dynamic json){
//     return WhatsNewDataModel(json['store_id'], json['stock'], json['varient_id'], json['product_id'], json['product_name'], '$imagebaseUrl${json['product_image']}', json['description'], json['price'], json['mrp'], '$imagebaseUrl${json['varient_image']}', json['unit'], json['quantity']);
//   }
//
//   @override
//   dynamic toString() {
//     return '{store_id: $store_id, stock: $stock, varient_id: $varient_id, product_id: $product_id, product_name: $product_name, product_image: $product_image, description: $description, price: $price, mrp: $mrp, varient_image: $varient_image, unit: $unit, quantity: $quantity}';
//   }
// }


class WhatsNewModel {
  dynamic status;
  dynamic message;
  List<WhatsNewDataModel> data;

  WhatsNewModel({this.status, this.message, this.data});

  WhatsNewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<WhatsNewDataModel>();
      json['data'].forEach((v) {
        data.add(new WhatsNewDataModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WhatsNewDataModel {
  dynamic storeId,stock,varientId,productId;
  dynamic productName,productImage,description,price;
  dynamic mrp,varientImage,unit,quantity;
  List<Tags> tags;
  List<VarientsData> varientsData;
  List<ProductVarient> productVarient;

  WhatsNewDataModel({this.storeId, this.stock,
    this.varientId, this.productId, this.productName,
    this.productImage, this.description, this.price,
    this.mrp, this.varientImage, this.unit,
    this.quantity, this.tags, this.varientsData,this.productVarient});

  WhatsNewDataModel.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    stock = json['stock'];
    varientId = json['varient_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productImage = '$imagebaseUrl${json['product_image']}';
    description = json['description'];
    price = json['price'];
    mrp = json['mrp'];
    varientImage = '$imagebaseUrl${json['varient_image']}';
    unit = json['unit'];
    quantity = json['quantity'];
    if (json['tags'] != null) {
      tags = new List<Tags>();
      json['tags'].forEach((v) {
        tags.add(new Tags.fromJson(v));
      });
    }
    if (json['varients'] != null) {
      print("json['varients'] ===> 1 : ${json['varients'].toString()}");
      varientsData = new List<VarientsData>();
      json['varients'].forEach((v) {
        varientsData.add(new VarientsData.fromJson(v));
      });
    }
    else{
      print("ELSE =======> json['varients'] 1 : ${json['varients'].toString()}");
    }

    if (json['varients'] != null) {
      print("json['varients'] ===> 2 : ${json['varients'].toString()}");
      productVarient = new List<ProductVarient>();
      json['varients'].forEach((v) {
        productVarient.add(new ProductVarient.fromJson(v));
      });
    }
    else{
      print("ELSE =======> json['varients'] 2 : ${json['varients'].toString()}");
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_id'] = this.storeId;
    data['stock'] = this.stock;
    data['varient_id'] = this.varientId;
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_image'] = this.productImage;
    data['description'] = this.description;
    data['price'] = this.price;
    data['mrp'] = this.mrp;
    data['varient_image'] = this.varientImage;
    data['unit'] = this.unit;
    data['quantity'] = this.quantity;
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    if (this.varientsData != null) {
      data['varients'] = this.varientsData.map((v) => v.toJson()).toList();
    }

    if (this.productVarient != null) {
      data['varients'] = this.productVarient.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tags {
  dynamic tagId;
  dynamic productId;
  dynamic tag;

  Tags({this.tagId, this.productId, this.tag});

  Tags.fromJson(Map<String, dynamic> json) {
    tagId = json['tag_id'];
    productId = json['product_id'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tag_id'] = this.tagId;
    data['product_id'] = this.productId;
    data['tag'] = this.tag;
    return data;
  }
}

class VarientsData {
  dynamic varient_id,product_id,quantity,unit,base_mrp,base_price,description,varient_image,ean,approved,added_by;

  VarientsData({
    this.varient_id,this.product_id,this.quantity,this.unit,
    this.base_mrp,this.base_price,this.description,this.varient_image,
    this.ean,this.approved,this.added_by
  });

  VarientsData.fromJson(Map<String, dynamic> json) {
    varient_id = json['varient_id'];
    product_id = json['product_id'];
    quantity = json['quantity'];
    unit = json['unit'];
    base_mrp = json['base_mrp'];
    base_price = json['base_price'];
    description = json['description'];
    varient_image = json['varient_image'];
    ean = json['ean'];
    approved = json['approved'];
    added_by = json['added_by'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['varient_id'] = this.varient_id;
    data['product_id'] = this.product_id;
    data['quantity'] = this.quantity;
    data['unit'] = this.unit;
    data['base_mrp'] = this.base_mrp;
    data['base_price'] = this.base_price;
    data['description'] = this.description;
    data['varient_image'] = this.varient_image;
    data['ean'] = this.ean;
    data['approved'] = this.approved;
    data['added_by'] = this.added_by;
    return data;
  }
}
