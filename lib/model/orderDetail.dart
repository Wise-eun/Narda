class OrderDetail{
  int orderId;
  int state;
  String orderTime;
  int predictTime;
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
  String storeName;
  String storePhoneNum;
  String storeLocation;
  int orderValue;
  String deliveryLocationDetail;
  //storeId 중복으로 출력 -> 중복 제거 필요

  OrderDetail(this.orderId, this.state, this.orderTime, this.predictTime, this.pickupTime, this.deliveryTime,
      this.deliveryDistance, this.deliveryFee, this.deliveryLocation, this.deliveryRequest,
      this.riderId, this.storeId, this.payment, this.orderInfo, this.customerNum, this.storeName, this.storePhoneNum, this.storeLocation, this.orderValue, this.deliveryLocationDetail);

  factory OrderDetail.fromJson(Map<String,dynamic> json) => OrderDetail(
    int.parse(json['orderId']),
    int.parse(json['state']),
    json['orderTime'] as String,
    int.parse(json['predictTime']),
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
    json['storeName'] as String,
    json['storePhoneNum'] as String,
    json['storeLocation'] as String,
    int.parse(json['orderValue']),
    json['deliveryLocationDetail'] as String
  );


  Map<String, dynamic> toJson() =>{
    'orderId' : orderId.toString(),
    'state' : state.toString(),
    'orderTime' : orderTime,
    'predictTime' : predictTime.toString(),
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
    'storeName' : storeName,
    'storePhoneNum' : storePhoneNum,
    'storeLocation' : storeLocation,
    'orderValue' : orderValue,
    'deliveryLocationDetail' : deliveryLocationDetail
  };
}