import 'dart:ffi';



class Routes{
   int result_code;
   String result_msg;
   Summary summary;
   List<Section> sections;


  Routes(
     this.result_code,
     this.result_msg,
     this.summary,
     this.sections,
  );

  factory Routes.fromJson(Map<String,dynamic> json) => Routes(
    json['result_code'] as int,
    json['result_msg'] as String,
    json['summary'] as Summary,
    json['sections'] as List<Section> ,
  );

}
////////////////////////////////////
class Summary{
late Origin origin;
late Destination destination;
late Waypoints waypoints;
late String priority;
late Bound bound;
late Fare fare;
late int distance;
late int duration;


}
class Origin{
  late String name;
  late double x;
  late double y;
}

class Destination{
  late String name;
  late double x;
  late double y;
}

class Waypoint{
  late String name;
  late double x;
  late double y;
}
class Waypoints{
  late List<Waypoint> waypoints;
}
class Bound{
  late double min_x;
  late double min_y;
  late double max_x;
  late double max_y;
}

class Fare{
  late int taxi;
  late int toll;
}

////////////////////////////////////
class Section{
  late int distance;
  late int duration;
  late Bound bound;
  late List<Road> roads;
  late List<Guide> guides;


  Section(
      this.distance,
      this.duration,
      this.bound,
      this.roads,
      this.guides
      );

  factory Section.fromJson(Map<String,dynamic> json) => Section(
    json['distance'] as int,
    json['duration'] as int,
    json['bound'] as Bound,
    json['roads'] as List<Road> ,
      json['guides'] as List<Guide>
  );

}

class Road{
  late String name;
  late int distance;
  late int duration;
  late double traffic_speed;
  late int traffic_state;
  late List<double> vertexes;
}

class Guide{
  late String name;
  late double x;
  late double y;
  late int distance;
  late int duration;
  late int type;
  late String guidance;
  late int road_index;
}