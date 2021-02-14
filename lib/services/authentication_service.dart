import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'dart:convert';

import 'package:mobile/models/user.dart';

class AuthenticationService {
  AuthenticationService();

  String phoneNumberCheckUrl =
      'http://10.0.2.2:5000/api/auth/phoneexists?phoneNumber=';
  String usernameCheckUrl =
      'http://10.0.2.2:5000/api/auth/userexists?username=';
  String signUpUrl = 'http://10.0.2.2:5000/api/auth/register?role=member';
  String verifyTokenUrl = 'http://10.0.2.2:5000/api/auth/verifytoken';
  String refineUserBasketUrl = 'http://10.0.2.2:5000/api/user/RefineRepetitiveCourses';
  String getUserEpisodesUrl = 'http://10.0.2.2:5000/api/member/episodes/';
  String verifyPhoneUrl = 'http://10.0.2.2:5000/api/auth/verifyphone';
  String basePhotoUrl = 'http://10.0.2.2:5000/files/';
  String sendLoginVerificationCode = 'http://10.0.2.2:5000/api/auth/login?usingphone=true';

  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    http.Response response = await http.get(phoneNumberCheckUrl + phoneNumber);
    return await responseChecker(response);
  }

  Future<bool> usernameExists(String username) async {
    http.Response response = await http.get(usernameCheckUrl + username);
    return await responseChecker(response);
  }

  Future<bool> responseChecker(http.Response response) async{
    if (response.statusCode == 200) {
      bool data = response.body.toLowerCase() == 'true';
      return data;
    } else {
      //TODO return correct answer
      print(response.statusCode);
      return null;
    }
  }

  Future<bool> sendVerificationCode(String phoneNumber) async {
    var body = jsonEncode({'phoneNumber': phoneNumber});

    http.Response response = await http.post(Uri.encodeFull(sendLoginVerificationCode),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });

    return response.statusCode == 200;
  }

  Future<User> signUp(String userName, String password) async {
    var body =
        jsonEncode({'userName': userName, 'password': password});

    http.Response response = await http.post(Uri.encodeFull(signUpUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });
    if(response.statusCode == 200){
      String data = response.body;
      var userMap = jsonDecode(data);

      User registeredUser = User.fromJson(userMap);

      return registeredUser;
    }
    else{
      print(response.statusCode);
      return null;
    }
  }

  Future<User> signIn(String phoneNumber, String authToken) async {
    var body =
      jsonEncode({'phoneNumber': phoneNumber, 'authToken': authToken});

    http.Response response = await http.post(Uri.encodeFull(verifyTokenUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });

    if(response.statusCode == 200){
      String data = response.body;
      var userMap = jsonDecode(data);

      User registeredUser = User.fromJson(userMap);

      return registeredUser;
    }
    else{
      print(response.statusCode);
      return null;
    }
  }

  Future<bool> verifyPhoneNumber(String phoneNumber, String userId) async {
    var body =
      jsonEncode({'phoneNumber': phoneNumber, 'userId': userId});

    http.Response response = await http.post(Uri.encodeFull(verifyPhoneUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });

    return response.statusCode == 200;
  }

  Future<bool> registerPhoneNumber(String phoneNumber, String authToken, String userId) async {
    var body =
    jsonEncode({'phoneNumber': phoneNumber, 'authToken': authToken, 'userId': userId});

    http.Response response = await http.post(Uri.encodeFull(verifyTokenUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });

    return response.statusCode == 200;
  }


  Future<List<Course>> refineUserBasket(List<Course> courses, int totalPrice, String userId, String token) async{
    var body = jsonEncode({
      'userId': userId,
      'totalPrice': totalPrice,
      'courseDtos': courses});

    http.Response response = await http.post(Uri.encodeFull(refineUserBasketUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        });

    if(response.statusCode == 200){
      String data = response.body;
      var courseMap = jsonDecode(data);
      List<Course> coursesList = List<Course>();
      for(var course in courseMap){
        coursesList.add(Course.fromJson(course, basePhotoUrl));
      }
      return coursesList;
    }
    else{
      print(response.statusCode);
      return null;
    }

  }

  Future<List<CourseEpisode>> getUserEpisodes(String userId, String token) async {
    http.Response response = await http.get(
        Uri.encodeFull(getUserEpisodesUrl + userId),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        });

    if(response.statusCode == 200){
      String data = response.body;
      var courseMap = jsonDecode(data);
      List<CourseEpisode> userEpisodesList = List<CourseEpisode>();
      for(var course in courseMap){
        userEpisodesList.add(CourseEpisode.fromJson(course));
      }
      return userEpisodesList;
    }
    else{
      print(response.statusCode);
      return null;
    }
  }
}
