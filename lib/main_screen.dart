import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const MethodChannel _methodChannel = MethodChannel('mobile/parameters');

  Future<void> _initTmapAPI() async{
    try{
      final String result = await _methodChannel.invokeMethod('initTmapAPI');
      print('initTmapAPI result : $result');
    }on PlatformException{
      print('PratformException');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    _initTmapAPI();
  }

  Future<void> _tmapCheck() async {
    try {
      final String result = await _methodChannel.invokeMethod(
          'isTmapApplicationInstalled');
      print('is TmapApplicationInstalled result : $result');

      if (result.isEmpty || result.length == 0) {
        if (await canLaunch(result)) {
          print("미설치되어서 설치페이지로 이동");
          await launch(result, forceSafariVC: false, forceWebView: false);
        }
      }
        else {
          /*
        String url = Uri.encodeFull(
            "https://apis.openapi.sk.com/tmap/app/routes?appKey=yIvsQzTPnWa2bnrbh6HeN9iq4CbOhadO3M3g46RT&name=SKT타워&lon=126.984098&lat=37.566385");
        print("1");
        if (await canLaunch(url)) {
          print("설치");
          await launch(url, forceSafariVC: false, forceWebView: false);
        }*/

       // final String result2 = await _methodChannel.invokeMethod(
           // 'tmapViewAPI');
         var result3 = await _methodChannel.invokeMethod(
    'tmapViewAPI');
        //print('tmapViewAPI result : $result3');
      }
    }
    on PlatformException {
      print('PlatformException');
    }
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.blue[200],
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("메인화면입니다."),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TestPage()));


                  },
                  child: Text("지도"))
            ],
          ),
        )

    );
  }

}


class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  late double latitude = 36.598654;
  late double longitude = 125.25654;


  Future<void> getMyCurrentLocation() async {

    // 위치권한을 가지고 있는지 확인

    var requestStatus = await Permission.location.request();
    if(requestStatus.isGranted)
{
  print("권한 동의");
}
    else
      {
        print("권한 비동의");
      }

    if (requestStatus.isGranted) {
      LocationPermission permission = await Geolocator.requestPermission();
      // 1-2. 권한이 있는 경우 위치정보를 받아와서 변수에 저장합니다.
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      latitude = position.latitude;
      longitude = position.longitude;

      print("latitude : " + latitude.toString() + ", longitude : " +longitude.toString() );
    } else {
      // 1-3. 권한이 없는 경우
      print("위치 권한이 필요합니다.");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize =
    Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    final physicalSize =
    Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      body: Center(
          child: SizedBox(
              width: mapSize.width,
              height: mapSize.height,
              // color: Colors.greenAccent,
              child: _naverMapSection())),
    );
  }

  Widget _naverMapSection() => NaverMap(
    initialCameraPosition:CameraPosition(
        target: LatLng(latitude,longitude),
        zoom: 17
    ),

  );
}






