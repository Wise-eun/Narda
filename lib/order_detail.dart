import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'api/api.dart';
import 'kakao_map.dart';
import 'model/store.dart';
import 'model/orderDetail.dart';


OrderDetail? order;
Duration? duration;

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({Key? key, required this.orderId, required this.storeId}) : super(key: key);
  final int orderId;
  final String storeId;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool callOk=false;

  @override
  void initState() {
    // TODO: implement initState
    orderDetail();
    super.initState();
  }

  orderDetail() async{

    try{
      var response = await http.post(
          Uri.parse(API.orderDetail),
          body:{
            'orderId' : widget.orderId.toString(),
            'storeId' : widget.storeId
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          callOk=true;
          print("오더 디테일 불러오기 성공");
          print(responseBody['userData']);
          order = OrderDetail.fromJson(responseBody['userData']);
          DateTime orderTime = DateTime.parse(order!.orderTime);
          DateTime current  = DateTime.now();

          duration = current.difference(orderTime);
          print("duration : $duration");

        }
        else{
          print("오더 디테일 불러오기 실패");
        }
      }
      else{
        print("오더 디테일 불러오기 실패2");
      }
      setState(() {});
    }catch(e){print(e.toString());}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                callOk?Text("주문일시 ${order?.orderTime}  경과시간 ${duration?.inMinutes}분"):Text('주문일시 및 경과시간'),
                callOk?Text(order!.storeName):Text('가게 이름'),
                callOk?Text(order!.storeLocation):Text('가게 주소'),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:  MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () async {

                    },
                    child: Text('픽업')),
                callOk?Text(order!.deliveryDistance.toString()):Text('Km'),
                callOk?Text(order!.deliveryLocation):Text('고객 주소'),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KakaoMapTest()),
                    );
                  },
                  child: Text('map')
                ),
                callOk?Text("배달비 ${order!.deliveryFee}원"):Text('배달비 원'),
                callOk?Text("주문 번호 ${order!.orderId}"):Text('주문 번호'),
                callOk?Text("결제 수단 ${order!.payment}"):Text('결제 수단'),
                callOk?Text("가게 번호 ${order!.storePhoneNum}"):Text('가게 전화번호'),
                const SizedBox(
                  height: 100,
                ),
                Text("주문 정보"),
                callOk?Text(order!.orderInfo):Text('메뉴'),
                Text("----------------"),
                callOk?Text("고객 요청사항 ${order!.deliveryRequest}"):Text('고객 요청사항'),
                callOk?Text("라이더 요청사항 ${order!.deliveryRequest}"):Text('라이더 요청사항'),
                callOk?Text("고객 번호 ${order!.customerNum}"):Text('고객 전화번호'),
              ],
            )
        )
    );


    // return  Scaffold(
    //   body:Center(
    //     child:  Text(widget.orderId.toString()),
    //   )
    // );
  }
}



