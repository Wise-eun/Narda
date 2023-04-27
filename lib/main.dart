import 'dart:convert';
import 'package:flutter/material.dart';
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
      //home: InitialSettingScreen(),
      home:Loginscreen(),
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
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(userId: _idController.text)),
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
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          print("아이디 : ${userInfo.userId}");
        }
        else{
          print("본인확인 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  orderList() async{
    try{
      List<Order> orders = [];

      var response = await http.post(
        Uri.parse(API.orderList),
          body:{
            'sort' : "deliveryFee",
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("오더 리스트 불러오기 성공");

          List<dynamic> responseList = responseBody['userData'];
          for(int i=0; i<responseList.length; i++){
            print(Order.fromJson(responseList[i]));
            orders.add(Order.fromJson(responseList[i]));
          }
        }
        else {
          print("오더 리스트 불러오기 실패");
        }
        print(orders.runtimeType);
        return orders;
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
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:  MaterialStateProperty.all(Colors.grey[350])
                    ),
                    onPressed: (){

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  FindIdScreen()),
                      );},
                    child: Text('아이디 찾기')),
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
                        MaterialPageRoute(builder: (context) =>  FindPwScreen()),
                      );},
                    child: Text('비밀번호 찾기')),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:  MaterialStateProperty.all(Colors.grey[350])
                    ),
                    onPressed: (){
                      Future<dynamic> orders = orderList();
                      orders.then((val) {
                        // int가 나오면 해당 값을 출력
                        print('val: $val');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  ListviewPage()),

                          // MaterialPageRoute(builder: (context) =>  ListviewPage(orders: val)),
                        );
                      }).catchError((error) {
                        // error가 해당 에러를 출력
                        print('error: $error');
                      });

                      },
                    child: Text('오더 리스트 뷰')),
              ],
            )
        )
    );
  }
}





