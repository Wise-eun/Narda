import 'dart:convert';

import 'package:flutter/material.dart';
import 'api/api.dart';
import 'model/user.dart';
import 'package:http/http.dart' as http;


class AfterFindPwScreen extends StatefulWidget {
  const AfterFindPwScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  _AfterFindPwScreenScreenState createState() => _AfterFindPwScreenScreenState();
}

class _AfterFindPwScreenScreenState extends State<AfterFindPwScreen> {
  final TextEditingController _currentPwController =
  TextEditingController(); //입력되는 값을 제어
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _newPwCheckController = TextEditingController();

  resetPw( newPw) async{
    try{
      var response = await http.post(
          Uri.parse(API.resetPw),
          body:{
            'userId' : widget.userId,
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

  Widget _newPwWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        //height: 40,
        child: TextFormField(
          controller: _newPwController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: '새 비밀번호',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xfff1f2f3),
            contentPadding: EdgeInsets.fromLTRB(15, 5, 0, 5),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ));
  }
  Widget _newPwCheckWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        //height: 40,
        child: TextFormField(
          controller: _newPwCheckController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: '새 비밀번호 확인',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xfff1f2f3),
            contentPadding: EdgeInsets.fromLTRB(15, 5, 0, 5),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            shape: Border(
                bottom: BorderSide(
                  color: Color(0xfff1f2f3),
                  width: 2,
                )),
            title: Text('비밀번호 변경',
                style: TextStyle(color: Colors.black, fontSize: 18)),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        backgroundColor: Colors.white,


        body: Center(
            child: Container(
                margin: const EdgeInsets.only(left: 45, right: 45),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Text("새 비밀번호", style: TextStyle(fontSize: 18),),
                      _newPwWidget(),
                      const SizedBox(height: 10),
                      _newPwCheckWidget(),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 200,
                        height: 45,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFF3478F6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                if(_newPwController.text.trim() == _newPwCheckController.text.trim()){
                                  resetPw(_newPwController.text.trim());
                                }
                                else{
                                  print("새로운 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                                }
                              }, child: Text("비밀번호 변경", style: TextStyle(color: Colors.white, fontSize: 20),))
                      ),
                    ]))));
  }
}
