import 'dart:convert';

import 'package:mobile/models/message.dart';
import 'package:mobile/shared/global_variables.dart';
import 'package:http/http.dart' as http;

class MessageService{
  String baseUrl = GlobalVariables.baseUrl + 'api/messages';

  Future<List<Message>> getPopularMessages() async {
    try{
      String url = baseUrl;
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var messagesMap = jsonDecode(data);
        List<Message> messageList = [];
        for(var message in messagesMap){
          messageList.add(Message.fromJson(message));
        }
        return messageList;
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

  Future<List<Message>> getPersonalMessages(String userId) async {
    try{
      String url = baseUrl + '/users/$userId';
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var messagesMap = jsonDecode(data);
        List<Message> messageList = [];
        for(var message in messagesMap){
          messageList.add(Message.fromJson(message));
        }
        return messageList;
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

  Future<bool> setMessageAsSeen(int messageId, String userId) async{
    try{
      final queryParameters = {
        'userId': userId,
        'messageId': messageId.toString(),
      };
      final uri = Uri.https('star-show.ir', 'api/messages/users', queryParameters);
      http.Response response = await http.put(uri);
      return response.statusCode == 200;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}