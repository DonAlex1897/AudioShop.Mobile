import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:mobile/utilities/banner_ads.dart';
import 'package:mobile/utilities/course_card.dart';
import 'package:mobile/utilities/horizontal_scrollabe_menu.dart';
import 'package:mobile/utilities/native_ads.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  final CourseType courseType;
  CategoryPage(this.courseType);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  CourseStore courseStore;
  CourseData courseData;
  double width;
  List<String> horizontalScrollableButtonNameList;
  Future<List<Category>> categoriesFuture;
  List<VoidCallback> horizontalScrollableButtonFunctionList;
  Future<dynamic> courses;
  List<Course> courseList = [];
  Future<List<Course>> topClickedCoursesFuture;
  List<Course> topClickedCourses = [];
  List<File> topClickedCoursesPicFiles = [];
  Future<List<Course>> featuredCoursesFuture;
  List<Course> featuredCourses = [];
  List<File> featuredCoursesPicFiles = [];
  Future<List<Course>> topSellerCoursesFuture;
  List<Course> topSellerCourses = [];
  List<File> topSellerCoursesPicFiles = [];
  List<File> newCoursesPicFiles = [];

  @override
  void initState() {
    courseData = CourseData();
    courses = getCourses();
    topClickedCoursesFuture = getTopClickedCoursesFuture();
    topSellerCoursesFuture = getTopSellerCoursesFuture();
    featuredCoursesFuture = getFeaturedCoursesFuture();
    super.initState();
  }

  Future<List<Course>> getCourses() async {
    courseList = await courseData.getCourses();
    for(var item in courseList){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      newCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return courseList;
  }

  Future<List<Course>> getTopClickedCoursesFuture() async {
    topClickedCourses = await courseData.getTopClickedCourses(CourseType.Course);
    for(var item in topClickedCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      topClickedCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return topClickedCourses;
  }

  Future<List<Course>> getTopSellerCoursesFuture() async {
    topSellerCourses = await courseData.getTopSellerCourses(CourseType.Course);
    for(var item in topSellerCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      topSellerCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return topSellerCourses;
  }

  Future<List<Course>> getFeaturedCoursesFuture() async {
    featuredCourses = await courseData.getFeaturedCourses(CourseType.Course);
    for(var item in featuredCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      featuredCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return featuredCourses;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                      future: categoriesFuture,
                      builder: (context, data){
                        if(data.hasData){
                          return HorizontalScrollableMenu(
                            horizontalScrollableButtonNameList,
                            horizontalScrollableButtonFunctionList,
                          );
                        }
                        else{
                          return SpinKitWave(
                            type: SpinKitWaveType.center,
                            color: Color(0xFF20BFA9),
                            size: 25.0,
                          );
                        }
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right:10),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 25,
                        child: Text(widget.courseType == CourseType.Course ?
                        'جدیدترین دوره ها' : 'جدیدترین کتاب های صوتی',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: width * 2,
                      height: 250,
                      child: CourseCard(topClickedCoursesFuture, topClickedCourses, topClickedCoursesPicFiles)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right:10),
                  child: SizedBox(
                    height: 25,
                    child: Text(widget.courseType == CourseType.Course ?
                    'پر بازدیدترین دوره ها' : 'پر بازدیدترین کتاب های صوتی',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: width * 2,
                    height: 250,
                    child: CourseCard(courses, courseList, newCoursesPicFiles),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right:10),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 25,
                        child: Text(widget.courseType == CourseType.Course ?
                          'پر فروش ترین دوره ها' : 'پر فروش ترین کتاب های صوتی',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: width * 2,
                      height: 250,
                      child: CourseCard(topSellerCoursesFuture, topSellerCourses, topSellerCoursesPicFiles)),
                ),
                NativeAds(NativeAdsLocation.HomePage),
              ],
            ),
          ),
        ),
    );
  }
}
