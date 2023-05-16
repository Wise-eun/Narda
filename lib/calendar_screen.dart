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

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double totalDistance=0.0;
  int totalFee=0;
  CalendarFormat format = CalendarFormat.month;
  late final ValueNotifier<List<Event>> _selectedEvents;
  bool callOk = false;
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
          print('000000 ${responseList.length}');
          for(int i=0;i<responseList.length;i++) {
            order!.add(calendar.fromJson(responseList[i]));
            totalFee = (totalFee + order[i].deliveryFee);
            totalDistance = (totalDistance + order[i].deliveryDistance);
            print('orderDay : ${order[i].orderTime}');
            int year = int.parse(order[i].orderTime.substring(0, 4));
            int month = int.parse(order[i].orderTime.substring(5, 7));
            int day = int.parse(order[i].orderTime.substring(8, 10));
            print('day : $day');
            DateTime orderDay = DateTime.parse(order[i].orderTime.substring(0, 10));
            DateTime orderDay2 = DateTime.utc(year, month, day);
            print('parse : $orderDay, utc : $orderDay2');
            //String temp = order[i].deliveryFee.toString();
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
    print(events);
    print('money : $money');
    print('빌드하는 곳!!!!');
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
        bottomNavigationBar: MenuBottom(userId: widget.userId),
        appBar: AppBar(
          title: Text('정산'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: mediaQuery.size.width,
                height: 15,
              ),
              SizedBox(
                width: mediaQuery.size.width,
                child: Text(
                  '이번달 수입 : $totalFee원',
                  textAlign: TextAlign.center,
                  style : TextStyle(fontSize: 18),
                ),
              ),
              Container(
                width: mediaQuery.size.width,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                color: Colors.grey[350],
                child: Column(
                  children: [
                    Text('월 평균 수입 : ${(totalFee/30).toStringAsFixed(2)}원'),
                    Text('총 배달 거리 : $totalDistance km'),
                  ],
                ),
              ),
              TableCalendar(
                //shouldFillViewport: true,
                locale: 'ko-KR',
                rowHeight: 65,
                firstDay: DateTime.utc(2022, 10, 4),
                lastDay: DateTime.utc(2030, 10, 4),
                focusedDay: focusedDay,
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  setState(() {
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
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
                      //if(events.isEmpty) return SizedBox();
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(top:20),
                            padding: const EdgeInsets.all(1),
                            child: Text(
                              '\n\n${money?[DateTime.parse(date.toString().substring(0,10))]}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      );
                    }
                ),

                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMMd(locale).format(date),
                  formatButtonVisible: false,
                  titleTextStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                  headerPadding: const EdgeInsets.symmetric(vertical: 4),
                  leftChevronIcon: const Icon(
                    Icons.arrow_left,
                    size: 40,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.arrow_right,
                    size: 40,
                  ),
                ),

                calendarStyle: const CalendarStyle(
                  canMarkersOverflow: true, //셀 영역 벗어남 여부
                  markersAutoAligned: true, //자동정렬
                  markerSize: 10, //마커 크기
                  markerSizeScale: 10, //마커 크기 비율
                  markerMargin: EdgeInsets.symmetric(horizontal: 3), //마진 조절
                  markersAlignment: Alignment.bottomCenter, //마커 위치
                  markersMaxCount: 2, //한줄에 마커 수
                  markersOffset: PositionedOffset(),
                  markerDecoration: BoxDecoration(//마커 모양
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),

                  isTodayHighlighted: true, //오늘 표시 여부
                  todayTextStyle: const TextStyle(//글자 조정
                    color: const Color(0xFFFAFAFA),
                    fontSize: 16,
                  ),
                  todayDecoration: const BoxDecoration(//모양 조정
                    color: const Color(0xFF9FA8DA),
                    shape: BoxShape.circle,
                  ),

                  selectedTextStyle: const TextStyle(//선택한 날 글자
                    color: const Color(0xFFFAFAFA),
                    fontSize: 16,
                  ),
                  selectedDecoration: const BoxDecoration(//선택한 날 모양
                    color: const Color(0xFF5C6BC0),
                    shape: BoxShape.circle,
                  ),

                  outsideDaysVisible: true, //다른 달 날짜 노출
                  outsideTextStyle: const TextStyle(color: const Color(0xFFAEAEAE)),
                  outsideDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),

                  weekendTextStyle: const TextStyle(
                    color: Colors.red,
                  ),
                  weekendDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),

                  cellMargin: const EdgeInsets.all(6),
                  cellPadding: const EdgeInsets.all(0),
                  cellAlignment: Alignment.center,
                ),
              ),
/*
            //캘린더 이벤트를 리스트 형식으로 출력
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: ()=> print('${value[index].title} clicked'),
                        title: Text('${value[index].title}'),
                      )
                    );
                  },
                );
              },
            )
          )
*/
            ],
          ),
        )
    );
  }
}

class Event {
  String title;
  Event(this.title);
}


