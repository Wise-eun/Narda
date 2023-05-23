import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speelow/HorizontalDashedDivider.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';
import 'kakao_map.dart';
import 'menu_bottom.dart';
import 'model/store.dart';
import 'model/orderDetail.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
    List<geo.Location> locations_Destination = await geo.locationFromAddress(address);
    to_latitude = locations_Destination[0].latitude.toDouble();
    to_longitude = locations_Destination[0].longitude.toDouble();
    print('$to_latitude, $to_longitude');
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
            from_latitude = position.latitude;
            from_longitude = position.longitude;
            print('현재위치 받아옴');
            Size size = new Size(17, 22);

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
                NOverlayImage.fromAssetImage('asset/images/testing.png')
            );
            path.setPatternInterval(9);
            path.setWidth(5);
            path.setColor(Colors.blue);
            _mapController.addOverlay(path);

            double centerlat = (from_latitude + to_latitude);
            double centerlon = (from_longitude + to_longitude);
            NCameraUpdate nCameraUpdate = NCameraUpdate.withParams(
                target: NLatLng(centerlat/2, centerlon/2),
                zoom: 9
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
    orderDetail();
    //getCurrentLocation();
    //addressToPM();
    //super.initState();
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
  return "";
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
          String address = order!.deliveryLocation;
          print('address : $address');
          addressToPM(address);
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




  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final mediaQuery = MediaQuery.of(context);
    final mapSize =
        Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    var valueFormat = NumberFormat('###,###,###,###');
    return Scaffold(
appBar: AppBar(
  leading: IconButton(
    icon: Icon(CupertinoIcons.chevron_left,
      color: Colors.grey[400],
      size: 30,), onPressed: () {
      Navigator.pop(context);
  },
  ),
  title: Container(
    child:
         Text(
              "주문내역",
              style: TextStyle(color: Colors.black),
            )

  ,),
  shape: Border(
      bottom: BorderSide(
        color: Color(0xfff1f2f3),
        width: 2,
      )),

  centerTitle: true,
  backgroundColor: Color(0xfff1f2f3),
  elevation: 0,
),
        body: Scrollbar(
            controller: _scrollController,
            isAlwaysShown: true,
            thickness: 10,
            child: ListView(controller: _scrollController, children: [
              Container(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  callOk?Container(
                    margin: EdgeInsets.fromLTRB(30,0,30,0),
                    child:
                  Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                    Text(ReturnStatusString(),style: TextStyle(fontSize: 25, color: Color(0xffFF3055)),),
                    Container(
                      child:Column(
crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("주문일시 ${order?.orderTime.substring(0,16).replaceAll('-', '.')} ",
                            style: TextStyle( color: Colors.grey[400]),
                            textAlign: TextAlign.left,),
                          order?.pickupTime!=null? Text("픽업시간 ${order?.pickupTime?.substring(0,16).replaceAll('-', '.')}",
                              style: TextStyle( color: Colors.grey[400]),
                              textAlign: TextAlign.left)
                              :Text("픽업시간 ",
                              textAlign: TextAlign.left,
                            style: TextStyle( color: Colors.grey[400]),
                          )
                        ],
                      ),
                    )
                  ],),)  : Text('배달상태'),

                  SizedBox(
                    height: 30,
                  ),
                  callOk ? Text(order!.storeName,
                    style:TextStyle(fontSize: 23 ) ,) : Text('가게 이름'),
                  callOk ? Text(order!.storeLocation
                  ,style: TextStyle(fontSize: 15),) : Text('가게 주소'),
                  SizedBox(
                    height: 15,
                  ),
                  callOk ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Container(

                     child:       Transform.rotate(angle: -90*math.pi / 180,
                      child:  Icon(CupertinoIcons.chevron_left_2,
                      color: Color(0xffFF3055),
                      size: 18,),),
                    ),

SizedBox(width: 5,),
                    Text(order!.deliveryDistance.toString() + "km",
                      style:TextStyle(fontSize: 18, color: Color(0xffFF3055)) ,)
                  ],)  : Text('거리'),
                  SizedBox(
                    height: 20,
                  ),
                 /* clicked
                      ? ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () async {

                          },
                          child: Text('완료'))
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              clicked = true;
                            });
                          },
                          child: Text('픽업'),
                        ),
*/
                  callOk ? Container(
      alignment: Alignment.center,
                    child: Text(order!.deliveryLocation + "\n"+order!.deliveryLocationDetail,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white
                      ),
                      textAlign: TextAlign.center,),
                    decoration: BoxDecoration(
                      color: Color(0xffFF3055),
                      borderRadius: BorderRadius.all(Radius.circular(15.0))
                    ),
                    width: 250,
                    height:60
                  ) : Text('고객 주소'),
                  SizedBox(
                    height: 20,
                  ),
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
               /*   TextButton(
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
                      child: Text('map')),*/
                  SizedBox(height: 20,),
