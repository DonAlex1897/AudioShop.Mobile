import 'package:http/http.dart' as http;
import 'package:mobile/models/category.dart';
import 'dart:convert';

import 'package:mobile/models/course.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/models/slider_item.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/shared/global_variables.dart';

class CourseData{
  String coursesUrl = GlobalVariables.baseUrl + 'api/courses/';
  String sliderUrl = GlobalVariables.baseUrl + 'api/sliders/';
  String coursePhotoUrl = GlobalVariables.baseUrl + 'files/';
  String sliderPhotoUrl = GlobalVariables.baseUrl + 'slider/';
  CourseData();

  Future<List<Course>> getCourses(CourseType courseType) async{
    try{
      http.Response response = await http
          .get(coursesUrl + '?courseType=${courseType.index}');
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

  Future<List<Course>> getCategoryCourses(
      CourseType courseType,
      String categoryTitle) async{
    try{
      final queryParameters = {
        'category': categoryTitle.toString(),
        'courseType': courseType.index.toString(),
      };
      final uri = Uri.https('star-show.ir', 'api/courses', queryParameters);
      String url = coursesUrl + '?category="$categoryTitle"&courseType=${courseType.index}';
      http.Response response = await http.get(uri);
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

  Future<List<Course>> getTopClickedCourses(CourseType courseType) async{
    try{
      http.Response response = await http
          .get(coursesUrl + '/topclicked?courseType=${courseType.index}');
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        List<Course> coursesList = List<Course>();
        for(var course in courseMap){
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

  Future<List<Course>> getTopSellerCourses(CourseType courseType) async{
    try{
      http.Response response = await http
          .get(coursesUrl + '/topsellers?courseType=${courseType.index}');
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        List<Course> coursesList = List<Course>();
        for(var course in courseMap){
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

  Future<List<Course>> getFeaturedCourses(CourseType courseType) async{
    try{
      http.Response response = await http
          .get(coursesUrl + '/featured?courseType=${courseType.index}');
      if(response.statusCode == 200){
        String data = response.body;
        var courseMap = jsonDecode(data);
        List<Course> coursesList = List<Course>();
        for(var course in courseMap){
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

  Future<List> getCourseReviews(
      [int courseId, int pageNumber = 1, int pageSize = 10]) async{ //https://star-show.ir//api/courses/1/reviews?pageNumber=2&&pageSize=20
    try{
      String url = coursesUrl +
          '$courseId/reviews?pageNumber=$pageNumber&&pageSize=$pageSize';
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        var courseReviewsMap = jsonDecode(data);
        List<Review> courseReviewsList = List<Review>();
        int totalItemsCount = courseReviewsMap['totalItems'];
        for(var courseReview in courseReviewsMap['items']){
          courseReviewsList.add(Review.fromJson(courseReview));
        }
        return [totalItemsCount, courseReviewsList];
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

  Future<List<Category>> getCategories() async{
    try{
      http.Response response = await http
          .get(GlobalVariables.baseUrl + 'api/categories');
      if(response.statusCode == 200){
        String data = response.body;
        var categoriesMap = jsonDecode(data);
        List<Category> categoriesList = [];
        for(var category in categoriesMap){
          categoriesList.add(Category.fromJson(category));
        }
        return categoriesList;
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