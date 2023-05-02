
class Store{
  String storeId;
  String storePhoneNum;
  String storeName;
  String storeLocation;


  Store(this.storeId, this.storeName, this.storePhoneNum,  this.storeLocation);

  factory Store.fromJson(Map<String,dynamic> json) => Store(
    json['storeId'] as String,
    json['storeName'] as String,
    json['storePhoneNum'] as String,
    json['storeLocation'] as String,
  );

  Map<String, dynamic> toJson() =>{
    'userId' : storeId,
    'storeName' : storeName,
    'storePhoneNum' : storePhoneNum,
    'storeLocation' : storeLocation
  };
}