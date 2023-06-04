import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speelow/slider_tickmark_shape.dart';
import 'package:speelow/tutorial_screen.dart';

class InitialSettingScreen extends StatefulWidget {
  const InitialSettingScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<InitialSettingScreen> createState() => _InitialSettingScreenState();
}

class _InitialSettingScreenState extends State<InitialSettingScreen> {
  static bool isSwitched_helmet = false;
  static bool isSwitched_safety = true;
  static double _voiceSpeedValue = 3;
  static double _voiceVolumeValue = 3;
  static double _deliveryRadius = 3;


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




  @override
  void initState() {
    super.initState();
    getPreferencesData();
  }
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        shape: Border(
            bottom: BorderSide(
              color: Color(0xfff1f2f3),
              width: 2,
            )),
        title: Text('사전 설정',
            style: TextStyle(color: Colors.black, fontSize: 18)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: mediaQuery.size.width,
                        height: 30,
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
                            activeColor: Color(0xff65C466),)
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
                              activeTickMarkColor: Color(0xff3478F6),
                              activeTrackColor: Color(0xff3478F6),
                              //   valueIndicatorColor: Colors.black,
                              //  disabledThumbColor:Colors.black,
                              trackHeight: 12,
                              tickMarkShape:const LineSliderTickMarkShape(),
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7,)
                          )

                          , child:    Slider(
                        min: 1,
                        max: 5,
                        value: _voiceSpeedValue,
                        divisions: 4,
//activeColor: Color(0xff4F40FD),
                        thumbColor: Color(0xff3478F6),
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
                              activeTickMarkColor: Color(0xff3478F6),
                              activeTrackColor: Color(0xff3478F6),
                              //   valueIndicatorColor: Colors.black,
                              //  disabledThumbColor:Colors.black,
                              trackHeight: 12,
                              tickMarkShape:const LineSliderTickMarkShape(),
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7,)
                          )

                          , child:    Slider(
                        min: 1,
                        max: 5,
                        value: _voiceVolumeValue,
                        divisions: 4,
//activeColor: Color(0xff4F40FD),
                        thumbColor: Color(0xff3478F6),

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
                            activeColor: Color(0xff65C466),),
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
                              activeTickMarkColor: Color(0xff3478F6),
                              activeTrackColor: Color(0xff3478F6),
                              //   valueIndicatorColor: Colors.black,
                              //  disabledThumbColor:Colors.black,
                              trackHeight: 12,
                              tickMarkShape:const LineSliderTickMarkShape(),
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7,)
                          )

                          , child:    Slider(
                        min: 1,
                        max: 5,
                        value: _deliveryRadius,
                        divisions: 4,
//activeColor: Color(0xff4F40FD),
                        thumbColor: Color(0xff3478F6),

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
              height: 50,
            )
     ,
            SizedBox(
              width: 80,
              height: 40,
              child: ElevatedButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TutorialScreen(userId: widget.userId,)),
                );
              }, child: Text("확인",
                style: TextStyle(fontSize: 17),),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(	//모서리를 둥글게
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color(0xff3478F6)),

              ),
            )
          ],
        ),
      )
    );
  }
}