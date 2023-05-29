import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';
import 'package:speelow/find_id_screen.dart';
import 'package:speelow/main_screen.dart';
import 'package:speelow/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart' hide Order;
import 'after_order_list.dart';
import 'api/api.dart';
import 'find_pw_screen.dart';
import 'firebase_options.dart' hide Order;
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'model/user.dart';
import 'model/order.dart';
import 'order_list.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


import 'api/api.dart';
import 'menu_bottom.dart';
import 'model/order.dart';
import 'model/orderDetail.dart';
import 'order_detail.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
//import 'package:flutter_hooks/flutter_hooks.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  KakaoSdk.init(nativeAppKey: '3e8531d2fdf84a885535fc7c4ac309ca');
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: '41fe7y8m8r');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //얘때문에 main에 async 넣음

  runApp(const MyApp());
}

void initialization() async {
  print('waiting for 3 seconds');
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NARDA',
      theme: ThemeData(primarySwatch: Colors.blue),
      //home: InitialSettingScreen(),
      home: Loginscreen(),
    );
  }
}

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final db = FirebaseFirestore.instance;

  final TextEditingController _idController =
  TextEditingController(); //입력되는 값을 제어
  final TextEditingController _pwController = TextEditingController();

  login() async {
    try {
      var response = await http.post(Uri.parse(API.login), body: {
        'userId': _idController.text.trim(), //오른쪽에 validate 확인할 id 입력
        'userPw': _pwController.text.trim()
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          showToastMessage("로그인 성공");
          print("로그인 성공");
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(userId: _idController.text)),
          );
        } else {
          showToastMessage("로그인 실패");
          print("로그인 실패");
        }
      }
    } catch (e) {
      showToastMessage("로그인 실패");
      print(e.toString());
    }
  }

  void showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        fontSize: 15,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }

  Widget _userIdWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: TextFormField(
          controller: _idController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: '아이디',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xfff1f2f3),
          ),
        ));
  }

  Widget _passwordWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: TextFormField(
          controller: _pwController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: '비밀번호',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xfff1f2f3),
          ),
        ));
  }

  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Container(
                margin: EdgeInsets.only(left: 45, right: 45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Image(
                      image: AssetImage('asset/images/logo.png'),
                      width: 150,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    _userIdWidget(),
                    const SizedBox(
                      height: 10,
                    ),
                    _passwordWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      // width: 250,
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0xfff9d94b),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)))),
                          onPressed: () async {
                            login();
                          },
                          child: Text('로그인', style: TextStyle(color: Colors.black))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FindIdScreen()),
                              );
                            },
                            child: Text(
                              '아이디 찾기',
                              style: TextStyle(fontSize: 13, color: Colors.black),
                            )),
                        const SizedBox(
                          width: 3,
                          height: 20,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xfff1f2f3)),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FindPwScreen()),
                              );
                            },
                            child: Text('비밀번호 찾기',
                                style: TextStyle(fontSize: 13, color: Colors.black))),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0xfff1f2f3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)))),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                          child: Text('회원가입', style: TextStyle(color: Colors.black))),
                    ),
                    Spacer(),
                  ],
                )
            )
        ));
  }
}
