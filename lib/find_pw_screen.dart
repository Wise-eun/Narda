import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:speelow/reset_pw.dart';
import 'after_find_pw_screen.dart';
import 'model/user.dart';
import 'api/api.dart';

class FindPwScreen extends StatefulWidget {
  const FindPwScreen({Key? key}) : super(key: key);

  @override
  _FindPwScreenState createState() => _FindPwScreenState();
}

class _FindPwScreenState extends State<FindPwScreen> {
  final TextEditingController _idController = TextEditingController();
  TextEditingController _phoneNumberController1 = TextEditingController();
  TextEditingController _phoneNumberController2 = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  FocusNode idFocusNode=FocusNode();
  FocusNode phoneNumberFocusNode1=FocusNode();
  FocusNode phoneNumberFocusNode2=FocusNode();
  FocusNode otpFocusNode=FocusNode();

  bool authOk = false; //폰인증이 정상적으로 완료됐는지 안됐는지 여부
  bool requestedAuth =
      false; //폰인증 요청을 보냈는지 여부. 인증 코드(OTP 6자리) 를 칠 수 있는 컨테이너의 visible 결정
  late String verificationId; //폰인증 시 생성되는 값
  bool showLoading = false; //폰인증 보낼 때와 로그인할 때 완료될 때까지 로딩 화면 보일 수 있도록 하는 장치
  bool checkValidation = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void phoneAuth(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });
      if (authCredential?.user != null) {
        setState(() {
          print("인증완료 및 로그인성공");
          authOk = true;
          requestedAuth = false;
        });
        await _auth.currentUser?.delete();
        print("auth 정보 삭제");
        _auth.signOut();
        print("phone 로그인 된 것 로그아웃");

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AfterFindPwScreen(userId: _idController.text.trim())),
        );
      }
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
          fontSize: 16.0);
    }
  }

  void checkIdPhoneNum() async {
    try {
      var response = await http.post(Uri.parse(API.checkIdPhoneNum), body: {
        'userId': _idController.text.trim(),
        'phoneNum':
            '010${_phoneNumberController1.text.trim()}${_phoneNumberController2.text.trim()}',
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("해당 아이디 전화번호 확인 성공");
          checkValidation = true;
          setState(() {});
          await _auth.verifyPhoneNumber(
            timeout: const Duration(seconds: 60),
            codeAutoRetrievalTimeout: (String verificationId) {
              // Auto-resolution timed out...
            },
            phoneNumber: "+8210" +
                _phoneNumberController1.text.trim() +
                _phoneNumberController2.text.trim(),
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
                  msg:
                      "010-${_phoneNumberController1.text}-${_phoneNumberController2.text} 로 인증코드를 발송하였습니다. 문자가 올때까지 잠시만 기다려 주세요.",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  fontSize: 12.0);
              setState(() {
                requestedAuth = true;
                showLoading = false;
                this.verificationId = verificationId;
              });
            },
          );
        } else {
          print("해당 아이디 전화번호 확인 실패");
          print(_idController.text.trim());
          print(
              '010${_phoneNumberController1.text.trim()}${_phoneNumberController2.text.trim()}');
          print(responseBody['success']);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _idWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          controller: _idController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          decoration: const InputDecoration(
              labelText: '아이디',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xfff1f2f3),
              contentPadding: EdgeInsets.fromLTRB(15, 5, 0, 5)),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ));
  }

  Widget numberInsert({
    bool? editAble,
    String? hintText,
    FocusNode? focusNode,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    Function? widgetFunction,
    required int maxLegnth,
  }) {
    return TextFormField(
      enabled: editAble,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
      ),
      decoration: InputDecoration(
        contentPadding: new EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
        isDense: true,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xfff1f2f3)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3478F6)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xfff1f2f3)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        counterText: '',
        filled: true,
        fillColor: Color(0xfff1f2f3),
      ),

      textInputAction: textInputAction,
      // keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      focusNode: focusNode,
      controller: controller,
      maxLength: maxLegnth,
      onChanged: (value) {
        if (value.length >= maxLegnth) {
          if (widgetFunction == null) {
            print("noFunction");
          } else {
            widgetFunction();
          }
        }
        setState(() {});
      },

      onEditingComplete: () {
        if (widgetFunction == null) {
          print("noFunction");
        } else {
          widgetFunction();
        }
      },
    );
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
            title: Text('비밀번호 찾기',
                style: TextStyle(color: Colors.black, fontSize: 18)),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
            margin: const EdgeInsets.only(left: 45, right: 45),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _idWidget(),
              const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child:

                        Row(
                          children: [
                            Expanded(
                                child:   Container(
                                    height: 49,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color: Color(0xfff1f2f3)),
                                    child:
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child:
                                            numberInsert(
                                              editAble: false,
                                              hintText: "010", maxLegnth: 3,

                                            )),
                                        SizedBox(width: 5,),
                                        Text('-',style: TextStyle(fontSize: 15),),
                                        SizedBox(width: 5,),
                                        Expanded(
                                          flex: 1,
                                          child: numberInsert(
                                            editAble: authOk?false:true,
                                            //hintText: "0000",
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
                                        Text('-',style: TextStyle(fontSize: 15),),
                                        SizedBox(width: 5,),
                                        Expanded(
                                          flex: 1,
                                          child: numberInsert(
                                            editAble: authOk?false:true,
                                            hintText: "",
                                            focusNode: phoneNumberFocusNode2,
                                            controller: _phoneNumberController2,
                                            textInputAction: TextInputAction.done,
                                            maxLegnth: 4, widgetFunction: null,
                                          ),
                                        ),
                                        SizedBox(width: 3,),
                                      ],
                                    ))
                            ),
                            SizedBox(width: 10,),
                            authOk?TextButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xffffffff)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color:Color(0xFF3478F6)))),
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)),
                                ),
                                onPressed:null,
                                child:Text(" 인증완료 ",style: TextStyle(fontSize: 14, color: Color(0xff000000)))):
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
                                          fontSize: 15.0
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
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xff3478F6)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color:Color(0xFF3478F6)))),
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)),
                                ),
                                child:Text(" 인증요청 ",style: TextStyle(fontSize: 14,color: Color(0xffffffff))))
                                :TextButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xffffffff)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color:Color(0xFF3478F6)))),
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)),
                                ),
                                onPressed: (){},
                                child:Text(" 인증요청 ",style: TextStyle(fontSize: 14, color: Color(0xff000000)))),
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
                  flex: 2,
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
                      SizedBox(width: 10,),
                      ElevatedButton(
                          onPressed: () {
                            PhoneAuthCredential phoneAuthCredential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: _otpController.text);
                            phoneAuth(phoneAuthCredential);
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xffffffff)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color:Color(0xFF3478F6)))),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)),
                          ),
                          child:Text(" 확인 ",style: TextStyle(fontSize: 14,color: Color(0xff000000)))),
                      Container(
                          width: 13,
                          child: Text("")),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),

              ],
            ),

          ),
            ])));
  }
}
