import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:http/http.dart' as http;

import 'api/api.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';

List<OrderDetail> orders = [];

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();

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
    // TODO: implement initState
    orderList("deliveryFee");
    super.initState();
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

  List<String> list = ["배달비 높은 순", "거리순", "경과시간순"];
  String? dropdownValue = "배달비 높은 순";

  @override
  Widget build(BuildContext context) {

    var _listView = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        String payment, elapsedTime;
        String storeDong = "";
        String deliveryDong = "";

        if (orders[index].payment == 0)
          payment = "선결제";
        else if (orders[index].payment == 1)
          payment = "현장결제(카드)";
        else
          payment = "현장결제(현금)";

        final storeLocationList = orders[index].storeLocation.split(' ');
        storeDong = storeLocationList[storeLocationList.length - 2];

        final deliveryLocationList = orders[index].deliveryLocation.split(' ');
        deliveryDong = deliveryLocationList[deliveryLocationList.length - 2];

        DateTime orderTime = DateTime.parse(orders[index].orderTime);

        DateTime current = DateTime.now();
        Duration duration = current.difference(orderTime);
        double percent =
        (duration.inMinutes / orders[index].predictTime).toDouble();

        return Card(
          child: ListTile(
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
                  Text("${storeDong} > ${deliveryDong}  ${payment}"),
                ]),
            subtitle: Text(""),
            trailing: Column(children: <Widget>[
              Text(
                orders[index].deliveryFee.toString() + "원",
                style: TextStyle(color: Colors.red),
              ),
              //Text("${duration.inMinutes}분"),
              CircularProgressIndicator(
                value: percent,
                color: Colors.red,
                backgroundColor: Color(0xffE3E5EA),
                strokeWidth: 6.0,
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

    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(

          ),
          body: Container(
            child: Center(
              child: Text('지도'),
            ),
          ),
        ),
        SlidingUpPanelWidget(
          controlHeight: 50.0,
          anchor: 0.4,
          panelController: panelController,
          onTap: () {
            if (SlidingUpPanelStatus.expanded == panelController.status) {
              panelController.collapse();
            } else {
              panelController.expand();
            }
          },
          enableOnTap: true,
          child: Container(
            //margin: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  alignment: Alignment.center,

                  height: 40.0,
                  child: Icon(
                    Icons.maximize_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                DropdownButton(
                  value: dropdownValue,
                  items: list.map(
                        (value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                  onChanged: (String? value) {
                    dropdownValue = value!;
                    if (dropdownValue == "배달비 높은 순") {
                      orderList("deliveryFee");
                    } else if (dropdownValue == "거리순") {
                      orderList("deliveryDistance");
                    } else {
                      orderList("orderTime");
                    }
                  },
                ),
                Flexible(
                  child: Container(
                    child: _listView,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }
}