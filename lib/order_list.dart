import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'api/api.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';

List<OrderDetail> orders = [];

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key, required this.userId}) : super(key: key);
final String userId;
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();
  int state = 0;
  TextStyle feeTextStyle = TextStyle(color: Colors.white);
  TextStyle distanceTextStyle = TextStyle(color: Colors.black);
  TextStyle timeTextStyle = TextStyle(color: Colors.black);

  Color feeColor = Colors.blue;
  Color distanceColor = Colors.white;
  Color timeColor = Colors.white;

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${orders[index].storeName}",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                      Text(
                        "${orders[index].deliveryFee}원",
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    LinearPercentIndicator(
                      lineHeight: 12,
                      percent: percent<0?0:percent,
                      barRadius: const Radius.circular(16),
                      progressColor: percent<0.33?Colors.red:percent<0.66?Colors.yellow:Colors.green,
                      backgroundColor: Colors.grey[300],
                    ),
                    Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          "${duration.inMinutes}분",
                          style: TextStyle(color: Colors.black),
                        )),
                  ],
                )
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

    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("오더리스트"),
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
                  height: 30,
                  child: Icon(
                    Icons.maximize_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  height: 35,
                  color: Color(0xfff1f2f3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                          height: 30,
                          child: FilledButton(
                        onPressed: () {
                          state = 0;
                          orderList("deliveryFee");
                          feeTextStyle = TextStyle(color: Colors.white);
                          feeColor = Colors.blue;
                          distanceTextStyle = TextStyle(color: Colors.black);
                          distanceColor = Colors.white;
                          timeTextStyle = TextStyle(color: Colors.black);
                          timeColor = Colors.white;
                        },
                        child: Text(
                          "배달비 높은",
                          style: feeTextStyle,
                        ),
                        style:
                            FilledButton.styleFrom(backgroundColor: feeColor),
                      )),
                  SizedBox(
                    height: 30,
                    child:FilledButton(
                        onPressed: () {
                          state = 1;
                          orderList("deliveryDistance");

                          feeTextStyle = TextStyle(color: Colors.black);
                          feeColor = Colors.white;
                          distanceTextStyle = TextStyle(color: Colors.white);
                          distanceColor = Colors.blue;
                          timeTextStyle = TextStyle(color: Colors.black);
                          timeColor = Colors.white;
                        },
                        child: Text(
                          "가까운",
                          style: distanceTextStyle,
                        ),
                        style: FilledButton.styleFrom(
                            backgroundColor: distanceColor),
                      ),),
                  SizedBox(
                    height: 30,
                    child:FilledButton(
                        onPressed: () {
                          state = 2;
                          orderList("orderTime");

                          feeTextStyle = TextStyle(color: Colors.black);
                          feeColor = Colors.white;
                          distanceTextStyle = TextStyle(color: Colors.black);
                          distanceColor = Colors.white;
                          timeTextStyle = TextStyle(color: Colors.white);
                          timeColor = Colors.blue;
                        },
                        child: Text(
                          "남은 시간",
                          style: timeTextStyle,
                        ),
                        style:
                            FilledButton.styleFrom(backgroundColor: timeColor),
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
          ),
        ),
      ],
    );
  }
}
