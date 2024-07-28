class DeliveryBoyLogin {
  dynamic status,message;
  DeliveryBoyLoginData data;

  DeliveryBoyLogin({this.status, this.message, this.data});

  DeliveryBoyLogin.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    var jsD = json['data'] as List;
    if (jsD != null && jsD.length>0) {
      List<DeliveryBoyLoginData> data1 = new List<DeliveryBoyLoginData>();
      json['data'].forEach((v) {
        data1.add(new DeliveryBoyLoginData.fromJson(v));
      });
      data = data1[0];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }
}

class DeliveryBoyLoginData {
  dynamic dboyId,boyName,boyPhone,boyCity,password,deviceId,boyLoc,lat;
  dynamic lng,status,storeId,addedBy,adDboyId,remByAdmin;

  DeliveryBoyLoginData({
    this.dboyId, this.boyName, this.boyPhone,
    this.boyCity, this.password, this.deviceId, this.boyLoc, this.lat,
    this.lng, this.status, this.storeId, this.addedBy, this.adDboyId,this.remByAdmin});

  DeliveryBoyLoginData.fromJson(Map<String, dynamic> json) {
    dboyId = json['dboy_id'];
    boyName = json['boy_name'];
    boyPhone = json['boy_phone'];
    boyCity = json['boy_city'];
    password = json['password'];
    deviceId = json['device_id'];
    boyLoc = json['boy_loc'];
    lat = json['lat'];
    lng = json['lng'];
    status = json['status'];
    storeId = json['store_id'];
    addedBy = json['added_by'];
    adDboyId = json['ad_dboy_id'];
    remByAdmin = json['rem_by_admin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dboy_id'] = this.dboyId;
    data['boy_name'] = this.boyName;
    data['boy_phone'] = this.boyPhone;
    data['boy_city'] = this.boyCity;
    data['password'] = this.password;
    data['device_id'] = this.deviceId;
    data['boy_loc'] = this.boyLoc;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['status'] = this.status;
    data['store_id'] = this.storeId;
    data['added_by'] = this.addedBy;
    data['ad_dboy_id'] = this.adDboyId;
    data['rem_by_admin'] = this.remByAdmin;
    return data;
  }
}