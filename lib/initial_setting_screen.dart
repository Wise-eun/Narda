import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InitialSettingScreen extends StatefulWidget {
  const InitialSettingScreen({Key? key}) : super(key: key);

  @override
  State<InitialSettingScreen> createState() => _InitialSettingScreenState();
}

class _InitialSettingScreenState extends State<InitialSettingScreen> {
  final _range = ['1', '3', '5', '7', '10'];
  String? _selectedRange = '0';

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedRange=_range[0];
    });
  }
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //margin=EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "배달 범위 설정",
                        style: TextStyle(
                          fontSize:15,
                        ),
                          textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      width: 10,
                    ),
                    DropdownButton(
                      value:_selectedRange,
                      items:_range
                          .map((e) => DropdownMenuItem(
                        value:e,
                        child:Text(e),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRange = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: Text(
                          "하나씩 배달",
                          style: TextStyle(
                            fontSize:15,
                          ),
                            textAlign: TextAlign.center,
                        )
                    ),
                    SizedBox(
                      height: 10,
                      width: 10,
                    ),
          Switch(
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value;
              });
            },
          ),
        ],
              ),
    ),
              OutlinedButton(
                onPressed: () {},
                child: Text("확인"),
              ),
  ],
        ),
      ),
    );
  }
}
