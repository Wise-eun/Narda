class OrderDetail{
  int orderId;
  int state;
  String orderTime;
  String? pickupTime;
  String? deliveryTime;
  double deliveryDistance;
  int deliveryFee;
  String deliveryLocation;
  String deliveryRequest;
  String? riderId;
  String storeId;
  int payment;
  String orderInfo;
  String customerNum;
  String storePhoneNum;
  String storeLocation;
  //storeId 중복으로 출력 -> 중복 제거 필요

  OrderDetail(this.orderId, this.state, this.orderTime, this.pickupTime, this.deliveryTime,
      this.deliveryDistance, this.deliveryFee, this.deliveryLocation, this.deliveryRequest,
      this.riderId, this.storeId, this.payment, this.orderInfo, this.customerNum, this.storePhoneNum, this.storeLocation);

  factory OrderDetail.fromJson(Map<String,dynamic> json) => OrderDetail(
    int.parse(json['orderId']),
    int.parse(json['state']),
    json['orderTime'] as String,
    json['pickupTime'] as String?,
    json['deliveryTime'] as String?,
    double.parse(json['deliveryDistance']),
    int.parse(json['deliveryFee']),
    json['deliveryLocation'] as String,
    json['deliveryRequest'] as String,
    json['riderId'] as String?,
    json['storeId'] as String,
    int.parse(json['payment']),
    json['orderInfo'] as String,
    json['customerNum'] as String,
    json['storePhoneNum'] as String,
    json['storeLocation'] as String,
  );


  Map<String, dynamic> toJson() =>{
    'orderId' : orderId.toString(),
    'state' : state.toString(),
    'orderTime' : orderTime,
    'pickupTime' : pickupTime,
    'deliveryTime' : deliveryTime,
    'deliveryDistance' : deliveryDistance.toString(),
    'deliveryFee' : deliveryFee.toString(),
    'deliveryLocation' : deliveryLocation,
    'deliveryRequest' : deliveryRequest,
    'riderId' : riderId,
    'storeId' : storeId,
    'payment' : payment.toString(),
    'orderInfo' : orderInfo,
    'customerNum' : customerNum,
    'storePhoneNum' : storePhoneNum,
    'storeLocation' : storeLocation,
  };
}