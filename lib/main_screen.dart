import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const MethodChannel _methodChannel = MethodChannel('mobile/parameters');

  Future<void> _initTmapAPI() async{
    try{
      final String result = await _methodChannel.invokeMethod('initTmapAPI');
      print('initTmapAPI result : $result');
    }on PlatformException{
      print('PratformException');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    _initTmapAPI();
  }

  Future<void> _tmapCheck() async {
    try {
      final String result = await _methodChannel.invokeMethod(
          'isTmapApplicationInstalled');
      print('is TmapApplicationInstalled result : $result');

      if (result.isEmpty || result.length == 0) {
        if (await canLaunch(result)) {
          print("미설치되어서 설치페이지로 이동");
          await launch(result, forceSafariVC: false, forceWebView: false);
        }
      }
        else {
        String url = Uri.encodeFull(
            "https://apis.openapi.sk.com/tmap/app/routes?appKey=yIvsQzTPnWa2bnrbh6HeN9iq4CbOhadO3M3g46RT&name=SKT타워&lon=126.984098&lat=37.566385");
        print("1");
        if (await canLaunch(url)) {
          print("설치");
          await launch(url, forceSafariVC: false, forceWebView: false);
        }

      }
    }
    on PlatformException {
      print('PlatformException');
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
              Text("메인화면입니다."),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: (){
                   // Navigator.pop(context);
                    _tmapCheck();
                  },
                  child: Text("지도"))
            ],
          ),
        )

    );
  }
}



