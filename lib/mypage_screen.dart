import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speelow/reset_pw.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'api/api.dart';
import 'calendar_screen.dart';
import 'menu_bottom.dart';
import 'package:speelow/model/user.dart';

RiderUser userInfo = RiderUser("", "", "", "");

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool callOk = false;
  bool isSwitched_helmet = false;
  bool isSwitched_safety = true;
  double _voiceSpeedValue = 3;
  double _voiceVolumeValue = 3;
  double _deliveryRadius = 3;

  @override
  void initState() {
    // TODO: implement initState
    getRider();
    super.initState();
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
    return Scaffold(
        appBar: AppBar(
          title: Text('마이페이지'),
          centerTitle: true,
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
                                        builder: (context) => CalendarScreen(riderId: userInfo.userId,)),
                                  );
                                },
                                child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey,
                                )
                            ),
                          ],
                        ),
                        //수입 가져오는 로직 필요
                        Text("오늘의 수입은 127,000원 입니다.",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 18)),
                        SizedBox(
                          width: mediaQuery.size.width,
                          height: 15,
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
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("내 AR 헬멧", style: TextStyle(fontSize: 18)),
                            Switch(
                              value: isSwitched_helmet,
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  isSwitched_helmet = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Text("음성 출력 속도", style: TextStyle(fontSize: 17)),
                      ])),
              Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SfSlider(
                          min: 1,
                          max: 5,
                          value: _voiceSpeedValue,
                          interval: 1,
                          showTicks: true,
                          showLabels: false,
                          enableTooltip: false,
                          minorTicksPerInterval: 1,
                          onChanged: (dynamic value) {
                            setState(() {
                              _voiceSpeedValue = value.toInt().toDouble();
                            });
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
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
                        SfSlider(
                          min: 1,
                          max: 5,
                          value: _voiceVolumeValue,
                          interval: 1,
                          showTicks: true,
                          showLabels: false,
                          enableTooltip: false,
                          minorTicksPerInterval: 1,
                          onChanged: (dynamic value) {
                            setState(() {
                              _voiceVolumeValue = value.toInt().toDouble();
                            });
                          },
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 20),
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
                          height: 15,
                        ),
                        Text("배달 및 환경 설정", style: TextStyle(fontSize: 18)),
                        Row(
                          children: [
                            Text("안전경로", style: TextStyle(fontSize: 17)),
                            Switch(
                              value: isSwitched_safety,
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  isSwitched_helmet = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Text("배달 반경", style: TextStyle(fontSize: 17)),
                      ])),
              Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SfSlider(
                          min: 1,
                          max: 5,
                          value: _deliveryRadius,
                          interval: 1,
                          showTicks: true,
                          showLabels: false,
                          enableTooltip: false,
                          minorTicksPerInterval: 1,
                          onChanged: (dynamic value) {
                            setState(() {
                              _deliveryRadius = value.toInt().toDouble();
                            });
                          },
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 15),
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
                        Text("내 정보 관리", style: TextStyle(fontSize: 18)),
                        SizedBox(
                          height: 10,
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
                          height: 7,
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
                      ])),
            ],
          ),
        ));
  }
}
