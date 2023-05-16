import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'api/api.dart';
import 'menu_bottom.dart';
import 'model/order.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const kPageTitle = 'Settings';
const kLabels = ["Edit Profile", "Accounts"];
const kTabBgColor = Color(0xFF8F32A9);
const kTabFgColor = Colors.white;

List<OrderDetail> orders = [];

class AfterOrderListScreen extends StatefulWidget {
  // const ListviewPage({Key? key, required this.orders}) : super(key: key);
  const AfterOrderListScreen({Key? key, required this.userId})
      : super(key: key);
  final String userId;

  @override
  _AfterOrderListScreenState createState() => _AfterOrderListScreenState();
}

class _AfterOrderListScreenState extends State<AfterOrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String tabValue = "진행 중";
  List<Tab> _tabs = [
    Tab(text: '진행 중 ()'),
    Tab(text: '완료 ()'),
  ];


  @override
  void initState() {
    // TODO: implement initState
    orderList();
    _tabController =
        TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    super.initState();
  }

  orderList() async {
    try {
      var response = await http.post(Uri.parse(API.afterOrderList),
          body: {'userId': widget.userId, 'state': tabValue});
      if (response.statusCode == 200) {
        orders = [];
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for (int i = 0; i < responseList.length; i++) {
            print(OrderDetail.fromJson(responseList[i]));
            orders.add(OrderDetail.fromJson(responseList[i]));
          }
        } else {
          print("오더 리스트 불러오기 실패");
        }
        _tabs = [
          Tab(text: '진행 중 (${orders.length})'),
          Tab(text: '완료 (${orders.length})'),
        ];

        setState(() {});
        return orders;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var _listView = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        String payment, elapsedTime;
        String state;
        String storeDong = "";
        String deliveryDong = "";

        if (orders[index].payment == 0)
          payment = "선결제";
        else if (orders[index].payment == 1)
          payment = "현장결제(카드)";
        else
          payment = "현장결제(현금)";

        if (orders[index].state == 2) {
          state = "픽업 전";
        } else if (orders[index].state == 3) {
          state = "배달 중";
        } else {
          state = "${orders[index].deliveryFee}원";
        }

        final storeLocationList = orders[index].storeLocation.split(' ');
        storeLocationList.forEach((element) {
          if(element[element.length-1] == '동'){
            storeDong = element;
          }
        });

        final deliveryLocationList = orders[index].deliveryLocation.split(' ');
        deliveryLocationList.forEach((element) {
          if(element[element.length-1] == '동'){
            deliveryDong = element;
          }
        });

        DateTime orderTime = DateTime.parse(orders[index].orderTime);

        DateTime current = DateTime.now();
        Duration duration = current.difference(orderTime);
        double percent = (duration.inMinutes/orders[index].predictTime).toDouble();

        print(duration.inMinutes.toString() + " // " + orders[index].predictTime.toString());
        print(orders[index].orderId);
        print(current.toString() + " " + orderTime.toString());
        print("percent : " + percent.toString());

        return Card(
          child: ListTile(
            //visualDensity: VisualDensity(horizontal: 0, vertical: 0),
            contentPadding: EdgeInsets.only(left:15, right: 15, top: 0, bottom: 0),
            leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                      "${orders[index].orderTime.substring(10, 16)}  ${orders[index].deliveryDistance.toStringAsFixed(2)}km"),
                  Text(
                    "${orders[index].storeName}",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text("${storeDong} > ${deliveryDong}"),
                ]),
            subtitle: Text(""),
            trailing: Column(children: <Widget>[
              Text(state, style: TextStyle(color: Colors.red),),
              //Text("${duration.inMinutes}분"),
              CircularProgressIndicator(
                  value: percent,
                  color: Colors.red,
                  backgroundColor: Color(0xffE3E5EA),
                  strokeWidth : 6.0,
              ),
            ]),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(
                          orderId: orders[index].orderId,
                          storeId: orders[index].storeId,
                        )),
              );
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: Container(
                child:
                Text(
                "오더리스트",
                style: TextStyle(color: Colors.black),
              ),),
              shape: Border(
                  bottom: BorderSide(
                color: Color(0xfff1f2f3),
                width: 2,
              )),
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Color(0xfff1f2f3),
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0)),
                    color: Colors.white),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                tabs: _tabs,
                onTap: (int i) {
                  if (i == 0) {
                    tabValue = "진행 중";
                    orderList();
                  } else {
                    tabValue = "완료";
                    orderList();
                  }
                },
              ),
            ),

          body: TabBarView(children: [_listView, _listView]),
        ));
  }
}
