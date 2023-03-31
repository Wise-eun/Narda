import 'package:flutter/material.dart';
import 'package:speelow/kakao_screen.dart';
import 'package:speelow/main_screen.dart';
import 'package:speelow/signup_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'kakao_login.dart';
import 'main_view_model.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';


void main() {
  KakaoSdk.init(nativeAppKey: '3e8531d2fdf84a885535fc7c4ac309ca');
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeeLow',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  //const LoginScreen({Key? key}) : super(key: key);
  final viewModel = MainViewModel(KakaoLogin());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //아래 이미지는 로그인 화면에 나타나는 이미지 (현재는 없음)
            //Image.network(viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
            Text(
              '${viewModel.isLogined}',
             // style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                onPressed: () async{
                  await viewModel.login();
                  //setState(() {});
                },
                child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () async{
                await viewModel.logout();
                //setState(() {});
              },
              child: Text('Logout'),
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
            Container(
              height: 45,
              margin: EdgeInsets.only(left:50,right:50),
              child:    TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '패스워드',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
                style: ButtonStyle(
                    backgroundColor:  MaterialStateProperty.all(Colors.grey[350]),
                ),

                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: Text('로그인')),
            SizedBox(
              height: 10,
            ),
            TextButton(
                style: ButtonStyle(
                    backgroundColor:  MaterialStateProperty.all(Colors.grey[350])
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );},
                child: Text('회원가입')),
            SizedBox(
              height: 10,
            ),
            TextButton(
                style: ButtonStyle(
                    backgroundColor:  MaterialStateProperty.all(Colors.grey[350])
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KaKaoScreen()),
                  );
                },
                child: Text('카카오톡으로 시작하기')),
          ],
        )

     )
    );
  }
}


