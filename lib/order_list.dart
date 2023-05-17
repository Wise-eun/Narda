import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api/api.dart';
import 'menu_bottom.dart';
import 'model/order.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';

List<OrderDetail> orders = [];

class ListviewPage extends StatefulWidget {
  // const ListviewPage({Key? key, required this.orders}) : super(key: key);
  const ListviewPage({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  _ListviewPageState createState() => _ListviewPageState();
}

class _ListviewPageState extends State<ListviewPage> {
  @override
  void initState() {
    // TODO: implement initState
    orderList("deliveryFee");
    super.initState();
  }

  orderList(String sort) async{
    try{
      var response = await http.post(
          Uri.parse(API.orderList),
          body:{
            'sort' : sort,
          }
      );
      if(response.statusCode == 200){
        orders = [];
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("$sort 오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for(int i=0; i<responseList.length; i++){
            print(OrderDetail.fromJson(responseList[i]));
            orders.add(OrderDetail.fromJson(responseList[i]));
          }
        }
        else {
          print("오더 리스트 불러오기 실패");
        }
        setState(() {});
        return orders;
      }
    }catch(e){print(e.toString());}
  }

  List<String> list = ["배달비 높은 순", "거리순", "경과시간순"];
  String? dropdownValue = "배달비 높은 순";

  @override
  Widget build(BuildContext context) {

    var navigationTextStyle =
        TextStyle(color: CupertinoColors.white, fontFamily: 'GyeonggiMedium');

    var _navigationBar = CupertinoNavigationBar(
        middle: Text("신규 오더 리스트", style: navigationTextStyle),
        backgroundColor: CupertinoColors.systemBlue);

    var _listView = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        String payment, elapsedTime;
        String storeDong = "";
        String deliveryDong = "";

        if(orders[index].payment == 0) payment = "선결제";
        else if(orders[index].payment == 1) payment = "카드 결제";
        else payment = "현금 결제";

        final storeLocationList = orders[index].storeLocation.split(' ');
        storeDong = storeLocationList[storeLocationList.length-2];
        // storeLocationList.forEach((element) {
        //   if(element[element.length-1] == '동'){
        //     storeDong = element;
        //   }
        // });

        final deliveryLocationList = orders[index].deliveryLocation.split(' ');
        deliveryDong = deliveryLocationList[deliveryLocationList.length-2];

        // deliveryLocationList.forEach((element) {
        //   if(element[element.length-1] == '동'){
        //     deliveryDong = element;
        //   }
        // });

        DateTime orderTime = DateTime.parse(orders[index].orderTime);

        DateTime current = DateTime.now();
        Duration duration = current.difference(orderTime);
        double percent = (duration.inMinutes/orders[index].predictTime).toDouble();


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
                  Text("${storeDong} > ${deliveryDong}"),
                ]),
            subtitle: Text(""),
            trailing: Column(children: <Widget>[
              Text(orders[index].deliveryFee.toString() + "원", style: TextStyle(color: Colors.red),),
              //Text("${duration.inMinutes}분"),
              CircularProgressIndicator(
                value: percent,
                color: Colors.red,
                backgroundColor: Color(0xffE3E5EA),
                strokeWidth : 6.0,
              ),
            ]),
            // leading: Text(orders[index].storeId,
            //     style: const TextStyle(fontSize: 20)),
            // title: Text(
            //     "${orders[index].deliveryDistance.toStringAsFixed(2)}km"),
            // subtitle: Text(orders[index].deliveryLocation),
            // trailing: Column(children: <Widget>[
            //   Text("${orders[index].deliveryFee}원"), // icon-1
            //   Text(payment),
            //   Text("${duration.inMinutes}분"),
            // ]),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  OrderDetailScreen(orderId: orders[index].orderId, storeId: orders[index].storeId,)),
            );},
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );

    return CupertinoPageScaffold(
      navigationBar: _navigationBar,
      child: Scaffold(
        bottomNavigationBar: MenuBottom(userId: widget.userId, tabItem: TabItem.list ),
        body: Column(children: <Widget>[
          const SizedBox(
            height: 10,
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

              if(dropdownValue == "배달비 높은 순"){
                orderList("deliveryFee");
              }
              else if(dropdownValue == "거리순"){
                orderList("deliveryDistance");
              }
              else{
                orderList("orderTime");
              }
            },
          ),
          Expanded(child: _listView),
        ]),
      ),
    );
  }
}
