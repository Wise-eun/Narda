import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speelow/reset_pw.dart';
import 'package:http/http.dart' as http;
import 'package:speelow/slider_tickmark_shape.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'api/api.dart';
import 'calendar_screen.dart';
import 'menu_bottom.dart';
import 'package:speelow/model/user.dart';

import 'model/calendar.dart';

RiderUser userInfo = RiderUser("", "", "", "");
List<calendar> order = [];
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool callOk = false;
  static bool isSwitched_helmet = false;
  static bool isSwitched_safety = true;
  static double _voiceSpeedValue = 3;
  static double _voiceVolumeValue = 3;
  static double _deliveryRadius = 3;

  double todayIncome=0;

  @override
  void initState() {
    // TODO: implement initState
    getPreferencesData();
    getRider();
    getIncome();
    super.initState();
  }

  static void getPreferencesData() async
  {
final SharedPreferences pref = await SharedPreferences.getInstance();
try{
  isSwitched_helmet = pref.getBool('isSwitched_helmet')!;
  isSwitched_safety = pref.getBool('isSwitched_safety')!;
  _voiceSpeedValue = pref.getDouble('_voiceSpeedValue')!;
  _voiceVolumeValue = pref.getDouble('_voiceVolumeValue')! ;
  _deliveryRadius = pref.getDouble('_deliveryRadius')! ;

}catch(e){}
  }

  static void UpdatePreferences() async
  {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('isSwitched_helmet',isSwitched_helmet);
    pref.setBool('isSwitched_safety',isSwitched_safety);
    pref.setDouble('_voiceSpeedValue',_voiceSpeedValue );
    pref.setDouble('_voiceVolumeValue',_voiceVolumeValue );
    pref.setDouble('_deliveryRadius',_deliveryRadius );
  }


  getIncome() async{
    try {
      var response = await http.post(Uri.parse(API.calendar), body: {
        'userId': widget.userId.toString(),
      });
      if (response.statusCode == 200) {
        callOk = true;
        var responseBody = jsonDecode(response.body);
        todayIncome=0;
        if (responseBody['success'] == true) {
          callOk = true;
          print("수입 내역 가져오기");
          print(responseBody['userData']);
          List<dynamic> responseList = responseBody['userData'];
          responseList2 = responseBody['userData'];
          order.clear();
          for(int i=0;i<responseList.length;i++) {
            order.add(calendar.fromJson(responseList[i]));
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

  getRider() async{
    try{
      var response = await http.post(
          Uri.parse(API.getRider),
          body:{
            'userId' : widget.userId, //오른쪽에 validate 확인할 id 입력
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          callOk = true;
          print("유저 가져오기 성공");
          userInfo = RiderUser.fromJson(responseBody['userData']);
          setState(() {

          });
        }
        else{
          print("유저 가져오기 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    todayIncome=0;
    for(int i=0;i<order.length;i++) {
      if((DateTime.now().toString().substring(0, 10) == order[i].orderTime.substring(0, 10))) {
        todayIncome=todayIncome+order[i].deliveryFee;
        print(order[i].orderTime);
      }
    }

    return Scaffold(
        bottomNavigationBar: MenuBottom(userId: widget.userId, tabItem: TabItem.mypage,),
        appBar: AppBar(
          title: Container(
            child: Text(
              "마이페이지",
              style: TextStyle(color: Colors.black),
            ),
          ),
          shape: Border(
              bottom: BorderSide(
                color: Color(0xfff1f2f3),
                width: 2,
              )),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Color(0xfff1f2f3),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: mediaQuery.size.width,
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            callOk? Text(
                              "${userInfo?.userName} 라이더님,",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ) : const Text(
                              " 라이더님,",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            )
                            ,
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.only(left: 2, right: 2, top: 4, bottom: 4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7)))
                              ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CalendarScreen(userId: userInfo.userId,)),
                                  );
                                },
                                child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey,
                                )
                            ),
                          ],
                        ),
                        //수입 가져오는 로직 필요
                        Text("오늘의 수입은 $todayIncome원 입니다.",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        SizedBox(
                          width: mediaQuery.size.width,
                          height: 25,
                        ),
                      ])),
              SizedBox(
                width: mediaQuery.size.width,
                height: 15,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xfff1f2f3)),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: mediaQuery.size.width,
                          height: 25,
                        ),
                        Row(//https://flutteragency.com/how-to-customize-the-switch-button-in-a-flutter/
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("내 AR 헬멧", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
                           FlutterSwitch(value: isSwitched_helmet,
                             onToggle: (bool value) {
                               isSwitched_helmet = value;
                               UpdatePreferences();
                             setState(() {
                               isSwitched_helmet = value;
                             });

                           },height: 25,width: 50,toggleSize: 23,
                           activeColor: Color(0xff4F40FD),)
                           ],
                           ),
                           SizedBox(height: 20,),
                           Text("음성 출력 속도", style: TextStyle(fontSize: 17)),
                           ])),
                           Container(
                           margin: EdgeInsets.only(left: 10, right: 10),
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                           SliderTheme(
                           data: const SliderThemeData(
                           inactiveTickMarkColor: Colors.grey,
                           inactiveTrackColor: Color(0xfff1f2f3),
                           activeTickMarkColor: Color(0xff4F40FD),
                           activeTrackColor: Color(0xff4F40FD),
                           //   valueIndicatorColor: Colors.black,
                           //  disabledThumbColor:Colors.black,
                           trackHeight: 18,
                           tickMarkShape:const LineSliderTickMarkShape(),
                           thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10,)
                           )

                           , child:    Slider(
                           min: 1,
                           max: 5,
                           value: _voiceSpeedValue,
                           divisions: 4,
//activeColor: Color(0xff4F40FD),
                           thumbColor: Color(0xff4F40FD),
                           onChanged: (dynamic value) {
                             _voiceSpeedValue = value.toInt().toDouble();
                             UpdatePreferences();
                           setState(() {
                           _voiceSpeedValue = value.toInt().toDouble();
                           });
                           },
                           )),

                           Container(
                           margin: EdgeInsets.only(left: 20, right: 20),
                           child: const Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                           Text("느리게"),
                           Text("보통"),
                           Text("빠르게"),
                           ],
                           ),
                           )
                           ])),
                           Container(
                           margin: EdgeInsets.only(left: 20, top: 10),
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                           SizedBox(
                           width: mediaQuery.size.width,
                           height: 10,
                           ),
                           Text("음성 크기", style: TextStyle(fontSize: 17)),
                           SizedBox(
                           width: mediaQuery.size.width,
                           ),
                           ],
                           ),
                           ),
                           Container(
                           margin: EdgeInsets.only(left: 10, right: 10),
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                           SliderTheme(
                           data: const SliderThemeData(
                           inactiveTickMarkColor: Colors.grey,
                           inactiveTrackColor: Color(0xfff1f2f3),
                           activeTickMarkColor: Color(0xff4F40FD),
                           activeTrackColor: Color(0xff4F40FD),
                           //   valueIndicatorColor: Colors.black,
                           //  disabledThumbColor:Colors.black,
                           trackHeight: 18,
                           tickMarkShape:const LineSliderTickMarkShape(),
                           thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10,)
                           )

                           , child:    Slider(
                           min: 1,
                           max: 5,
                           value: _voiceVolumeValue,
                           divisions: 4,
//activeColor: Color(0xff4F40FD),
                           thumbColor: Color(0xff4F40FD),

                           onChanged: (dynamic value) {
                             _voiceVolumeValue = value.toInt().toDouble();
                             UpdatePreferences();
                           setState(() {
                           _voiceVolumeValue = value.toInt().toDouble();
                           });
                           },
                           )),
                           Container(
                           margin:
                           EdgeInsets.only(left: 20, right: 20, bottom: 20),
                           child: const Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                           Text("작게"),
                           Text("보통"),
                           Text("크게"),
                           ],
                           ),
                           )
                           ])),
                           SizedBox(
                           width: mediaQuery.size.width,
                           height: 15,
                           child: DecoratedBox(
                           decoration: BoxDecoration(color: Color(0xfff1f2f3)),
                           ),
                           ),
                           Container(
                           margin: EdgeInsets.only(left: 20),
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                           SizedBox(
                           width: mediaQuery.size.width,
                           height: 25,
                           ),
                           Text("배달 및 환경 설정", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
                           SizedBox(height: 20,),
                             Row(
                           children: [
                           Text("안전경로", style: TextStyle(fontSize: 17)),
                             SizedBox(width:10),
                             FlutterSwitch(value: isSwitched_safety,
                               onToggle: (bool value) {
                                 isSwitched_safety = value;
                                 UpdatePreferences();
                                 setState(() {
                                   isSwitched_safety = value;
                                 });

                               },height: 25,width: 50,toggleSize: 23,
                               activeColor: Color(0xff4F40FD),),
                           ],
                           ),
                           SizedBox(height: 10,),
                           Text("배달 반경", style: TextStyle(fontSize: 17)),
                           ])),
                           Container(
                           margin: EdgeInsets.only(left: 10, right: 10),
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                           SliderTheme(
                           data: const SliderThemeData(
                           inactiveTickMarkColor: Colors.grey,
                           inactiveTrackColor: Color(0xfff1f2f3),
                           activeTickMarkColor: Color(0xff4F40FD),
                           activeTrackColor: Color(0xff4F40FD),
                           //   valueIndicatorColor: Colors.black,
                           //  disabledThumbColor:Colors.black,
                           trackHeight: 18,
                           tickMarkShape:const LineSliderTickMarkShape(),
                           thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10,)
                           )

                           , child:    Slider(
                           min: 1,
                           max: 5,
                           value: _deliveryRadius,
                           divisions: 4,
//activeColor: Color(0xff4F40FD),
                           thumbColor: Color(0xff4F40FD),

                           onChanged: (dynamic value) {
                             _deliveryRadius = value.toInt().toDouble();
                             UpdatePreferences();
                           setState(() {
                           _deliveryRadius = value.toInt().toDouble();
                           });
                           },
                           )),

                           Container(
                           margin:
                           EdgeInsets.only(left: 20, right: 20, bottom: 15),
                           child: const Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                           Text("1km"),
                           Text("3km"),
                           Text("5km"),
                           ],
                           ),
                           )
                           ])),
                           SizedBox(
                           width: mediaQuery.size.width,
                           height: 15,
                           child: DecoratedBox(
                           decoration: BoxDecoration(color: Color(0xfff1f2f3)),
                           ),
                           ),
                           Container(
                           margin: EdgeInsets.only(left: 20),
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                           SizedBox(
                           width: mediaQuery.size.width,
                           height: 15,
                           ),
                           Text("내 정보 관리", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
                           SizedBox(
                           height: 20,
                           ),
                           TextButton(
                           style: TextButton.styleFrom(
                           minimumSize: Size.zero,
                           padding: EdgeInsets.zero,
                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                           child:
                           Text("비밀번호 변경", style: TextStyle(fontSize: 17, color: Colors.black)),
                           onPressed: () {
                           Navigator.push(
                           context,
                           MaterialPageRoute(
                           builder: (context) => ResetPwScreen(user: userInfo,)),
                           );
                           },
                           ),
                           SizedBox(
                           height: 10,
                           ),
                           TextButton(
                           style: TextButton.styleFrom(
                           minimumSize: Size.zero,
                           padding: EdgeInsets.zero,
                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                           child: Text("로그아웃", style: TextStyle(fontSize: 17, color: Colors.black)),
                           onPressed: () {
                           //로그아웃 할 것인지 여부 확인 팝업 띄우기
                           Navigator.of(context).popUntil((route) => route.isFirst);
                           },
                           ),
                             SizedBox(height: 30)
                           ])),
                           ],
                           ),
                           ));
                           }
                           }

