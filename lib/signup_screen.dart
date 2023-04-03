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
final userCollectionReference = db.collection("user").doc(id);
userCollectionReference.set({
  "id":id,
  "phone_num":phone_num,
  "pw":pw,
});
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


  bool checkUserID(String id)
  {



    final docRef = db.collection("user").doc(id);
    docRef.get().then(
        (DocumentSnapshot doc){
          final data = doc.data() as Map<String,dynamic>;

          if(data.isNotEmpty)
          {
            return true;
          }
          else
          {
            return false;
          }
        },
    );
return false;


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
                child:
                TextField(
                  controller: _idTextEditController,
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
                        if(checkUserID(_idTextEditController.text))
                          {
                            ShowToastMessage("사용할 수 없는 아이디입니다.");
                            checkID = false;
                          }
                          else
                            {
                              ShowToastMessage("사용할 수 있는 아이디입니다.");
                              checkID = true;

                            }
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
                TextField(
                  controller: _pwTextEditController,
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
                TextField(
                  controller: _pwCheckTextEditController,
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
                TextField(
                  controller: _phoneTextEditController,
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
                    if(_pwTextEditController.text.compareTo(_pwCheckTextEditController.text) == 0 )
                    {

                      print("비밀번호 서로 같음");
                      //id 중복확인
                      bool checkID = checkUserID(_idTextEditController.text);
if(checkID)
  {
    createUserData(_idTextEditController.text,_phoneTextEditController.text,
        _pwTextEditController.text);
  }
else
  {
ShowToastMessage("아이디 중복확인을 해주세요");
  }


                    }
                    else
                    {
                      print("비밀번호 서로 안같음");
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


