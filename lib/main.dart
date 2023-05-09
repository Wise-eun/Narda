import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';
import 'package:speelow/find_id_screen.dart';
import 'package:speelow/main_screen.dart';
import 'package:speelow/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart' hide Order;
import 'api/api.dart';
import 'find_pw_screen.dart';
import 'firebase_options.dart' hide Order;
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'model/user.dart';
import 'model/order.dart';
import 'initial_setting_screen.dart';
import 'order_list.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

void main() async {
  KakaoSdk.init(nativeAppKey: '3e8531d2fdf84a885535fc7c4ac309ca');
  //await local.initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: '41fe7y8m8r');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //얘때문에 main에 async 넣음

  runApp(const MyApp());
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
          print("로그인 성공");
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TestPage(userId: _idController.text)),
          );
        } else {
          print("로그인 실패");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  validateId() async {
    try {
      var response = await http.post(Uri.parse(API.validateId), body: {
        'userId': "user" //오른쪽에 validate 확인할 id 입력
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['exist'] == true) {
          //이미 존재하는 아이디
          print("이미 존재하는 아이디");
        } else {
          //존재하지 않는 아이디 (사용가능한)
          print("존재하지 않는 아이디 ");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  singUp() async {
    try {
      var response =
          await http.post(Uri.parse(API.signup), body: <String, String>{
        //오른쪽에 signup할 정보 입력
        'userId': 'user4',
        'userPw': 'user4!',
        'userPhoneNum': '01044444444',
        'userName': '이애사'
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("회원가입 성공");
        } else {
          print("회원가입 실패");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  identification() async {
    try {
      var response = await http.post(Uri.parse(API.identification),
          body: {'userId': "user4", 'userPhoneNum': "01044444444"});
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("본인확인 완료");
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          print("아이디 : ${userInfo.userId}");
        } else {
          print("본인확인 실패");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  orderList() async {
    try {
      List<Order> orders = [];

      var response = await http.post(Uri.parse(API.orderList), body: {
        'sort': "deliveryFee",
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for (int i = 0; i < responseList.length; i++) {
            print(Order.fromJson(responseList[i]));
            orders.add(Order.fromJson(responseList[i]));
          }
        } else {
          print("오더 리스트 불러오기 실패");
        }
        print(orders.runtimeType);
        return orders;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void ShowToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 20,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            if (value!.isEmpty) {
              return '아이디를 입력해주세요.';
            }
            return null;
          },
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            if (value!.isEmpty) {
              return '비밀번호를 입력해주세요.';
            }
            return null;
          },
        ));
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
