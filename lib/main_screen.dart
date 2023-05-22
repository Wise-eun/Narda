import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:speelow/menu_bottom.dart';
import 'package:speelow/order_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'api/api.dart';
import 'package:http/http.dart' as http;
import 'model/orderDetail.dart';

Map<String,int> orderLocations={};


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();

  List<NMarker> markers=[];
  double latitudes=37.588;
  double longitudes=26.356;
  double circlelatitude=37.588;
  double circlelongitude=26.356;

  bool _serviceEnabled = false;
  // late PermissionStatus _permissionGranted;

  newOrderList() async{
    try{
      var response = await http.post(
        Uri.parse(API.newOrderList),

      );
      if(response.statusCode == 200){
        //orderLocations= [];
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("오더 리스트 불러오기 성공");
          List<dynamic> responseList = responseBody['userData'];
          for(int i=0; i<responseList.length; i++){
            //print(OrderDetail.fromJson(responseList[i]));
            String orderLocation=(responseList[i]['storeLocation']).toString();
            final locationSplitList=orderLocation.split(' ');
            orderLocation=locationSplitList[0]+" "+locationSplitList[1]+" "+locationSplitList[2];
            print(orderLocation);
            if(orderLocations.containsKey(orderLocation)==false) {
              print("어이");
              orderLocations.addEntries({orderLocation:1}.entries);} //여기서 바로 스플릿해서 지도 넣는데 맵으로 넣자자자자자ㅏ잦
            else {
              print("짱나");
              orderLocations[orderLocation]=orderLocations[orderLocation]!+1;}
            print(orderLocations.entries);
          }
        }
        else {
          print("오더 리스트 불러오기 실패");
        }
        setState(() {});
        return orderLocations;
      }
    }catch(e){print(e.toString());}
  }

  addressToPM(String address) async {
    print("투피엠");
    List<Location> locations = await locationFromAddress(address);
    circlelatitude = locations[0].latitude.toDouble();
    circlelongitude = locations[0].longitude.toDouble();
    print(address);
    print('좌표 :$circlelatitude, $circlelongitude');
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
            print("latitude : " + latitudes.toString()  + ", " + "longitude : " + longitudes.toString());
            latitudes = position.latitude;
            longitudes = position.longitude;

            //final marker = NMarker(id: 'current', position: NLatLng(latitude ,longitude));
            //_mapController.addOverlay(marker);

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
            NLatLng target = NLatLng(latitudes,longitudes);
            NCameraUpdate nCameraUpdate = NCameraUpdate.withParams(
              target: NLatLng(latitudes,longitudes),
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

  circleCluster() async{
    print('나 여기똥');
    //print(orderLocations.length);
    for(MapEntry element in orderLocations.entries){
      //addressToPM(element.key);
      List<Location> locations = await locationFromAddress(element.key);
      circlelatitude = locations[0].latitude.toDouble();
      circlelongitude = locations[0].longitude.toDouble();
      print(element.key);
      print('좌표 :$circlelatitude, $circlelongitude');
      int count=element.value;
      final NCircleOverlay overlay= await NCircleOverlay(id: element.key, center: NLatLng(circlelatitude ,circlelongitude),
        radius: 380,//element.value<6?400:element.value<16?500:800,
        color:Color(0xB35a4dfd),
      );
      //overlay.setOnTapListener((overlay) => )
      _mapController.addOverlay(overlay);
      print("오버레이 추가 완");

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    //addressToPM();
    getCurrentLocation();
    newOrderList();


  }
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    final physicalSize = Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");
    print('build : $latitudes, $longitudes');

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      bottomNavigationBar: MenuBottom(userId: widget.userId, tabItem: TabItem.mypage,),
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
                    options: NaverMapViewOptions(
                        initialCameraPosition: NCameraPosition(target: NLatLng(latitudes, longitudes), zoom: 10, bearing: 0, tilt: 0)
                    ),
                    onMapReady:(controller) {
                      _mapController = controller;
                      circleCluster();
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





