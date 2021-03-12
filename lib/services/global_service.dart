import 'dart:convert';

import 'package:mobile/models/configuration.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/global_variables.dart';
import 'package:mobile/store/course_store.dart';

class GlobalService{
  String configsUrl = GlobalVariables.baseUrl + 'api/configs/';
  GlobalService();

  Future<List<Configuration>> getConfigsByGroup(String groupTitleEn) async{
    try{
      String url = configsUrl;
      if(groupTitleEn != 'General' && groupTitleEn != '')
        url += groupTitleEn;
      else
        url += 'General';
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

  Future<int> getLatestVersionAvailable() async{
    String url = configsUrl + '?title=LatestMobileAppName';
    try{
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var configMap = jsonDecode(data);
        Configuration latestMobileAppName = Configuration.fromJson(configMap);
        return int.parse(latestMobileAppName.value.replaceAll(new RegExp(r'[^0-9]'),''));
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

  Future<String> getDownloadUrl() async {
    String fileNameUrl = configsUrl + '?title=LatestMobileAppName';
    String downloadUrl = GlobalVariables.baseUrl + 'mobile/';
    try{
      http.Response response = await http.get(fileNameUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var configMap = jsonDecode(data);
        Configuration latestMobileAppName = Configuration.fromJson(configMap);
        downloadUrl += latestMobileAppName.value;
        return downloadUrl;
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