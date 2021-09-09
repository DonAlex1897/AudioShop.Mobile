import 'dart:convert';

import 'package:mobile/models/message.dart';
import 'package:mobile/shared/global_variables.dart';
import 'package:http/http.dart' as http;

class MessageService {
  String baseUrl = GlobalVariables.baseUrl + 'api/messages';

  Future<List<Message>> getPopularMessages() async {
    try {
      String url = baseUrl;
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        String data = response.body;
        var messagesMap = jsonDecode(data);
        List<Message> messageList = [];
        for (var message in messagesMap) {
          messageList.add(Message.fromJson(message));
        }
        return messageList;
      } else {
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Message>> getPersonalMessages(String userId) async {
    try {
      String url = baseUrl + '/users/$userId';
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        String data = response.body;
        var messagesMap = jsonDecode(data);
        List<Message> messageList = [];
        for (var message in messagesMap) {
          messageList.add(Message.fromJson(message));
        }
        return messageList;
      } else {
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Future<bool> setMessageAsSeen(int messageId, String userId) async{
  //   try{
  //     final queryParameters = {
  //       'messageId': messageId.toString(),
  //     };
  //     String url = baseUrl + '/users/$userId' + '?messageId=$messageId';
  //     http.Response response = await http.put(url);
  //     return response.statusCode == 200;
  //   }
  //   catch(e){
  //     print(e.toString());
  //     return null;
  //   }
  // }

  Future<bool> setMessageAsSeen(
      String userId,
      List<int> messageIdsForPushStatus,
      List<int> messageIdsForInAppStatus) async {

    try {
      var body = jsonEncode({
        "userId": userId,
        "messageIdsForPushStatus": messageIdsForPushStatus,
        "messageIdsForInAppStatus": messageIdsForInAppStatus
      });

      String url = baseUrl + '/users/$userId';

      http.Response response = await http.put(Uri.encodeFull(url),
          body: body,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          });

      return response.statusCode == 200;
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }
}
