import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/models/course.dart';
import 'package:mobile/models/favorite.dart';
import 'package:mobile/models/progress.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/models/slider_item.dart';
import 'package:mobile/shared/global_variables.dart';

class UserService{
  String baseUrl = GlobalVariables.baseUrl + 'api/member';
  UserService();

  Future<Progress> getCourseProgress(int courseId, String token) async{
    String url = '$baseUrl/$courseId/progress';
    try{
      http.Response response = await http.get(Uri.encodeFull(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var progressMap = jsonDecode(data);
        Progress progress = Progress.fromJson(progressMap);

        return progress;
      }
      else{
        print(response.statusCode);
        return Progress(id: 0);
      }
    }
    catch(e){
      print(e.toString());
      return Progress(id: 0);
    }
  }

  Future<bool> updateCourseProgress(int courseId, Progress progress, String token) async{
    String url = '$baseUrl/$courseId/progress/${progress.id}';
    try{
      http.Response response = await http.put(Uri.encodeFull(url),
          body: progress.toJson(),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        return true;
      }
      else{
        print(response.statusCode);
        return false;
      }
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }

  Future<Progress> createCourseProgress(int courseId, Progress progress, String token) async{
    String url = '$baseUrl/$courseId/progress';
    try{
      var body = progress.toJson();
      http.Response response = await http.post(Uri.encodeFull(url),
          body: body,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var progressMap = jsonDecode(data);
        Progress progress = Progress.fromJson(progressMap);

        return progress;
      }
      else{
        print(response.statusCode);
        return Progress(id: 0);
      }
    }
    catch(e){
      print(e.toString());
      return Progress(id: 0);
    }
  }

  Future<List<Favorite>> getUserFavoriteCourses(String token) async{
    String url = '$baseUrl/favorites';
    try{
      http.Response response = await http.get(Uri.encodeFull(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var favoritesMap = jsonDecode(data);
        List<Favorite> favorites = [];
        for(var favorite in favoritesMap){
          favorites.add(Favorite.fromJson(favorite));
        }
        return favorites;
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

  Future<Favorite> addCourseToUserFavorites(Favorite favorite, String token) async{
    String url = '$baseUrl/favorites';
    try{
      var body = favorite.toJson();
      http.Response response = await http.post(Uri.encodeFull(url),
          body: body,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var favoriteMap = jsonDecode(data);
        Favorite favorite = Favorite.fromJson(favoriteMap);
        return favorite;
      }
      else{
        print(response.statusCode);
        return Favorite(id: 0);
      }
    }
    catch(e){
      print(e.toString());
      return Favorite(id: 0);
    }
  }

  Future<bool> deleteCourseFromUserFavorites(int favoriteId, String token) async{
    String url = '$baseUrl/favorites/$favoriteId';
    try{
      http.Response response = await http.delete(Uri.encodeFull(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        return true;
      }
      else{
        print(response.statusCode);
        return false;
      }
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }
}