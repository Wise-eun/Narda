import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
class RiderPosition{
  String userId;
  double latitude;
  double longitude;

  RiderPosition(this.userId, this.latitude, this.longitude);

  factory RiderPosition.fromJson(Map<String,dynamic> json) => RiderPosition(
    json['userId'] as String,
    double.parse(json['latitude']),
    double.parse(json['longitude']),
  );

  Map<String, dynamic> toJson() =>{
    'userId' : userId,
    'latitude' : latitude.toString(),
    'longitude' : longitude.toString()
  };
}