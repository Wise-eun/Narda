import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast_web.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _idTextEditController = TextEditingController();
  final _pwTextEditController = TextEditingController();
  final _pwCheckTextEditController = TextEditingController();
  final _phoneTextEditController = TextEditingController();

final db = FirebaseFirestore.instance;
  bool checkID = false;
  @override
  void dispose() {
    // TODO: implement dispose
  _idTextEditController.dispose();
  _pwTextEditController.dispose();
  _pwCheckTextEditController.dispose();
  _phoneTextEditController.dispose();
    super.dispose();
  }

  void createUserData(String id, String phone_num, String pw)
  {
final userCollectionReference = db.collection("user").doc();
userCollectionReference.set({
  "id":id,
  "phone_num":phone_num,
  "pw":pw,
});
  }

  void CheckUserID()
  {
if(_idTextEditController.text == "")
  {
    ShowToastMessage("아이디 값을 입력해주세요");
  }
else
  {
    db.collection("user").where("id", isEqualTo: _idTextEditController.text).get().then(
            (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            print('${docSnapshot.id}');
          }
          if (querySnapshot.size != 0) {
            //중복되는 아이디 존재
            ShowToastMessage("사용할 수 없는 아이디입니다.");
            showIdField();
          }
          else {
            ShowToastMessage("사용할 수 있는 아이디입니다.");
            hideIdField();
          }
        });
  }

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
void hideIdField()
{
  setState(() {
    checkID = true;
  });
}

  void showIdField()
  {
    setState(() {
      checkID = false;
    });
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
Visibility(
    child:    Container(
      height: 45,
      margin: EdgeInsets.only(left:50,right:50),
      child:
      TextFormField(
        controller: _idTextEditController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: '아이디',
        ),
      ),
    ),
  visible: !checkID,
)
           ,
Visibility(
    child: Text("아이디 : "+_idTextEditController.text),
              visible:checkID),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                    CheckUserID();
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
                child:
                TextFormField(
                  controller: _pwTextEditController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                child:
                TextFormField(
                  controller: _pwCheckTextEditController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '비밀번호 확인',
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                margin: EdgeInsets.only(left:50,right:50),
                child:
                TextFormField(
                  controller: _phoneTextEditController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '휴대폰 번호',
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
                    if(_idTextEditController.text == "" ||
                        _pwTextEditController.text == ""||
                        _pwCheckTextEditController.text == "")
                    {
                      ShowToastMessage("빈칸이 있는지 확인해주세요");
                    }
                    else
                      {

                        if(_pwTextEditController.text.compareTo(_pwCheckTextEditController.text) == 0 )
                        {
                          print("비밀번호 서로 같음");
                          if(checkID)
                          {
                            createUserData(_idTextEditController.text,_phoneTextEditController.text,
                                _pwTextEditController.text);
                            Navigator.pop(context);
                          }
                          else
                          {
                            ShowToastMessage("아이디 중복확인을 해주세요");
                          }
                        }
                        else
                        {
                          ShowToastMessage("비밀번호를 다시 확인해주세요");
                          print("비밀번호 서로 안같음");
                        }
                      }

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


