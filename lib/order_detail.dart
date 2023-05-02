import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'api/api.dart';
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
                Text("주문일시 ${order?.orderTime}  경과시간 ${duration?.inMinutes}분"),
                Text(order!.storeName),
                Text(order!.storeLocation),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:  MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () async {

                    },
                    child: Text('픽업')),
                Text(order!.deliveryDistance.toString()),
                Text(order!.deliveryLocation),
                Text("지도 ><"),
                Text("배달비 ${order!.deliveryFee}원"),
                Text("주문 번호 ${order!.orderId}"),
                Text("결제 수단 ${order!.payment}"),
                Text("가게 번호 ${order!.storePhoneNum}"),
                const SizedBox(
                  height: 100,
                ),
                Text("주문 정보"),
                Text(order!.orderInfo),
                Text("----------------"),
                Text("고객 요청사항 ${order!.deliveryRequest}"),
                Text("라이더 요청사항 ${order!.deliveryRequest}"),
                Text("고객 번호 ${order!.customerNum}"),


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



