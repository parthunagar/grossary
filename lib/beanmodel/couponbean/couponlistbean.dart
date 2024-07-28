class CouponListMain {
  dynamic status,message;
  List<CouponListData> data;

  CouponListMain({this.status, this.message, this.data});

  CouponListMain.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<CouponListData>();
      json['data'].forEach((v) {
        data.add(new CouponListData.fromJson(v));
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

class CouponListData {
  dynamic couponId,couponName,couponCode,couponDescription;
  dynamic startDate,endDate,cartValue,amount,type,usesRestriction,storeId;

  CouponListData({
    this.couponId, this.couponName, this.couponCode, this.couponDescription,
    this.startDate, this.endDate, this.cartValue, this.amount, this.type,
    this.usesRestriction, this.storeId});

  CouponListData.fromJson(Map<String, dynamic> json) {
    couponId = json['coupon_id'];
    couponName = json['coupon_name'];
    couponCode = json['coupon_code'];
    couponDescription = json['coupon_description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    cartValue = json['cart_value'];
    amount = json['amount'];
    type = json['type'];
    usesRestriction = json['uses_restriction'];
    storeId = json['store_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coupon_id'] = this.couponId;
    data['coupon_name'] = this.couponName;
    data['coupon_code'] = this.couponCode;
    data['coupon_description'] = this.couponDescription;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['cart_value'] = this.cartValue;
    data['amount'] = this.amount;
    data['type'] = this.type;
    data['uses_restriction'] = this.usesRestriction;
    data['store_id'] = this.storeId;
    return data;
  }
}