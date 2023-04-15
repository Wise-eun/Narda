import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speelow/main_screen.dart';
import 'package:speelow/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'api/api.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'SpeeLow',
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
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

  final TextEditingController _idController = TextEditingController(); //입력되는 값을 제어
  final TextEditingController _pwController = TextEditingController();

  login() async{
    try{
      var response = await http.post(
          Uri.parse(API.login),
          body:{
            'userId' : _idController.text.trim(), //오른쪽에 validate 확인할 id 입력
            'userPw' : _pwController.text.trim()
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("로그인 성공");
          User userInfo = User.fromJson(responseBody['userData']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );

        }
        else{
          print("로그인 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  validateId() async{
    try{
      var response = await http.post(
          Uri.parse(API.validateId),
          body:{
            'userId' : "user" //오른쪽에 validate 확인할 id 입력
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['exist'] == true){
          //이미 존재하는 아이디
          print("이미 존재하는 아이디");
        }
        else{
          //존재하지 않는 아이디 (사용가능한)
          print("존재하지 않는 아이디 ");
        }
      }
    }catch(e){print(e.toString());}
  }

  singUp() async{
    try{
      var response = await http.post(
          Uri.parse(API.signup),
          body: <String,String> { //오른쪽에 signup할 정보 입력
            'userId' : 'user4',
            'userPw' : 'user4!',
            'userPhoneNum' : '01044444444',
            'userName' : '이애사'
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("회원가입 성공");
        }
        else{
          print("회원가입 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  findId() async{
    try{
      var response = await http.post(
          Uri.parse(API.findId),
          body:{
            'userName' : "이애사",
            'userPhoneNum' : "01044444444"
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("아이디 찾기 성공 ");
          User userInfo = User.fromJson(responseBody['userData']);
          print("아이디 : ${userInfo.userId}");
        }
        else{
          print("아이디 찾기 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  identification() async{
    try{
      var response = await http.post(
          Uri.parse(API.identification),
          body:{
            'userId' : "user4",
            'userPhoneNum' : "01044444444"
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("본인확인 완료");
          User userInfo = User.fromJson(responseBody['userData']);
          print("아이디 : ${userInfo.userId}");
        }
        else{
          print("본인확인 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  resetPw() async{
    try{
      var response = await http.post(
          Uri.parse(API.resetPw),
          body:{
            'userId' : "user4",
            'newPw' : "user4!"
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("비밀번호 변경 완료");
        }
        else{
          print("비밀번호 변경 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  void ShowToastMessage(String msg)
  {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT
    );
  }
  Widget _userIdWidget(){
    return TextFormField(
      controller: _idController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '아이디',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value){
        if (value!.isEmpty) {// == null or isEmpty
          return '아이디를 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _passwordWidget(){
    return TextFormField(
      controller: _pwController,
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value){
        if (value!.isEmpty) {// == null or isEmpty
          return '비밀번호를 입력해주세요.';
        }
        return null;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _userIdWidget(),
                const SizedBox(
                  height: 10,
                ),
                _passwordWidget(),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:  MaterialStateProperty.all(Colors.grey[350]),
                    ),

                    onPressed: () async {
                      //firebase 코드
                      // final user = FirebaseFirestore.instance.collection("user").doc("vxO6VnTgUA9zwRPUdq53");
                      // user.update({"phone_num":"x"});
                      // db.collection("user").where("id", isEqualTo: _idController.text).where("pw", isEqualTo: _pwController.text).get().then(
                      //       (querySnapshot) {
                      //     for (var docSnapshot in querySnapshot.docs) {
                      //       print('${docSnapshot.id}');
                      //     }
                      //     if(querySnapshot.size!=0){
                      //       //로그인 성공 시
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(builder: (context) => const MainScreen()),
                      //       );
                      //     }
                      //     else{
                      //       //로그인 실패 시 실패 팝업 띄우기
                      //       String message = '사용자가 존재하지 않습니다.';
                      //   //   ShowToastMessage(message);
                      //     }
                      //   },
                      //   onError: (e) => print("Error completing: $e"),
                      // );

                      //로그인 코드
                      login();

                    },
                    child: Text('로그인')),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:  MaterialStateProperty.all(Colors.grey[350])
                    ),
                    onPressed: (){

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  SignupScreen()),
                      );},
                    child: Text('회원가입')),
                const SizedBox(
                  height: 10,
                ),
              ],
            )
        )
    );
  }
}





