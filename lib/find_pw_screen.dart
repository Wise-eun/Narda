import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'model/user.dart';
import 'api/api.dart';

class FindPwScreen extends StatefulWidget {
  const FindPwScreen({Key? key}) : super(key: key);
  @override
  _FindPwScreenState createState() => _FindPwScreenState();
}

class _FindPwScreenState extends State<FindPwScreen> {
  final TextEditingController _phoneNumController = TextEditingController(); //입력되는 값을 제어
  final TextEditingController _idController = TextEditingController();

  Widget _phoneNumWidget() {
    return TextFormField(
      controller: _phoneNumController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '전화번호',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        if (value!.isEmpty) {
          // == null or isEmpty
          return '전화번호를 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _idWidget() {
    return TextFormField(
      controller: _idController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '아이디',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        if (value!.isEmpty) {
          // == null or isEmpty
          return '아이디를 입력해주세요.';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _phoneNumWidget(),
                const SizedBox(
                  height: 10,
                ),
                _idWidget(),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () async {
                      //인증번호 보내는 코드
                    },
                    child: Text('인증번호 보내기')),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewPwScreen(userId: _idController.text)),
                      );
                    },
                    child: Text('비밀번호 찾기')),
                const SizedBox(
                  height: 10,
                )
              ],
            )));
  }
}

class NewPwScreen extends StatefulWidget {
  const NewPwScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<NewPwScreen> createState() => _NewPwScreenState();
}

class _NewPwScreenState extends State<NewPwScreen> {
  final TextEditingController _pwController = TextEditingController(); //입력되는 값을 제어
  final TextEditingController _pwCheckController = TextEditingController();

  Widget _pwWidget() {
    return TextFormField(
      controller: _pwController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        if (value!.isEmpty) {
          // == null or isEmpty
          return '비밀번호를 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _pwCheckWidget() {
    return TextFormField(
      controller: _pwCheckController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호 확인',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        if (value!.isEmpty) {
          // == null or isEmpty
          return '비밀번호를 입력해주세요.';
        }
        return null;
      },
    );
  }


  resetPw() async{
    if(_pwController.text == _pwCheckController.text){
      try{
        var response = await http.post(
            Uri.parse(API.resetPw),
            body:{
              'userId' : widget.userId,
              'newPw' : _pwController.text
            }
        );
        if(response.statusCode == 200){
          var responseBody = jsonDecode(response.body);
          if(responseBody['success'] == true){
            print("비밀번호 변경 완료");
            Navigator.pop(context);
            Navigator.pop(context);
          }
          else{
            print("비밀번호 변경 실패");
          }
        }
      }catch(e){print(e.toString());}
    }
    else{
      print("비밀번호가 일치하지 않습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.blue[200],
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pwWidget(),
              SizedBox(
                height: 10,
              ),
              _pwCheckWidget(),
              SizedBox(
                height: 10,
              ),

              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    resetPw();
                  },
                  child: Text("새 비밀번호 설정"))
            ],
          ),
        )

    );
  }
}