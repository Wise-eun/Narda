import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speelow/main_screen.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _verifyPasswordController = TextEditingController();
  TextEditingController _phoneNumberController1 = TextEditingController();
  TextEditingController _phoneNumberController2 = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  FocusNode idFocusNode=FocusNode();
  FocusNode passwordFocusNode=FocusNode();
  FocusNode verifyPasswordFocusNode=FocusNode();
  FocusNode phoneNumberFocusNode1=FocusNode();
  FocusNode phoneNumberFocusNode2=FocusNode();
  FocusNode otpFocusNode=FocusNode();


  bool authOk=false; //폰인증이 정상적으로 완료됐는지 안됐는지 여부
  bool idcheckOk=false;
  bool passwordHide=true;
  bool requestedAuth=false; //폰인증 요청을 보냈는지 여부. 인증 코드(OTP 6자리) 를 칠 수 있는 컨테이너의 visible 결정
  late String verificationId; //폰인증 시 생성되는 값
  bool showLoading = false; //폰인증 보낼 때와 로그인할 때 완료될 때까지 로딩 화면 보일 수 있도록 하는 장치

  FirebaseAuth _auth = FirebaseAuth.instance;

  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    _phoneNumberController1.dispose();
    _phoneNumberController2.dispose();
    _otpController.dispose();
    super.dispose();
  }
  signUp(String name, String id, String pw, String phone_num) async{
    try{
      var response = await http.post(
          Uri.parse(API.signup),
          body: <String,String> { //오른쪽에 signup할 정보 입력
            'userId' : id,
            'userPw' : pw,
            'userPhoneNum' : phone_num,
            'userName' : name
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['success'] == true){
          print("회원가입 성공");
        }
        else{
          print("회원가입 실패");
        }
      }
    }catch(e){print(e.toString());}
  }

  validateId(String id) async{
    try{
      var response = await http.post(
          Uri.parse(API.validateId),
          body:{
            'userId' : id //오른쪽에 validate 확인할 id 입력
          }
      );
      if(response.statusCode == 200){
        var responseBody = jsonDecode(response.body);
        if(responseBody['exist'] == true){
          Fluttertoast.showToast(
              msg: "이미 존재하는 아이디입니다.",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              fontSize: 16.0
          );
          print("이미 존재하는 아이디");
        }
        else{
          idcheckOk=true;
          Fluttertoast.showToast(
              msg: "사용 가능한 아이디입니다.",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blue,
              fontSize: 16.0
          );
          print("존재하지 않는 아이디 ");
        }
      }
    }catch(e){print(e.toString());}
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
        await _auth.currentUser?.delete();
        print("auth 정보 삭제");
        _auth.signOut();
        print("phone 로그인 된 것 로그아웃");
      } //가입이 성공적으로 끝나면 Firebase 콘솔에 Auth정보가 남기 때문에 회원탈퇴처럼 delete 지워주고.
    //앱내에 firebase 현재유저로 등록되어있으니 SignOut 을 해줘요.


    } on FirebaseAuthException catch (e) {
      setState(() {
        print("인증실패..로그인실패");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('회원가입'),),
        body: Stack(

          children: [
            Container(

              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("이름")),
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
                              hintText: "이름 입력",
                              enabledBorder: OutlineInputBorder(

                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(idFocusNode),
                            keyboardType: TextInputType.name,
                            controller: _nameController,

                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
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
                            onEditingComplete: () => FocusScope.of(context).requestFocus(passwordFocusNode),
                            //keyboardType: TextInputType.,
                            controller: _idController,

                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      ElevatedButton(
                          onPressed: ()async {
                            validateId(_idController.text);
                          }, child: Text("중복검사"),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(

                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("비밀번호")),
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
                              hintText: "비밀번호 입력",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(verifyPasswordFocusNode),
                            focusNode:passwordFocusNode,
                            obscureText: passwordHide,
                            controller: _passwordController,

                          ),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(

                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("")),
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
                              hintText: "비밀번호 확인",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                            focusNode:verifyPasswordFocusNode,
                            obscureText: passwordHide,
                            controller: _verifyPasswordController,

                          ),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(

                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("휴대폰")),
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
                                        controller: _phoneNumberController1,
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
                                        controller: _phoneNumberController2,
                                        textInputAction: TextInputAction.done,
                                        maxLegnth: 4, widgetFunction: null,

                                      ),
                                    ),
                                  ],
                                )
                            ),
                            SizedBox(width: 5,),
                            authOk?ElevatedButton(
                                onPressed:null,
                                child:Text("인증완료")):
                            _phoneNumberController1.text.length==4&&_phoneNumberController2.text.length==4
                                ?
                            ElevatedButton(
                                onPressed: ()async{
                                  setState(() {
                                    showLoading = true;
                                  });
                                  await _auth.verifyPhoneNumber(
                                    timeout: const Duration(seconds: 60),
                                    codeAutoRetrievalTimeout: (String verificationId) {
                                      // Auto-resolution timed out...
                                    },
                                    phoneNumber: "+8210"+_phoneNumberController1.text.trim()+_phoneNumberController2.text.trim(),
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
                                          msg: "010-${_phoneNumberController1.text}-${_phoneNumberController2.text} 로 인증코드를 발송하였습니다. 문자가 올때까지 잠시만 기다려 주세요.",
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
                    child: Text('가입하기'),
                    onPressed: ()async {
                      if (_nameController.text.length > 0) {
                        if (_idController.text.length > 0 &&
                            _passwordController.text.length > 0 &&
                            _verifyPasswordController.text.length > 0) {
                          if (_passwordController.text ==
                              _verifyPasswordController.text) {
                            if(idcheckOk) {
                              if (authOk) {
                                setState(() {
                                  showLoading = true;
                                });
                                signUp(_nameController.text, _idController.text,
                                    _passwordController.text,"010${_phoneNumberController1
                                        .text}${_phoneNumberController2.text}");

                                //await signUpUserCredential(id:idController.text ,password:passwordController.text );

                                setState(() {
                                  showLoading = false;
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => MainScreen(userId: _idController.text)),);
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
                                  msg: "아이디 중복확인을 해주세요.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  fontSize: 16.0
                              );
                            }
                          }
                          else {
                            Fluttertoast.showToast(
                                msg: "비밀번호를 확인해주세요.",
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                fontSize: 16.0
                            );
                          }
                        }
                        else {
                          Fluttertoast.showToast(
                              msg: "아이디 및 비밀번호를 확인해주세요.",
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              fontSize: 16.0
                          );
                        }
                      }
                      else {
                        Fluttertoast.showToast(
                            msg: "이름을 입력해주세요.",
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



                        textStyle: TextStyle(

                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 50,),
                ],
              ),
            ),

            Positioned.fill(
              child: Visibility(
                  visible: showLoading,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,

                      child: Center(child: Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: 80,
                          color: Colors.white,
                          child: Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator()),
                              SizedBox(width: 20,),
                              Text("잠시만 기다려 주세요"),
                              SizedBox(width: 20,),
                              Opacity(
                                opacity: 0,
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator()),
                              ),


                            ],
                          ))))

                  )
              ),
            )
          ],
        )
    );
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
