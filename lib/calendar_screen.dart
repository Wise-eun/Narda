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
  CalendarFormat format = CalendarFormat.month;
  late final ValueNotifier<List<Event>> _selectedEvents;
  bool callOk = false;
  var valueFormat = NumberFormat('###,###,###,###');

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  Map<DateTime, List<Event>>? events = {
    //DateTime.utc(2023,5,4): [Event('45,000원')],
    //DateTime.utc(2023, 5, 20): [Event('120,000원')],
    //DateTime.utc(2023, 5, 23): [Event('78,000원')],
  };
  Map<DateTime, String> money = {
    //DateTime.utc(2023, 5, 20):'5',
  };

  List<Event> _getEventsForDay(DateTime day) {
    //datetime 인자를 받아 list 출력
    return events?[day] ?? [];
  }

  void account() {
    delivercount=0;
    totalDistance=0;
    monthlyFee=0;
    print('order length ${responseList2!.length}');
    for(int i=0;i<responseList2!.length;i++) {
      if(selectedDay.year.toString() == order[i].deliveryTime.substring(0, 4)
          && selectedDay.toString().substring(5, 7) == order[i].deliveryTime.substring(5, 7)) {
        print('조건문 체크2222');
        print(selectedDay);
        delivercount=delivercount+1;
        totalDistance = (totalDistance + order[i].deliveryDistance);
        print('total distance ${totalDistance}');
        monthlyFee = (monthlyFee + order[i].deliveryFee);
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
              print('temp : $temp');
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
            margin: EdgeInsets.only(left: 15, right: 15),
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
                  width: mediaQuery.size.width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xff475DFE),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('월 평균 수입 \n총 배달 거리 \n하루 평균 건수 ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          )
                      ),
                      Text(valueFormat.format((totalFee/30))+'원\n'
                          '$totalDistance km\n'
                          '${(delivercount/30).toStringAsFixed(2)}건',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('일일 평균 수입 : '+valueFormat.format(monthlyFee/delivercount) +'원',
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
                TableCalendar(
                  //shouldFillViewport: true,
                  locale: 'ko-KR',
                  rowHeight: 65,
                  firstDay: DateTime.utc(2022, 10, 4),
                  lastDay: DateTime.utc(2030, 10, 4),
                  focusedDay: focusedDay,

/*                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState(() {
                      this.selectedDay = selectedDay;
                      this.focusedDay = focusedDay;
                      account();
                    });
                    print(events?[selectedDay].toString());
                    _selectedEvents.value = _getEventsForDay(selectedDay);
                    print(_selectedEvents.value);
                  },
                  selectedDayPredicate: (DateTime day) {
                    return isSameDay(selectedDay, day);
                  },*/
                  eventLoader: _getEventsForDay,
                  onFormatChanged: (CalendarFormat _format) {
                    setState(() {
                      format = _format;
                    });
                  },

                  calendarBuilders: CalendarBuilders(

                      markerBuilder: (BuildContext context, date, events) {

                        if(events.isEmpty) return SizedBox();
                        print("AVERAGE : " + (monthlyFee/delivercount).toString());
                        print(int.parse(money[DateTime.parse(date.toString().substring(0,10))]!));
                        if(int.parse(money[DateTime.parse(date.toString().substring(0,10))]!)
                            > (monthlyFee/delivercount)) {
                          average = true;
                          print('bool chandged');
                        }
                        else
                          {
                            average = false;
                          }
                        if(average) {
                          print('true');
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
                        else {    print('false');
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
                      }
                  ),

                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    //titleTextFormatter: (date, locale) => DateFormat.yMMMMd(locale).format(date),
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                      //color: Colors.blue,
                    ),
                    headerPadding: EdgeInsets.symmetric(vertical: 4),
                    leftChevronIcon: Icon(
                      Icons.keyboard_arrow_left,
                      size: 30,
                    ),
                    rightChevronIcon: Icon(
                      Icons.keyboard_arrow_right,
                      size: 30,
                    ),
                  ),

                  calendarStyle: CalendarStyle(

/*                    canMarkersOverflow : false,
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
                    outsideDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),

                    cellMargin: const EdgeInsets.all(6),
                    cellPadding: const EdgeInsets.all(0),
                    cellAlignment: Alignment.center,
                  ),
                ),
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




