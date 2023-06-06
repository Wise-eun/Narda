import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
//import 'package:percent_indicator/circular_percent_indicator.dart';

import 'api/api.dart';
import 'menu_bottom.dart';
import 'model/order.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

List<OrderDetail> proceedingOrders = [];
List<OrderDetail> completeOrders = [];


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
  bool order_state = true;
  bool previous = false;
  var _listView;
  String tabValue = "진행 중";
  List<Tab> _tabs = [
    Tab(text: '진행 중 ()'),
    Tab(text: '완료 ()'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    proceedingOrderList();
    completeOrderList();
    _tabController =
        TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    super.initState();
  }

  proceedingOrderList() async {
    try {
      var response = await http.post(Uri.parse(API.afterOrderList),
          body: {'userId': widget.userId, 'state': "진행 중"});
      if (response.statusCode == 200) {
        proceedingOrders = [];
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for (int i = 0; i < responseList.length; i++) {
            //print(OrderDetail.fromJson(responseList[i]));
            proceedingOrders.add(OrderDetail.fromJson(responseList[i]));
          }
        } else {
          print("오더 리스트 불러오기 실패");
        }
        _tabs = [
          Tab(text: '진행 중 (${proceedingOrders.length})'),
          Tab(text: '완료 (${completeOrders.length})'),
        ];

        setState(() {});
        return proceedingOrders;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  completeOrderList() async {
    try {
      var response = await http.post(Uri.parse(API.afterOrderList),
          body: {'userId': widget.userId, 'state': "완료"});
      if (response.statusCode == 200) {
        completeOrders = [];
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("신규 오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for (int i = 0; i < responseList.length; i++) {
            //print(OrderDetail.fromJson(responseList[i]));
            if(!previous){
              print("${responseList[i]['deliveryTime']}  ${responseList[i]['orderId']}");
              if(responseList[i]['deliveryTime'] != null){
                if(responseList[i]['deliveryTime'].toString().substring(0,10) == DateTime.now().toString().substring(0, 10)){
                  completeOrders.add(OrderDetail.fromJson(responseList[i]));
                }
              }

            }
            else{
              completeOrders.add(OrderDetail.fromJson(responseList[i]));
            }
          }
        } else {
          //print("오더 리스트 불러오기 실패");
        }
        _tabs = [
          Tab(text: '진행 중 (${proceedingOrders.length})'),
          Tab(text: '완료 (${completeOrders.length})'),
        ];

        print("탭 텍스트 설정");

        setState(() {});
        return completeOrders;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  proceeding() {
    _listView = ListView.separated(
      itemCount: proceedingOrders.length,
      itemBuilder: (BuildContext context, int index) {
        String payment, elapsedTime;
        String state;
        String storeDong = "";
        String deliveryDong = "";

        if (proceedingOrders[index].payment == 0)
          payment = "선결제";
        else if (proceedingOrders[index].payment == 1)
          payment = "현장/카드";
        else
          payment = "현장/현금";

        if (proceedingOrders[index].state == 2) {
          state = "픽업 전";
        } else if (proceedingOrders[index].state == 3) {
          state = "배달 중";
        } else {
          state = "${proceedingOrders[index].deliveryFee}원";
        }

        final storeLocationList = proceedingOrders[index].storeLocation.split(' ');
        storeLocationList.forEach((element) {
          if (element[element.length - 1] == '동') {
            storeDong = element;
          }
        });

        final deliveryLocationList = proceedingOrders[index].deliveryLocation.split(' ');
        deliveryLocationList.forEach((element) {
          if (element[element.length - 1] == '동') {
            deliveryDong = element;
          }
        });

        DateTime orderTime = DateTime.parse(proceedingOrders[index].orderTime);

        DateTime current = DateTime.now();
        Duration duration = orderTime.difference(current);

        int timestamp1 = duration.inMinutes + proceedingOrders[index].predictTime;
        int timestamp2 = proceedingOrders[index].predictTime;

        double percent = timestamp1/timestamp2;
        if(percent>1) percent = 1;

        return GestureDetector(
            child:Container(
                margin: EdgeInsets.fromLTRB(15,0,15,0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xfff1f2f3),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          "${storeDong} > ${deliveryDong}  |  ${proceedingOrders[index].deliveryDistance.toStringAsFixed(2)}km",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )),
                                  SizedBox(width: 5,),
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xfff1f2f3),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          payment,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child:  Text(
                                state,
                                style: TextStyle(
                                    color:(proceedingOrders[index].state == 3 && timestamp1 > 0)?Color(0xffFF4E17):Color(0xff797979),
                                    fontSize: 21),
                                textAlign: TextAlign.end
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${proceedingOrders[index].storeName}",
                              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                            )
                            ,
                            Container(
                                alignment: Alignment.centerRight,
                                child: timestamp1>0?Text(
                                  "${timestamp1}분",
                                  style: TextStyle(color: Color(0xff797979), fontSize: 16),
                                ):Text(
                                  "${timestamp1.abs()}분 초과",
                                  style: TextStyle(color: Color(0xffFF4E17), fontSize: 16),
                                ))
                          ],
                        )
                       ,
                        SizedBox(
                          height: 5,
                        ),

                      ],
                    ),

              ),
              Stack(
                children: [
                  LinearPercentIndicator(
                    lineHeight: 12,
                    percent: percent<0?1:percent,
                    //percent: 1,
                    barRadius: const Radius.circular(16),
                    progressColor: percent<0?Color(0xff686A70):percent<0.33?Color(0xffFF4E17):percent<0.66?Color(0xffFFBB0B):Color(0xff65C466),
                    backgroundColor: Color(0xffE3E5EA),
                  ),

                ],
              )
            ])),
        onTap: (){Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderDetailScreen(
                orderId: proceedingOrders[index].orderId,
                storeId: proceedingOrders[index].storeId,
                userId: widget.userId,
              )),
        );},);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }


  complete() {
    _listView = ListView.separated(
      itemCount: completeOrders.length,
      itemBuilder: (BuildContext context, int index) {
        String payment, elapsedTime;
        String state;
        String storeDong = "";
        String deliveryDong = "";

        if (completeOrders[index].payment == 0)
          payment = "선결제";
        else if (completeOrders[index].payment == 1)
          payment = "현장/카드";
        else
          payment = "현장/현금";

        if (completeOrders[index].state == 2) {
          state = "픽업 전";
        } else if (completeOrders[index].state == 3) {
          state = "배달 중";
        } else {
          state = "${completeOrders[index].deliveryFee}원";
        }

        final storeLocationList = completeOrders[index].storeLocation.split(' ');
        storeLocationList.forEach((element) {
          if (element[element.length - 1] == '동') {
            storeDong = element;
          }
        });

        final deliveryLocationList = completeOrders[index].deliveryLocation.split(' ');
        deliveryLocationList.forEach((element) {
          if (element[element.length - 1] == '동') {
            deliveryDong = element;
          }
        });

        DateTime orderTime = DateTime.parse(completeOrders[index].orderTime);

        DateTime current = DateTime.now();
        Duration duration = current.difference(orderTime);
        double _percent =
            (duration.inMinutes / completeOrders[index].predictTime).toDouble();
        if (_percent >= 1) _percent = 1;

        return GestureDetector(
            child:Container(
            margin: EdgeInsets.only(left:15, right:15, top: 10, bottom: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${completeOrders[index].deliveryTime?.substring(0, 16)}"),
                      Text(
                        "${completeOrders[index].deliveryFee}원",
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    color: Color(0xfff1f2f3),
                    height: 2,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "${completeOrders[index].orderInfo.hashCode.toRadixString(16).toUpperCase()}",style: TextStyle(fontSize: 17),),
                          SizedBox(height: 5,),
                          Text(
                            "${completeOrders[index].storeName}",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              "${completeOrders[index].deliveryDistance.toStringAsFixed(2)}km"),
                          SizedBox(height: 5,),
                          Text("총 ${duration.inMinutes}분 소요",style: TextStyle(fontSize: 17),),
                        ],
                      )
                    ],
                  ),
                ])
        ),
          onTap: (){
            Navigator.push(
               context,
             MaterialPageRoute(
                 builder: (context) => OrderDetailScreen(
                   orderId: completeOrders[index].orderId,
                   storeId: completeOrders[index].storeId,
                   userId: widget.userId,
                 )),
             );
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(thickness: 4,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    order_state ? proceeding() : complete();

    return DefaultTabController(
        length: 1,
        child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar:
                MenuBottom(userId: widget.userId, tabItem: TabItem.list),
            appBar: AppBar(
              title: Container(
                child: Text(
                  "오더리스트",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),

              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,

            ),
            //body: TabBarView(children: [_listView],
            body: Column(
            children: [
              Container(
                height: 53,
                child:
                Container(
                    height: 0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)
                      ),
                      color:  Color(0xffF1F2F3),
                    ),
                    child:
                    Column(
                      children: [
                        SizedBox(height:5),
                        TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                              color: Colors.white),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black,
                          tabs: _tabs,
                          onTap: (int i) {
                            if (i == 0) {
                              tabValue = "진행 중";
                              order_state = true;
                              proceedingOrderList();
                            } else {
                              tabValue = "완료";
                              order_state = false;
                              completeOrderList();
                            }
                          },
                        ),
                      ],
                    )
                ),
              )
              ,
              Expanded(child: TabBarView(children: [_listView]),),
              if(!order_state && !previous)SizedBox(

                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xfff1f2f3)),
                  onPressed: () {
                    previous = true;
                    completeOrderList();
                    setState(() {});
                  }, child: Text("지난 내역 >", style: TextStyle(color: Colors.black),)),
              )
            ]
        ))
    );
  }
}
