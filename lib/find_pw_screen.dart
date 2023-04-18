import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'model/user.dart';
import 'api/api.dart';




class FindPwScreen extends StatefulWidget {
  const FindPwScreen({Key? key}) : super(key: key);
  @override
  _FindPwScreenState createState() => _FindPwScreenState();
}

class _FindPwScreenState extends State<FindPwScreen> {
  final TextEditingController _phoneNumController1 = TextEditingController();
  final TextEditingController _phoneNumController2 = TextEditingController();//입력되는 값을 제어
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  FocusNode idFocusNode=FocusNode();
  FocusNode phoneNumberFocusNode1=FocusNode();
  FocusNode phoneNumberFocusNode2=FocusNode();
  FocusNode otpFocusNode=FocusNode();

  bool authOk=false;
  bool showLoading=false;
  bool requestedAuth=false;
  late String verificationId;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void dispose() {
    // TODO: implement dispose
    _idController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });
    try {
      final authCredential = await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });
      if(authCredential?.user != null){
        setState(() {
          print("인증완료 및 로그인성공");
          authOk=true;
          requestedAuth=false;
        });
      } //가입이 성공적으로 끝나면 Firebase 콘솔에 Auth정보가 남기 때문에 회원탈퇴처럼 delete 지워주고.
      //앱내에 firebase 현재유저로 등록되어있으니 SignOut 을 해줘요.
    } on FirebaseAuthException catch (e) {
      setState(() {
        print("인증실패");
        showLoading = false;
      });

      await Fluttertoast.showToast(
          msg: e.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          fontSize: 16.0
      );
    }
  }

  findPw(String id, String PhoneNum) async{
    try{
      var response = await http.post(
          Uri.parse(API.findPw),
          body:{
            'userId' : id, //오른쪽에 validate 확인할 id 입력
            'userPhoneNum' : PhoneNum
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['exist'] == true) {
          print("해당 회원정보 존재");
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => NewPwScreen(userId: _idController.text)),);
        }
        else{
          Fluttertoast.showToast(
              msg: "일치하지 않는 회원정보입니다.",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              fontSize: 16.0
          );
          print("해당 회원정보 존재하지 않음");
        }
      }
    }catch(e){print(e.toString());}
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text("아이디")),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: TextFormField(

                              style: TextStyle(
                                fontSize: 12,
                              ),
                              decoration: InputDecoration(
                                contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                isDense: true,
                                hintText: "아이디 입력",
                                enabledBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () => FocusScope.of(context).requestFocus(phoneNumberFocusNode1),
                              //keyboardType: TextInputType.,
                              controller: _idController,

                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text("휴대전화번호")),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child:
                                          numberInsert(
                                            editAble: false,
                                            hintText: "010", maxLegnth: 3,
                                          )),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        flex: 1,
                                        child: numberInsert(
                                          editAble: authOk?false:true,
                                          hintText: "0000",
                                          focusNode: phoneNumberFocusNode1,
                                          controller: _phoneNumController1,
                                          textInputAction: TextInputAction.next,
                                          maxLegnth: 4,
                                          widgetFunction: (){
                                            FocusScope.of(context).requestFocus(phoneNumberFocusNode2);
                                            },

                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        flex: 1,
                                        child: numberInsert(
                                          editAble: authOk?false:true,
                                          hintText: "0000",
                                          focusNode: phoneNumberFocusNode2,
                                          controller: _phoneNumController2,
                                          textInputAction: TextInputAction.done,
                                          maxLegnth: 4, widgetFunction: null,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                        authOk?ElevatedButton(
                          onPressed:null,
                          child:Text("인증완료")):
                        _phoneNumController1.text.length==4&&_phoneNumController2.text.length==4
                            ?
                        ElevatedButton(
                            onPressed: ()async{
                              print("aaaaaa");
                              setState(() {
                                showLoading = true;
                              });

                              await _auth.verifyPhoneNumber(
                                timeout: const Duration(seconds: 60),
                                codeAutoRetrievalTimeout: (String verificationId) {
                                  // Auto-resolution timed out...
                                },
                                phoneNumber: "+8210"+_phoneNumController1.text.trim()+_phoneNumController2.text.trim(),
                                verificationCompleted: (phoneAuthCredential) async {
                                  print("otp 문자옴");
                                },
                                verificationFailed: (verificationFailed) async {
                                  print(verificationFailed.code);

                                  print("코드발송실패");
                                  setState(() {
                                    showLoading = false;
                                  });
                                },
                                codeSent: (verificationId, resendingToken) async {
                                  print("코드보냄");
                                  Fluttertoast.showToast(
                                      msg: "010-${_phoneNumController1.text}-${_phoneNumController2.text} 로 인증코드를 발송하였습니다. 문자가 올때까지 잠시만 기다려 주세요.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      fontSize: 12.0
                                  );
                                  setState(() {
                                    requestedAuth=true;
                                    FocusScope.of(context).requestFocus(otpFocusNode);
                                    showLoading = false;
                                    this.verificationId = verificationId;
                                  });
                                },
                              );

                            },
                            child:Text("인증요청"))
                            :ElevatedButton(
                            onPressed: (){},
                            child:Text("인증요청")),
                            ],
                          ),
                        ),
                    ],
    ),

                    SizedBox(height: 5,),
                    authOk?SizedBox():Visibility(
                      visible: requestedAuth,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text("")),
                          Expanded(
                            flex: 3,
                            child:Row(
                              children: [
                                Expanded(
                                  child:
                                  numberInsert(
                                    editAble: true,
                                    hintText: "6자리 입력",
                                    focusNode: otpFocusNode,
                                    controller: _otpController,
                                    textInputAction: TextInputAction.done,
                                    maxLegnth: 6, widgetFunction: null,

                                  ),
                                ),
                                SizedBox(width: 5,),
                                ElevatedButton(
                                  onPressed: (){
                                    PhoneAuthCredential phoneAuthCredential =
                                    PhoneAuthProvider.credential(
                                      verificationId: verificationId, smsCode: _otpController.text);
                                    signInWithPhoneAuthCredential(phoneAuthCredential);
                                  },
                                  child: Text("확인")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      child: Text('확인'),
                      onPressed: ()async {
                        if(_idController.text.length>0) {
                          if (authOk) {
                            setState(() {
                              showLoading = true;
                            });
                            findPw(_idController.text,"010${_phoneNumController1
                                .text}${_phoneNumController2.text}");
                            setState(() {
                              showLoading = false;
                            });
                          }
                          else {
                            Fluttertoast.showToast(
                                msg: "휴대폰 인증을 완료해주세요.",
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                fontSize: 16.0
                            );
                          }
                        }
                        else{
                          Fluttertoast.showToast(
                              msg: "아이디를 입력해주세요",
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              fontSize: 16.0
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                          minimumSize: Size(double.infinity,0),
                          textStyle: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 50,),
              ],
            )));
  }

  Widget numberInsert(
      {
        bool? editAble,
        String? hintText,
        FocusNode? focusNode,
        TextEditingController? controller,

        TextInputAction? textInputAction,
        Function? widgetFunction,
        required int maxLegnth,

      }){
    return TextFormField(
      enabled: editAble,
      style: TextStyle(
        fontSize: 12,
      ),
      decoration: InputDecoration(
        contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        isDense: true,
        counterText: "",
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),

      textInputAction: textInputAction,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
      focusNode:focusNode,
      controller: controller,
      maxLength: maxLegnth,
      onChanged: (value){

        if(value.length>=maxLegnth){
          if(widgetFunction==null){
            print("noFunction");
          }else{
            widgetFunction();
          }
        }
        setState(() {

        });
      },


      onEditingComplete: (){
        if(widgetFunction==null){
          print("noFunction");
        }else{
          widgetFunction();
        }

      },
    );
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