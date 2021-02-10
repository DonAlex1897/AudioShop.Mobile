import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/models/course.dart';

class CourseData{
  String coursesUrl = 'http://10.0.2.2:5000/api/courses/'; //TODO change to production
  String photoUrl = 'http://10.0.2.2:5000/files/';
  CourseData();

  Future<List<Course>> getCourses() async{
    try{
      http.Response response = await http.get(coursesUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        List<Course> coursesList = List<Course>();
        for(var course in courseMap){
          coursesList.add(Course.fromJson(course, photoUrl));
        }
        return coursesList;
      }
      else{
        print(response.statusCode);
        return null;
      }
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}