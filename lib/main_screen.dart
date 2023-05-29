import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:speelow/menu_bottom.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'api/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import 'model/orderDetail.dart';
import 'order_detail.dart';

Map<String, int> orderLocations = {};
List<OrderDetail> orders = [];

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();

  List<NMarker> markers = [];
  double latitudes = 37.588;
  double longitudes = 26.356;
  double circlelatitude = 37.588;
  double circlelongitude = 26.356;

  bool _serviceEnabled = false;

  // late PermissionStatus _permissionGranted;

  late ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();
  int state = 0;
  TextStyle feeTextStyle = TextStyle(color: Colors.white);
  TextStyle distanceTextStyle = TextStyle(color: Colors.black);
  TextStyle timeTextStyle = TextStyle(color: Colors.black);

  Color feeColor = Colors.blue;
  Color distanceColor = Colors.white;
  Color timeColor = Colors.white;

  void dispose() {
    super.dispose();
    panelController.dispose();
  }

  newOrderList() async {
    try {
      var response = await http.post(
        Uri.parse(API.newOrderList),
      );
      if (response.statusCode == 200) {
        //orderLocations= [];
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("오더 리스트 불러오기 성공");
          List<dynamic> responseList = responseBody['userData'];
          for (int i = 0; i < responseList.length; i++) {
            //print(OrderDetail.fromJson(responseList[i]));
            String orderLocation =
                (responseList[i]['storeLocation']).toString();
            final locationSplitList = orderLocation.split(' ');
            orderLocation = locationSplitList[0] +
                " " +
                locationSplitList[1] +
                " " +
                locationSplitList[2];
            print(orderLocation);
            if (orderLocations.containsKey(orderLocation) == false) {
              print("어이");
              orderLocations.addEntries({orderLocation: 1}.entries);
            } //여기서 바로 스플릿해서 지도 넣는데 맵으로 넣자자자자자ㅏ잦
            else {
              print("짱나");
              orderLocations[orderLocation] =
                  orderLocations[orderLocation]! + 1;
            }
            print(orderLocations.entries);
          }
        } else {
          print("오더 리스트 불러오기 실패");
        }
        setState(() {});
        return orderLocations;
      }
    } catch (e) {
      print(e.toString());
    }
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
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .then((position) {
          setState(() {
            print("latitude : " +
                latitudes.toString() +
                ", " +
                "longitude : " +
                longitudes.toString());
            latitudes = position.latitude;
            longitudes = position.longitude;

            NLatLng target = NLatLng(latitudes, longitudes);
            NCameraUpdate nCameraUpdate = NCameraUpdate.withParams(
              target: NLatLng(latitudes, longitudes),
              zoom: 13,
            );
            //.scrollAndZoomTo(target, 10)
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

  circleCluster() async {
    print('나 여기똥');
    //print(orderLocations.length);
    for (MapEntry element in orderLocations.entries) {
      //addressToPM(element.key);
      List<Location> locations = await locationFromAddress(element.key);
      circlelatitude = locations[0].latitude.toDouble();
      circlelongitude = locations[0].longitude.toDouble();
      print(element.key);
      print('좌표 :$circlelatitude, $circlelongitude');
      int count = element.value;
      final NCircleOverlay overlay = await NCircleOverlay(
        id: element.key, center: NLatLng(circlelatitude, circlelongitude),
        radius: 380, //element.value<6?400:element.value<16?500:800,
        color: Color(0xB35a4dfd),
      );
      //overlay.setOnTapListener((overlay) => )
      overlay.setOnTapListener((overlay) {
        panelController.expand();
      });
      _mapController.addOverlay(overlay);
      print("오버레이 추가 완");
    }
  }

  orderList(String sort) async {
    try {
      var response = await http.post(Uri.parse(API.orderList), body: {
        'sort': sort,
      });
      if (response.statusCode == 200) {
        orders = [];
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("$sort 오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for (int i = 0; i < responseList.length; i++) {
            print(OrderDetail.fromJson(responseList[i]));
            orders.add(OrderDetail.fromJson(responseList[i]));
          }
        } else {
          print("오더 리스트 불러오기 실패");
        }
        setState(() {});
        return orders;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void onMapCreated(NaverMapController controller) {
    if (mapControllerCompleter.isCompleted)
      mapControllerCompleter = Completer();
    mapControllerCompleter.complete(controller);
  }

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });

    orderList("deliveryFee");

    //addressToPM();
    getCurrentLocation();
    newOrderList();

    super.initState();
  }

  List<String> list = ["배달비 높은 순", "거리순", "경과시간순"];
  String? dropdownValue = "배달비 높은 순";

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width, mediaQuery.size.height - 50);
    final physicalSize =
        Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");
    print('build : $latitudes, $longitudes');

    var _listView = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        String payment, elapsedTime;
        String storeDong = "";
        String deliveryDong = "";

        final storeLocationList = orders[index].storeLocation.split(' ');
        storeDong = storeLocationList[storeLocationList.length - 2];

        final deliveryLocationList = orders[index].deliveryLocation.split(' ');
        deliveryDong = deliveryLocationList[deliveryLocationList.length - 2];

        DateTime orderTime = DateTime.parse(orders[index].orderTime);

        DateTime current = DateTime.now();
        Duration duration = orderTime.difference(current);

        int timestamp1 = duration.inMinutes + orders[index].predictTime;
        int timestamp2 = orders[index].predictTime;

        double percent = timestamp1/timestamp2;

        return GestureDetector(
          child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Color(0xfff1f2f3),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    "${storeDong} > ${deliveryDong}  |  ${orders[index].deliveryDistance.toStringAsFixed(2)}km",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                )),
                            Text(
                              "${orders[index].deliveryFee}원",
                              style: TextStyle(fontSize: 20),
                            ),

                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${orders[index].storeName}",
                              style: TextStyle(fontSize: 20),
                            ),
                            timestamp1>0?Text(
                              "${timestamp1}분",
                              style: TextStyle(color: Colors.grey),
                            ):Text(
                              "+${timestamp1.abs()}분",
                              style: TextStyle(color: Colors.red),
                            )

                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ]
                  ),
                ),
                    LinearPercentIndicator(
                      lineHeight: 12,
                      percent: percent<0?0:percent,
                      barRadius: const Radius.circular(16),
                      progressColor: percent<0.33?Colors.red:percent<0.66?Colors.yellow:Colors.green,
                      backgroundColor: Colors.grey[300],
                    ),
              ])),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(
                        orderId: orders[index].orderId,
                        storeId: orders[index].storeId,
                    userId: widget.userId,
                      )),
            );
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );

    return Scaffold(
        backgroundColor: const Color(0xFF343945),
        bottomNavigationBar: MenuBottom(
          userId: widget.userId,
          tabItem: TabItem.home,
        ),
        body: Stack(
          children: <Widget>[
            Scaffold(
              body: Center(
                  child: Column(
                children: [
                  /*
                  Text("Lat: $latitude, Lng: $longitude"),
                  TextButton(
                    child: Text("Locate Me"),
                    onPressed: () => getCurrentLocation(),
                  )*/
                  SizedBox(
                      width: mapSize.width,
                      height: (mapSize.height - 18), //하단바때문에 오버픽셀 부분 뺌
                      // color: Colors.greenAccent,
                      child: NaverMap(
                        options: NaverMapViewOptions(
                            initialCameraPosition: NCameraPosition(
                                target: NLatLng(latitudes, longitudes),
                                zoom: 10,
                                bearing: 0,
                                tilt: 0)),
                        onMapReady: (controller) {
                          _mapController = controller;
                          circleCluster();
                        },

                        //onCameraChange: onChanged(LatLng(latitude, longitude), CameraChangeReason.location, true),
                      )),
                ],
              )),
            ),
            SlidingUpPanelWidget(
              controlHeight: 0.0,
              anchor: 0.4,
              panelController: panelController,
              onTap: () {},
              enableOnTap: true,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(50.0),
                  child: AppBar(
                    shape: Border(
                        bottom: BorderSide(
                          color: Color(0xfff1f2f3),
                          width: 2,
                        )),
                    title: Text('오더리스트',
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                floatingActionButton: FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  elevation: 12,
                    onPressed: (){panelController.collapse();},
                    label: Container(child:Row(
                        children:[
                          Icon(Icons.map_outlined, color: Colors.blue,),
                          Text(" 지도보기", style: TextStyle(color: Colors.blue),)])),),
                body:Container(
                //margin: EdgeInsets.symmetric(horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 5,),
                    Container(
                      height: 35,
                      //color: Color(0xfff1f2f3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              height: 40,
                              width: 100,
                              child: FilledButton(
                                onPressed: () {
                                  state = 0;
                                  orderList("deliveryFee");
                                  feeTextStyle = TextStyle(color: Colors.white);
                                  feeColor = Colors.blue;
                                  distanceTextStyle =
                                      TextStyle(color: Colors.black);
                                  distanceColor = Colors.white;
                                  timeTextStyle =
                                      TextStyle(color: Colors.black);
                                  timeColor = Colors.white;
                                },
                                child: Text(
                                  "배달비 높은",
                                  style: feeTextStyle,
                                ),
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: BorderSide(width:0.3, color: Colors.grey)
                                  ),
                                    backgroundColor: feeColor),
                              )),
                          SizedBox(
                            height: 40,
                            width: 100,

                            child: FilledButton(
                              onPressed: () {
                                state = 1;
                                orderList("deliveryDistance");

                                feeTextStyle = TextStyle(color: Colors.black);
                                feeColor = Colors.white;
                                distanceTextStyle =
                                    TextStyle(color: Colors.white);
                                distanceColor = Colors.blue;
                                timeTextStyle = TextStyle(color: Colors.black);
                                timeColor = Colors.white;
                              },
                              child: Text(
                                "가까운",
                                style: distanceTextStyle,
                              ),
                              style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: BorderSide(width:0.3, color: Colors.grey)
                                  ),
                                  backgroundColor: distanceColor),
                            ),
                          ),
                          SizedBox(
                              height: 40,
                              width: 100,

                              child: FilledButton(
                                onPressed: () {
                                  state = 2;
                                  orderList("orderTime");

                                  feeTextStyle = TextStyle(color: Colors.black);
                                  feeColor = Colors.white;
                                  distanceTextStyle =
                                      TextStyle(color: Colors.black);
                                  distanceColor = Colors.white;
                                  timeTextStyle =
                                      TextStyle(color: Colors.white);
                                  timeColor = Colors.blue;
                                },
                                child: Text(
                                  "남은 시간",
                                  style: timeTextStyle,
                                ),
                                style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        side: BorderSide(width:0.3, color: Colors.grey)
                                    ),
                                    backgroundColor: timeColor),
                              )),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: _listView,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),)
            ),
          ],
        ));
  }
}
