class AppInfoModel{
  dynamic status,message,app_name,app_logo,firebase,country_code;
  dynamic firebase_iso,sms,phone_number_length,currency_sign,refertext,last_loc;


  AppInfoModel(this.status, this.message, this.app_name, this.app_logo,
      this.firebase, this.country_code, this.firebase_iso, this.sms, this.phone_number_length,this.currency_sign,this.refertext,this.last_loc);

  factory AppInfoModel.fromJson(dynamic json){
    return AppInfoModel(json['status'], json['message'], json['app_name'], json['app_logo'], json['firebase'], json['country_code'], json['firebase_iso'], json['sms'], json['phone_number_length'],json['currency_sign'],json['refertext'],json['last_loc']);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, app_name: $app_name, app_logo: $app_logo, firebase: $firebase, country_code: $country_code, firebase_iso: $firebase_iso, sms: $sms, phone_number_length: $phone_number_length, currency_sign: $currency_sign, refertext: $refertext, last_loc: $last_loc}';
  }
}