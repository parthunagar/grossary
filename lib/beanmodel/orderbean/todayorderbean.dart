import 'package:vendor/baseurl/baseurlg.dart';

class TodayOrderMain{
  dynamic user_address,cart_id,user_name,user_phone,remaining_price,order_price;
  dynamic delivery_boy_name,delivery_boy_phone,delivery_date,time_slot;
  dynamic payment_mode,payment_status,order_status,customer_phone;
  dynamic paid_by_wallet,coupon_discount,delivery_charge;
  List<TodayOrderItems> order_details;

  TodayOrderMain(
      this.user_address, this.cart_id,this.user_name,
      this.user_phone, this.remaining_price, this.order_price,
      this.delivery_boy_name, this.delivery_boy_phone, this.delivery_date,
      this.time_slot, this.payment_mode, this.payment_status,
      this.order_status, this.customer_phone, this.paid_by_wallet,
      this.coupon_discount, this.delivery_charge, this.order_details);
  
  factory TodayOrderMain.fromJson(dynamic json){

    var js = json['order_details'] as List;
    List<TodayOrderItems> order_d = [];
    if(js!=null && js.length>0){
      order_d = js.map((e) => TodayOrderItems.fromJson(e)).toList();
    }

    return TodayOrderMain(json['user_address'], json['cart_id'], json['user_name'], json['user_phone'], json['remaining_price'],
        json['order_price'], json['delivery_boy_name'],
        json['delivery_boy_phone'], json['delivery_date'], json['time_slot'], json['payment_mode'], json['payment_status'],
        json['order_status'], json['customer_phone'], json['paid_by_wallet'], json['coupon_discount'], json['delivery_charge'], order_d);
  }
}

class TodayOrderItems{
  dynamic store_order_id,product_name,varient_image;
  dynamic quantity,varient_id, qty,unit,price;
  dynamic order_cart_id,total_mrp,order_date,store_approval;

  TodayOrderItems(
      this.store_order_id, this.product_name, this.varient_image, this.quantity, this.varient_id,
      this.qty, this.unit, this.price, this.order_cart_id, this.total_mrp, this.order_date, this.store_approval);
  
  factory TodayOrderItems.fromJson(dynamic json){
    return TodayOrderItems(json['store_order_id'], json['product_name'], '$imagebaseUrl${json['varient_image']}', json['quantity'], json['varient_id'], json['qty'], json['unit'], json['price'], json['order_cart_id'], json['total_mrp'], json['order_date'], json['store_approval']);
  }

  @override
  String toString() {
    return '{store_order_id: $store_order_id, product_name: $product_name, varient_image: $varient_image, quantity: $quantity, varient_id: $varient_id, qty: $qty, unit: $unit, price: $price, order_cart_id: $order_cart_id, total_mrp: $total_mrp, order_date: $order_date, store_approval: $store_approval}';
  }
}