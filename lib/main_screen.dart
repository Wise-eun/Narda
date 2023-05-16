import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:speelow/DirectionProviders.dart';
import 'package:speelow/menu_bottom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speelow/DirectionProviders.dart';
import 'model/directions.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();

  double latitude=37.588;
  double longitude=26.356;

  bool _serviceEnabled = false;
 // late PermissionStatus _permissionGranted;

   addressToPM() async {
     List<Location> locations = await locationFromAddress("대구 동구 화랑로100길 17");
     setState(() {
       latitude = locations[0].latitude.toDouble();
       longitude = locations[0].longitude.toDouble();
       print('예지언니네3 : $latitude, $longitude');
     });
   }

   getCurrentLocation() async {
     try {
      var status_position = await Permission.location.status;
      var requestStatus = await Permission.location.request();
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      //if (status_position.isGranted) {
        // 1-2. 권한이 있는 경우 위치정보를 받아와서 변수에 저장합니다.
        // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
          setState(() {
            print("latitude : " + latitude.toString()  + ", " + "longitude : " + longitude.toString());
            latitude = position.latitude;
            longitude = position.longitude;

            final marker = NMarker(id: 'current', position: NLatLng(latitude ,longitude));
            _mapController.addOverlay(marker);

            /*
            //다중 마커 추가
            final marker2 = NMarker(id:'2', position:NLatLng(latitude-0.001, longitude-0.002));
            marker2.setIconTintColor(Colors.blueAccent);
            _mapController.addOverlay(marker2);

            //경로 추가
            NPathOverlay path = NPathOverlay(id: 'route', coords: [
              NLatLng(latitude, longitude),
              NLatLng(latitude-0.001, longitude-0.002),
            ]);
            path.setColor(Colors.blue);
            _mapController.addOverlay(path);

            //영역 추가
            final overlay = NCircleOverlay(id: "test", center: NLatLng(latitude ,longitude),
              radius:2000,
              color:Colors.white60,
            );
            _mapController.addOverlay(overlay);

            //경계 추가 (미완성)
            var bounds = NLatLngBounds(southWest: NLatLng(latitude-0.002, longitude+0.002),
                northEast: NLatLng(latitude+0.002, longitude+0.002));
             */
            NLatLng target = NLatLng(latitude,longitude);
            NCameraUpdate nCameraUpdate = NCameraUpdate.withParams(
              target: NLatLng(latitude,longitude),
              zoom: 13,
            );
            //.scrollAndZoomTo(target, 10)
            if(_mapController != null)
              _mapController.updateCamera(nCameraUpdate);
            });
        });
      } else {
        // 1-3. 권한이 없는 경우
        print("위치 권한이 필요합니다.");
      }
      /*
      if(!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if(!_serviceEnabled)
          {return;
        }
      }

      _locationData = await location.getLocation();
      // Geolocator API로 위도, 경도 호출
      this.latitude = _locationData.latitude!;
      this.longitude = _locationData.longitude!;
      */
    } catch (e) {
      print(e);
    }
  }

  late List<Routes> directions = [];
  DirectionProvider directionProvider = DirectionProvider();
  @override
  void initState() {
    // TODO: implement initState
    //addressToPM();
    getCurrentLocation();
    PrintDestination();
  }

  Future PrintDestination() async{
    directions = await directionProvider.getDestination();
    print("DESTINATION!!!!");
    print(directions.toString());
    print(directions.length);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    final physicalSize = Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");
    print('build : $latitude, $longitude');

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      bottomNavigationBar: MenuBottom(userId: widget.userId, tabItem: TabItem.home),
      body:
      Center(
          child:
              Column(
                children: [
                  /*
                  Text("Lat: $latitude, Lng: $longitude"),
                  TextButton(
                    child: Text("Locate Me"),
                    onPressed: () => getCurrentLocation(),
                  )*/
                  SizedBox(
                      width: mapSize.width,
                      height: (mapSize.height-18), //하단바때문에 오버픽셀 부분 뺌
                      // color: Colors.greenAccent,
                      child:
                      NaverMap(
                        options:  NaverMapViewOptions(
                            initialCameraPosition: NCameraPosition(target: NLatLng(latitude, longitude), zoom: 10, bearing: 0, tilt: 0)
                        ),
                        onMapReady:(controller) {
                          _mapController = controller;
                        },
                        //onCameraChange: onChanged(LatLng(latitude, longitude), CameraChangeReason.location, true),
                      )
                  ),
                ],
              )

        /*
          SizedBox(
              width: mapSize.width,
              height: mapSize.height,
              // color: Colors.greenAccent,
              child:
              NaverMap(
                initialCameraPosition:CameraPosition(
                  target: LatLng(latitude,longitude),
                  zoom: 17,
                ),
              )
          )
          */
      ),
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (mapControllerCompleter.isCompleted) mapControllerCompleter = Completer();
    mapControllerCompleter.complete(controller);
  }
}






