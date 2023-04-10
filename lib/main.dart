import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speelow/main_screen.dart';
import 'package:speelow/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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
                      var url = Uri.parse('http://speelow.ivyro.net/login.php');

                      //회원가입 할 때 사용할 코드
                      // http.Response response = await http.post(url,
                      //     body: <String,String> {
                      //       'userId' : 'user2',
                      //       'userPw' : 'user2!',
                      //       'userPhoneNum' : '01032123481'
                      //     });

                      //로그인 할 때 사용하는 코드
                      print(_idController.text + _pwController.text);
                      http.Response response = await http.post(url,
                          body: <String,String> {
                            'userId' : _idController.text,
                            'userPw' : _pwController.text
                          });
                      var data = json.decode(response.body);
                      print(data.toString());
                      if(data.toString() == "Success"){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      }
                      else{
                        String message = '사용자가 존재하지 않습니다.';
                        print(message);
                        // showToast(message);
                      }
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





