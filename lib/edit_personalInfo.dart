import 'package:flutter/material.dart';

import 'model/user.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({Key? key, required this.user}) : super(key: key);
  final RiderUser user;
  @override
  _EditPersonalInfoScreenState createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('마이페이지'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
        child: Column(
        children: [

          ]
        ))
    );
  }
}




