
class calendar{
  String orderTime;
  int deliveryFee;
  double deliveryDistance;

  calendar(this.orderTime, this.deliveryFee, this.deliveryDistance);

  factory calendar.fromJson(Map<String,dynamic> json) => calendar(
    json['orderTime'] as String,
    int.parse(json['deliveryFee']),
    double.parse(json['deliveryDistance']),
  );

  Map<String, dynamic> toJson() =>{
    'orderTime' : orderTime,
    'deliveryFee' : deliveryFee.toString(),
    'deliveryDisstance' : deliveryDistance,
  };
}