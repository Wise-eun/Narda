
class getstore{
  String storeLocation;

  getstore(this.storeLocation);

  factory getstore.fromJson(Map<String,dynamic> json) => getstore(
    json['storeLocation'] as String,
  );

  Map<String, dynamic> toJson() =>{
    'storeLocation' : storeLocation,
  };
}