import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _idTextEditController = TextEditingController();
  final _pwTextEditController = TextEditingController();
  final _pwCheckTextEditController = TextEditingController();


@override
  void dispose() {
    // TODO: implement dispose
  _idTextEditController.dispose();
  _pwTextEditController.dispose();
  _pwCheckTextEditController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.pink[100],
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("회원가입 화면입니다."),
              SizedBox(
                height: 10,
              ),

              Container(

                height: 45,
                margin: EdgeInsets.only(left:50,right:50),
                child:    TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '아이디',
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("중복확인"))
              ,
              SizedBox(
                height: 15,
              )
              ,
              Container(
                height: 45,
                margin: EdgeInsets.only(left:50,right:50),
                child:    TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '비밀번호',
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                margin: EdgeInsets.only(left:50,right:50),
                child:    TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '비밀번호 확인',
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("회원가입"))
              ,
              SizedBox(
                height: 10,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("돌아가기"))
            ],
          ),
        )



    );
  }
}


