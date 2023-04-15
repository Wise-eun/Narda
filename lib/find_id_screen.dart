import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  findId() async {
    try {
      var response = await http.post(Uri.parse(API.findId),
          body: {
            'userName': _nameController.text,
            'userPhoneNum': _phoneNumController.text
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("아이디 찾기 성공 ");
          RiderUser userInfo = RiderUser.fromJson(responseBody['userData']);
          print("아이디 : ${userInfo.userId}");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowIdScreen(userId:userInfo.userId)),
          );
        }
        else {
          print("아이디 찾기 실패");
        }}
      } catch (e) {
      print(e.toString());
    }
  }

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

  Widget _nameWidget() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '이름',
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        if (value!.isEmpty) {
          // == null or isEmpty
          return '이름을 입력해주세요.';
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
        _nameWidget(),
        const SizedBox(
          height: 20,
        ),
        TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey[350]),
            ),
            onPressed: () async {
              findId();
            },
            child: Text('아이디 찾기')),
        const SizedBox(
          height: 10,
        )
      ],
    )));
  }
}

class ShowIdScreen extends StatefulWidget {
  const ShowIdScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<ShowIdScreen> createState() => _ShowIdScreenState();
}

class _ShowIdScreenState extends State<ShowIdScreen> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.blue[200],
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.userId),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("돌아가기"))
            ],
          ),
        )

    );
  }
}