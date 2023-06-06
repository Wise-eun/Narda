import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speelow/main_screen.dart';
import 'after_order_list.dart';
import 'mypage_screen.dart';
import 'order_list.dart';

enum TabItem {home,list,mypage}
const Map<TabItem, int> tabIdx = {
  TabItem.home: 0,
  TabItem.list: 1,
  TabItem.mypage: 2,
};

List<BottomNavigationBarItem> navbarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_filled),
    label: '홈',
  ),
  BottomNavigationBarItem(
icon:Icon(Icons.list),
    label: '오더리스트',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.account_circle_rounded),
    label: '마이페이지',
  ),

];

class MenuBottom extends StatefulWidget {
  const MenuBottom({Key? key, required this.userId, required this.tabItem}) : super(key: key);
  final String userId;
  final TabItem tabItem;
  @override
  _MenuBottomState createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  int _selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onItemTapped(int idx){
    setState((){
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.tabItem.index;
    return BottomNavigationBar(
      iconSize: 40 ,
      selectedItemColor: Color(0xff5a4dfd),
      items: [
        _buildItem(TabItem.home),
        _buildItem(TabItem.list),
        _buildItem(TabItem.mypage)
      ],
      currentIndex: _selectedIndex,
      onTap: (int index)
      {
        TabItem.values[index];
        _onItemTapped(index);
        switch(index){
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  MainScreen(userId: widget.userId,)),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  AfterOrderListScreen(userId: widget.userId)),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  MyPageScreen(userId: widget.userId)),
            );
            break;
        };
      },);
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem){
    return navbarItems[tabIdx[tabItem]!];
  }

}


