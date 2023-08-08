import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speelow/menu_bottom.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'api/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
Map<String, int> orderLocations = {};
Map<String, List<OrderDetail>> detaillist={};
List<OrderDetail> newOrders = [];
List<OrderDetail> orders = [];
class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
  List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  List<NMarker> markers = [];
  double latitudes = 35.830624;
  double longitudes = 128.7544595;
  double circlelatitude = 37.588;
  double circlelongitude = 26.356;
  late Color overlayColor;
  bool attendance= false;
  bool isOrderlist = false;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  StreamSubscription? _subscription;
  BluetoothConnection? connection;
  late ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();
  int state = 0;
  TextStyle feeTextStyle = TextStyle(color: Colors.white);
  TextStyle distanceTextStyle = TextStyle(color: Colors.black);
  TextStyle timeTextStyle = TextStyle(color: Colors.black);

  Color feeColor = Color(0xff3478F6);
  Color distanceColor = Colors.white;
  Color timeColor = Colors.white;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  static late Timer _refreshPositionTimer;
  var _refreshPositionTime = 0;
  var _isRefreshRunning = false;

  bool isDisconnecting = false;
  void dispose() {
    _refreshPositionTimer?.cancel();
    super.dispose();
    panelController.dispose();
  }

  void showToastMessage(String msg) {
    final fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color:Color(0xff3478F6),
        ),
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      child: Text(msg,style: TextStyle(fontSize: 18, color: Color(0xff3478F6))),
    );

    fToast.showToast(
      gravity: ToastGravity.CENTER,
      child: toast,
      toastDuration: const Duration(seconds: 2),
    );

  }

  void StopRefresh()
  {
    _refreshPositionTimer?.cancel();
  }

  void StartRefresh()
  {
       _refreshPositionTimer = Timer.periodic(Duration(seconds:5), (timer) {
         RefreshPosition();
       });
  }

  RefreshPosition() async {
    print("현재 위치 서버에 전송");

    try {
      var response = await http.post(Uri.parse(API.refreshPosition), body: {
        'userId': widget.userId, //오른쪽에 validate 확인할 id 입력
        'latitude': latitudes.toString(),
        'longitude': longitudes.toString()
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
        } else {
          print("위치 새로고침 실패");
        }
      }
    } catch (e) {
      showToastMessage("위치 새로고침 실패");
      print(e.toString());
    }
  }




  newOrderList() async {
    try {
      var response = await http.post(
        Uri.parse(API.newOrderList),
      );
      if (response.statusCode == 200) {
        //orderLocations= [];
        newOrders.clear();
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
            print("orderListLocation 출력 $orderLocation");

            if(detaillist.containsKey(orderLocation) == false){
              detaillist.addEntries({orderLocation: [OrderDetail.fromJson(responseList[i])]}.entries);
            }
            else{
              detaillist[orderLocation]?.add(OrderDetail.fromJson(responseList[i]));
            }

            if (orderLocations.containsKey(orderLocation) == false) {
              orderLocations.addEntries({orderLocation: 1}.entries);
            } //여기서 바로 스플릿해서 지도 넣는데 맵으로 넣자자자자자ㅏ잦
            else {
              orderLocations[orderLocation] =
                  orderLocations[orderLocation]! + 1;
            }
            print(orderLocations.entries);
          }
        } else {
          print("오더 리스트 불러오기 실패");
        }
        setState(() {
          circleCluster();
        });
        return orderLocations;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  addressToPM(String address) async {
    List<Location> locations = await locationFromAddress(address);
    circlelatitude = locations[0].latitude.toDouble();
    circlelongitude = locations[0].longitude.toDouble();
    print(address);
    print('좌표 :$circlelatitude, $circlelongitude');
  }
  void _sendMessage(String addr) async {


    if (addr.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(addr)));
        await connection!.output.allSent;


        Future.delayed(Duration(milliseconds: 333)).then((_) {
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
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
            latitudes = position.latitude;
            longitudes = position.longitude;
            _sendMessage("o"+longitudes.toString()+","+latitudes.toString());

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
        print("위치 권한이 필요합니다.");
      }
    } catch (e) {
      print(e);
    }
  }

  circleCluster() async {
    //print(orderLocations.length);
    print('circlecluster');
    print(orderLocations["경상북도 경산시 대동"]);
    for (MapEntry element in orderLocations.entries) {
      //addressToPM(element.key);
      List<Location> locations = await locationFromAddress(element.key);
      circlelatitude = locations[0].latitude.toDouble();
      circlelongitude = locations[0].longitude.toDouble();
      print("key ${element.key}");
      int count = element.value;
      print(element.value);
      print("엘리펀트");


      final iconImage = await NOverlayImage.fromWidget(
          widget: Icon(Icons.circle, color: element.value<6?overlayColor = Color(0xB3948ED2):
          element.value<16?overlayColor = Color(0xB35D50F3):
          overlayColor = Color(0xB33022D6),
            size: element.value<6?100:element.value<16?250:300,),
          size: Size(element.value<6?100:element.value<16?250:300, element.value<6?200:element.value<16?250:300,),
          context: context);

      final marker = NMarker(
          captionAligns : const [NAlign.center],
          caption: NOverlayCaption(text: count.toString(), textSize: 30, color: Colors.white,
              haloColor: overlayColor),
          id: element.key,
          position: NLatLng(circlelatitude, circlelongitude),
          icon: iconImage
      );
      _mapController.addOverlay(marker);
      print(overlayColor);
      marker.setOnTapListener((overlay) {
        orders.clear();
        for(OrderDetail value in detaillist[(element.key)]!){
          orders.add(value);
          print("entry 순환 : ${value.storeName}");
        }
        sorting("deliveryFee");
        setState(() {
          isOrderlist = true;
        });
        panelController.expand();
      });
      //_mapController.addOverlay(overlay);
      print("오버레이 추가 완");
    }
  }

  sorting(String sort) async {

    if(sort == "deliveryFee"){
      orders.sort((a,b)=>b.deliveryFee.compareTo(a.deliveryFee));
      //배달비 높은순
    }
    else if(sort == "deliveryDistance"){
      orders.sort((a,b)=>a.deliveryDistance.compareTo(b.deliveryDistance));
      //거리 가까운순
    }
    else {
      orders.sort((a,b)=>(DateTime.parse(b.orderTime).difference(DateTime.now()).inMinutes+b.predictTime).compareTo(DateTime.parse(a.orderTime).difference(DateTime.now()).inMinutes+a.predictTime));
      //남은 시간순
    }
    setState(() {});

  }

  void onMapCreated(NaverMapController controller) {
    if (mapControllerCompleter.isCompleted)
      mapControllerCompleter = Completer();
    mapControllerCompleter.complete(controller);
  }

  String changeAppBarText()
  {
    if(isOrderlist==true)
    {
      return "오더리스트";
    }
    else
    {
      return "홈";
    }
  }

  setOrderState(orderId) async{
    try{
      var response = await http.post(
          Uri.parse(API.setOrderState),
          body:{
            'orderId' : orderId.toString(),
            'newState' : '2',
            'riderId' : widget.userId.toString(),
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("Order update 완료");
          if(order?.state == 1)
          {
            setState(() {
              print("배차 버튼 누르셨습니다.");
              order?.state=2;
            });
          }
        }
        else{
          print("Order update 실패");
        }
      }
    }catch(e){print(e.toString());}
  }


  void UpdatePreferences() async
  {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('attendance',attendance);

  }
  void getPreferences() async
  {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    try{
      attendance = pref.getBool('attendance')!;
    }catch(e){}
  }



  @override
  void initState() {
   /* BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });*/
    getPreferences();
    BluetoothConnection.toAddress("D8:3A:DD:18:63:E2").then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
print("===========================================================================");
      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });



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

    //addressToPM();
    newOrders.clear();
    detaillist.clear();
    getCurrentLocation();

    orderLocations.clear();
    orders.clear();
    print('clear');
    newOrderList();

    print("똥");
    print(orderLocations.length);
    sorting("deliveryFee");

    super.initState();
  }


  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }


  List<String> list = ["배달비 높은 순", "거리순", "경과시간순"];
  String? dropdownValue = "배달비 높은 순";
  late FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  final _devices = <DiscoveredDevice>[];
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width, mediaQuery.size.height-47 );
    final physicalSize =
    Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    //print("physicalSize: $physicalSize");
    //print('build : $latitudes, $longitudes');

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
                                  style: TextStyle(color: Color(0xff797979), fontSize: 16),
                                ):Text(
                                  "${timestamp1.abs()}분 초과",
                                  style: TextStyle(color: Color(0xffFF4E17), fontSize: 16),
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
                      percent: percent<0?1:percent,
                      barRadius: const Radius.circular(16),
                      progressColor: percent<0?Color(0xff686A70):percent<0.33?Color(0xffFF4E17):percent<0.66?Color(0xffFFBB0B):Color(0xff65C466),
                      backgroundColor: Color(0xffE3E5EA),
                    ),
                  ])),
          onTap: () {
            //toast띄우기 그리고 바로 배차
            addressToPM(orders[index].storeLocation);
            _sendMessage("d"+circlelongitude.toString()+","+ circlelatitude.toString());

            setOrderState(orders[index].orderId);
            showToastMessage("배차가 완료되었습니다.");
            setState(() {
              orders.removeAt(index);
            });

          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar:  AppBar(
          shape: Border(
              bottom: BorderSide(
                color: Color(0xfff1f2f3),
                width: 2,
              )),
          title: Text(changeAppBarText(),
              style: TextStyle(color: Colors.black, fontSize: 18)),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: const Color(0xFF343945),
        bottomNavigationBar: MenuBottom(
          userId: widget.userId,
          tabItem: TabItem.home,
        ),
        //floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

        body:Stack(
          children: <Widget>[
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: Center(
                  child: Column(
                    children: [

                      SizedBox(
                          width: mapSize.width,
                          height: (mapSize.height - 158 ), //하단바때문에 오버픽셀 부분 뺌
                          // color: Colors.greenAccent,
                          child: NaverMap(
                            options: NaverMapViewOptions(
                                maxZoom:13,
                                minZoom: 13,
                                locationButtonEnable: true,
                                initialCameraPosition: NCameraPosition(
                                    target: NLatLng(latitudes, longitudes),
                                    zoom: 10,
                                    bearing: 0,
                                    tilt: 0)
                            ),
                            onMapReady: (controller) {
                              _mapController = controller;
                              //circleCluster();
                            },
                          )
                      ),
                    ],
                  )),
            ),
            Column(
              children: [
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    FlutterSwitch(value: attendance,
                      onToggle: (bool value) {
                        setState(() {
                          attendance = value;
                          if(value==true){

                                StartRefresh();
                                UpdatePreferences();
                            Fluttertoast.showToast(
                                msg: "출근하였습니다.",
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
                          else{
                            _streamSubscription?.cancel();
                            StopRefresh();
                            UpdatePreferences();
                            Fluttertoast.showToast(
                                msg: "퇴근하였습니다.",
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
                        });

                      },height: 40,
                      width: 85,
                      toggleSize: 25,
                      valueFontSize: 20,
                      showOnOff: true,
                      activeText: "출근",
                      activeTextFontWeight: FontWeight.w400,
                      activeColor: Colors.white,
                      activeToggleColor: Color(0xff3478f6),
                      activeTextColor: Color(0xff3478f6),
                      inactiveText: "퇴근",
                      inactiveTextFontWeight: FontWeight.w400,
                      inactiveColor: Color(0xFF666666),
                      inactiveToggleColor: Colors.white,
                      inactiveTextColor: Colors.white,
                      switchBorder: Border.all(
                          color: Color.fromRGBO(52, 120, 246, 1)
                      ),


                    ),
                    SizedBox(width: 20,)
                  ],
                )

              ],
            ),
            SlidingUpPanelWidget(
                controlHeight: 0.0,
                anchor: 0.4,
                panelController: panelController,
                onTap: () {},
                enableOnTap: true,
                child: Scaffold(
                    resizeToAvoidBottomInset:false,
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: FloatingActionButton.extended(
                      backgroundColor: Colors.white,
                      elevation: 12,
                      onPressed: (){
                        setState(() {
                          isOrderlist = false;
                          newOrders.clear();
                          detaillist.clear();
                          orderLocations.clear();
                          orders.clear();
                          newOrderList();
                        });
                        panelController.collapse();},
                      label: Container(child:Row(
                          children:[
                            Icon(Icons.map_outlined, color: Color(0xff3478F6)),
                            Text(" 지도보기", style: TextStyle(color: Color(0xff3478F6)),)])),),
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
                                        sorting("deliveryFee");
                                        feeTextStyle = TextStyle(color: Colors.white);
                                        feeColor = Color(0xff3478F6);
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
                                      sorting("deliveryDistance");

                                      feeTextStyle = TextStyle(color: Colors.black);
                                      feeColor = Colors.white;
                                      distanceTextStyle =
                                          TextStyle(color: Colors.white);
                                      distanceColor = Color(0xff3478F6);
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
                                        sorting("orderTime");

                                        feeTextStyle = TextStyle(color: Colors.black);
                                        feeColor = Colors.white;
                                        distanceTextStyle =
                                            TextStyle(color: Colors.black);
                                        distanceColor = Colors.white;
                                        timeTextStyle =
                                            TextStyle(color: Colors.white);
                                        timeColor = Color(0xff3478F6);
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
                    ))
            ),

          ],
        ));
  }
}