callOk? Column(
  children: [
    Row(
      children: [
        SizedBox(width: 30,),
        Text("주문 번호",
        style: TextStyle(fontSize: 18),),
        SizedBox(width: 30,),
        Text(order!.orderInfo.hashCode.toRadixString(16).toUpperCase(),
        style: TextStyle(fontSize: 18))
      ],
    ),
    SizedBox(height: 10),
    Row(
      children: [
        SizedBox(width: 30,),
        Text("결제 수단",
          style: TextStyle(fontSize: 18),),
        SizedBox(width: 30,),
        Text(ReturnPaymentString(),
            style: TextStyle(fontSize: 18))
      ],
    ),
    SizedBox(height: 10),
    Row(
      children: [
        SizedBox(width: 30,),
        Text("가게 번호",
          style: TextStyle(fontSize: 18),),
        SizedBox(width: 30,),
        Text(ReturnPhoneNum(order!.storePhoneNum),
            style: TextStyle(fontSize: 18))
      ],
    )
  ],
):Text('주문번호/결제수단/가게번호'),
                  SizedBox(height: 20,),
                  Container(
                    color: Colors.grey[200],
                    height: 20,
                  ),
                  SizedBox(height: 20,),
                  callOk ?
                  Container(
                    alignment: Alignment.centerLeft,
                    child:  Row(
                      children: [
                        SizedBox(width: 30,)
                      ,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text("고객 번호",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700 ),),
                                SizedBox(height: 5,),
                                Text(ReturnPhoneNum(order!.customerNum),style: TextStyle(fontSize: 18),)
                              ],),
                            SizedBox(height: 25,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("고객 요청사항",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700),),
                                SizedBox(height: 5,),
                                Text("리뷰이벤트 콜라 부탁드려요 :)\n수저,포크(x)",style: TextStyle(fontSize: 18),)
                              ],),
                            SizedBox(height: 25,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("라이더 요청사항",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700),),
                                SizedBox(height: 5,),
                                Text(order!.deliveryRequest,style: TextStyle(fontSize: 18),)
                              ],)
                          ],
                        )

                      ],
                    )   ,
                  ):Text("요청사항")
             ,
                  SizedBox(height: 20,),
                  Container(
                    color: Colors.grey[200],
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                      SizedBox(width: 30,),
                  callOk ?
                      Container(
                          margin: EdgeInsets.fromLTRB(30,0,50,50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("주문 정보",style: TextStyle(fontSize: 18,fontWeight:FontWeight.w700)),
                            SizedBox(height: 10,),
                            Text(order!.orderInfo,style: TextStyle(fontSize: 18)),
                            SizedBox(height: 10,),
                            Container(
                              width: 350,
                              child: Divider(color: Colors.grey[400],thickness: 1.0,),),
                            SizedBox(height: 5,),
                            Container(
                                width:300,
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
                              width: 350,
                              child: Divider(color: Colors.grey[400],thickness: 1.0,),),
                            SizedBox(height:10),
                              Container(
                                width:300,
                                child:       Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text("기본 배달료",style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.start),

                                    Text("1,000원",
                                        style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.end)
                                  ],
                                ),
                              ),
                            SizedBox(height:5),
                            Container(
                              width:300,
                              child:       Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text("거리 할증",style: TextStyle(fontSize: 18)
                                      ,  textAlign: TextAlign.start),

                                  Text(valueFormat.format(order!.deliveryFee - 1000) + "원",
                                      style: TextStyle(fontSize: 18)
                                      ,  textAlign: TextAlign.end)
                                ],
                              ),
                            ),SizedBox(height:10),
                              HorizontalDashedDivider(),
                            SizedBox(height:10),
                              Container(
                                width:300,
                                child:       Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text("총 배달료",style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.start),

                                    Text(valueFormat.format(order?.deliveryFee) + "원",
                                        style: TextStyle(fontSize: 18)
                                        ,  textAlign: TextAlign.end)
                                  ],
                                ),
                              ),



                            SizedBox(height: 20,),
                          ],
                        )
                      ): Text("배달료")



                 ,

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
