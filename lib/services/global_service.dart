import 'dart:convert';

import 'package:mobile/models/configuration.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/store/course_store.dart';

class GlobalService{
  String configsUrl = 'http://10.0.2.2:5000/api/configs/all';
  GlobalService();

  Future<List<Configuration>> getConfigsByGroup(String groupTitleEn) async{
    try{
      String url = configsUrl;
      if(groupTitleEn != 'General' && groupTitleEn != '')
        url += '?group=$groupTitleEn';
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var configMap = jsonDecode(data);
        List<Configuration> configsList = List<Configuration>();
        for(var config in configMap){
          configsList.add(Configuration.fromJson(config));
        }
        return configsList;
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