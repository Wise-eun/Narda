
class calendar{
  String deliveryTime;
  int deliveryFee;
  double deliveryDistance;

  calendar(this.deliveryTime, this.deliveryFee, this.deliveryDistance);

  factory calendar.fromJson(Map<String,dynamic> json) => calendar(
    json['deliveryTime'] as String,
    int.parse(json['deliveryFee']),
    double.parse(json['deliveryDistance']),
  );

  Map<String, dynamic> toJson() =>{
    'deliveryTime' : deliveryTime,
    'deliveryFee' : deliveryFee.toString(),
    'deliveryDisstance' : deliveryDistance,
  };
}