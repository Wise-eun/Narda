import 'dart:convert';

import 'package:http/http.dart' as http;

import 'model/directions.dart';

class DirectionProvider{
  String REST_API_KEY ="eadc10ffba8f652a200505f28c3cf92d";
  Uri uri = Uri.parse("https://apis-navi.kakaomobility.com/v1/directions?origin=127.11015314141542,37.39472714688412&destination=127.10824367964793,37.401937080111644&waypoints=&priority=RECOMMEND&car_fuel=GASOLINE&car_hipass=false&alternatives=false&road_details=false");


  Future<List<Routes>> getDestination() async {
    List<Routes> directions = [];

    final response = await http.get(uri, headers: {"Authorization":"KakaoAK eadc10ffba8f652a200505f28c3cf92d"});
    print("response.statusCode : " + response.statusCode.toString());
    if (response.statusCode == 200) {
      print("PRINT!!!!!!");
      print(response.body);
      directions = jsonDecode(response.body)['routes'].map<Routes>( (routes) {
        return Routes.fromJson(routes);
      }).toList();
    }

    return directions;
  }


}