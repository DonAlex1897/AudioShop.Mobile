import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/models/course.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/models/slider_item.dart';
import 'package:mobile/shared/global_variables.dart';

class CourseData{
  String coursesUrl = GlobalVariables.baseUrl + 'api/courses/';
  String sliderUrl = GlobalVariables.baseUrl + 'api/sliders/';
  String coursePhotoUrl = GlobalVariables.baseUrl + 'files/';
  String sliderPhotoUrl = GlobalVariables.baseUrl + 'slider/';
  CourseData();

  Future<List<Course>> getCourses() async{
    try{
      http.Response response = await http.get(coursesUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        List<Course> coursesList = List<Course>();
        for(var course in courseMap['items']){
          coursesList.add(Course.fromJson(course, coursePhotoUrl));
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

  Future<Course> getCourseById(int id) async{
    try{
      http.Response response = await http.get(coursesUrl + id.toString());
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        Course course = Course.fromJson(courseMap, coursePhotoUrl);
        return course;
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

  Future<List<Review>> getCourseReviews(int courseId) async{
    try{
      String url = coursesUrl + courseId.toString() + '/reviews';
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var courseReviewsMap = jsonDecode(data);
        List<Review> courseReviewsList = List<Review>();
        for(var courseReview in courseReviewsMap['items']){
          courseReviewsList.add(Review.fromJson(courseReview));
        }
        return courseReviewsList;
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

  Future<bool> addReviewToCourse(Review review, String token) async{
    try{
      String url = coursesUrl + review.courseId.toString() + '/reviews';
      var body = jsonEncode({
        'text': review.text,
        'rating': review.rating,
        'courseId': review.courseId,
        'userId': review.userId,
        'userFirstName': review.userFirstName,
      });
      http.Response response = await http.post(Uri.encodeFull(url),
          body: body,
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

  Future<List<SliderItem>> getSliderItems() async{
    try{
      http.Response response = await http.get(sliderUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var sliderItemsMap = jsonDecode(data);
        List<SliderItem> sliderItemsList = List<SliderItem>();
        for(var sliderItem in sliderItemsMap){
          sliderItemsList.add(SliderItem.fromJson(sliderItem, sliderPhotoUrl));
        }
        return sliderItemsList;
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

  Future<List<Course>> searchCourses(String searchParameter) async{
    try{
      String url = coursesUrl + '?search=' + searchParameter;
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        List<Course> coursesList = List<Course>();
        for(var course in courseMap['items']){
          coursesList.add(Course.fromJson(course, coursePhotoUrl));
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