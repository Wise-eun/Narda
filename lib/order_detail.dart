import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';
import 'kakao_map.dart';
import 'menu_bottom.dart';
import 'model/store.dart';
import 'model/orderDetail.dart';

OrderDetail? order;
Duration? duration;

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen(
      {Key? key, required this.orderId, required this.storeId})
      : super(key: key);
  final int orderId;
  final String storeId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();
  bool callOk = false;
  bool clicked = false;
  double from_latitude = 37.588;
  double from_longitude = 26.356;
  double to_latitude = 30;
  double to_longitude = 20;

  addressToPM(String address) async {
    //String address = '경북 경산시 대학로 280';
    print('topm 주소 : $address');
    List<Location> locations = await locationFromAddress(address);
    setState(() {
      to_latitude = locations[0].latitude.toDouble();
      to_longitude = locations[0].longitude.toDouble();
      print('우리집 : $to_latitude, $to_longitude');
      getCurrentLocation();
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
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .then((position) {
          setState(() {
            from_latitude = position.latitude;
            from_longitude = position.longitude;
            print('현재위치 받아옴');
            Size size = new Size(15, 17);
            final marker = NMarker(
                id: '출발지', position: NLatLng(from_latitude, from_longitude));
            marker.setSize(size);
            _mapController.addOverlay(marker);
            final marker2 = NMarker(
                id: '목적지', position: NLatLng(to_latitude, to_longitude));
            //marker2.setIcon(Colors.black as NOverlayImage?);
            marker2.setIconTintColor(Colors.blue);
            marker2.setSize(size);
            _mapController.addOverlay(marker2);

            print('출발지!!! : $from_latitude, $from_longitude');
            print('목적지!!! : $to_latitude, $from_longitude');

            NPathOverlay path = NPathOverlay(id: 'route', coords: [
              NLatLng(from_latitude, from_longitude),
              NLatLng(to_latitude, to_longitude),
            ]);
            path.setColor(Colors.blue);
            _mapController.addOverlay(path);

            NCameraUpdate nCameraUpdate = NCameraUpdate.withParams(
                target: NLatLng((from_latitude + to_latitude) / 2,
                    (from_longitude + to_longitude) / 2),
                zoom: 11);

            if (_mapController != null)
              _mapController.updateCamera(nCameraUpdate);
          });
        });
      } else {
        // 1-3. 권한이 없는 경우
        print("위치 권한이 필요합니다.");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    orderDetail();
    //getCurrentLocation();
    //addressToPM();
    //super.initState();
  }

  orderDetail() async {
    try {
      var response = await http.post(Uri.parse(API.orderDetail), body: {
        'orderId': widget.orderId.toString(),
        'storeId': widget.storeId
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          callOk = true;
          print("오더 디테일 불러오기 성공");
          print(responseBody['userData']);
          order = OrderDetail.fromJson(responseBody['userData']);
          DateTime orderTime = DateTime.parse(order!.orderTime);
          DateTime current = DateTime.now();
          duration = current.difference(orderTime);
          print("duration : $duration");
          //address=order!.deliveryLocation;
          addressToPM(order!.deliveryLocation);
        } else {
          print("오더 디테일 불러오기 실패");
        }
      } else {
        print("오더 디테일 불러오기 실패2");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final mediaQuery = MediaQuery.of(context);
    final mapSize =
        Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    return Scaffold(
        bottomNavigationBar: MenuBottom(userId: (widget.orderId).toString()),
        body: Scrollbar(
            controller: _scrollController,
            isAlwaysShown: true,
            thickness: 10,
            child: ListView(controller: _scrollController, children: [
              Container(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  callOk
                      ? Text(
                          "주문일시 ${order?.orderTime}  경과시간 ${duration?.inMinutes}분")
                      : Text('주문일시 및 경과시간'),
                  callOk ? Text(order!.storeName) : Text('가게 이름'),
                  callOk ? Text(order!.storeLocation) : Text('가게 주소'),
                  clicked
                      ? ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () async {},
                          child: Text('완료'))
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              clicked = true;
                            });
                          },
                          child: Text('픽업'),
                        ),
                  callOk
                      ? Text(order!.deliveryDistance.toString())
                      : Text('Km'),
                  callOk ? Text(order!.deliveryLocation) : Text('고객 주소'),
                  SizedBox(
                      //지도 띄울 부분 (목적지까지의 거리)
                      width: mapSize.width,
                      height: 400,
                      child: NaverMap(
                        options: NaverMapViewOptions(
                          initialCameraPosition: NCameraPosition(
                              target: NLatLng(from_latitude, from_longitude),
                              zoom: 11,
                              bearing: 0,
                              tilt: 0),
                          scrollGesturesEnable: true,
                        ),
                        onMapReady: (controller) {
                          _mapController = controller;
                        },
                        //onCameraChange: onChanged(LatLng(latitude, longitude), CameraChangeReason.location, true),
                      )),
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KakaoMapTest()),
                        );
                      },
                      child: Text('map')),
                  callOk ? Text("배달비 ${order!.deliveryFee}원") : Text('배달비 원'),
                  callOk ? Text("주문 번호 ${order!.orderId}") : Text('주문 번호'),
                  callOk ? Text("결제 수단 ${order!.payment}") : Text('결제 수단'),
                  callOk
                      ? Text("가게 번호 ${order!.storePhoneNum}")
                      : Text('가게 전화번호'),
                  const SizedBox(
                    height: 100,
                  ),
                  Text("주문 정보"),
                  callOk ? Text(order!.orderInfo) : Text('메뉴'),
                  Text("----------------"),
                  callOk
                      ? Text("고객 요청사항 ${order!.deliveryRequest}")
                      : Text('고객 요청사항'),
                  callOk
                      ? Text("라이더 요청사항 ${order!.deliveryRequest}")
                      : Text('라이더 요청사항'),
                  callOk
                      ? Text("고객 번호 ${order!.customerNum}")
                      : Text('고객 전화번호'),
                ],
              ))
            ])));

    // return  Scaffold(
    //   body:Center(
    //     child:  Text(widget.orderId.toString()),
    //   )
    // );
  }
}
