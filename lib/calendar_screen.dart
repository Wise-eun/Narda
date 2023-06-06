import 'dart:convert';
import 'model/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';
import 'menu_bottom.dart';
import 'model/orderDetail.dart';
import 'model/user.dart';

RiderUser userInfo = RiderUser("", "", "", "");
List<calendar> order = [];
List<dynamic>? responseList2;
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double totalDistance=0.0;
  int totalFee=0;
  int monthlyFee=0;
  int delivercount=0;

  int todayFee=0;
  int todaycount=0;
  double todayDistance=0.0;
  CalendarFormat format = CalendarFormat.month;
  late final ValueNotifier<List<Event>> _selectedEvents;
  bool callOk = false;
  var valueFormat = NumberFormat('###,###,###,###');
  bool isShape=false;

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  Map<DateTime, List<Event>>? events = {};
  Map<DateTime, String> money = {};
  Map<DateTime, int> todayInfo={};
  Map<DateTime, double> todayInfo2={};

  List<Event> _getEventsForDay(DateTime day) {
    //datetime 인자를 받아 list 출력
    return events?[day] ?? [];
  }

  void account() {
    todaycount=0;
    todayDistance=0;
    print('order length ${responseList2!.length}');
    for(int i=0;i<responseList2!.length;i++) {
      if(selectedDay.year.toString() == order[i].deliveryTime.substring(0, 4)
          && selectedDay.toString().substring(5, 7) == order[i].deliveryTime.substring(5, 7)
      && selectedDay.toString().substring(8, 10) == order[i].deliveryTime.substring(8, 10)) {
        print('조건문 체크2222');
        print(selectedDay);
        print(order[i].deliveryTime);

        todaycount=todaycount+1;
        todayDistance=todayDistance+order[i].deliveryDistance;
        print('${order[i].deliveryDistance}');
        print('여기!');
        todayInfo[DateTime.parse(order[i].deliveryTime.substring(0,10))]=todaycount;
        todayInfo2[DateTime.parse(order[i].deliveryTime.substring(0,10))]=todayDistance;
        print('$todaycount, $todayDistance');
      }
    }
  }

  @override
  void initState() {
    riderDetail();
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(selectedDay!));
  }

  riderDetail() async {
    try {
      var response = await http.post(Uri.parse(API.calendar), body: {
        'userId': widget.userId.toString(),
      });
      if (response.statusCode == 200) {
        callOk = true;
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          callOk = true;
          print("불러오기 성공");
          print(responseBody['userData']);
          List<dynamic> responseList = responseBody['userData'];
          responseList2 = responseBody['userData'];
          print('라이더가 완료한 주문 수 : ${responseList.length}');
          totalFee=0;
          monthlyFee=0;
          delivercount=0;
          for(int i=0;i<responseList.length;i++) {
            order.add(calendar.fromJson(responseList[i]));
            print('orderDay : ${order[i].deliveryTime}');
            int year = int.parse(order[i].deliveryTime.substring(0, 4));
            int month = int.parse(order[i].deliveryTime.substring(5, 7));
            int day = int.parse(order[i].deliveryTime.substring(8, 10));
            DateTime orderDay = DateTime.parse(order[i].deliveryTime.substring(0, 10));
            DateTime orderDay2 = DateTime.utc(year, month, day);
            print('money_parse : $orderDay, event_utc : $orderDay2');
            String temp = order[i].deliveryFee.toString();

            if(money.containsKey(orderDay)) {
              String temp = (int.parse(money[orderDay]!)+order[i].deliveryFee).toString();
              events?[orderDay2] = [Event(temp)];
              money[orderDay] = temp;
            }
            else {
              String temp = order[i].deliveryFee.toString();
              events?[orderDay2] = [Event(temp)];
              money[orderDay] = temp;
            }
            totalFee = (totalFee + order[i].deliveryFee);
            if((DateTime.now().year.toString() == order[i].deliveryTime.substring(0, 4)
                && DateTime.now().toString().substring(5, 7) == order[i].deliveryTime.substring(5, 7))) {
              print('조건문 체크');
              delivercount=delivercount+1;
              totalDistance = (totalDistance + order[i].deliveryDistance);
              monthlyFee = (monthlyFee + order[i].deliveryFee);
            }
          }

        } else {
          print("불러오기 실패");
        }
      } else {
        print("불러오기 실패2");
      }
      setState(() {
        account();
      });

    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print('event : $events');
    print('money : $money');
    print('빌드하는 곳!!!!');
    isShape=true;
    if(money!.containsKey(selectedDay)) {
      print('bbbb');
      todayFee=todayFee=int.parse(money[DateTime.parse(selectedDay.toString().substring(0,10))]!);
    }
    bool average = false;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
        //bottomNavigationBar: MenuBottom(userId: widget.userId),
        appBar:
        AppBar(
          shape: Border(
              bottom: BorderSide(
                color: Color(0xfff1f2f3),
                width: 2,
              )),
          title: Text('정산',
              style: TextStyle(color: Colors.black, fontSize: 18)),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        )
    ,
        body: SingleChildScrollView(
          child:
          Container(
            child: Column(
              children: [
                SizedBox(height: 15),
                SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '이번 달 수입 ',
                          style : TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(valueFormat.format(monthlyFee)+"원",
                          style : TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color : Color(0xff475DFE),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  width: mediaQuery.size.width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xff233D9A),
                    image: DecorationImage(
                      image: AssetImage('asset/images/rider.jpeg'),
                      fit: BoxFit.fitWidth,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.dstATop,
                      )
                    )
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('월 평균 수입 \n총 배달 거리 \n하루 평균 건수 ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.5
                          )
                      ),
                      Text(valueFormat.format((totalFee/30))+'원\n'
                          '${totalDistance.toStringAsFixed(2)} km\n'
                          '${(delivercount/money.length).toStringAsFixed(2)}건',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('일일 평균 수입 : '+valueFormat.format(monthlyFee/money.length) +'원',
                          style: TextStyle(
                            color: Colors.grey[700],
                          )
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.circle_fill,color:Color(0xff475DFE) ,size: 10,),
                          SizedBox(width: 5,),
                          Text('평균이상',
                              style: TextStyle(
                                color:Color(0xff475DFE),
                              )
                          ),
                          SizedBox(width: 10,),
                          Icon(CupertinoIcons.circle_fill,color:Color(0xffFF3055) ,size: 10,),
                          SizedBox(width: 5,),
                          Text('평균이하',
                              style: TextStyle(
                                color: Color(0xffFF3055),
                              )
                          )
                         ,
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  child: TableCalendar(
                    //shouldFillViewport: true,
                    locale: 'ko-KR',
                    rowHeight: 60,
                    firstDay: DateTime.utc(2022, 10, 4),
                    lastDay: DateTime.utc(2030, 10, 4),
                    focusedDay: focusedDay,

                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                      setState(() {
                        this.selectedDay = selectedDay;
                        this.focusedDay = focusedDay;
                      });
                      account();
                      if(events!.containsKey(selectedDay)) {
                        print('이벤트 있음');
                        todayFee=int.parse(money[DateTime.parse(selectedDay.toString().substring(0,10))]!);
                        todayDistance=todayInfo2[DateTime.parse(selectedDay.toString().substring(0,10))]!;
                        todaycount=todayInfo[DateTime.parse(selectedDay.toString().substring(0,10))]!;
                      }
                      else {
                        todayFee=0;
                      }
                      print(events?[selectedDay].toString());
                      _selectedEvents.value = _getEventsForDay(selectedDay);
                      print(_selectedEvents.value);
                    },
                    selectedDayPredicate: (DateTime day) {
                      return isSameDay(selectedDay, day);
                    },
                    eventLoader: _getEventsForDay,
                    onFormatChanged: (CalendarFormat _format) {
                      setState(() {
                        format = _format;
                      });
                    },

                    calendarBuilders: CalendarBuilders(
                        markerBuilder: (BuildContext context, date, events) {
                          if(events.isEmpty) return SizedBox();
                          print(int.parse(money[DateTime.parse(date.toString().substring(0,10))]!));
                          if(int.parse(money[DateTime.parse(date.toString().substring(0,10))]!)
                              > (monthlyFee/delivercount)) {
                            average = true;
                          }
                          else
                            {
                              average = false;
                            }
                          if(average) {
                            return Container(
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(height: 10,),
                                    Icon(CupertinoIcons.circle_fill,color:Color(0xff475DFE) ,size: 6,),
                                    SizedBox(height: 20,),
                                    Text(
                                      '${money?[DateTime.parse(date.toString().substring(0,10))]}',
                                      style: TextStyle(
                                        color: Color(0xff475DFE),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                )
                            );
                          }
                          else {
                            return Container(
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(height: 10,),
                                    Icon(CupertinoIcons.circle_fill,color:Color(0xffFF3055) ,size: 6,),
                                    SizedBox(height: 20,),
                                    Text(
                                      '${money?[DateTime.parse(date.toString().substring(0,10))]}',
                                      style: TextStyle(
                                        color: Color(0xffFF3055),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                )
                            );
                          }
                        },
                    ),

                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        //color: Colors.blue,
                      ),
                      headerPadding: EdgeInsets.symmetric(vertical: 4),
                      leftChevronIcon: Icon(
                        Icons.keyboard_arrow_left,
                        size: 30,
                        color: Colors.grey,
                      ),
                      rightChevronIcon: Icon(
                        Icons.keyboard_arrow_right,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),

                    calendarStyle: CalendarStyle(
                      /*
                      canMarkersOverflow : false,
                      markersAutoAligned : true,
                      markerSize : 8.0,
                      markerSizeScale : 8.0,
                      markersAnchor : 0.7,
                      markerMargin : const EdgeInsets.symmetric(horizontal: 0.3),
                      markersAlignment : Alignment.bottomCenter,
                      markersMaxCount : 4,
                      markersOffset : const PositionedOffset(),*/

                      isTodayHighlighted: true, //오늘 표시 여부
                      todayDecoration:  BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        shape: BoxShape.rectangle,
                        backgroundBlendMode: BlendMode.darken,
                        color: Colors.grey[200],
                      ),
                      todayTextStyle: TextStyle(color: Colors.black),
                      outsideDaysVisible: true, //다른 달 날짜 노출
                      outsideTextStyle: const TextStyle(color: const Color(0xFFAEAEAE)),

                      selectedTextStyle: TextStyle(
                        color: const Color(0xFF000000),
                      ),
                      selectedDecoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        backgroundBlendMode: BlendMode.darken,
                        color: Colors.grey[300],
                      ),

                      cellMargin: const EdgeInsets.all(5),
                      cellPadding: const EdgeInsets.all(0),
                      cellAlignment: Alignment.center,
                    ),
                  ),
                ),


                Container(
                  width: mediaQuery.size.width,
                  height: 1,
                  color: Colors.grey[300],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '하루 수입',
                        style: TextStyle(
                          fontSize: 18,
                        )
                      ),
                      Text(
                        '$todayFee원',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w600,
                        )
                      )
                    ],
                  )
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                  color: Colors.grey[300],
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          //color: Colors.blue,
                          width: mediaQuery.size.width/3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('배달 ',
                            style: TextStyle(
                              fontSize: 15,
                            )),
                            Text('$todaycount건',
                                style: TextStyle(fontWeight: FontWeight.w600,
                                  fontSize: 15,)),
                          ],
                        )
                      ),

                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        height: 30,
                        width: 1,
                        color:Colors.grey[300],
                      ),

                      SizedBox(
                        //color: Colors.blue
                          width: mediaQuery.size.width/3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('배달 거리 ',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                              Text('${todayDistance.toStringAsFixed(2)} km',
                                  style: TextStyle(fontWeight: FontWeight.w600,
                                    fontSize:15,)),
                            ],
                          )
                      ),
                    ],
                  )
                )
              ],
            ),
          )
        )
    );
  }
}

class Event {
  String title;
  Event(this.title);
}




