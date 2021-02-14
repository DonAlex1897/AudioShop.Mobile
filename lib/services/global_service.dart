import 'dart:convert';

import 'package:mobile/models/config.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/store/course_store.dart';

class GlobalService{
  String configsUrl = 'http://10.0.2.2:5000/api/configs/all';
  CourseStore courseStore = CourseStore();
  GlobalService();

  Future getAllConfigs() async{
    try{
      http.Response response = await http.get(configsUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var configMap = jsonDecode(data);
        List<Config> configsList = List<Config>();
        for(var config in configMap){
          configsList.add(Config.fromJson(config));
        }
        courseStore.setConfigs(configsList);
      }
      else{
        print(response.statusCode);
      }
    }
    catch(e){
      print(e.toString());
    }
  }
}