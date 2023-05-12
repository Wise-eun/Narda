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
        height: 40,
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
          ),
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
      style: TextStyle(
        fontSize: 12,
      ),
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("010"),
                  SizedBox(width: 5,),
                  Container(
                    width: 70,
                    height: 40,
                    child: numberInsert(
                      controller: _phoneNumberController1,
                      maxLegnth: 4,
                    ),
                  ),
                  SizedBox(width: 5,),
                  Container(
                    width: 70,
                    height: 40,
                    child: numberInsert(
                      controller: _phoneNumberController2,
                      maxLegnth: 4,
                    ),
                  ),
                  SizedBox(width: 10,),

                  authOk
                      ? ElevatedButton(onPressed: null, child: Text("인증완료"))
                      : _phoneNumberController1.text.length == 4 &&
                              _phoneNumberController2.text.length == 4
                          ? TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xfff9d94b),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () async {
                                checkIdPhoneNum();
                                if (checkValidation) {
                                  setState(() {
                                    showLoading = true;
                                  });
                                } else {
                                  //해당 정보가 존재하지 않습니다. toast 띄우기
                                  print('해당 정보가 존재하지 않습니다.');
                                }
                              },
                              child: Text("인증요청",
                                  style: TextStyle(color: Colors.black)))
                          : TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xfff9d94b),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {},
                              child: Text("인증요청",
                                  style: TextStyle(color: Colors.black))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 40,
                    child: numberInsert(
                      controller: _otpController,
                      maxLegnth: 6,
                    ),
                  ),
                  SizedBox(width: 10,),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xfff9d94b),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      onPressed: () {
                        PhoneAuthCredential phoneAuthCredential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: _otpController.text);
                        phoneAuth(phoneAuthCredential);
                      },
                      child: Text(
                        "확인",
                        style: TextStyle(color: Colors.black),
                      )),
                ],
              )
            ])));
  }
}
