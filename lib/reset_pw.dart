import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
            Fluttertoast.showToast(
                msg: "비밀번호 변경이 완료되었습니다.",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                fontSize: 15,
                textColor: Colors.white,
            );
            Navigator.pop(context);
          }
          else{
            print("비밀번호 변경 실패");
          }
        }
      }catch(e){print(e.toString());}
  }

  Widget _currentPwWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          controller: _currentPwController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: '현재 비밀번호',
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

  Widget _newPwWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
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
                      _currentPwWidget(),
                      const SizedBox(height: 10),
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
                        if(widget.user.userPw == _currentPwController.text.trim()){
                          if(_newPwController.text.trim() == _newPwCheckController.text.trim()){
                            resetPw(widget.user.userId ,_newPwController.text.trim());
                            print("비밀번호 변경 완료");

                          }
                          else{
                            print("새로운 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                            Fluttertoast.showToast(
                                msg: "새로운 비밀번호와 비밀번호 확인이 일치하지 않습니다.",
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                fontSize: 15.0
                            );
                          }
                        }
                        else{
                          //팝업 띄워야됨
                          print("현재 비밀번호가 틀렸습니다.");
                          Fluttertoast.showToast(
                              msg: "현재 비밀번호가 틀렸습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              fontSize: 15.0
                          );
                        }
                      }, child: Text("비밀번호 변경", style: TextStyle(color: Colors.white, fontSize: 20),)),

                      )]))


            /*child: Container(
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

                    ]))*/

    ));
  }
}
