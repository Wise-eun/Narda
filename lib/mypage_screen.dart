import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'api/api.dart';
import 'calendar_screen.dart';
import 'menu_bottom.dart';
import 'package:speelow/model/user.dart';

RiderUser? riderUser;

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String ridername="";
  bool callOk = false;
  riderDetail() async {
    try {
      var response = await http.post(Uri.parse(API.riderUser), body: {
        //php $_POST{userid}에서 post 내의 userid : 위젯에서 가져온 변수 명
        //php userid = $_POST에서 왼쪽의 userid는 myadmin db에서 찾을 변수명
        'userId': widget.userId.toString(),
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          callOk = true;
          print("불러오기 성공");
          print(responseBody['userData']);
          RiderUser riderInfo = RiderUser.fromJson(responseBody['userData']);
          print("라이더 이름 : ${riderInfo.userName}");
          ridername=riderInfo.userName;
        } else {
          print("불러오기 실패");
        }
      } else {
        print("불러오기 실패2");
      }
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    riderDetail();
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    final mediaQuery = MediaQuery.of(context);
    //bottomNavigationBar:MenuBottom(userId: widget.userId);
    return Scaffold(
        appBar: AppBar(
          title: Text('마이페이지'),
          centerTitle: true,
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: mediaQuery.size.width,
                    height: 30,
                    child: Text(
                      '$ridername 라이더님,',
                    )
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:  MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalendarScreen(riderId: riderUser!.userId)),
                      );
                    },
                    child: Text('정산내역'),
                  )
                ]
            )
        )
    );
  }
}
