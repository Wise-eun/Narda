import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speelow/HorizontalDashedDivider.dart';
import 'package:http/http.dart' as http;
import 'package:speelow/calendar_screen.dart';
import 'package:speelow/main_screen.dart';
import 'after_order_list.dart';
import 'api/api.dart';
import 'model/getstore.dart';
import 'model/orderDetail.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_line/dotted_line.dart';

OrderDetail? order;
Duration? duration;
getstore? store;

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen(
      {Key? key, required this.orderId, required this.storeId, required this.userId})
      : super(key: key);
  final int orderId;
  final String storeId;
  final String userId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();
  bool callOk = false;
  bool clicked = false;
  bool storeOk = false;
  double from_latitude = 35.830624;
  double from_longitude = 128.7544595;
  double to_latitude = 30;
  double to_longitude = 20;
  bool pickUped = false;

  addressToPM(String address, String address2) async {
    print('topm 주소 : $address');
    List<geo.Location> locations_Destination = await geo.locationFromAddress(address);
    to_latitude = locations_Destination[0].latitude.toDouble();
    to_longitude = locations_Destination[0].longitude.toDouble();
    print('$to_latitude, $to_longitude');
    //address2='경상북도 경산시 삼풍동 511-4';
    print('frompm 주소 : $address2');
    List<geo.Location> locations_start = await geo.locationFromAddress(address2);
    from_latitude = locations_start[0].latitude.toDouble();
    from_longitude = locations_start[0].longitude.toDouble();
    print('$from_latitude, $from_longitude');

    setState(() {
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
          setState(() async {
            //from_latitude = position.latitude;
            //from_longitude = position.longitude;
            print('현재위치 받아옴');
            print('$from_latitude, $from_longitude');
            Size size = new Size(20, 27);

            final marker = NMarker(
                id: '출발지', position: NLatLng(from_latitude, from_longitude));
            marker.setIcon(const NOverlayImage.fromAssetImage('asset/images/from.png'));
            marker.setSize(size);
            _mapController.addOverlay(marker);

            final marker2 = NMarker(
                id: '목적지', position: NLatLng(to_latitude, to_longitude));
            marker2.setIcon(const NOverlayImage.fromAssetImage('asset/images/to.png'));
            marker2.setSize(size);
            _mapController.addOverlay(marker2);

            NPathOverlay path = NPathOverlay(
              id: 'route', coords: [
              NLatLng(from_latitude, from_longitude),
              NLatLng(to_latitude, to_longitude)],
              outlineWidth: 0,
            );
            path.setPatternImage(
                NOverlayImage.fromAssetImage('asset/images/route.png')
            );
            path.setPatternInterval(18);
            path.setWidth(13);
            path.setColor(Color(0xFF4848C7));
            _mapController.addOverlay(path);

            double centerlat = (from_latitude + to_latitude);
            double centerlon = (from_longitude + to_longitude);
            print('거리 : ${centerlon*centerlon + centerlat*centerlat}');
            double distance = centerlon*centerlon + centerlat*centerlat;
            double zoomsize = distance>71480?10:(distance<71440?10:12);

            NCameraUpdate nCameraUpdate = NCameraUpdate.withParams(
              target: NLatLng(centerlat/2, centerlon/2),
              zoom: zoomsize,
            );

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
    getStore();
    orderDetail();
    //getCurrentLocation();
    //addressToPM();
    super.initState();
  }

  String ReturnPhoneNum(String num)
  {
    String phoneNum = num.substring(0,3);
    if(num.length==10)
    {
      phoneNum+="-";
      phoneNum+=num.substring(3,6);
      phoneNum+="-";
      phoneNum+=num.substring(6,10);

    }
    else
    {
      phoneNum+="-";
      phoneNum+=num.substring(3,7);
      phoneNum+="-";
      phoneNum+=num.substring(7,11);
    }
    return phoneNum;
  }



  String ReturnPaymentString()
  {
    switch(order!.payment)
    {
      case 0:
        return "선결제";
      case 1:
        return "카드결제";
      case 2:
        return "현금결제";
    }
    return "";
  }

  String ReturnStatusString()
  {
    switch(order!.state)
    {
      case 2:
        return "픽업 전";
      case 3:
        return "배달 중";
    }
    return "배달 완료";
  }

  getStore() async {
    try {
      var response = await http.post(Uri.parse(API.getStore), body: {
        'storeId': widget.storeId.toString(),
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          callOk = true;
          print("가게정보");
          print(responseBody['userData']);
          store = getstore.fromJson(responseBody['userData']);
          print(store?.storeLocation);
        } else {
          print("오더 디테일 불러오기 실패");
        }
      } else {
        print("오더 디테일 불러오기 실패2");
      }
      setState(() {
      });
    } catch (e) {
      print(e.toString());
    }
  }

  orderDetail() async {
    try {
      var response = await http.post(Uri.parse(API.orderDetail), body: {
        'orderId': widget.orderId.toString(),
        'storeId': widget.storeId,
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
          String address = order!.deliveryLocation;
          String address2=order!.storeLocation;
          print('address : $address');
          addressToPM(address,address2 );
          print('addresstopm passing');
        } else {
          print("오더 디테일 불러오기 실패");
        }
      } else {
        print("오더 디테일 불러오기 실패2");
      }
      setState(() {
      });
    } catch (e) {
      print(e.toString());
    }
  }

  String ReturnStatusButtonString()
  {
    switch(order!.state)
    {
      case 1:
        return "배차하기";
      case 2:
        return "픽업하기";
      case 3:
        return "완료하기";
    }
    return "";
  }

  setOrderState(orderId,newState) async{
    try{
      var response = await http.post(
          Uri.parse(API.setOrderState),
          body:{
            'orderId' : orderId.toString(),
            'newState' : (newState+1).toString(),
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
          else if(order?.state == 2) //픽업전인 상태에서, 픽업 버튼을 눌렀을 때
              {
            Fluttertoast.showToast(
                msg: "픽업 완료되었습니다.",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0
            );
            setState(() {
              print("픽업 버튼 누르셨습니다.");
              order?.pickupTime = DateTime.now().toString();
              order?.state=3;
            });
          }
          else if(order?.state == 3) //픽업이 이미 된 경우, 완료 버튼을 눌렀을 때
              {
            Fluttertoast.showToast(
                msg: "배달 완료되었습니다.",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  AfterOrderListScreen(userId: widget.userId)),
            );
            print("완료되었습니다.");
          }

        }
        else{
          print("Order update 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final mediaQuery = MediaQuery.of(context);
    final mapSize =
    Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    var valueFormat = NumberFormat('###,###,###,###');
    DateTime orderTime  = DateTime.now();
    Duration duration;
    int timestamp1=0, timestamp2= 0;
    double percent  = 0.0;


    try{
      orderTime =  DateTime.parse(order!.orderTime);
      duration = orderTime.difference(DateTime.now());

      timestamp1 = duration.inMinutes + order!.predictTime;
      timestamp2 = order!.predictTime;

      percent = timestamp1/timestamp2;
    }
    catch(e)
    {
      print(e);
    }


    try {
      if (order!.deliveryLocationDetail != "") {
        print(order!.deliveryLocationDetail);
        storeOk = true;
        print('쌍따옴표 아님');
      }
    }
    catch(e)
    {

    }
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_left,
              color: Color(0xffB7C1CF),
              size: 30,), onPressed: () {
            if(order?.state == 1 )
            {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MainScreen(userId: widget.userId)),
              );

            }
            else
            {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AfterOrderListScreen(userId: widget.userId)),
              );
            }

          },
          ),
          shape: Border(
              bottom: BorderSide(
                color: Color(0xfff1f2f3),
                width: 2,
              )),
          title: Text("주문내역",
              style: TextStyle(color: Colors.black, fontSize: 18)),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: callOk?Column(
          children: [
            callOk?Expanded(child: Scrollbar(
              controller: _scrollController,
              thickness: 10,
              child:

              ListView(controller: _scrollController, children: [
                Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        callOk?
                        Container(
                          margin: EdgeInsets.fromLTRB(20,0,20,0),
                          color: Colors.white,
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Text("주문일시 ${order?.orderTime.substring(0,16).replaceAll('-', '.')} ",
                                style: TextStyle( color: Color(0xffB7B7B7)),
                                textAlign: TextAlign.left,),
                              order?.pickupTime!=null? Text("픽업시간 ${order?.pickupTime?.substring(0,16).replaceAll('-', '.')}",
                                  style: TextStyle( color: Color(0xffB7B7B7)),
                                  textAlign: TextAlign.left)
                                  :Text("픽업시간 ",
                                textAlign: TextAlign.left,
                                style: TextStyle( color: Color(0xffB7B7B7)),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              order!.state!=4?Container(
                                color: Colors.white,
                                width: mediaQuery.size.width-30, //위의 패딩값 뺌
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(ReturnStatusString(),style: TextStyle(fontSize: 22, color: Color(0xffFF4E17)),),
                                      timestamp1>0?Text(
                                        "${timestamp1}분",
                                        style: TextStyle(fontSize: 18,color: Color(0xff2A274E)),
                                      ):Text(
                                        "${timestamp1.abs()}분 초과",
                                        style: TextStyle(fontSize: 18,color: Color(0xffFF4E17)),
                                      ),
                                    ]
                                ),
                              ):Text(""),
                              order!.state!=4?SizedBox(
                                height: 5,
                              ):SizedBox(height: 0,),
                              order!.state!=4?LinearPercentIndicator(
                                lineHeight: 12,
                                percent: percent<0?1:percent,
                                barRadius: const Radius.circular(16),
                                progressColor: percent<0?Color(0xff686A70):percent<0.33?Color(0xffFF4E17):percent<0.66?Color(0xffFFBB0B):Color(0xff65C466),
                                backgroundColor: Color(0xffF1F2F3),
                              ):SizedBox(height: 0,),

                              order!.state!=4?SizedBox(
                                height: 30,
                              ):SizedBox(height: 0,),

                              Row(
                                children: [
                                  Container(
                                      color: Colors.white,
                                      child: const Column(
                                          children:<Widget>[
                                            Icon(Icons.room, size: 16),
                                            //Icon(Icons.more_vert, size: 35),
                                            DottedLine(
                                              direction: Axis.vertical,
                                              lineLength: 60,
                                              dashLength: 2,
                                            ),
                                            Icon(Icons.room, size: 16),
                                          ]
                                      )
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:  CrossAxisAlignment.start,
                                        children: [
                                          callOk ? Text(order!.storeName,
                                            style:TextStyle(fontSize: 20 ) ,) : Text('가게 이름'),
                                          callOk ? Text('${order?.storeLocation}',
                                            style:TextStyle(fontSize: 16 ) ,) : Text('가게 주소'),

                                          SizedBox(
                                            height: 10,
                                          ),
                                          callOk ? Text('${order?.deliveryDistance}km',
                                              style:TextStyle(fontSize: 15, color: Colors.grey[600])) : Text('거리'),

                                          SizedBox(
                                            height: 10,
                                          ),
                                          callOk ? Text(order!.deliveryLocation
                                            ,style: TextStyle(fontSize: 20),) : Text('고객 주소'),
                                          storeOk ? Text(order!.deliveryLocationDetail,
                                            style:TextStyle(fontSize: 16 ) ,) : Text('고객 상세 주소'),
                                        ],
                                      )
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                //지도 띄울 부분 (목적지까지의 거리)
                                  width: mapSize.width,
                                  height: 300,
                                  child: NaverMap(
                                    options: NaverMapViewOptions(
                                      initialCameraPosition: NCameraPosition(
                                          target: NLatLng(from_latitude, from_longitude),
                                          zoom: 12,
                                          bearing: 0,
                                          tilt: 0),
                                      scrollGesturesEnable: true,
                                    ),
                                    onMapReady: (controller) {
                                      _mapController = controller;
                                    },
                                    //onCameraChange: onChanged(LatLng(latitude, longitude), CameraChangeReason.location, true),
                                  )),
                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Text("주문 번호    ",
                                    style: TextStyle(fontSize: 18),),
                                  Text(order!.orderInfo.hashCode.toRadixString(16).toUpperCase(),
                                      style: TextStyle(fontSize: 18))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text("결제 수단    ",
                                    style: TextStyle(fontSize: 18),),
                                  Text(ReturnPaymentString(),
                                      style: TextStyle(fontSize: 18))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text("가게 번호    ",
                                    style: TextStyle(fontSize: 18),),
                                  Text(ReturnPhoneNum(order!.storePhoneNum),
                                      style: TextStyle(fontSize: 18))
                                ],
                              ),

                            ],
                          ),
                        )
                            : Text('배달상태'),


                        SizedBox(height: 20,),
                        Container(
                          color: Color(0xffF1F2F3),
                          height: 20,
                        ),
                        SizedBox(height: 20,),

                        callOk ?
                        Container(
                          margin: EdgeInsets.fromLTRB(20,0,20,0),
                          color: Colors.white,
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("고객 번호",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700 ),),
                              SizedBox(height: 5,),
                              Text(ReturnPhoneNum(order!.customerNum),style: TextStyle(fontSize: 18),),
                              SizedBox(height: 25,),
                              Text("고객 요청사항",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700),),
                              SizedBox(height: 5,),
                              Text("리뷰이벤트 콜라 부탁드려요 :)\n수저,포크(x)",style: TextStyle(fontSize: 18),),
                              SizedBox(height: 25,),
                              Text("라이더 요청사항",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700),),
                              SizedBox(height: 5,),
                              Text(order!.deliveryRequest,style: TextStyle(fontSize: 18),),
                            ],
                          )   ,
                        ):Text("요청사항")
                        ,
                        SizedBox(height: 20,),
                        Container(
                          color: Color(0xffF1F2F3),
                          height: 20,
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        SizedBox(width: 30,),
                        callOk ?
                        Container(
                            margin: EdgeInsets.fromLTRB(20,0,20,0),
                            color: Colors.white,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("주문 정보",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700)),
                                SizedBox(height: 10,),
                                Text(order!.orderInfo,style: TextStyle(fontSize: 18)),
                                SizedBox(height: 10,),
                                Container(
                                  color: Colors.white,
                                  child: Divider(color: Color(0xffB7C1CF),thickness: 1.0,),),
                                SizedBox(height: 5,),
                                Container(
                                    color: Colors.white,
                                    child:
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("메뉴 금액",
                                            style: TextStyle(fontSize: 18)
                                            ,  textAlign: TextAlign.start),

                                        Text(valueFormat.format(order!.orderValue) + "원",
                                            style: TextStyle(fontSize: 18),
                                            textAlign: TextAlign.end),
                                      ],

                                    )),
                                SizedBox(height: 5,),
                                Container(
                                  color: Colors.white,
                                  child: Divider(color: Color(0xffB7C1CF),thickness: 1.0,),),
                                SizedBox(height:10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text("기본 배달료",style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.start),

                                    Text("1,000원",
                                        style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.end)
                                  ],
                                ),
                                SizedBox(height:5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text("거리 할증",style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.start),

                                    Text(valueFormat.format(order!.deliveryFee - 1000) + "원",
                                        style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.end)
                                  ],
                                ),
                                SizedBox(height:10),
                                HorizontalDashedDivider(),
                                SizedBox(height:10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text("총 배달료",style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.start),

                                    Text(valueFormat.format(order?.deliveryFee) + "원",
                                        style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.end)
                                  ],
                                ),
                                SizedBox(height: 20,),
                              ],
                            )
                        ): Text("배달료")


                      ],
                    ))
              ]),


            )):Text("")
            , SizedBox(height:10),
            order!.state!=4?SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(onPressed: (){
                setOrderState(order?.orderId,order?.state );
              }, child: Text(ReturnStatusButtonString(),
                style: TextStyle(fontSize: 20),),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(   //모서리를 둥글게
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color(0xff3478F6)),

              ),
            ):Text(""),
            SizedBox(height:10)
          ],
        ): Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(strokeWidth: 5,),
        )

    );

  }
}