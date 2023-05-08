import 'package:flutter/material.dart';
import 'package:speelow/main_screen.dart';
import 'mypage_screen.dart';
import 'order_list.dart';

class MenuBottom extends StatelessWidget {
  const MenuBottom({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: (int index)
        {
          switch(index){
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ListviewPage(userId: userId)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  TestPage(userId: userId,)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MyPageScreen(userId: userId)),
              );
              break;
          }
        }
        ,

        items: const[
          BottomNavigationBarItem(icon: Icon(Icons.list), label:'List'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label:'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label:'MyPage')
        ]);
  }
}
