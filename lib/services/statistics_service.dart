import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/models/course.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/models/slider_item.dart';
import 'package:mobile/shared/global_variables.dart';

class StatisticsService{
  String pageNavigationUrl = GlobalVariables.baseUrl + 'api/stats/set/';
  StatisticsService();

  Future enteredApplication() async{
    try{
      await http.get(pageNavigationUrl + '1');
    }
    catch(e){
      print(e.toString());
    }
  }

  Future enteredPaymentPage() async{
    try{
      await http.get(pageNavigationUrl + '0');
    }
    catch(e){
      print(e.toString());
    }
  }

  Future enteredCoursePage(int courseId) async{
    try{
      await http.get(pageNavigationUrl + 'course/$courseId');
    }
    catch(e){
      print(e.toString());
    }
  }
}