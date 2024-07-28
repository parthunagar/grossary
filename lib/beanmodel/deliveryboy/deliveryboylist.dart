class DeliveryBoyMain{
  dynamic status,message;
  List<DeliveryBoyData> data;

  DeliveryBoyMain(this.status, this.message, this.data);

  factory DeliveryBoyMain.fromJson(dynamic json){

    var js = json['data'] as List;
    List<DeliveryBoyData> dlist = [];
    if(js!=null && js.length>0){
      dlist = js.map((e) => DeliveryBoyData.fromJson(e)).toList();
    }
    return DeliveryBoyMain(json['status'], json['message'], dlist);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class DeliveryBoyData{

  dynamic boy_name,dboy_id,lat,lng,boy_city,count,distance;

  DeliveryBoyData(this.boy_name, this.dboy_id, this.lat, this.lng, this.boy_city, this.count, this.distance);

  factory DeliveryBoyData.fromJson(dynamic json){
    return DeliveryBoyData(json['boy_name'], json['dboy_id'], json['lat'], json['lng'], json['boy_city'], json['count'], json['distance']);
  }

  @override
  String toString() {
    return '{boy_name: $boy_name, dboy_id: $dboy_id, lat: $lat, lng: $lng, boy_city: $boy_city, count: $count, distance: $distance}';
  }
}