import 'dart:convert';

import 'package:flutter/material.dart';
import 'api/api.dart';
import 'model/user.dart';
import 'package:http/http.dart' as http;


class ResetPwScreen extends StatefulWidget {
  const ResetPwScreen({Key? key, required this.user}) : super(key: key);
  final RiderUser user;

  @override
  _ResetPwScreenState createState() => _ResetPwScreenState();
}

class _ResetPwScreenState extends State<ResetPwScreen> {
  final TextEditingController _currentPwController =
      TextEditingController(); //입력되는 값을 제어
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _newPwCheckController = TextEditingController();

  resetPw(userId, newPw) async{
      try{
        var response = await http.post(
            Uri.parse(API.resetPw),
            body:{
              'userId' : userId,
              'newPw' : newPw,
            }
        );
        if(response.statusCode == 200){
          var responseBody = jsonDecode(response.body);
          if(responseBody['success'] == true){
            print("비밀번호 변경 완료");
            Navigator.pop(context);
          }
          else{
            print("비밀번호 변경 실패");
          }
        }
      }catch(e){print(e.toString());}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('마이페이지'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("현재 비밀번호", style: TextStyle(fontSize: 18),),
                      SizedBox(
                        height: 45,
                        child: TextFormField(
                          controller: _currentPwController,
                          keyboardType: TextInputType.text,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              // == null or isEmpty
                              return '현재 비밀번호를 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 15,),

                      Text("새 비밀번호", style: TextStyle(fontSize: 18),),
                SizedBox(
                    height: 45,
                    child: TextFormField(
                        controller: _newPwController,
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            // == null or isEmpty
                            return '새 비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                      )),
                      SizedBox(height: 15,),

                      Text("새 비밀번호 확인", style: TextStyle(fontSize: 18)),

                SizedBox(
                    height: 45,
                    child: TextFormField(
                        controller: _newPwCheckController,
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            // == null or isEmpty
                            return '새 비밀번호 확인을 입력해주세요.';
                          }
                          return null;
                        },
                      )),
                      TextButton(onPressed: () {
                        if(widget.user.userPw == _currentPwController.text.trim()){
                          if(_newPwController.text.trim() == _newPwCheckController.text.trim()){
                            resetPw(widget.user.userId ,_newPwController.text.trim());
                          }
                          else{
                            print("새로운 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                          }
                        }
                        else{
                          //팝업 띄워야됨
                          print("현재 비밀번호가 틀렸습니다.");
                        }
                      }, child: Text("비밀번호 변경")),
                    ]))));
  }
}
