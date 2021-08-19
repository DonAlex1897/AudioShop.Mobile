import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/register.dart';
import 'dart:convert';

import 'package:mobile/models/user.dart';
import 'package:mobile/models/user_update.dart';
import 'package:mobile/shared/global_variables.dart';

class AuthenticationService {
  AuthenticationService();

  String phoneNumberCheckUrl = GlobalVariables.baseUrl +
      'api/auth/phoneexists?phoneNumber=';
  String usernameCheckUrl = GlobalVariables.baseUrl +
      'api/auth/userexists?username=';
  String signUpUrl = GlobalVariables.baseUrl + 'api/auth/register?role=member';
  String updateUserInfoUrl = GlobalVariables.baseUrl + 'api/auth/updateUser?role=member';
  String verifyTokenUrl = GlobalVariables.baseUrl + 'api/auth/verifytoken';
  String refineUserBasketUrl = GlobalVariables.baseUrl + 'api/user/RefineRepetitiveCourses';
  String getUserEpisodesUrl = GlobalVariables.baseUrl + 'api/member/episodes/';
  String verifyPhoneUrl = GlobalVariables.baseUrl + 'api/auth/verifyphone';
  String basePhotoUrl = GlobalVariables.baseUrl + 'files/';
  String sendLoginVerificationCode = GlobalVariables.baseUrl + 'api/auth/login?usingphone=true';

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

  Future<User> signUp(Register registerInfo) async {
    var body = jsonEncode({
          'userName': registerInfo.userName,
          'password': registerInfo.password,
          'firstName': registerInfo.firstName,
          'lastName': registerInfo.lastName,
          if (registerInfo.employed != null)
            'employed': registerInfo.employed,
          'city': registerInfo.city,
          if (registerInfo.gender != null)
            'gender': registerInfo.gender.toString().split('.')[1],
          if (registerInfo.age != null)
            'age': registerInfo.age,
        });

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

  Future<User> updateUserInfo(UserUpdate userInfo) async {
    var body = userInfo.toJson();

    http.Response response = await http.post(Uri.encodeFull(updateUserInfoUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });
    if(response.statusCode == 200){
      String data = response.body;
      var userMap = jsonDecode(data);

      User updatedUserInfo = User.fromJson(userMap);

      return updatedUserInfo;
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

  Future<User> registerPhoneNumber(String phoneNumber, String authToken, String userId) async {
    var body =
    jsonEncode({'phoneNumber': phoneNumber, 'authToken': authToken, 'userId': userId});

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
