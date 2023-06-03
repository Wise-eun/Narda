import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:speelow/main_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {

  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: Border(
            bottom: BorderSide(
              color: Color(0xfff1f2f3),
              width: 2,
            )),
        title: Text('사용 방법',
            style: TextStyle(color: Colors.black, fontSize: 18)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(left: 20, right: 20),
            child: PageView(
              controller: pageController,
              children: [
                SizedBox(
                  child:Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("1" ,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,),
                        SizedBox(height: 10,),
                        Text("AR헬멧의 전원을 켠다.",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  child:Container(
                    color: Colors.white,
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("2" ,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,),
                        SizedBox(height: 10,),
                        Text("스마트폰에서 '블루투스' 기능을 켜고, 등록 가능한 기기 목록에서 AR헬멧을 찾는다.",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  child:Container(
                    color: Colors.white,
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("3" ,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,),
                        SizedBox(height: 10,),
                        Text("AR헬멧과 블루투스를 연결한 다음,\n 어플 메인화면에서 출근버튼을 눌러 출근을 한다",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  child:Container(
                    color: Colors.white,
                    child:   Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("4" ,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,),
                        SizedBox(height: 10,),
                        Text("어플에서 주문을 배차하여 배달을 시작하거나\n헬멧을 이용하여 가까운 거리에 있는 주문을 먼저 추천받는다",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center)
                      ],
                    )
                  ),
                ),
                SizedBox(
                  child:Container(
                      color: Colors.white,
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("5" ,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,),
                          SizedBox(height: 10,),
                          Text("안전하게 배달한다",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center),
                          SizedBox(height: 10,),
                          ElevatedButton(onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen(userId: widget.userId)),
                            );
                          }, child: Text("시작하기",
                            style: TextStyle(fontSize: 17),),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(	//모서리를 둥글게
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Color(0xff3478F6)),

                          )
                          
                        ],
                      )
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: 30),
            child: SmoothPageIndicator(
              controller: pageController,
              count: 5,
              effect: WormEffect(
                  dotHeight: 16,
                  dotWidth: 16,
                  dotColor: Color(0xFFCECECE),
                  activeDotColor: Color(0xff3478F6),
                  type: WormType.thinUnderground
              ),
            ),
          ),



        ],
      )
      ,
    );
  }
}
