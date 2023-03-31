import 'package:flutter/material.dart';

class KaKaoScreen extends StatelessWidget {
  const KaKaoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow[300],
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("카카오 로그인 화면입니다."),
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
                  child: Text("로그인 화면 돌아가기"))
            ],
          ),
        )

    );
  }
}
