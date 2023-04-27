import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'api/api.dart';
import 'model/orderDetail.dart';


class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({Key? key, required this.orderId, required this.storeId}) : super(key: key);
  final int orderId;
  final String storeId;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {

  orderList(String sort) async{
    try{
      var response = await http.post(
          Uri.parse(API.orderDetail),
          body:{
            'orderId' : widget.orderId,
            'storeId' : widget.storeId
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("로그인 성공");
          OrderDetail order = OrderDetail.fromJson(responseBody['userData']);
        }
        else{
          print("로그인 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:Center(
        child:  Text(widget.orderId.toString()),
      )
    );
  }
}



