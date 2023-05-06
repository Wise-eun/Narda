import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

const String kakaoMapKey = '3e8531d2fdf84a885535fc7c4ac309ca';

class KakaoMapTest extends StatefulWidget {
  const KakaoMapTest({Key? key}) : super(key: key);

  @override
  State<KakaoMapTest> createState() => _KakaoMapTestState();
}

class _KakaoMapTestState extends State<KakaoMapTest> {
  WebViewController? controller;
  double latitude = 37.58886;
  double longitude = 26.3546;
  bool _serviceEnabled = false;

  getCurrentLocation() async {
    bool result = await NaviApi.instance.isKakaoNaviInstalled();
    try {
      var status_position = await Permission.location.status;
      var requestStatus = await Permission.location.request();
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {

        await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high).then((position) {
              setState(() {
                print("latitude : " + latitude.toString() + ", "
                    + "longitude : " + longitude.toString());
            latitude = position.latitude;
            longitude = position.longitude;
          });
        });
      }
    } catch(e) {
      print(e);
    }
    /*
    //x(longitude경도), y(latitude위도)
    if(await NaviApi.instance.isKakaoNaviInstalled()) {
      var navioption = NaviOption(
        startX: '$longitude',
        startY: '$latitude',
      );
      print('카카오내비 설치됨 : $latitude, $longitude');
      await NaviApi.instance.navigate(
        destination :
          Location(name: 'ex1', x: '127.111', y: '37.39'),
        option:
          navioption,
      );
    } else {
      print('카카오내비 미설치');
      launchBrowserTab(Uri.parse(NaviApi.webNaviInstall));
    }
    */
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          KakaoMapView(
            width: size.width,
            height:600,
            kakaoMapKey: kakaoMapKey,
            lat: latitude,
            lng: longitude,
            showMapTypeControl: true,
            showZoomControl: true,
          ),

          TextButton(
            onPressed: () async {
              print('kakao map 버튼 클릭');
              await _openKakaoMapScreen(context);
            },
            child: Text('kakao map screen')
          )
        ],
      )
    );
  }

  Future<void> _openKakaoMapScreen(BuildContext context) async {
    KakaoMapUtil util = KakaoMapUtil();
    String url = await util.getMapScreenURL(latitude, longitude, name: 'test');
    Navigator.push(
      context, MaterialPageRoute(builder: (_) => KakaoMapScreen(url: url))
    );
  }
}

class MapTest extends State<KakaoMapTest> {
  String url="https://map.kakao.com";
  //link/to/이름,위도,경도
  //String url="https://map.kakao.com/link/to/카카오판교오피스,37.402056,127.108212";
  Set<JavascriptChannel>? channel;
  WebViewController? controller;
  double latitude = 32.7;
  double longitude = 127.5;

  @override
  void initState() {
    if(Platform.isIOS) {
      print('in ios');
    }
    else if(Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double ratio = MediaQuery.of(context).devicePixelRatio;
    return ClipRect(
      child: Transform.scale(
        alignment: Alignment.center,
        scale: ratio/3,
        child: WebView(
          initialUrl: url,
          onWebViewCreated: (controller) {
            this.controller=controller;
          },
          onProgress: (int progress) {
            print('webview is loading (progress: $progress%)');
          },
          navigationDelegate: (navigation) {
            final host = Uri.parse(navigation.url).host;
            return NavigationDecision.navigate;
          },
          javascriptChannels: <JavascriptChannel>{
            _webToAppChange(context),
          },
          javascriptMode: JavascriptMode.unrestricted,
        )
      )
    );
  }

  JavascriptChannel _webToAppChange(BuildContext context) {
    return JavascriptChannel(
        name: 'onClickMarker',
        onMessageReceived: (message) {
          Fluttertoast.showToast(msg: message.message);
    });
  }
}