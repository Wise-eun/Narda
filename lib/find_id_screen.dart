import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'model/user.dart';
import 'api/api.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({Key? key}) : super(key: key);

  @override
  _FindIdScreenState createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final TextEditingController _phoneNumController =
      TextEditingController(); //입력되는 값을 제어
  final TextEditingController _nameController = TextEditingController();
  String showIdText = "";

  void showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        fontSize: 15,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }

  findId() async {
    try {
      var response = await http.post(Uri.parse(API.findId), body: {
        'userName': _nameController.text,
        'userPhoneNum': _phoneNumController.text
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("아이디 찾기 성공 ");
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          print("아이디 : ${userInfo.userId}");
          showIdText = "아이디 : ${userInfo.userId}";
          setState(() {});
        } else {
          print("아이디 찾기 실패");
          showToastMessage("해당 정보가 존재하지 않습니다.");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _phoneNumWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: TextFormField(
            controller: _phoneNumController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              labelText: '전화번호',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xfff1f2f3),
            ),
            ));
  }

  Widget _nameWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            labelText: '이름',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xfff1f2f3),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            shape: Border(
                bottom: BorderSide(
              color: Color(0xfff1f2f3),
              width: 2,
            )),
            title: Text('아이디 찾기',
                style: TextStyle(color: Colors.black, fontSize: 17)),
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
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
              ),
              _phoneNumWidget(),
              const SizedBox(height: 10),
              _nameWidget(),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 45,
                child:TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF3478F6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    onPressed: () async {findId();},
                    child: Text('아이디 찾기', style: TextStyle(color: Colors.white, fontSize: 20))),
              ),
              const SizedBox(height: 10),
              Text(showIdText),
            ],)
          )
        ));
  }
}