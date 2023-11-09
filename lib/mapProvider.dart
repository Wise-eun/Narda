import 'package:flutter/foundation.dart';

import 'package:naver_map_plugin/naver_map_plugin.dart' show LocationTrackingMode;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
class MapProvider with ChangeNotifier {

  late double latitude ;
  late double longitude ;

  MapProvider(){

    Future(this.setCurrentLocation);
  }

  LocationTrackingMode _trackingMode = LocationTrackingMode.None;
  LocationTrackingMode get trackingMode => this._trackingMode;
  set trackingMode(LocationTrackingMode m) => throw "error";

  Future<void> setCurrentLocation() async {
    var requestStatus = await Permission.location.request();

    if (requestStatus.isGranted) {
      LocationPermission permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      latitude = position.latitude;
      longitude = position.longitude;

      this._trackingMode = LocationTrackingMode.Follow;
      this.notifyListeners();
    }
  }

}